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

if ($s.Contains("  {v:'20.22',what:")) { throw "check 20.22 is in the fixture already" }

SubRx @'
  {v:'20.21',what:
'@ @'
  {v:'20.22',what:'the RACKS page is readable: its status line, the hints under its buttons and the name box are 14px',
   run:function(){
     var bad=[], ids=['mfstatus','mfhint','mfarrayhint','mfslothint','mfghosthint','mfghostname'], i, el, f;
     for(i=0;i<ids.length;i++){ el=document.getElementById(ids[i]); if(!el) return 'SKIP: no RACKS page here'; f=parseFloat(getComputedStyle(el).fontSize); if(!(f>=13.9)) bad.push(ids[i]+' is '+f+'px'); }
     return bad.length?bad.join('; '):null; }},
  {v:'20.21',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
