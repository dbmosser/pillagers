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

# PAUSE BOX LEAVE BUTTON IS A DANGER GHOST, ONE FOCUS RING (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
#root #pausebox > h3{ font-size:var(--fs-title); border-bottom-color:var(--ui-line); }
'@ @'
#root #pausebox > h3{ font-size:var(--fs-title); border-bottom-color:var(--ui-line); }
/* v34.xx (cw-pausedlg) critic on the four pause boxes (25, 78, 42, 49 all 3): "mismatched button stack", "tiny abandon link", "no pad focus state". The box stays a 480 dialog (style guide, Window: a dialog is not a window). One graded stack: lime primary, ghost secondaries, then the leave button as the guide's danger ghost (1px danger border, same 56px height); every pause button wears the one 3px lime focus ring. */
#root #pausebox:not(.asking) > div:has(> #resumebtn) > :is(#abandonbtn,#arcendbtn,#charselbtn){ border:1px solid var(--danger) !important; background:transparent; }
#root #pausebox:not(.asking) > div:has(> #resumebtn) > :is(#abandonbtn,#arcendbtn,#charselbtn):is(:hover,:focus-visible,.padfocus){ background:color-mix(in srgb,var(--danger) 14%,transparent); }
#root #pausebox > div:has(> #resumebtn) > button:is(:focus-visible,.padfocus){ outline:3px solid var(--acc) !important; outline-offset:3px !important; }
'@

SubRx @'
var VER='34.30';
'@ @'
var VER='34.31';
'@

$pat = "(?m)^  now:'v34\.30:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v34.31: Abandon, end run and return to character selection get a red box at the same height, and every pause button shows one lime focus ring. Check 34.31 fails on v34.30',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
