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

# THE PARTY WINDOW IS THE 90 PERCENT CARD AGAIN (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
#root #partymodal.ui-win:not(#zz1):not(#zz2) > .ui-foot > .ui-back{ top:calc(50% - var(--cfh,440px) / 2 + var(--sp-2)); }
#root #partymodal.ui-win:not(#zz1):not(#zz2)::before{ inset:50% auto auto 50%; width:min(960px,calc(100% - 28px)); height:min(var(--cfh,440px),calc(100% - 28px)); transform:translate(-50%,-50%); }
#root #partymodal.ui-win:not(#zz1):not(#zz2){ padding:0 max(14px, calc(50% - 440px)); }

'@ @'
/* v34.63 (cw-partywin), his Q43 (2026-10-18): a window is "a centred card with an X in the corner ... nearly the entire screen", and style-guide.md (Window, 90 x 90) names party. v34.22 (cw-wpcard, job 100) gave the party window a fitted 960 card with a 4-id rule that beat the 90 percent card, following the critic over his order. The fitted frame and its side padding are gone; the party window is the 90 percent card again. The X keeps its 48px look and sits in the card corner like every window's. */
#root #partymodal.ui-win:not(#zz1):not(#zz2) > .ui-foot > .ui-back{ top:calc(5vh + 12px); right:calc(5vw + 16px); }

'@

SubRx @'
var VER='34.62';
'@ @'
var VER='34.63';
'@

$pat = "(?m)^  now:'v34\.62:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v34.63: The party window fills 90 percent of the screen like the shop and the other windows. Check 34.63 fails on v34.62',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
