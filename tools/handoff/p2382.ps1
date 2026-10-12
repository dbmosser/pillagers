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

# GRAPHITE MENUS: THE NEW COLOURS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  :root {
    --void:#0a0d1c; --steel:#2f4394; --steel-hi:#7f92d8; --ash:#9aa4b0;
    --bone:#FFF6DC; --amber:#ffc04a; --rust:#d8543a; --coolant:#4de3d0;
    --hazard:#ff5a4a; --gain:#7fc4a0; --win-top:#1c2a63; --win-bot:#101a42;
  }
'@ @'
  :root {
    /* v23.82, UI REDESIGN ui2 (his #50 2026-10-12: "MAKE IT LOOK LIKE A TRIPLE-A GAME"; #20: gritty and grounded, like ARC Raiders).
       The Chrono Trigger navy and periwinkle are gone: near-black graphite surfaces, hairline frames, one hot accent (signal amber),
       a cream paper card for decisions, and the rarity colours. The old names are re-pointed here so every existing rule recolours
       at once; new code uses the new names. UIC in the script is the same table for the canvas, so the HUD and the menus match. */
    --ui-void:#0b0c0d; --ui-bg:#111315; --ui-panel:#16191b; --ui-raised:#1e2225; --ui-hover:#272c30;
    --ui-line:#2e3337; --ui-line-hi:#4a5257; --ui-scrim:rgba(6,7,8,.82);
    --ui-paper:#ebe5d6; --ui-paper-2:#ddd5c3; --ui-paper-ink:#17150f; --ui-paper-ink-2:#5a554a;
    --tx-1:#efe9dc; --tx-2:#aaa498; --tx-3:#7a766e; --tx-off:#55524c;
    --acc:#f5b73b; --acc-ink:#1a1205; --acc-dim:rgba(245,183,59,.16);
    --danger:#e5482f; --danger-bg:rgba(60,12,8,.86); --warn:#f5b73b; --ok:#76b97c;
    --extract:#47d8c6; --ally:#9cc7ff; --armour:#7fa6c9;
    --r-common:#9da3a8; --r-uncommon:#5fbf6a; --r-rare:#3f9de9; --r-elite:#a866e0; --r-gold:#f08f2e;
    --void:var(--ui-void); --steel:var(--ui-line); --steel-hi:var(--ui-line-hi); --ash:var(--tx-2);
    --bone:var(--tx-1); --amber:var(--acc); --rust:var(--danger); --coolant:var(--extract);
    --hazard:var(--danger); --gain:var(--ok); --win-top:var(--ui-panel); --win-bot:var(--ui-bg);
  }
'@

SubRx @'
    --void:#0a0d1c; --steel:#2f4394; --steel-hi:#7f92d8; --ash:#9aa4b0;
--bone:#FFF6DC; --amber:#ffc04a; --rust:#d8543a; --coolant:#4de3d0; --hazard:#ff5a4a; --gain:#7fc4a0;
    --win-top:#1c2a63; --win-bot:#101a42;
'@ @'
    /* v23.82, ui2: re-pointed to the graphite tokens declared at :root. */
    --void:var(--ui-void); --steel:var(--ui-line); --steel-hi:var(--ui-line-hi); --ash:var(--tx-2);
    --bone:var(--tx-1); --amber:var(--acc); --rust:var(--danger); --coolant:var(--extract); --hazard:var(--danger); --gain:var(--ok);
    --win-top:var(--ui-panel); --win-bot:var(--ui-bg);
'@

