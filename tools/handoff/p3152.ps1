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

# END CARDS: CLOSE X, NO COPY REPORT, CLEAN HAUL REVEAL (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  #root #oc_copy{ background:transparent; border:1px solid var(--ui-line-hi); color:var(--tx-1); font-weight:600; }

'@ @'
  #root #oc_copy{ background:transparent; border:1px solid var(--ui-line-hi); color:var(--tx-1); font-weight:600; }
  /* v28.xx (cw-endx), the critic on 35, 38, 60, 76 and 77 (2 and 3 of 5): "no close X", "copy report is a dev action", "a lone dark tile outside the strip". His Q43: a dialog gets the card with an X in the corner.
     (1) the 48px ghost X sits top right of every end card; it is the same job as the primary (log the run and go back), so it clicks that button and adds no second way out.
     (2) Q8, reason logged in notes/ui/changes.md: copy report and its 13px sentence are off the card. The recorder page in Settings already has Copy to clipboard and holds the same text (the raid is logged before the card opens), so that one row is the one control for it.
     (3) the haul reveal: a tile not yet shown stays an empty slot (rarity bar gone, picture hidden) instead of vanishing, and the pop is a 1.25x settle with no glow, so a tile arriving at the strip edge no longer looks like a stray box. */
  #root #oc_x{ position:absolute; top:var(--sp-3); right:var(--sp-3); box-sizing:border-box; width:var(--btn-h-sm); height:var(--btn-h-sm); min-width:0 !important; min-height:0 !important; padding:0 !important; display:flex; align-items:center; justify-content:center; background:transparent; background-image:none; color:var(--tx-1); border:1px solid var(--ui-line-hi); border-radius:var(--rad); font:400 var(--fs-title)/1 var(--f-cond); cursor:pointer; outline:none; box-shadow:none; z-index:3; }
  #root #oc_x::before{ content:'\00d7'; }
  #root #oc_x:hover, #root #oc_x:focus-visible{ border-color:var(--acc); color:var(--acc); }
  #root #oc_copy, #root #oc_copynote{ display:none !important; }
  #root .ocwin .haulit.hid{ opacity:1; border-bottom-color:var(--ui-line) !important; }
  #root .ocwin .haulit.hid>*{ opacity:0; }
  #root .ocwin .haulit>*{ transition:opacity .12s; }
  #root .ocwin .haulit.pop{ animation:haulsettle .35s ease-out; }
  @keyframes haulsettle{ 0%{ transform:scale(1.25); filter:brightness(2); } 100%{ transform:scale(1); filter:none; } }

'@

SubRx @'
<div class="ocwin">
  <h1 id="oc_title">EXTRACTED</h1>

'@ @'
<div class="ocwin">
  <button type="button" id="oc_x" aria-label="Close" onclick="document.getElementById('oc_btn').click()"></button>   <!-- v28.xx (cw-endx): the card's one X, the same job as the primary -->
  <h1 id="oc_title">EXTRACTED</h1>

'@

SubRx @'
<div style="font-size:13px;color:var(--ash);margin-top:8px;max-width:774px;line-height:1.5;margin-bottom:26px">Copy report puts
'@ @'
<div id="oc_copynote" style="font-size:13px;color:var(--ash);margin-top:8px;max-width:774px;line-height:1.5;margin-bottom:26px">Copy report puts
'@

SubRx @'
var VER='31.51';
'@ @'
var VER='31.52';
'@

$pat = "(?m)^  now:'v31\.51:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.52: Every end card has a 48px X top right that leaves like the primary. Copy report is gone from the card. Haul tiles not yet shown are empty slots, and each settles in instead of flashing big. Check 31.52 fails on v31.51',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
