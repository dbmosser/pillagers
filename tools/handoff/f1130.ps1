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
  {v:'11.29',what:'the sector screen says whose figures it shows and shows the ones in the code, and a death card on a fresh profile gives the XP total without measuring it against the last reward of the season',
'@ @'
  {v:'11.30',what:'a belt key for a gun still in the backpack names the key that equips it, ENTER, and not TAB alone; a belt key for the gun in hand says nothing of the sort',
   run:function(){
     if(!(window.__deploy&&window.__loop&&window.__state)) return 'SKIP: this fixture cannot press keys in a raid';
     var bad=[];
     function press(code, key){ var d=new KeyboardEvent('keydown',{code:code,key:key,bubbles:true,cancelable:true}); window.dispatchEvent(d); var u=new KeyboardEvent('keyup',{code:code,key:key,bubbles:true}); window.dispatchEvent(u); }
     function frames(n){ var t0=performance.now(); for(var i=0;i<n;i++) __loop(t0+i*16.7); }
     // THE FINDING. A pistol in the backpack, on belt key 3, the SMG in hand. Press 3.
     __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0);
     __deploy({kit:[],safe:null,mapIx:0,seed:4242});
     var g=__state(), p=g.player;
     if(!(p.wep&&p.wep.id&&p.wep.id!=='pistol')) return 'SKIP: the deploy did not put a non-pistol gun in hand ('+(p.wep&&p.wep.id)+')';
     g.bag=['gun_pistol']; g.hotAssign={2:'gun_pistol'}; g.msg=''; frames(1);
     press('Digit3','3'); frames(2);
     var m=String(g.msg||'');
     var wrong=['TAB to ','equip it'].join('');
     if(m.indexOf(wrong)>=0) bad.push('the belt key still says "'+m+'"');
     if(m.indexOf('ENTER')<0) bad.push('the belt key does not name ENTER: "'+m+'"');
     if(m.indexOf('backpack')<0) bad.push('control: the belt key did not produce the backpack message at all: "'+m+'", so key 3 did not reach the pistol');
     // CONTROL: a belt key for the gun in hand prints no such message.
     g.bag=[]; g.hotAssign={}; g.msg=''; frames(1);
     press('Digit1','1'); frames(2);
     var m2=String(g.msg||'');
     if(m2.indexOf('ENTER')>=0||m2.indexOf(wrong)>=0) bad.push('control: key 1 for the gun in hand printed "'+m2+'"');
     __topClear();
     return bad.length?bad.join('; '):null; }},
  {v:'11.29',what:'the sector screen says whose figures it shows and shows the ones in the code, and a death card on a fresh profile gives the XP total without measuring it against the last reward of the season',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
