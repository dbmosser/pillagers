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

if ($s.Contains("  {v:'17.97',what:")) { throw "check 17.97 is in the fixture already" }

SubRx @'
  {v:'17.96',what:
'@ @'
  {v:'17.97',what:'the seal opens marginally quicker, his note of 2026-10-03: 34 seconds of cutting at stage 1 instead of 40, 55 at stage 2 instead of 65, 76 at stage 3 instead of 90, and the Undercroft lines read that one number',
   run:function(){
     if(!(window.__seal&&__seal.need)) return 'SKIP: no seal here';
     var bad=[], src='';
     if(__seal.need(0)!==34) bad.push('stage 1 needs '+__seal.need(0)+' seconds');
     if(__seal.need(1)!==55) bad.push('stage 2 needs '+__seal.need(1)+' seconds');
     if(__seal.need(2)!==76) bad.push('stage 3 needs '+__seal.need(2)+' seconds');
     try{ src=sealLines.toString(); }catch(e){ src=''; }
     if(src.indexOf('sealNeed(')<0) bad.push('control: the Undercroft lines do not read sealNeed, so the number on screen is not this one');
     return bad.length?bad.join('; '):null; }},
  {v:'17.96',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
