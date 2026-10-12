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

# ONE SET OF MENU PARTS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  .credits, #topright, .vprice, .cnt{ font-variant-numeric:tabular-nums; }
'@ @'
  .credits, #topright, .vprice, .cnt{ font-variant-numeric:tabular-nums; }
  /* v24.19, UI REDESIGN ui5 (his #50 2026-10-12: "MAKE IT LOOK LIKE A TRIPLE-A GAME"): THE SHARED COMPONENTS. One button, row, tab,
     chip, keycap, panel, paper card, well, stepper, slider and toggle (the .ui-* classes, for the screens the next builds redo), and
     the classes every window already uses take the same look now, so every screen changes without a line of its markup changing:
     square cut corners (2px) instead of the rounded glass of the v17.94 and v18.32 styling passes; one flat amber primary with dark
     ink, no gradient and no glow; secondary buttons a hairline frame; underline tabs; item cells flat graphite with the rarity as a
     bar along the foot and a faint tint behind the icon (the rarity frame stays, his v7.99 rule); a disabled button that is never
     see-through but greys its words; and ONE focus for keyboard and pad: an amber outline with a bone rail down the left edge. */
  :root{ --m-fast:90ms; --m-med:160ms; --m-in:220ms; --m-out:140ms; --m-count:450ms;
    --m-ease:cubic-bezier(.2,.8,.2,1); --m-ease-out:cubic-bezier(.4,0,1,1); }
  /* buttons: every button is the secondary unless it says otherwise */
  #root button{ border-radius:2px; min-height:40px; border-color:var(--ui-line-hi); font-family:var(--f-cond); font-weight:600; letter-spacing:.08em;
    box-shadow:none; transition:background-color var(--m-fast) var(--m-ease), border-color var(--m-fast) var(--m-ease), color var(--m-fast) var(--m-ease), transform var(--m-fast) var(--m-ease); }
  #root button:hover:not(:disabled){ background:var(--ui-hover); border-color:var(--tx-2); box-shadow:none; }
  #root button:active:not(:disabled){ transform:translateY(1px); background:var(--ui-raised); }
  #root .deploy, #root #oc_btn, #root .ui-btn.pri{ min-height:44px; border:1px solid var(--acc); border-radius:2px; background:var(--acc); background-image:none;
    color:var(--acc-ink); font-family:var(--f-cond); font-weight:700; font-size:16px; letter-spacing:.08em; box-shadow:none; filter:none; text-shadow:none; }
  #root .deploy:hover:not(:disabled), #root #oc_btn:hover:not(:disabled), #root .ui-btn.pri:hover:not(:disabled){ background:#f7c25a; background-image:none; border-color:#f7c25a; color:var(--acc-ink); filter:none; box-shadow:none; }
  #root .deploy:active:not(:disabled), #root #oc_btn:active:not(:disabled), #root .ui-btn.pri:active:not(:disabled){ background:#dfa52f; }
  #root .deploy.ghost, #root .ghost{ min-height:40px; background:transparent; border-color:var(--ui-line-hi); color:var(--acc); font-weight:600; }
  #root .deploy.ghost:hover:not(:disabled), #root .ghost:hover:not(:disabled){ background:var(--ui-hover); border-color:var(--acc); color:var(--acc); }
  /* a disabled button greys its words and frame and is never see-through, even where its own markup dims it or colours it (the pad focus keeps its v19.92 dimming) */
  #root button:disabled:not(.padfocus){ opacity:1 !important; color:var(--tx-3) !important; border-color:var(--ui-line) !important; cursor:not-allowed; }
  #root .deploy:not(.ghost):disabled, #root #oc_btn:disabled{ background:var(--ui-hover); border-color:var(--ui-hover); }
  /* the buttons on the cream card keep the card ink */
  #root .vbuy{ border-radius:2px; min-height:48px; background:var(--acc); color:var(--acc-ink); font-family:var(--f-cond); letter-spacing:.08em; }
  #root .vbuy:hover:not(:disabled){ background:#f7c25a; color:var(--acc-ink); }
  #root .vdet .vbuy:disabled:not(.padfocus){ background:var(--ui-paper-2); color:var(--ui-paper-ink-2) !important; border-color:transparent !important; }
  #root .vqty button{ border-radius:2px; background:var(--ui-paper-2); color:var(--ui-paper-ink); }
  #root .vqty button:hover:not(:disabled){ background:#cbc2ae; color:var(--ui-paper-ink); }
  #root .vqty span{ border-radius:2px; }
  .ui-btn, #root .ui-btn{ display:inline-flex; align-items:center; justify-content:center; gap:8px; min-height:44px; padding:0 24px; border-radius:2px;
    border:1px solid var(--ui-line-hi); background:transparent; color:var(--tx-1); font:var(--t-button); letter-spacing:.08em; text-transform:uppercase; cursor:pointer; }
  #root .ui-btn.sm{ min-height:36px; padding:0 14px; font-size:14px; }
  #root .ui-btn.danger{ border-color:var(--danger); color:var(--danger); }
  #root .ui-btn.danger:hover:not(:disabled){ background:rgba(229,72,47,.12); border-color:var(--danger); }
  #root .ui-btn.danger:active:not(:disabled){ background:var(--danger); color:var(--tx-1); }
  #root .ui-btn.hold{ position:relative; overflow:hidden; }
  #root .ui-btn.hold::before{ content:''; position:absolute; inset:0; background:currentColor; opacity:.22; transform-origin:left center;
    transform:scaleX(var(--hold,0)); pointer-events:none; }
  /* ONE FOCUS for keyboard and pad (2.5): the amber outline set off the edge, and a bone rail down the left side. The halo ring and
     its dark edge keep it easy to find from the couch (his v19.69 TV note) without a glow. */
  #root button:focus-visible, #root .invtab:focus-visible, #root .cell:focus-visible, #root .vcell:focus-visible, #root .tag:focus-visible,
  #root .ui-btn:focus-visible, #root .ui-tab:focus-visible, #root .ui-row:focus-visible, .padfocus{
    outline:3px solid var(--acc) !important; outline-offset:3px !important;
    box-shadow:inset 4px 0 0 var(--tx-1), inset 0 -3px 0 var(--bar,transparent), 0 0 0 6px rgba(245,183,59,.22), 0 0 0 7px rgba(11,12,13,.6) !important; }
  #root .ui-btn.danger:focus-visible, #root .ui-btn.danger.padfocus{ outline-color:var(--danger) !important; }
  /* rows */
  #root .row{ border-radius:2px; }
  #root .row:hover{ background:var(--ui-hover); }
  .ui-row{ display:flex; align-items:center; gap:12px; min-height:52px; padding:0 16px; background:var(--ui-raised); border-bottom:1px solid var(--ui-line); }
  .ui-row:hover{ background:var(--ui-hover); }
  .ui-row.on{ background:var(--acc-dim); box-shadow:inset 3px 0 0 var(--acc); }
  .ui-row .ui-row-t{ font:var(--t-h3); letter-spacing:.06em; text-transform:uppercase; color:var(--tx-1); }
  .ui-row .ui-row-s{ font:var(--t-small); color:var(--tx-2); }
  .ui-row .ui-row-v{ margin-left:auto; font:var(--t-num); font-variant-numeric:tabular-nums; color:var(--tx-1); }
  /* tabs: underline tabs, the chosen one bone with an amber bar under it */
  #root .invtabs{ gap:4px; border-bottom:1px solid var(--ui-line); }
  #root .invtab{ border:0; border-bottom:3px solid transparent; border-radius:0; background:transparent; color:var(--tx-2); padding:10px 14px 8px;
    font-family:var(--f-cond); font-weight:600; letter-spacing:.06em; transition:color var(--m-med) var(--m-ease), border-color var(--m-med) var(--m-ease); }
  #root .invtab:hover{ color:var(--tx-1); border-color:transparent; border-bottom-color:var(--ui-line-hi); }
  #root .invtab.on, #root .modal .invtab.on{ color:var(--tx-1); background:transparent; border-color:transparent; border-bottom-color:var(--acc); }
  .ui-tabs{ display:flex; align-items:stretch; gap:4px; min-height:48px; border-bottom:1px solid var(--ui-line); }
  .ui-tab{ display:flex; align-items:center; gap:8px; padding:0 16px; border-bottom:3px solid transparent; font:var(--t-h3); letter-spacing:.06em;
    text-transform:uppercase; color:var(--tx-2); cursor:pointer; transition:color var(--m-med) var(--m-ease), border-color var(--m-med) var(--m-ease); }
  .ui-tab:hover{ color:var(--tx-1); }
  .ui-tab.on{ color:var(--tx-1); border-bottom-color:var(--acc); }
  /* chips */
  #root .tag{ border-radius:2px; }
  #root .tag:hover{ background:var(--ui-hover); }
  .ui-chip{ display:inline-flex; align-items:center; gap:6px; height:22px; padding:0 8px; border-radius:2px; font:600 13px/1 var(--f-cond);
    letter-spacing:.1em; text-transform:uppercase; background:var(--ui-hover); color:var(--tx-2); white-space:nowrap; }
  .ui-chip.ok{ background:rgba(118,185,124,.16); color:var(--ok); }
  .ui-chip.danger{ background:rgba(229,72,47,.16); color:var(--danger); }
  .ui-chip.ink{ background:var(--ui-paper-ink); color:var(--ui-paper); }
  .ui-chip.r-common{ background:rgba(157,163,168,.18); } .ui-chip.r-uncommon{ background:rgba(95,191,106,.18); } .ui-chip.r-rare{ background:rgba(63,157,233,.18); }
  .ui-chip.r-elite{ background:rgba(168,102,224,.18); } .ui-chip.r-gold{ background:rgba(240,143,46,.18); }
  /* keycaps: a key, not a pill (ui7 fills them in through uiKey) */
  .ui-key{ display:inline-flex; align-items:center; justify-content:center; min-width:24px; height:24px; padding:0 6px; box-sizing:border-box;
    border:1px solid var(--tx-1); border-bottom-width:2px; border-radius:3px; background:rgba(0,0,0,.35); color:var(--tx-1);
    font:700 13px/1 var(--f-cond); letter-spacing:.04em; text-transform:uppercase; white-space:nowrap; vertical-align:middle; }
  /* surfaces */
  #root .panel, .ui-panel{ border:1px solid var(--ui-line); border-radius:2px; background:var(--ui-panel); box-shadow:inset 0 1px 0 rgba(255,255,255,.035); }
  #root .panel::after{ content:none; }
  .ui-well{ background:rgba(0,0,0,.32); border:1px solid var(--ui-line); border-radius:2px; box-shadow:inset 0 1px 2px rgba(0,0,0,.5); }
  #root .vdet, .ui-card{ background:var(--ui-paper); color:var(--ui-paper-ink); border:1px solid rgba(0,0,0,.2); border-radius:2px; box-shadow:0 12px 32px rgba(0,0,0,.45); }
  #root .vdet h4{ color:var(--ui-paper-ink); }
  #root .vdet .vpill, #root .vdet .vpill.r{ background:var(--ui-paper-ink); color:var(--ui-paper); letter-spacing:.1em; }
  #root .vendgrid{ border-radius:2px; border-color:var(--ui-line); }
  /* item cells: flat graphite, the rarity frame, a bar of the rarity along the foot and a faint tint of it behind the icon */
  #root .cell, #root .vcell{ border-radius:2px; transform:none;
    background:radial-gradient(circle at 50% 44%, var(--tint,rgba(255,255,255,.035)) 0%, transparent 64%), var(--ui-raised);
    box-shadow:inset 0 -3px 0 var(--bar,transparent); }
  #root .cell:hover, #root .vcell:hover{ transform:none;
    background:radial-gradient(circle at 50% 44%, var(--tint,rgba(255,255,255,.05)) 0%, transparent 64%), var(--ui-hover);
    box-shadow:inset 0 -3px 0 var(--bar,transparent); }
  #root .cell.c-common{ --bar:var(--r-common); --tint:rgba(157,163,168,.10); }
  #root .cell.c-uncommon{ --bar:var(--r-uncommon); --tint:rgba(95,191,106,.12); }
  #root .cell.c-rare{ --bar:var(--r-rare); --tint:rgba(63,157,233,.12); }
  #root .cell.c-elite{ --bar:var(--r-elite); --tint:rgba(168,102,224,.12); }
  #root .cell.c-gold{ --bar:var(--r-gold); --tint:rgba(240,143,46,.12); }
  #root .cell .cnt{ border-radius:2px; }
  #root .vcell.on{ background:var(--acc-dim); border-color:var(--acc); box-shadow:inset 0 0 0 1px var(--acc); }
  #root .vcell.took{ background:rgba(118,185,124,.18); }
  #root .vcell.poor .vp{ color:var(--tx-2) !important; opacity:1; }
  /* inputs: placeholders that can be read */
  #root input::placeholder, #root textarea::placeholder{ color:var(--tx-2); opacity:1; }
  #root input:not([type=range]):not([type=checkbox]), #root textarea{ border-radius:2px; }
  /* stepper, slider, toggle (2.6) */
  .ui-stepper{ display:inline-flex; align-items:center; justify-content:space-between; width:180px; height:36px; border:1px solid var(--ui-line);
    border-radius:2px; background:rgba(0,0,0,.32); font:600 15px/1 var(--f-cond); letter-spacing:.06em; text-transform:uppercase; color:var(--tx-1); }
  #root .ui-stepper > button{ min-height:0; height:100%; padding:0 10px; border:0; background:transparent; color:var(--tx-2); }
  #root .ui-stepper > button:hover:not(:disabled){ color:var(--acc); background:transparent; }
  .ui-slider{ -webkit-appearance:none; appearance:none; height:4px; border-radius:0; cursor:pointer;
    background:linear-gradient(var(--acc),var(--acc)) 0 0/var(--v,50%) 100% no-repeat, var(--ui-line); }
  .ui-slider::-webkit-slider-thumb{ -webkit-appearance:none; appearance:none; width:14px; height:18px; border:0; border-radius:2px; background:var(--tx-1); }
  #root .ui-toggle{ position:relative; display:inline-block; width:40px; height:20px; min-height:0; padding:0; border:0; border-radius:10px;
    background:var(--ui-line); cursor:pointer; vertical-align:middle; }
  #root .ui-toggle::after{ content:''; position:absolute; left:2px; top:2px; width:16px; height:16px; border-radius:50%; background:var(--tx-2);
    transition:transform var(--m-med) var(--m-ease); }
  #root .ui-toggle.on{ background:var(--acc); }
  #root .ui-toggle.on::after{ transform:translateX(20px); background:var(--acc-ink); }
  .ui-ico{ display:inline-block; vertical-align:middle; flex:none; }
  /* the wordmark and the brand in the display face (2.1; Titan One leaves the menus) */
  #title .wordmark{ font-family:var(--f-cond); font-weight:800; letter-spacing:.01em; filter:drop-shadow(0 4px 0 rgba(0,0,0,.55)); }
  .brand{ font-family:var(--f-cond); }
  /* motion: windows and rows ease in (ui6 uses --m-in); with reduced motion nothing moves, it only fades */
  @media (prefers-reduced-motion: reduce){
    #root *, #root *::before, #root *::after{ transition-property:opacity, background-color, border-color, color !important; }
    #root button:active:not(:disabled), #root .ui-btn:active:not(:disabled){ transform:none !important; }
  }
