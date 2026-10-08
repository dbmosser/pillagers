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

if ($s.Contains("  {v:'19.50',what:")) { throw "check 19.50 is in the fixture already" }

SubRx @'
  {v:'19.49',what:
'@ @'
  {v:'19.50',what:'the run card fade strip stays in the gap: on a card that does not scroll, the fade above the buttons does not reach the note box',
   run:function(){
     var oc=document.getElementById('outcome'), a=oc&&oc.querySelector('.ocacts'), nb=document.getElementById('oc_note'), was=oc&&oc.classList.contains('on'), bad=[], s, top, h, ar, nr;
     if(!oc||!a||!nb) return 'SKIP: no run card here';
     try{
       oc.classList.add('on');
       s=getComputedStyle(a,'::before'); top=parseFloat(s.top); h=parseFloat(s.height);
       if(!(h>0)) return 'SKIP: no fade strip';
       ar=a.getBoundingClientRect(); nr=nb.getBoundingClientRect();
       var z=ar.height>0&&a.offsetHeight>0?ar.height/a.offsetHeight:1;
       if(ar.top+top*z<nr.bottom-1) bad.push('the fade strip starts '+Math.round(nr.bottom-(ar.top+top*z))+' px inside the note box');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ if(!was) oc.classList.remove('on'); }
     return bad.length?bad.join('; '):null; }},
  {v:'19.49',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
