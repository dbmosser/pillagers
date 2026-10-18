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

if ($s.Contains("  {v:'29.35',what:")) { throw "check 29.35 is in the fixture already" }

SubRx @'
  {v:'29.34',what:
'@ @'
  {v:'29.35',what:'the title is calmer on the shared look: the three step cards are flat columns (no box), every mode row is 48px or more on the 8px grid, the step numbers carry the one accent, the save buttons are not accent text (critic 2 of 5)',
   run:function(){
     var t=document.querySelector('#title .tcard'), s=document.querySelector('#title .tstep'), r, i, ids=['modecoop','modearcade','modearcade1','modecoopsrv','modepvp','modepvpsrv'], h, cs;
     if(!t||!s) return 'no step card';
     cs=getComputedStyle(t);
     if(cs.borderLeftWidth!=='0px'||cs.borderRightWidth!=='0px'||cs.borderBottomWidth!=='0px') return 'the step card still has a box border';
     if(cs.borderTopLeftRadius!=='0px') return 'the step card still has rounded corners';
     for(i=0;i<ids.length;i++){ r=document.getElementById(ids[i]); if(!r) return 'no row '+ids[i]; h=parseFloat(getComputedStyle(r).minHeight); if(h<48||h%8) return ids[i]+' row is '+h+'px min height, not 48 on the 8px grid'; }
     if(getComputedStyle(s).color===getComputedStyle(t.querySelector('.tbody')).color) return 'the step number does not carry the accent';
     if(getComputedStyle(document.getElementById('newgame')).color===getComputedStyle(document.getElementById('titlestart')).backgroundColor) return 'the create save button is still accent text';
     return null;
   }},
  {v:'29.34',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
