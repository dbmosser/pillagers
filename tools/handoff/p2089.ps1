$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
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

# THE SHOPKEEPER LINE SITS IN THE FOOTER (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  #hubtoast.on{ opacity:1; }
'@ @'
  #hubtoast.on{ opacity:1; }
  /* v20.89, from the whole-game bug hunt of 2026-10-08 (V-A2): THE ANSWER LINE SITS IN THE FOOTER OF A STATION WINDOW. At 38 up
     its box landed on the bottom edge of the shop grid and of the Fashion racks, its top border drawn over the panel frame line (the
     4K screenshots of both). In the shop, Fashion, the Mainframe and Settings it now sits 26 up, the window padding, so it is level
     with CLOSE in the empty middle of the button row and clear of every panel. Everywhere else it is where it was. */
  body:has(#tradermodal.on) #hubtoast, body:has(#appearmodal.on) #hubtoast,
  body:has(#opmodal.on) #hubtoast, body:has(#settingsmodal.on) #hubtoast{ bottom:26px; }
'@

SubRx @'
var VER='20.88';
'@ @'
var VER='20.89';
'@

$pat = "(?m)^  now:'v20\.88:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.89: The shopkeeper line no longer sits on the bottom edge of the shop and Fashion panels. Check 20.89 fails on v20.88',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