SubRx @'
      radial-gradient(1100px 500px at 20% -10%, rgba(255,192,74,.09), transparent 60%),
      radial-gradient(900px 600px at 90% 110%, rgba(77,227,208,.05), transparent 60%),
      linear-gradient(165deg,#131c46 0%,#0d1435 55%,#090f28 100%);
'@ @'
      radial-gradient(1100px 500px at 20% -10%, rgba(245,183,59,.09), transparent 60%),
      radial-gradient(900px 600px at 90% 110%, rgba(71,216,198,.05), transparent 60%),
      linear-gradient(165deg,#16191b 0%,#111315 55%,#0b0c0d 100%);
'@

SubRx @'
   #title.on { background:radial-gradient(ellipse 70% 62% at 50% 42%, rgba(9,15,40,.60) 0%, rgba(9,15,40,.84) 70%, rgba(5,8,22,.96) 100%); }
'@ @'
   #title.on { background:radial-gradient(ellipse 70% 62% at 50% 42%, rgba(17,19,21,.60) 0%, rgba(17,19,21,.84) 70%, rgba(17,19,21,.96) 100%); }
'@

SubRx @'
     background:linear-gradient(180deg,#ffe9a8 0%,#ffc04a 55%,#e08a1a 100%); -webkit-background-clip:text; background-clip:text; color:transparent;
     filter:drop-shadow(0 4px 0 rgba(0,0,0,.55)) drop-shadow(0 0 22px rgba(255,192,74,.28)); }
   #title .tcard{ border:1px solid rgba(127,146,216,.35); border-radius:10px; padding:14px 16px;
     background:linear-gradient(180deg,rgba(30,38,72,.92),rgba(9,13,28,.92)); box-shadow:0 10px 30px rgba(0,0,0,.25), inset 0 1px 0 rgba(255,255,255,.06); }   /* v18.73, seen on the 4K title screenshot (2026-10-07): the Undercroft behind the title showed through the three step cards, a head inside 2 PILLAGE; solid like the mode rows (v18.67) */
'@ @'
     background:linear-gradient(180deg,#ffe9a8 0%,#f5b73b 55%,#e08a1a 100%); -webkit-background-clip:text; background-clip:text; color:transparent;
     filter:drop-shadow(0 4px 0 rgba(0,0,0,.55)) drop-shadow(0 0 22px rgba(245,183,59,.28)); }
   #title .tcard{ border:1px solid rgba(170,164,152,.35); border-radius:10px; padding:14px 16px;
     background:linear-gradient(180deg,rgba(30,34,37,.92),rgba(17,19,21,.92)); box-shadow:0 10px 30px rgba(0,0,0,.25), inset 0 1px 0 rgba(255,255,255,.06); }   /* v18.73, seen on the 4K title screenshot (2026-10-07): the Undercroft behind the title showed through the three step cards, a head inside 2 PILLAGE; solid like the mode rows (v18.67) */
'@

SubRx @'
    border:1px solid rgba(127,146,216,.22); border-radius:3px; }
'@ @'
    border:1px solid rgba(170,164,152,.22); border-radius:3px; }
'@

SubRx @'
  .pmore:hover { background:rgba(255,192,74,.08); }
'@ @'
  .pmore:hover { background:rgba(245,183,59,.08); }
'@

SubRx @'
    border-bottom:1px solid rgba(42,50,61,.35); }
  .row:hover { background:rgba(255,192,74,.06); }
'@ @'
    border-bottom:1px solid rgba(46,51,55,.35); }
  .row:hover { background:rgba(245,183,59,.06); }
'@

SubRx @'
  .r-common{color:#cfd8ef;} .r-uncommon{color:#7fc4a0;} .r-rare{color:#7cc4ff;} .r-elite{color:#d08ce8;} .r-gold{color:#ffc72e;}
'@ @'
  .r-common{color:var(--r-common);} .r-uncommon{color:var(--r-uncommon);} .r-rare{color:var(--r-rare);} .r-elite{color:var(--r-elite);} .r-gold{color:var(--r-gold);}
'@

SubRx @'
  background:radial-gradient(ellipse at 50% 70%, rgba(255,192,74,.10), rgba(0,0,0,0) 70%); }   /* v10.25: the painter's canvas */
'@ @'
  background:radial-gradient(ellipse at 50% 70%, rgba(245,183,59,.10), rgba(0,0,0,0) 70%); }   /* v10.25: the painter's canvas */
'@

SubRx @'
  display:flex; align-items:center; justify-content:center; font-size:11px; color:#0d1435; }
'@ @'
  display:flex; align-items:center; justify-content:center; font-size:11px; color:#111315; }
'@

SubRx @'
.aveye{ width:6px; height:7px; border-radius:3px; background:#FFF6DC; }
'@ @'
.aveye{ width:6px; height:7px; border-radius:3px; background:#efe9dc; }
'@

SubRx @'
  border-top:1px solid rgba(42,50,61,.55); }
.avslot:hover{ background:rgba(255,192,74,.10); }
.avslot.on{ background:rgba(255,192,74,.16); }
'@ @'
  border-top:1px solid rgba(46,51,55,.55); }
.avslot:hover{ background:rgba(245,183,59,.10); }
.avslot.on{ background:rgba(245,183,59,.16); }
'@

