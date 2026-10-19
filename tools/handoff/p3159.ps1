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

# PAD BUTTONS CALLOUT WIDTH, 8PX SCROLLBAR, ONE SETTINGS ROW HEIGHT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
#root #keyslist, #root #setlist{ padding-bottom:var(--sp-5); -webkit-mask-image:linear-gradient(to bottom, var(--ui-void) calc(100% - var(--sp-5)), transparent); mask-image:linear-gradient(to bottom, var(--ui-void) calc(100% - var(--sp-5)), transparent); }
'@ @'
#root #keyslist, #root #setlist{ padding-bottom:var(--sp-5); -webkit-mask-image:linear-gradient(to bottom, var(--ui-void) calc(100% - var(--sp-5)), transparent); mask-image:linear-gradient(to bottom, var(--ui-void) calc(100% - var(--sp-5)), transparent); }
/* v31.xx (cw-pset10) critic c-31y (Pad buttons 75 at 2: "the banner is offset (481 to 1439) from the list columns", "the scrollbar is a thin dim 4px line", "the key column leaves empty cells"; Settings 70 at 2: "the pause when the window loses focus row is 82px against 66px for the others", "the description pane touches the footer divider with no bottom padding"). Now: the rebind callout is as wide as the pad buttons table (1440) and lines up with its labels, the Settings and Keys scrollbar is 8px, every Settings row is one height (the hidden hint line no longer pads a row), and the detail strip keeps 16px above the footer hint. */
#root #keysmodal #keysnote{ max-width:calc(var(--sp-5) * 30); padding-inline:var(--sp-3); }
#root #setlist::-webkit-scrollbar, #root #keyslist::-webkit-scrollbar{ width:8px; }
#root #setlist::-webkit-scrollbar-thumb, #root #keyslist::-webkit-scrollbar-thumb{ border-radius:4px; }
#root #setlist .row:not(.setjump) > div:first-child > .hint{ display:none; }
#root #setlist .row:not(.setjump){ box-sizing:border-box; height:var(--btn-h); padding-block:0; align-items:center; }
#root #setdetail{ margin-bottom:var(--sp-2); }
'@

SubRx @'
var VER='31.58';
'@ @'
var VER='31.59';
'@

$pat = "(?m)^  now:'v31\.58:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.59: The pad buttons callout lines up with the table, scrollbars are 8px, and every settings row is the same height. Check 31.59 fails on v31.58',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
