$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

SubRx @'
  {v:'11.27',what:'F is one thing: a press while hurt with a Bandage in the backpack swings the strike and keeps the Bandage; the belt still spends it; down, F still revives',
'@ @'
  {v:'11.28',what:'the backpack arrows keep a number: with every carried item claimed by a belt key an arrow leaves the selection at 0, and with two free stacks the arrows still walk the grid',
   run:function(){
     if(!(window.__deploy&&window.__loop&&window.__state)) return 'SKIP: this fixture cannot press keys in a raid';
     var bad=[];
     function press(code, key){ var d=new KeyboardEvent('keydown',{code:code,key:key,bubbles:true,cancelable:true}); window.dispatchEvent(d); var u=new KeyboardEvent('keyup',{code:code,key:key,bubbles:true}); window.dispatchEvent(u); }
     // THE FINDING. One gun in the backpack, the same gun claimed by belt key 6: the grid is empty.
     __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0);
     __deploy({kit:[],safe:null,mapIx:0,seed:4242});
     var g=__state(), p=g.player, key='gun_'+(p.wep&&p.wep.id);
     g.bag=[key]; g.hotAssign={5:key}; g.bagOpen=true; g.bagSel=0;
     press('ArrowLeft','ArrowLeft');
     if(typeof g.bagSel!=='number'||!isFinite(g.bagSel)) bad.push('with the whole backpack on the belt, arrow left made the selection '+g.bagSel);
     else if(g.bagSel!==0) bad.push('with the whole backpack on the belt, arrow left moved the selection to '+g.bagSel+' on an empty grid');
     press('ArrowRight','ArrowRight'); press('ArrowUp','ArrowUp'); press('ArrowDown','ArrowDown');
     if(typeof g.bagSel!=='number'||!isFinite(g.bagSel)) bad.push('the other arrows made the selection '+g.bagSel);
     // CONTROL: two free stacks, the arrows still walk. Right from 0 goes to 1, left from 0 wraps to 1.
     g.bag=['bandage','frag']; g.hotAssign={}; g.bagOpen=true; g.bagSel=0;
     press('ArrowRight','ArrowRight');
     if(g.bagSel!==1) bad.push('control: with two free stacks arrow right took the selection to '+g.bagSel+' rather than 1, so the arrows no longer walk the grid');
     g.bagSel=0; press('ArrowLeft','ArrowLeft');
     if(g.bagSel!==1) bad.push('control: with two free stacks arrow left from 0 gave '+g.bagSel+' rather than wrapping to 1');
     g.bagOpen=false; g.bagSel=0;
     __topClear();
     return bad.length?bad.join('; '):null; }},
  {v:'11.27',what:'F is one thing: a press while hurt with a Bandage in the backpack swings the strike and keeps the Bandage; the belt still spends it; down, F still revives',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
