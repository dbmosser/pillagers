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

# UNDERCROFT: RACKS COLUMN, CODEX FOUR COLUMNS, STASH TYPE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
#root #keyslist, #root #setlist{ padding-bottom:var(--sp-5); -webkit-mask-image:linear-gradient(to bottom, var(--ui-void) calc(100% - var(--sp-5)), transparent); mask-image:linear-gradient(to bottom, var(--ui-void) calc(100% - var(--sp-5)), transparent); }
'@ @'
#root #keyslist, #root #setlist{ padding-bottom:var(--sp-5); -webkit-mask-image:linear-gradient(to bottom, var(--ui-void) calc(100% - var(--sp-5)), transparent); mask-image:linear-gradient(to bottom, var(--ui-void) calc(100% - var(--sp-5)), transparent); }
/* v28.xx (cw-uc-racks) b-31 step 7, the Undercroft on the shared look (style guide: one reading column, 16px type floor, no filler lines). The racks page ran 1316px wide buttons across a 1700px card (his "one grid" rule gave way to the centred card, Q7 and Q43) with 14px grey-amber hint lines: now one 672px column centred in the card, buttons 48px high, status and hint lines 16px in the second text colour, and the line under the tab name that only repeated it is gone (Q8, reason in changes.md). The codex was an auto-fill grid hugging the top left: now four columns, 1344px at most, centred, 16px rarity and kills lines. The stash setup plates (gun keys, item wheel) and their reset buttons were 12px: 14px now, and the one-line swap note under them is gone (Q70 no tutorial prompts, Q8). */
#root #opane_mf > *{ box-sizing:border-box; width:100%; max-width:calc(var(--sp-5) * 14); margin-left:auto; margin-right:auto; }
#root #opane_mf .msub{ display:none; }
#root #opane_mf #mfstatus, #root #opane_mf .hint{ font-size:var(--fs-label) !important; line-height:1.4 !important; color:var(--tx-2); }
#root #opane_mf button{ min-height:var(--btn-h-sm); font-size:var(--fs-label); }
#root #opane_mf #mfghostname{ min-height:var(--btn-h-sm); box-sizing:border-box; font-size:var(--fs-label) !important; }
#root #codexmodal .cxgrid{ grid-template-columns:repeat(4, minmax(0, 1fr)); width:100%; max-width:calc(var(--sp-5) * 28); margin:0 auto; gap:var(--sp-2); align-content:start; }
#root #codexmodal .cxt .cxr, #root #codexmodal .cxt .cxk{ font-size:var(--fs-label); }
#root #kitsetup .kst span, #root #kitsetup .kstc span, #root #kitsetup .ksreset{ font-size:var(--fs-fine); }
#root #kitsetup .ksnote{ display:none; }
'@

SubRx @'
var VER='31.56';
'@ @'
var VER='31.57';
'@

$pat = "(?m)^  now:'v31\.56:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.57: Racks page is one centred column, the codex is four columns, stash plates are bigger. Check 31.57 fails on v31.56',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
