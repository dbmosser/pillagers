$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $new = $new.Replace("`r`n", "`n")
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

if ($s.Contains("  {v:'19.51',what:")) { throw "check 19.51 is in the fixture already" }

SubRx @'
  {v:'19.50',what:
'@ @'
  {v:'19.51',what:'ENTER in the floor backpack leaves the what is new card: with the card waiting behind the open bag, ENTER does not mark it seen',
   run:function(){
     if(!(window.__wnseen&&window.__hubEnter&&window.__hubBagSet&&window.__showScreen)) return 'SKIP: this fixture cannot drive the floor card';
     var bad=[], P2=__P(), keepRuns=P2.runs, t;
     try{
       __topClear(); __runPrep();
       P2.runs=Math.max(1,keepRuns||0);
       t=document.getElementById('title'); if(t) t.classList.remove('on');
       G=null; keys={}; __showScreen('hub'); __hubEnter();
       __wnseen(0); __hubBagSet(true);
       window.dispatchEvent(new KeyboardEvent('keydown',{code:'Enter',key:'Enter',bubbles:true}));
       window.dispatchEvent(new KeyboardEvent('keyup',{code:'Enter',key:'Enter',bubbles:true}));
       if(__wnseen()!==0) bad.push('ENTER in the open backpack marked the hidden card seen');
       __hubBagSet(false);
       window.dispatchEvent(new KeyboardEvent('keydown',{code:'Enter',key:'Enter',bubbles:true}));
       window.dispatchEvent(new KeyboardEvent('keyup',{code:'Enter',key:'Enter',bubbles:true}));
       if(__wnseen()!==1) bad.push('control: ENTER with the bag closed did not dismiss the card');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ __hubBagSet(false); }catch(_b){} P2.runs=keepRuns; __wnseen(1); keys={}; try{ saveProfile(); }catch(_s){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'19.50',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
