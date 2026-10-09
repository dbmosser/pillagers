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

# THE RUN CARD FITS THE SCREEN (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  .tagwrap{ display:flex; flex-wrap:wrap; gap:6px; justify-content:center; max-width:560px; margin:14px 0 8px; }
'@ @'
  /* v21.09, from the whole-game bug hunt of 2026-10-08 (V-E1), seen on the 4K run card screenshots: THE FEEL TAGS USE THE CARD WIDTH.
     The 29 tags were held to a column 560 wide in a card with 774 of room, so they stacked eleven rows deep: the card ran past the
     screen with a scrollbar down its edge, the line under the buttons was out of sight, and on a death card the note box hid half
     under the pinned buttons. The tags, the note box and that line now take the full width of the card (about eight rows of tags),
     so a normal card fits. The card itself keeps its 880 cap. */
  .tagwrap{ display:flex; flex-wrap:wrap; gap:6px; justify-content:center; max-width:774px; margin:14px 0 8px; }
'@

SubRx @'
  <textarea id="oc_note" rows="2" style="max-width:520px" placeholder="Anything else? (optional)"></textarea>
'@ @'
  <textarea id="oc_note" rows="2" style="max-width:774px" placeholder="Anything else? (optional)"></textarea>
'@

SubRx @'
  <div style="font-size:11px;color:var(--ash);margin-top:8px;max-width:520px;line-height:1.5;margin-bottom:26px">Copy report puts this raid
'@ @'
  <div style="font-size:11px;color:var(--ash);margin-top:8px;max-width:774px;line-height:1.5;margin-bottom:26px">Copy report puts this raid
'@

SubRx @'
var VER='21.08';
'@ @'
var VER='21.09';
'@

$pat = "(?m)^  now:'v21\.08:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.09: The end of raid card lays its feel tags out wider, so it fits on the screen and the note box is never hidden. Check 21.09 fails on v21.08',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
