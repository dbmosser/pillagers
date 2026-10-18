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

# The title screen is calmer: flat step columns and one pitch for the mode rows (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
#root .ui-panel, #root #title .tcard{ box-sizing:border-box;
'@ @'
#root .ui-panel{ box-sizing:border-box;
'@

SubRx @'
#root #title #modemenu .modelater button.moderow{ min-height:var(--btn-h-xs); font-size:var(--fs-label) !important; }

'@ @'
#root #title #modemenu .modelater button.moderow{ min-height:var(--btn-h-sm); font-size:var(--fs-body) !important; }
'@

SubRx @'
#root #title #slotpanel button, #root #title #pnamein{ min-height:var(--btn-h-xs); border-radius:var(--rad) !important; font:600 var(--fs-label)/1 var(--f-cond) !important; }
</style>

'@ @'
#root #title #slotpanel button, #root #title #pnamein{ min-height:var(--btn-h-xs); border-radius:var(--rad) !important; font:600 var(--fs-label)/1 var(--f-cond) !important; }
/* v28.xx (cw-uishared-title2), the critic scored the title 2 of 5 ("template page, cards read as buttons, five amber things, rows off the grid,
   no pad focus"). Cards are flat columns under a 1px rule, not boxes; one amber per zone; every mode row 48px on the 8px grid; a focus cue. */
#root #title .tcard{ background:transparent; border:0; border-top:1px solid var(--ui-line-hi); border-radius:0; box-shadow:none; padding:var(--sp-2) var(--sp-1) 0 0; }
#root #title .tstep{ color:var(--acc); }
#root #title .titlecol > div[style*="grid"]{ margin-top:var(--sp-3) !important; gap:var(--sp-4) !important; }
#root #title .kbrow, #root #title .padrow{ margin-top:var(--sp-3) !important; }
#root #title .kbrow b{ font-size:var(--fs-fine) !important; }
#root #title #modemenu button.moderow:focus-visible{ outline:none; background:var(--ui-raised); border-color:var(--acc); box-shadow:inset 3px 0 0 var(--acc); }
#root #title #slotpanel #pnamesave, #root #title #slotpanel #newgame{ background:transparent; border:1px solid var(--ui-line-hi) !important; color:var(--tx-1) !important; }
#root #title #slotpanel #pnamein{ text-transform:none; }
</style>
'@

SubRx @'
var VER='29.34';
'@ @'
var VER='29.35';
'@

$pat = "(?m)^  now:'v29\.34:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.35: The title screen has fewer boxes and one row height, with a focus bar on the menu row. Check 29.35 fails on v29.34',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
