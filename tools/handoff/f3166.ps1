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

if ($s.Contains("  {v:'31.66',what:")) { throw "check 31.66 is in the fixture already" }

SubRx @'
  {v:'31.65',what:
'@ @'
  {v:'31.66',what:'the stash labels and hint lines are at the 16px floor (17.4px before the 0.92 scale) and the loadout head says $ going up, not the old c',
   run:function(){
     if(!(window.__hubEnter&&window.__showScreen)) return 'SKIP: this fixture cannot walk the Undercroft';
     var bad=[], ids=['sellhint','nextunlock','invkeybar'], i, el, fs, em;
     try{
       __topClear(); __cleanProfile();
       G=null; keys={}; __showScreen('hub'); __hubEnter();
       for(i=0;i<ids.length;i++){
         el=document.getElementById(ids[i]); if(!el){ bad.push('no '+ids[i]); continue; }
         fs=parseFloat(getComputedStyle(el.querySelector('kbd')||el).fontSize);
         if(!(fs>=17)) bad.push(ids[i]+' text is '+fs+'px, under the 17.4px floor');
       }
       em=document.querySelector('#kitcol .lohead em');
       if(!em||!/^\$/.test(em.textContent.trim())) bad.push('the loadout head reads "'+(em&&em.textContent)+'", not $ going up');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ __topClear(); }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
  {v:'31.65',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