'@

SubRx @'
    <div id="titleres" style="margin-top:7px;font-size:13px;letter-spacing:.12em;color:var(--steel-hi);
'@ @'
    <div id="titleres" style="margin-top:7px;font-size:13px;letter-spacing:.12em;color:var(--tx-2);
'@

SubRx @'
var HUDC={text:UIC.tx_1, dim:UIC.tx_2, danger:UIC.danger, warn:UIC.warn, extract:UIC.extract, gain:UIC.ok, ally:UIC.ally,
  special:UIC.r_elite, plate:'rgba(6,9,13,.78)', dangerPlate:'rgba(40,8,6,.84)', ink:INK};
'@ @'
var HUDC={text:UIC.tx_1, dim:UIC.tx_2, danger:UIC.danger, warn:UIC.warn, extract:UIC.extract, gain:UIC.ok, ally:UIC.ally,
  special:UIC.r_elite, plate:'rgba(6,9,13,.78)', dangerPlate:'rgba(40,8,6,.84)', ink:INK};
// v24.19, UI REDESIGN ui5 (his #50): UIICON, the one line glyph set of the menus and the HUD (design 2.7). Path data on a 24 grid,
// drawn with a 2px stroke and square caps in the current colour: uiIcon(name,px) makes the DOM svg, uiIconPath(name) the canvas
// Path2D (cached), so a glyph in a window and the same glyph on the HUD are one drawing. Never emoji, dingbats or text arrows.
var UIICON={
  close:'M6 6L18 18M18 6L6 18', back:'M15 5L8 12L15 19', chevron:'M9 5L16 12L9 19',
  lock:'M7 11V8a5 5 0 0 1 10 0v3M5 11h14v10H5z', warning:'M12 3L22 20H2zM12 9v5M12 17v1', info:'M12 3a9 9 0 1 0 0 18a9 9 0 1 0 0-18zM12 11v6M12 7v1',
  credits:'M12 3a9 9 0 1 0 0 18a9 9 0 1 0 0-18zM15 9h-4a2 2 0 0 0 0 4h2a2 2 0 0 1 0 4H9M12 6v2M12 16v2',
  xp:'M12 3l2.6 5.6 6.1.7-4.5 4.2 1.2 6L12 16.6 6.6 19.5l1.2-6L3.3 9.3l6.1-.7z',
  backpack:'M6 8a3 3 0 0 1 3-3h6a3 3 0 0 1 3 3v12H6zM9 5V3h6v2M9 13h6', belt:'M3 9h18v6H3zM10 9v6M14 9v6',
  map:'M3 6l6-2 6 2 6-2v14l-6 2-6-2-6 2zM9 4v14M15 6v14', contract:'M6 3h9l3 3v15H6zM9 9h6M9 13h6M9 17h4',
  settings:'M12 9a3 3 0 1 0 0 6a3 3 0 1 0 0-6zM12 2v3M12 19v3M2 12h3M19 12h3M4.9 4.9l2.1 2.1M17 17l2.1 2.1M4.9 19.1L7 17M17 7l2.1-2.1',
  speaker:'M4 9h4l5-4v14l-5-4H4zM16 9a4 4 0 0 1 0 6M18.5 6.5a8 8 0 0 1 0 11',
  controller:'M7 8h10a4 4 0 0 1 4 4v3a3 3 0 0 1-5.2 2L14 15h-4l-1.8 2A3 3 0 0 1 3 15v-3a4 4 0 0 1 4-4zM7 11v3M5.5 12.5h3M16 12h1M18 14h1',
  keyboard:'M2 6h20v12H2zM6 10h1M10 10h1M14 10h1M18 10h1M7 14h10', check:'M4 12l5 5L20 6', plus:'M12 5v14M5 12h14', minus:'M5 12h14',
  sun:'M12 8a4 4 0 1 0 0 8a4 4 0 1 0 0-8zM12 2v2M12 20v2M2 12h2M20 12h2M4.9 4.9l1.4 1.4M17.7 17.7l1.4 1.4M4.9 19.1l1.4-1.4M17.7 6.3l1.4-1.4',
  moon:'M20 14.5A8 8 0 0 1 9.5 4A8 8 0 1 0 20 14.5z', rain:'M7 15a4 4 0 0 1 .5-8A5 5 0 0 1 17 8a3.5 3.5 0 0 1 0 7zM8 18l-1 3M12 18l-1 3M16 18l-1 3',
  fog:'M3 8h18M5 12h14M3 16h18M7 20h10', storm:'M7 14a4 4 0 0 1 .5-8A5 5 0 0 1 17 7a3.5 3.5 0 0 1 0 7zM13 14l-3 4h4l-3 4',
  blackout:'M12 3a9 9 0 1 0 0 18a9 9 0 1 0 0-18zM5.6 5.6l12.8 12.8', extraction:'M12 21V7M6 12l6-6 6 6M4 3h16',
  skull:'M12 3a8 8 0 0 0-8 8c0 3 1.5 4.8 3 5.8V20h10v-3.2c1.5-1 3-2.8 3-5.8a8 8 0 0 0-8-8zM9 11h1M14 11h1M10 20v-2M14 20v-2',
  armour:'M12 3l8 3v6c0 5-3.5 8-8 9-4.5-1-8-4-8-9V6z', heart:'M12 20s-8-4.8-8-10.5A4.5 4.5 0 0 1 12 7a4.5 4.5 0 0 1 8 2.5C20 15.2 12 20 12 20z',
  stand:'M12 3a2 2 0 1 0 0 4a2 2 0 1 0 0-4zM12 8v7M8 11h8M12 15l-3 6M12 15l3 6', crouch:'M12 6a2 2 0 1 0 0 4a2 2 0 1 0 0-4zM12 11v5M8 13h8M12 16l-4 2v3M12 16l4 2v3',
  concealed:'M2 12s4-7 10-7 10 7 10 7-4 7-10 7S2 12 2 12zM4 4l16 16', signal:'M4 20v-3M9 20v-7M14 20V9M19 20V4',
  party:'M9 8a3 3 0 1 0 0 6a3 3 0 1 0 0-6zM17 9a2.5 2.5 0 1 0 0 5a2.5 2.5 0 1 0 0-5zM3 20a6 6 0 0 1 12 0M15 20a5 5 0 0 1 7-4'
};
var _uiIconP={};
function uiIcon(name,px,cls){
  var d=UIICON[name]; if(!d) return '';
  var s=(px>0)?px:20;
  return '<svg class="ui-ico'+(cls?' '+cls:'')+'" viewBox="0 0 24 24" width="'+s+'" height="'+s+'" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="square" stroke-linejoin="miter" aria-hidden="true"><path d="'+d+'"/></svg>';
}
function uiIconPath(name){
  if(_uiIconP[name]) return _uiIconP[name];
  if(!UIICON[name]||typeof Path2D==='undefined') return null;
  try{ _uiIconP[name]=new Path2D(UIICON[name]); }catch(_e){ return null; }
  return _uiIconP[name];
}
'@

SubRx @'
var VER='24.18';
'@ @'
var VER='24.19';
'@

$pat = "(?m)^  now:'v24\.18:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v24.19: Menus share one set of parts: square cut buttons with one flat amber primary, underline tabs, flat item cells with a rarity bar, and one focus look for keys and the controller. Check 24.19 fails on v24.18',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
