$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
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
     var full=(CFG&&CFG.raidSec)||DEF.raidSec;
'@ @'
     // v14.95, falsy-zero audit finding 1: A RAID CLOCK THAT IS OFF IS NOT CUT. The tuning console's raid timer reaches 0, which
     // every other reader treats as no clock, but 0 read as unset here, so the board promised about 356 seconds instead of 540
     // on a raid with no clock at all.
     var full=(CFG&&typeof CFG.raidSec==='number')?CFG.raidSec:DEF.raidSec;
     if(full<=0) return 'The raid clock is off, so there is no clock to cut.';
'@
SubRx @'
var VER='14.94';
'@ @'
var VER='14.95';
'@

$pat = "(?m)^  now:'v14\.94:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.95: THE SHORT WINDOW TERM DOES NOT PROMISE TO CUT A RAID CLOCK THAT IS OFF. The raid timer dial reaches 0, which means no clock everywhere else, but the term read 0 as unset and promised about 356 seconds instead of 540. With the clock off it now says there is no clock to cut. Check 14.95 reads the term with the clock on and off; it fails on v14.94',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