SubRx @'
  .invtab.on{ color:#0d1435; background:var(--amber); border-color:var(--amber); font-weight:700; }
'@ @'
  .invtab.on{ color:#111315; background:var(--amber); border-color:var(--amber); font-weight:700; }
'@

SubRx @'
  .imenurow:hover{ background:rgba(255,192,74,.14); color:#fff; }
'@ @'
  .imenurow:hover{ background:rgba(245,183,59,.14); color:#fff; }
'@

SubRx @'
    background:rgba(255,192,74,.08); display:flex; align-items:center; gap:12px; }
'@ @'
    background:rgba(245,183,59,.08); display:flex; align-items:center; gap:12px; }
'@

SubRx @'
  .imenukeys button.mine{ color:#0d1435; background:var(--amber); border-color:var(--amber); }
'@ @'
  .imenukeys button.mine{ color:#111315; background:var(--amber); border-color:var(--amber); }
'@

SubRx @'
  .vcell:hover{ background:rgba(255,192,74,.10); }
  .vcell.on{ border-color:var(--amber); background:rgba(255,192,74,.15);
'@ @'
  .vcell:hover{ background:rgba(245,183,59,.10); }
  .vcell.on{ border-color:var(--amber); background:rgba(245,183,59,.15);
'@

SubRx @'
  .cell:hover{ background:rgba(255,192,74,.10); transform:translateY(-1px); }
  .cell.c-common{ border-color:#5a6478; }
  .cell.c-uncommon{ border-color:#7fc4a0; box-shadow:inset 0 0 8px rgba(127,196,160,.16); }
  .cell.c-rare{ border-color:#7cc4ff; box-shadow:inset 0 0 8px rgba(124,196,255,.20); }
  .cell.c-elite{ border-color:#d08ce8; box-shadow:inset 0 0 10px rgba(208,140,232,.26); }
  .cell.c-gold{ border-color:#ffc72e; box-shadow:inset 0 0 10px rgba(255,199,46,.30); }
'@ @'
  .cell:hover{ background:rgba(245,183,59,.10); transform:translateY(-1px); }
  .cell.c-common{ border-color:var(--r-common); }
  .cell.c-uncommon{ border-color:var(--r-uncommon); box-shadow:inset 0 0 8px rgba(95,191,106,.16); }
  .cell.c-rare{ border-color:var(--r-rare); box-shadow:inset 0 0 8px rgba(63,157,233,.20); }
  .cell.c-elite{ border-color:var(--r-elite); box-shadow:inset 0 0 10px rgba(168,102,224,.26); }
  .cell.c-gold{ border-color:var(--r-gold); box-shadow:inset 0 0 10px rgba(240,143,46,.30); }
'@

SubRx @'
  .cell .cnt{ right:6px; bottom:5px; padding:0 6px; border-radius:7px; background:rgba(8,12,24,.72); line-height:1.35; text-shadow:none; }
'@ @'
  .cell .cnt{ right:6px; bottom:5px; padding:0 6px; border-radius:7px; background:rgba(17,19,21,.72); line-height:1.35; text-shadow:none; }
'@

SubRx @'
  button:hover:not(:disabled){ border-color:var(--amber); color:var(--amber); background:rgba(255,192,74,.08); }
'@ @'
  button:hover:not(:disabled){ border-color:var(--amber); color:var(--amber); background:rgba(245,183,59,.08); }
'@

SubRx @'
  .ghost:hover{ background:rgba(255,192,74,.09); }
'@ @'
  .ghost:hover{ background:rgba(245,183,59,.09); }
'@

SubRx @'
  .outcome{ position:absolute; inset:0; background:rgba(8,12,32,.92);
'@ @'
  .outcome{ position:absolute; inset:0; background:rgba(17,19,21,.92);
'@

SubRx @'
  textarea{ font-family:'Rubik',system-ui,sans-serif; font-size:14px; background:rgba(9,14,40,.92);
'@ @'
  textarea{ font-family:'Rubik',system-ui,sans-serif; font-size:14px; background:rgba(17,19,21,.92);
'@

SubRx @'
  .pausebox{ position:absolute; inset:0; background:rgba(8,12,32,.9); z-index:35;
'@ @'
  .pausebox{ position:absolute; inset:0; background:rgba(17,19,21,.9); z-index:35;
'@

SubRx @'
  .modal{ position:absolute; inset:0; background:rgba(8,12,32,.92); z-index:60;
'@ @'
  .modal{ position:absolute; inset:0; background:rgba(17,19,21,.92); z-index:60;
'@

SubRx @'
    box-shadow:0 0 0 6px rgba(255,192,74,.35), 0 0 22px 4px rgba(255,192,74,.45) !important; }
'@ @'
    box-shadow:0 0 0 6px rgba(245,183,59,.35), 0 0 22px 4px rgba(245,183,59,.45) !important; }
'@

SubRx @'
    background:linear-gradient(180deg,#141a33,#0f1428);
'@ @'
    background:linear-gradient(180deg,#16191b,#111315);
'@

SubRx @'
  #modemenu button.moderow.ghost{ background:rgba(9,13,28,.88); }   /* v18.67, seen on the title screenshot (2026-10-07): the mode rows were see-through, so the Undercroft behind the title showed inside them, a head in 2 PLAYER CO-OP; solid now, the gold outline kept */
'@ @'
  #modemenu button.moderow.ghost{ background:rgba(17,19,21,.88); }   /* v18.67, seen on the title screenshot (2026-10-07): the mode rows were see-through, so the Undercroft behind the title showed inside them, a head in 2 PLAYER CO-OP; solid now, the gold outline kept */
'@

SubRx @'
  .runline{ display:flex; gap:8px; padding:6px 12px; font-size:13px; border-bottom:1px solid rgba(42,50,61,.3); }
'@ @'
  .runline{ display:flex; gap:8px; padding:6px 12px; font-size:13px; border-bottom:1px solid rgba(46,51,55,.3); }
'@

SubRx @'
  .crow{ padding:13px 16px; border-bottom:1px solid rgba(42,50,61,.35); font-size:18px; }   /* v18.66, seen on the Mainframe screenshot (2026-10-07): the contract list read in 15, 13.5, 11 and 10.5 pixel lines across a wide panel; each a few sizes up */
'@ @'
  .crow{ padding:13px 16px; border-bottom:1px solid rgba(46,51,55,.35); font-size:18px; }   /* v18.66, seen on the Mainframe screenshot (2026-10-07): the contract list read in 15, 13.5, 11 and 10.5 pixel lines across a wide panel; each a few sizes up */
'@

SubRx @'
    background:rgba(9,14,40,.92); border:1px solid var(--steel-hi); border-radius:3px;
'@ @'
    background:rgba(17,19,21,.92); border:1px solid var(--steel-hi); border-radius:3px;
'@

SubRx @'
  #root .modal{ background:radial-gradient(1200px 700px at 50% -10%, rgba(127,146,216,.12), transparent 60%), rgba(8,12,28,.95);
'@ @'
  #root .modal{ background:radial-gradient(1200px 700px at 50% -10%, rgba(170,164,152,.12), transparent 60%), rgba(17,19,21,.95);
'@

SubRx @'
    padding-bottom:12px; border-bottom:1px solid rgba(127,146,216,.22); }
'@ @'
    padding-bottom:12px; border-bottom:1px solid rgba(170,164,152,.22); }
'@

SubRx @'
  #root .row:hover{ background:rgba(127,146,216,.07); }
  #root .plist .row + .row{ border-top-color:rgba(127,146,216,.10); border-radius:0; }
  #root button{ border-radius:6px; border-color:rgba(127,146,216,.45); padding:9px 18px; min-height:38px; font-weight:600; letter-spacing:.08em; }
  #root button:hover:not(:disabled){ background:rgba(255,192,74,.10); box-shadow:0 0 0 1px rgba(255,192,74,.25) inset; }
'@ @'
  #root .row:hover{ background:rgba(170,164,152,.07); }
  #root .plist .row + .row{ border-top-color:rgba(170,164,152,.10); border-radius:0; }
  #root button{ border-radius:6px; border-color:rgba(170,164,152,.45); padding:9px 18px; min-height:38px; font-weight:600; letter-spacing:.08em; }
  #root button:hover:not(:disabled){ background:rgba(245,183,59,.10); box-shadow:0 0 0 1px rgba(245,183,59,.25) inset; }
'@

SubRx @'
  #root .deploy.ghost{ background:transparent; color:var(--amber); border-color:rgba(255,192,74,.55); box-shadow:none; }
  #root .deploy.ghost:hover:not(:disabled){ background:rgba(255,192,74,.10); color:var(--amber); }
  #root input:not([type=range]):not([type=checkbox]), #root textarea{ background:rgba(0,0,0,.35); border:1px solid rgba(127,146,216,.35); border-radius:6px;
'@ @'
  #root .deploy.ghost{ background:transparent; color:var(--amber); border-color:rgba(245,183,59,.55); box-shadow:none; }
  #root .deploy.ghost:hover:not(:disabled){ background:rgba(245,183,59,.10); color:var(--amber); }
  #root input:not([type=range]):not([type=checkbox]), #root textarea{ background:rgba(0,0,0,.35); border:1px solid rgba(170,164,152,.35); border-radius:6px;
'@

SubRx @'
  #root input:not([type=range]):focus, #root textarea:focus{ border-color:var(--amber); outline:none; box-shadow:0 0 0 2px rgba(255,192,74,.22); }
'@ @'
  #root input:not([type=range]):focus, #root textarea:focus{ border-color:var(--amber); outline:none; box-shadow:0 0 0 2px rgba(245,183,59,.22); }
'@

SubRx @'
  *::-webkit-scrollbar-thumb{ background:rgba(127,146,216,.35); border-radius:8px; }
  *::-webkit-scrollbar-thumb:hover{ background:rgba(127,146,216,.55); }
'@ @'
  *::-webkit-scrollbar-thumb{ background:rgba(170,164,152,.35); border-radius:8px; }
  *::-webkit-scrollbar-thumb:hover{ background:rgba(170,164,152,.55); }
'@

SubRx @'
  #root .ocwin{ border-radius:14px; border:1px solid rgba(127,146,216,.45);
    background:radial-gradient(900px 420px at 50% -12%, rgba(127,146,216,.16), transparent 62%), linear-gradient(180deg,var(--win-top),var(--win-bot));
'@ @'
  #root .ocwin{ border-radius:14px; border:1px solid rgba(170,164,152,.45);
    background:radial-gradient(900px 420px at 50% -12%, rgba(170,164,152,.16), transparent 62%), linear-gradient(180deg,var(--win-top),var(--win-bot));
'@

SubRx @'
  #root .tag:hover{ background:rgba(127,146,216,.10); }
'@ @'
  #root .tag:hover{ background:rgba(170,164,152,.10); }
'@

SubRx @'
  #root .cell, #root .vcell{ border-radius:8px; background:linear-gradient(180deg,rgba(127,146,216,.07) 0%,rgba(0,0,0,.34) 100%);
'@ @'
  #root .cell, #root .vcell{ border-radius:8px; background:linear-gradient(180deg,rgba(170,164,152,.07) 0%,rgba(0,0,0,.34) 100%);
'@

SubRx @'
  #root .cell:hover, #root .vcell:hover{ background:linear-gradient(180deg,rgba(255,192,74,.14) 0%,rgba(0,0,0,.30) 100%); transform:translateY(-2px);
'@ @'
  #root .cell:hover, #root .vcell:hover{ background:linear-gradient(180deg,rgba(245,183,59,.14) 0%,rgba(0,0,0,.30) 100%); transform:translateY(-2px);
'@

SubRx @'
  #root .vcell.on{ background:linear-gradient(180deg,rgba(255,192,74,.22) 0%,rgba(255,192,74,.08) 100%); }
'@ @'
  #root .vcell.on{ background:linear-gradient(180deg,rgba(245,183,59,.22) 0%,rgba(245,183,59,.08) 100%); }
'@

SubRx @'
    <div style="color:#ff5a4a;font-weight:800;letter-spacing:.14em;font-size:26px;text-align:center;margin:4px 0 8px">***EXPERIMENTAL***</div>
'@ @'
    <div style="color:#e5482f;font-weight:800;letter-spacing:.14em;font-size:26px;text-align:center;margin:4px 0 8px">***EXPERIMENTAL***</div>
'@

SubRx @'
  <div id="wirtsec_offer" style="border:1px solid var(--amber);padding:10px 12px;margin:14px 0 0;background:rgba(255,192,74,.05)">
'@ @'
  <div id="wirtsec_offer" style="border:1px solid var(--amber);padding:10px 12px;margin:14px 0 0;background:rgba(245,183,59,.05)">
'@

SubRx @'
    <select id="buildsel" style="flex:1;background:rgba(9,14,40,.92);color:var(--bone);border:1px solid var(--steel-hi);font-family:'Rubik',system-ui,sans-serif;font-size:12px;padding:6px"></select>
'@ @'
    <select id="buildsel" style="flex:1;background:rgba(17,19,21,.92);color:var(--bone);border:1px solid var(--steel-hi);font-family:'Rubik',system-ui,sans-serif;font-size:12px;padding:6px"></select>
'@

SubRx @'
      <div id="seasonfill" style="height:100%;width:0%;background:linear-gradient(90deg,#ffc04a,#ffc04a)"></div>
'@ @'
      <div id="seasonfill" style="height:100%;width:0%;background:linear-gradient(90deg,#f5b73b,#f5b73b)"></div>
'@

SubRx @'
        style="flex:1;background:rgba(9,14,40,.92);color:var(--bone);border:1px solid var(--steel-hi);font-family:'Rubik',system-ui,sans-serif;font-size:14px;padding:7px">
'@ @'
        style="flex:1;background:rgba(17,19,21,.92);color:var(--bone);border:1px solid var(--steel-hi);font-family:'Rubik',system-ui,sans-serif;font-size:14px;padding:7px">
'@

SubRx @'
            'color:var(--ash);opacity:.75;padding:0 0 3px 0;border-bottom:1px solid rgba(127,146,216,.28);margin-bottom:3px">'+
'@ @'
            'color:var(--ash);opacity:.75;padding:0 0 3px 0;border-bottom:1px solid rgba(170,164,152,.28);margin-bottom:3px">'+
'@

SubRx @'
             'width:'+Math.round(15*bb.sh)+'px;height:9px;background:#7f92d8;border-radius:2px"></span>'+
'@ @'
             'width:'+Math.round(15*bb.sh)+'px;height:9px;background:#4a5257;border-radius:2px"></span>'+
'@

SubRx @'
           ';border-radius:3px;padding:8px 11px;background:rgba(9,13,28,.82);display:flex;justify-content:space-between;gap:10px;align-items:center">'+
'@ @'
           ';border-radius:3px;padding:8px 11px;background:rgba(17,19,21,.82);display:flex;justify-content:space-between;gap:10px;align-items:center">'+
'@

SubRx @'
var HUDC={text:'#e8f0f6', dim:'#8a96a1', danger:'#ff5a4a', warn:'#ffc04a', extract:'#4de3d0', gain:'#7fc4a0', ally:'#bfe0ff',
  special:'#d08ce8', plate:'rgba(6,9,13,.78)', dangerPlate:'rgba(40,8,6,.84)', ink:INK};
'@ @'
// v23.82, UI REDESIGN ui2 (his #50 and #20, 2026-10-12): UIC is the graphite palette of the stylesheet (:root) as one JS table,
// key for key (--ui-panel is UIC.ui_panel, --r-rare is UIC.r_rare), so the canvas HUD and the DOM menus can never drift apart.
// HUDC keeps its names and its plates; its colours now come from UIC.
var UIC={ui_void:'#0b0c0d', ui_bg:'#111315', ui_panel:'#16191b', ui_raised:'#1e2225', ui_hover:'#272c30', ui_line:'#2e3337',
  ui_line_hi:'#4a5257', ui_scrim:'rgba(6,7,8,.82)', ui_paper:'#ebe5d6', ui_paper_2:'#ddd5c3', ui_paper_ink:'#17150f', ui_paper_ink_2:'#5a554a',
  tx_1:'#efe9dc', tx_2:'#aaa498', tx_3:'#7a766e', tx_off:'#55524c', acc:'#f5b73b', acc_ink:'#1a1205', acc_dim:'rgba(245,183,59,.16)',
  danger:'#e5482f', danger_bg:'rgba(60,12,8,.86)', warn:'#f5b73b', ok:'#76b97c', extract:'#47d8c6', ally:'#9cc7ff', armour:'#7fa6c9',
  r_common:'#9da3a8', r_uncommon:'#5fbf6a', r_rare:'#3f9de9', r_elite:'#a866e0', r_gold:'#f08f2e'};
var HUDC={text:UIC.tx_1, dim:UIC.tx_2, danger:UIC.danger, warn:UIC.warn, extract:UIC.extract, gain:UIC.ok, ally:UIC.ally,
  special:UIC.r_elite, plate:'rgba(6,9,13,.78)', dangerPlate:'rgba(40,8,6,.84)', ink:INK};
'@

SubRx @'
var VER='23.81';
'@ @'
var VER='23.82';
'@

$pat = "(?m)^  now:'v23\.81:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.82: Every menu now uses the new graphite palette with one amber accent instead of the old navy and periwinkle. Check 23.82 fails on v23.81',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
