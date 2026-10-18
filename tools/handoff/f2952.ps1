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

if ($s.Contains("  {v:'29.52',what:")) { throw "check 29.52 is in the fixture already" }

SubRx @'
  {v:'29.51',what:
'@ @'
  {v:'29.52',what:'the end card is one flat shell: 4px radius, no glow on the title, a 56px primary, the scrim blurs the world behind it (critic: debug dialog, screens 35 38 60 77)',
   run:function(){
     var oc=document.getElementById('outcome'), win=oc&&oc.querySelector('.ocwin'), h=document.getElementById('oc_title'), b=document.getElementById('oc_btn'), res=null, cs;
     if(!oc||!win||!h||!b) return 'SKIP: no end card here';
     cs=getComputedStyle(win);
     if(cs.borderTopLeftRadius!=='4px') res='the card radius is '+cs.borderTopLeftRadius+', not 4px';
     else if(cs.boxShadow!=='none') res='the card still has a shadow: '+cs.boxShadow;
     else if(cs.backgroundImage!=='none') res='the card still has a gradient';
     else if(getComputedStyle(h).textShadow!=='none') res='the title still glows';
     else if(parseFloat(getComputedStyle(b).minHeight)<56) res='the primary is '+getComputedStyle(b).minHeight+' high, not 56px';
     else if(String(getComputedStyle(oc).backdropFilter||getComputedStyle(oc).webkitBackdropFilter).indexOf('blur')<0) res='the scrim does not blur the world behind it';
     return res;
   }},
  {v:'29.51',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
