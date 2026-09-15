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
  P.freeKit=0; P.kitChosen=0; P.dropKit=[];
'@ @'
  // v15.02, save audit finding 3: AND WIRT'S OFFER IS OPEN TO THE RESTORED CHARACTER. The lot bought this period belonged to the
  // character being replaced, and it kept the offer hidden from a character who had bought nothing until the period turned.
  P.freeKit=0; P.kitChosen=0; P.dropKit=[]; P.wirtLotBought=null;
'@
SubRx @'
var VER='15.01';
'@ @'
var VER='15.02';
'@

$pat = "(?m)^  now:'v15\.01:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.02: A RESTORE CODE OPENS WIRT S OFFER TO THE RESTORED CHARACTER. The limited offer bought this period belonged to the character being replaced, and after a restore it stayed marked bought, so the restored character could not buy it until the period turned. A restore now clears it. Check 15.02 buys the lot, restores a code and reads the mark; it fails on v15.01',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
