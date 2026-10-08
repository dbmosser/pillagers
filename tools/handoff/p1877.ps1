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

# THE GAMBLER WINDOW LINES ARE CENTRED (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  #gamblemodal .msub, #gamblemodal .plist{ max-width:1060px; width:100%; }
'@ @'
  #gamblemodal .msub, #gamblemodal .plist{ max-width:1060px; width:100%; }
  #gamblemodal .msub{ text-align:center; }   /* v18.77, seen on the 4K screenshot (2026-10-07): the credits line and Wirt's line ran full width from the panel's left edge, flush against its border, under a centred title and centred cards; centred like them */
'@

SubRx @'
var VER='18.76';
'@ @'
var VER='18.77';
'@

$pat = "(?m)^  now:'v18\.76:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.77: The lines at the top of the gambler window are centred and clear of the frame. Check 18.77 fails on v18.76',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
