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

# Detail panes go dark (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  #root .vdet .vpill, #root .vdet .vpill.r{ background:var(--ui-paper-ink); color:var(--ui-paper); letter-spacing:.1em; }
'@ @'
  #root .vdet .vpill, #root .vdet .vpill.r{ background:var(--ui-paper-ink); color:var(--ui-paper); letter-spacing:.1em; }
  /* v28.xx (cw-vdetdark), UI STEP 7 (his AAA bar, style guide): the detail pane of the shop, craft, hire, contracts and gambler windows
     is a dark pane, not the cream paper card. The guide keeps paper for the ask dialog only (it was the brightest thing on every
     Undercroft screen and pulled the eye off the list). Fill --ui-raised, 1px --ui-line-hi, 4px radius, 24px padding; title 32px, labels
     16px tx-2, values tx-1, hero price 32px; the stepper is two 48px ghost squares; Buy is 56px. Colours only: no text or logic moves. */
  #root .vdet{ background:var(--ui-raised); color:var(--tx-1); border:1px solid var(--ui-line-hi); border-radius:4px; box-shadow:none; padding:24px; }
  #root .vdet h4{ color:var(--tx-1); font-family:var(--f-cond); font-weight:700; font-size:32px; line-height:1.1; letter-spacing:.02em; margin:0 0 12px; }
  #root .vdet .vpill, #root .vdet .vpill.r{ background:var(--ui-hover); color:var(--tx-1); font-family:var(--f-cond); font-size:14px; letter-spacing:.1em; }
  #root .vdet .vdesc{ color:var(--tx-2); font-size:16px; }
  #root .vdet .vdesc[style]{ color:var(--tx-2) !important; }
  #root .vdet .vdesc[style] b{ color:var(--tx-1) !important; }
  #root .vdet .vdesc[style*="8a3423"], #root .vdet .vdesc[style*="8a5a2c"]{ color:var(--danger) !important; }
  #root .vdet .vstat{ color:var(--tx-2); font-size:16px; }
  #root .vdet .vbar{ background:var(--ui-line); }
  #root .vdet .vbar i{ background:var(--tx-1); }
  #root .vdet .crlab{ color:var(--tx-2); font-size:16px; }
  #root .vdet .crew, #root .vdet .vprice{ border-top:1px solid var(--ui-line); }
  #root .vdet .crewc, #root .vdet .crn, #root .vdet .crv{ color:var(--tx-1); }
  #root .vdet .crewc{ font-size:20px; }
  #root .vdet .crewc em, #root .vdet .crv em{ color:var(--tx-2); font-size:16px; }
  #root .vdet .crv[style*="2f6f4e"]{ color:var(--ok) !important; }
  #root .vdet .crv[style*="a33d22"]{ color:var(--danger) !important; }
  #root .vdet .crewcell{ background:var(--ui-panel); border:1px solid var(--ui-line-hi); border-radius:2px; }
  #root .vdet .crewcell .cnt{ color:var(--tx-1); text-shadow:none; }
  #root .vdet .vprice{ color:var(--tx-2); font-size:16px; letter-spacing:.08em; }
  #root .vdet .vprice b{ color:var(--tx-1); font-family:var(--f-cond); font-size:32px; font-weight:700; }
  #root .vdet .vqty button{ width:48px; height:48px; background:transparent; color:var(--tx-1); border:1px solid var(--ui-line-hi); border-radius:2px; }
  #root .vdet .vqty button:hover:not(:disabled){ background:var(--ui-hover); color:var(--tx-1); border-color:var(--tx-2); }
  #root .vdet .vqty span{ background:transparent; color:var(--tx-1); font-size:20px; letter-spacing:.04em; }
  #root .vdet .cqty button{ color:var(--tx-1); }
  #root .vdet .cqty button.on{ color:var(--acc-ink); }
  #root .vdet .vbuy{ min-height:56px; font-size:20px; letter-spacing:.06em; }
  #root .vdet .vbuy:disabled:not(.padfocus){ background:var(--ui-hover); color:var(--tx-3) !important; border-color:var(--ui-line) !important; }
'@

SubRx @'
var VER='29.67';
'@ @'
var VER='29.68';
'@

$pat = "(?m)^  now:'v29\.67:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.68: The shop, craft, hire and contracts detail panes are dark instead of cream. Check 29.68 fails on v29.67',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
