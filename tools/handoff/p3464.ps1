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

# THE PARTY WINDOW CONTENT STARTS AT THE TOP LEFT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
#root #partymodal.ui-win:not(#zz1):not(#zz2) > .ui-foot > .ui-back{ top:calc(5vh + 12px); right:calc(5vw + 16px); }

'@ @'
#root #partymodal.ui-win:not(#zz1):not(#zz2) > .ui-foot > .ui-back{ top:calc(5vh + 12px); right:calc(5vw + 16px); }
/* v34.64 (cw-partyalign): the 90 percent party card centred its content both ways, so the title sat on the left edge in the middle of the card and the body floated 300px to its right. Content now starts at the top left under the title, one left edge like the shop. */
#root #partymodal.ui-win:not(#zz1):not(#zz2){ align-items:flex-start; justify-content:flex-start; }

'@

SubRx @'
var VER='34.63';
'@ @'
var VER='34.64';
'@

$pat = "(?m)^  now:'v34\.63:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v34.64: The party window title and lines line up on the left and start at the top of the card. Check 34.64 fails on v34.63',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
