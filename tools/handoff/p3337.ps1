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

# experimental page: lime on chip, dim off chip, one focus mark (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
#root #settingsmodal.expmode #setlist{ --rail:0px; padding-left:0; padding-right:8px; padding-bottom:var(--sp-5);
'@ @'
#root #settingsmodal.expmode #setlist{ --rail:0px; padding-left:0; padding-right:8px; padding-bottom:72px;
'@

SubRx @'
#root #settingsmodal.expmode #setlist .exprow .expvalue{ display:inline-flex; align-items:center; justify-content:center; min-width:56px; min-height:32px; border:1px solid var(--ui-line-hi); border-radius:var(--rad); background:var(--ui-raised); font:600 var(--fs-body)/1 var(--f-cond); color:var(--tx-1); }
'@ @'
/* v33.35 (cw-expchip) critic 61 round 3 (score 2): on and off chips looked alike, the detail pane repeated the chip, focus was stacked (bar + fill + framed chevrons + caret bar), footer 13px, last row cut. On is a lime chip, off a dim one; the lime row bar is the one focus mark. */
#root #settingsmodal.expmode #setlist .exprow .expvalue{ display:inline-flex; align-items:center; justify-content:center; min-width:56px; min-height:32px; border:1px solid var(--acc); border-radius:var(--rad); background:var(--acc); font:700 var(--fs-body)/1 var(--f-cond); color:var(--ui-void); }
#root #settingsmodal.expmode #setlist .exprow.expoff .expvalue{ background:transparent; color:var(--tx-2); border-color:var(--ui-line); font-weight:400; }
'@

SubRx @'
#root #settingsmodal.expmode #setlist .exprow > button::before, #root #settingsmodal.expmode #setlist .exprow > button::after{ visibility:hidden; font:400 40px/1 var(--f-body); color:var(--tx-2) !important; }
'@ @'
#root #settingsmodal.expmode #setlist .exprow > button::before, #root #settingsmodal.expmode #setlist .exprow > button::after{ display:none !important; content:none !important; }
#root #settingsmodal.expmode #setlist .exprow::before, #root #settingsmodal.expmode #setlist .exprow::after{ display:none !important; content:none !important; }
'@

SubRx @'
#root #settingsmodal.expmode #setlist .exprow:hover > button::before, #root #settingsmodal.expmode #setlist .exprow:hover > button::after, #root #settingsmodal.expmode #setlist .exprow.dshow > button::before, #root #settingsmodal.expmode #setlist .exprow.dshow > button::after, #root #settingsmodal.expmode #setlist .exprow > button.padfocus::before, #root #settingsmodal.expmode #setlist .exprow > button.padfocus::after{ visibility:visible; color:var(--acc) !important; }
'@ @'
#root #settingsmodal.expmode #setlist .exprow > button, #root #settingsmodal.expmode #setlist .exprow:hover > button, #root #settingsmodal.expmode #setlist .exprow.dshow > button, #root #settingsmodal.expmode #setlist .exprow > button.padfocus, #root #settingsmodal.expmode #setlist .exprow > button:focus-visible{ border:0 !important; outline:0 !important; box-shadow:none !important; background:transparent !important; }
'@

SubRx @'
#root #settingsmodal.expmode #setlist .exprow.dshow .expvalue, #root #settingsmodal.expmode #setlist .exprow:hover .expvalue, #root #settingsmodal.expmode #setlist .exprow > button.padfocus .expvalue{ border-color:var(--acc); color:var(--acc); }
'@ @'
/* v33.35 (cw-expchip): no chip recolour on focus; the row bar alone marks it. */
'@

SubRx @'
#root #settingsmodal.expmode::after{ content:'enter change    esc back'; font-size:var(--fs-label); }
'@ @'
#root #settingsmodal.expmode::after{ content:'enter change    esc back'; font-size:16px; }
'@

SubRx @'
#root #settingsmodal.expmode #setdetail .sdv{ display:inline-block; padding:8px 16px; border:1px solid var(--ui-line-hi); border-radius:var(--rad); background:var(--ui-raised); font:600 var(--fs-body)/1 var(--f-cond); color:var(--tx-1); }
'@ @'
#root #settingsmodal.expmode #setdetail .sdv{ display:none; }
'@

SubRx @'
var VER='33.36';
'@ @'
var VER='33.37';
'@

$pat = "(?m)^  now:'v33\.36:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v33.37: The experimental page shows on as a lime chip and off as a dim one, with one focus mark and a readable footer. Check 33.37 fails on v33.36',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
