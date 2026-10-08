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

if ($s.Contains("  {v:'20.23',what:")) { throw "check 20.23 is in the fixture already" }

SubRx @'
  {v:'20.22',what:
'@ @'
  {v:'20.23',what:'the achievements list is readable: its rows are 14px with a name column wide enough for LOCKED MACHINE BREAKER on one line',
   run:function(){
     if(typeof renderStatCards!=='function') return 'SKIP: no stats page here';
     var bad=[], row, nm;
     try{ renderStatCards(); }catch(e){ return 'threw: '+(e&&e.message||e); }
     row=document.querySelector('#achlist > div:nth-child(2)'); nm=row&&row.querySelector('span');
     if(!row||!nm) return 'SKIP: no achievements listed';
     if(!(parseFloat(getComputedStyle(row).fontSize)>=13.9)) bad.push('the rows are '+getComputedStyle(row).fontSize);
     if(!(parseFloat(nm.style.width)>=220)) bad.push('the name column is '+nm.style.width);
     return bad.length?bad.join('; '):null; }},
  {v:'20.22',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
