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

# ONE TYPE SYSTEM FOR THE MENUS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    --hazard:var(--danger); --gain:var(--ok); --win-top:var(--ui-panel); --win-bot:var(--ui-bg);
'@ @'
    --hazard:var(--danger); --gain:var(--ok); --win-top:var(--ui-panel); --win-bot:var(--ui-bg);
    /* v23.85, UI REDESIGN ui3 (his #50): the menu type system. Condensed industrial caps for anything you scan (titles, tabs,
       buttons, labels, chips), a plain grotesque for anything you read. Barlow Condensed and Barlow are embedded by ui1 once he
       says yes to the download; until then the stacks land on Bahnschrift SemiCondensed and Bahnschrift, both local Windows fonts.
       The sizes are 1080p CSS px (applyMenuZoom grows them with the screen). Tracking never passes .12em; nothing is under 13px. */
    --f-cond:"Barlow Condensed","Bahnschrift SemiCondensed","Arial Narrow","Roboto Condensed",sans-serif;
    --f-body:"Barlow","Bahnschrift","Segoe UI",system-ui,sans-serif;
    --f-mono:"IBM Plex Mono",Consolas,ui-monospace,monospace;
    --t-display:800 72px/.9 var(--f-cond); --t-h1:700 40px/1 var(--f-cond); --t-h2:700 24px/1.1 var(--f-cond); --t-h3:600 18px/1.2 var(--f-cond);
    --t-label:600 13px/1.2 var(--f-cond); --t-button:700 16px/1 var(--f-cond); --t-lead:400 17px/1.45 var(--f-body); --t-body:400 15px/1.45 var(--f-body);
    --t-small:500 13px/1.4 var(--f-body); --t-num-xl:700 48px/1 var(--f-cond); --t-num:600 18px/1 var(--f-cond);
'@

SubRx @'
    background:var(--void); color:var(--bone); font-family:'Rubik',system-ui,sans-serif;
'@ @'
    background:var(--void); color:var(--bone); font-family:var(--f-body);
'@

SubRx @'
   #title .wordmark{ font-family:'Titan One','Rubik',sans-serif; font-size:64px; letter-spacing:.16em; line-height:1;
'@ @'
   #title .wordmark{ font-family:'Titan One','Rubik',sans-serif; font-size:64px; letter-spacing:.02em; line-height:1;
'@

SubRx @'
   #title .tstep{ font-size:11px; letter-spacing:.22em; color:var(--amber); font-weight:700; }
   #title .tcard .tbody{ font-size:12px; color:var(--ash); margin-top:6px; line-height:1.5; }
'@ @'
   #title .tstep{ font-size:13px; letter-spacing:.12em; color:var(--amber); font-weight:700; }
   #title .tcard .tbody{ font-size:13px; color:var(--ash); margin-top:6px; line-height:1.5; }
'@

SubRx @'
    letter-spacing:.42em; color:var(--amber); text-transform:uppercase; }
'@ @'
    letter-spacing:.12em; color:var(--amber); text-transform:uppercase; }
'@

SubRx @'
  #verlabel { font-family:'Rubik',system-ui,sans-serif; font-weight:700; letter-spacing:.18em; }
'@ @'
  #verlabel { font-family:var(--f-body); font-weight:700; letter-spacing:.12em; }
'@

SubRx @'
  input, textarea, select, option { font-family:'Rubik',system-ui,sans-serif; }
'@ @'
  input, textarea, select, option { font-family:var(--f-body); }
'@

SubRx @'
  .gx{ color:var(--ash); font-size:11px; }
'@ @'
  .gx{ color:var(--ash); font-size:13px; }
'@

SubRx @'
  .glab{ font-size:10.5px; letter-spacing:.18em; color:var(--ash); }
  .gnm{ font-family:'Rubik',system-ui,sans-serif; font-weight:700; font-size:13.5px; color:var(--coolant);
'@ @'
  .glab{ font-size:13px; letter-spacing:.12em; color:var(--ash); }
  .gnm{ font-family:var(--f-body); font-weight:700; font-size:13.5px; color:var(--coolant);
'@

SubRx @'
  .gsub{ font-size:10.5px; color:var(--ash); letter-spacing:.04em; }
  .gtag{ font-size:10.5px; letter-spacing:.14em; color:var(--coolant); flex:none; }
'@ @'
  .gsub{ font-size:13px; color:var(--ash); letter-spacing:.04em; }
  .gtag{ font-size:13px; letter-spacing:.14em; color:var(--coolant); flex:none; }
'@

SubRx @'
  .itag{ font-size:12.5px; letter-spacing:.12em; padding:2px 6px; border:1px solid;
'@ @'
  .itag{ font-size:13px; letter-spacing:.12em; padding:2px 6px; border:1px solid;
'@

SubRx @'
  .panel h2 { font-family:'Rubik',system-ui,sans-serif; font-size:11px; font-weight:700;
    letter-spacing:.28em; text-transform:uppercase; color:var(--ash);
'@ @'
  .panel h2 { font-family:var(--f-body); font-size:13px; font-weight:700;
    letter-spacing:.12em; text-transform:uppercase; color:var(--ash);
'@

SubRx @'
  display:flex; align-items:center; justify-content:center; font-size:11px; color:#111315; }
'@ @'
  display:flex; align-items:center; justify-content:center; font-size:13px; color:#111315; }
'@

SubRx @'
  display:flex; align-items:center; justify-content:center; font-size:12px;
'@ @'
  display:flex; align-items:center; justify-content:center; font-size:13px;
'@

SubRx @'
.avslab{ font-size:12.5px; letter-spacing:.16em; color:var(--ash); }
'@ @'
.avslab{ font-size:13px; letter-spacing:.12em; color:var(--ash); }
'@

SubRx @'
.cosname{margin-top:6px;font-size:12px;letter-spacing:1px}
.cosreq{margin-top:2px;font-size:11px;opacity:.65;letter-spacing:1px;text-transform:uppercase}
'@ @'
.cosname{margin-top:6px;font-size:13px;letter-spacing:1px}
.cosreq{margin-top:2px;font-size:13px;opacity:.65;letter-spacing:1px;text-transform:uppercase}
'@

SubRx @'
    font-size:11px; color:var(--bone); user-select:none; }
'@ @'
    font-size:13px; color:var(--bone); user-select:none; }
'@

SubRx @'
  .imenuhead b{ font-size:11.5px; letter-spacing:.02em; }
  .imenuhead em{ font-style:normal; color:var(--ash); font-size:11px; }
'@ @'
  .imenuhead b{ font-size:13px; letter-spacing:.02em; }
  .imenuhead em{ font-style:normal; color:var(--ash); font-size:13px; }
'@

SubRx @'
  .imenurow em{ font-style:normal; color:var(--ash); font-size:11px; letter-spacing:.06em; }
'@ @'
  .imenurow em{ font-style:normal; color:var(--ash); font-size:13px; letter-spacing:.06em; }
'@

SubRx @'
  .imenukeys button{ padding:2px 0; width:20px; font-size:11px; min-width:0; }
'@ @'
  .imenukeys button{ padding:2px 0; width:20px; font-size:13px; min-width:0; }
'@

SubRx @'
    align-items:baseline; gap:8px; font-size:12.5px; font-weight:700;
    letter-spacing:.15em; color:var(--bone); }
'@ @'
    align-items:baseline; gap:8px; font-size:13px; font-weight:700;
    letter-spacing:.12em; color:var(--bone); }
'@

SubRx @'
    font-size:13px; letter-spacing:.17em; color:var(--ash); text-transform:uppercase; }
'@ @'
    font-size:13px; letter-spacing:.12em; color:var(--ash); text-transform:uppercase; }
'@

SubRx @'
    text-align:center; font-size:13px; letter-spacing:.16em; color:var(--gain);
'@ @'
    text-align:center; font-size:13px; letter-spacing:.12em; color:var(--gain);
'@

SubRx @'
  .crlab{ font-size:12.5px; letter-spacing:.16em; color:#6a655a; margin:4px 0 7px; }   /* v19.80, seen on the 4K Mainframe screenshot (2026-10-08): PROGRESS, REWARDS and REQUIRED RESOURCES were 10.5px captions */
'@ @'
  .crlab{ font-size:13px; letter-spacing:.12em; color:#6a655a; margin:4px 0 7px; }   /* v19.80, seen on the 4K Mainframe screenshot (2026-10-08): PROGRESS, REWARDS and REQUIRED RESOURCES were 10.5px captions */
'@

SubRx @'
  .crewcell .cnt{ position:absolute; right:2px; bottom:0; font-size:11px;
'@ @'
  .crewcell .cnt{ position:absolute; right:2px; bottom:0; font-size:13px;
'@

SubRx @'
    font-size:12.5px; letter-spacing:.13em; color:var(--ash); text-transform:uppercase; }   /* v19.77, seen on a 4K menu text scan (2026-10-08): 10.5px, the smallest print in any menu, on a row half empty */
'@ @'
    font-size:13px; letter-spacing:.13em; color:var(--ash); text-transform:uppercase; }   /* v19.77, seen on a 4K menu text scan (2026-10-08): 10.5px, the smallest print in any menu, on a row half empty */
'@

SubRx @'
    background:var(--bone); color:#11161d; font-size:12.5px; font-weight:700;
'@ @'
    background:var(--bone); color:#11161d; font-size:13px; font-weight:700;
'@

SubRx @'
  button { font-family:'Rubik',system-ui,sans-serif; background:transparent;
'@ @'
  button { font-family:var(--f-body); background:transparent;
'@

SubRx @'
  .deploy { padding:12px; font-family:'Rubik',system-ui,sans-serif; font-weight:800;
    font-size:13px; letter-spacing:.3em; border:2px solid #ffe9b0; border-radius:4px;
'@ @'
  .deploy { padding:12px; font-family:var(--f-body); font-weight:800;
    font-size:13px; letter-spacing:.12em; border:2px solid #ffe9b0; border-radius:4px;
'@

SubRx @'
  .equipped .wn{ font-family:'Rubik',system-ui,sans-serif; font-weight:700; font-size:15px; color:var(--coolant); }
'@ @'
  .equipped .wn{ font-family:var(--f-body); font-weight:700; font-size:15px; color:var(--coolant); }
'@

SubRx @'
  .credits{ font-family:'Rubik',system-ui,sans-serif; font-weight:800; font-size:22px; color:var(--amber); text-align:right; }
  .credits small{ font-size:10.5px; color:var(--ash); letter-spacing:.28em; display:block; font-weight:400; }
'@ @'
  .credits{ font-family:var(--f-body); font-weight:800; font-size:22px; color:var(--amber); text-align:right; }
  .credits small{ font-size:13px; color:var(--ash); letter-spacing:.12em; display:block; font-weight:400; }
'@

SubRx @'
    font-family:'Rubik',system-ui,sans-serif; font-weight:800; font-size:32px; color:var(--amber); white-space:nowrap; text-align:right; }
'@ @'
    font-family:var(--f-body); font-weight:800; font-size:32px; color:var(--amber); white-space:nowrap; text-align:right; }
'@

SubRx @'
  #topright small{ font-size:14px; color:var(--ash); letter-spacing:.24em; font-weight:400; margin-left:7px; margin-right:20px; }
'@ @'
  #topright small{ font-size:14px; color:var(--ash); letter-spacing:.12em; font-weight:400; margin-left:7px; margin-right:20px; }
'@

SubRx @'
  .outcome h1{ font-family:'Rubik',system-ui,sans-serif; font-weight:800; font-size:30px;
    letter-spacing:.2em; margin:0; text-transform:uppercase; }
  .outcome .sub{ color:var(--ash); font-size:14px; letter-spacing:.18em; margin-bottom:12px; }
'@ @'
  .outcome h1{ font-family:var(--f-body); font-weight:800; font-size:30px;
    letter-spacing:.02em; margin:0; text-transform:uppercase; }
  .outcome .sub{ color:var(--ash); font-size:14px; letter-spacing:.12em; margin-bottom:12px; }
'@

SubRx @'
  textarea{ font-family:'Rubik',system-ui,sans-serif; font-size:14px; background:rgba(17,19,21,.92);
'@ @'
  textarea{ font-family:var(--f-body); font-size:14px; background:rgba(17,19,21,.92);
'@

SubRx @'
.pausebox h3{ font-family:'Rubik',system-ui,sans-serif; font-weight:800; font-size:25px;
    letter-spacing:.24em; margin:0; color:var(--amber); text-transform:uppercase; }
'@ @'
.pausebox h3{ font-family:var(--f-body); font-weight:800; font-size:25px;
    letter-spacing:.04em; margin:0; color:var(--amber); text-transform:uppercase; }
'@

SubRx @'
.modal h3{ font-family:'Rubik',system-ui,sans-serif; font-weight:800; font-size:30px;
    letter-spacing:.24em; margin:0 0 10px; color:var(--amber); text-transform:uppercase; }
  .modal h2{ font-family:'Rubik',system-ui,sans-serif; font-weight:800; font-size:19px;
    letter-spacing:.24em; margin:12px 0 6px; color:var(--amber); text-transform:uppercase; }
'@ @'
.modal h3{ font-family:var(--f-body); font-weight:800; font-size:30px;
    letter-spacing:.02em; margin:0 0 10px; color:var(--amber); text-transform:uppercase; }
  .modal h2{ font-family:var(--f-body); font-weight:800; font-size:19px;
    letter-spacing:.06em; margin:12px 0 6px; color:var(--amber); text-transform:uppercase; }
'@

SubRx @'
  #partymodal textarea{ font-size:12px; word-break:break-all; }   /* v16.91: the game font, as every text box (his v11.09 rule) */
'@ @'
  #partymodal textarea{ font-size:13px; word-break:break-all; }   /* v16.91: the game font, as every text box (his v11.09 rule) */
'@

SubRx @'
  #modemenu button.moderow{ min-width:440px; padding:9px 28px; font-size:12px; letter-spacing:.22em; }
'@ @'
  #modemenu button.moderow{ min-width:440px; padding:9px 28px; font-size:13px; letter-spacing:.12em; }
'@

SubRx @'
    font-size:10.5px; letter-spacing:.18em; color:var(--ash); text-transform:uppercase; }
  #modemsg{ font-size:12.5px; line-height:1.5; color:var(--hazard); max-width:640px; }
  #p2line{ font-size:12.5px; line-height:1.5; color:var(--amber); max-width:640px; }
'@ @'
    font-size:13px; letter-spacing:.12em; color:var(--ash); text-transform:uppercase; }
  #modemsg{ font-size:13px; line-height:1.5; color:var(--hazard); max-width:640px; }
  #p2line{ font-size:13px; line-height:1.5; color:var(--amber); max-width:640px; }
'@

SubRx @'
    padding:4px 0; font-size:11px; }
'@ @'
    padding:4px 0; font-size:13px; }
'@

SubRx @'
  pre.simpre{ font-family:'Rubik',system-ui,sans-serif; font-size:11px; color:var(--bone);
'@ @'
  pre.simpre{ font-family:var(--f-body); font-size:13px; color:var(--bone);
'@

SubRx @'
  .scard .sk{ font-size:11px; letter-spacing:.10em; text-transform:uppercase;
'@ @'
  .scard .sk{ font-size:13px; letter-spacing:.10em; text-transform:uppercase;
'@

SubRx @'
  .scard .ss{ font-size:12px; color:var(--ash); margin-top:2px; }
'@ @'
  .scard .ss{ font-size:13px; color:var(--ash); margin-top:2px; }
'@

SubRx @'
  #root .modal h3{ font-size:22px; letter-spacing:.22em; text-transform:uppercase; color:var(--amber); margin:0 0 14px;
'@ @'
  #root .modal h3{ font-size:22px; letter-spacing:.04em; text-transform:uppercase; color:var(--amber); margin:0 0 14px;
'@

SubRx @'
    box-shadow:0 8px 22px rgba(255,180,50,.22), 0 1px 0 rgba(255,255,255,.35) inset; letter-spacing:.24em; font-weight:800; }
'@ @'
    box-shadow:0 8px 22px rgba(255,180,50,.22), 0 1px 0 rgba(255,255,255,.35) inset; letter-spacing:.12em; font-weight:800; }
'@

SubRx @'
    font-weight:800; letter-spacing:.16em; box-shadow:0 8px 22px rgba(255,180,50,.22); }
'@ @'
    font-weight:800; letter-spacing:.12em; box-shadow:0 8px 22px rgba(255,180,50,.22); }
'@

SubRx @'
</style>
'@ @'
  /* v23.85, UI REDESIGN ui3: the type roles as classes (new markup uses these), and the scanned caps of every existing window in the
     condensed family: buttons, tabs, chips, window and panel titles, the run card headline, the loadout heads and the key bar. */
  .t-display{ font:var(--t-display); letter-spacing:.01em; text-transform:uppercase; }
  .t-h1{ font:var(--t-h1); letter-spacing:.02em; text-transform:uppercase; }
  .t-h2{ font:var(--t-h2); letter-spacing:.04em; text-transform:uppercase; }
  .t-h3{ font:var(--t-h3); letter-spacing:.06em; text-transform:uppercase; }
  .t-label{ font:var(--t-label); letter-spacing:.12em; text-transform:uppercase; }
  .t-button{ font:var(--t-button); letter-spacing:.08em; text-transform:uppercase; }
  .t-lead{ font:var(--t-lead); } .t-body{ font:var(--t-body); } .t-small{ font:var(--t-small); letter-spacing:.01em; }
  .t-num-xl{ font:var(--t-num-xl); font-variant-numeric:tabular-nums; } .t-num{ font:var(--t-num); font-variant-numeric:tabular-nums; }
  button, .deploy, .invtab, .tag, .modal h2, .modal h3, .pausebox h3, .outcome h1, .panel h2, .loslab, .lohead, .keybar, .credits, #topright{ font-family:var(--f-cond); }
  .credits, #topright, .vprice, .cnt{ font-variant-numeric:tabular-nums; }
</style>
'@

SubRx @'
  <div style="font-size:12.5px;color:var(--ash);letter-spacing:.2em;margin-top:16px">HOW DID THAT RUN FEEL</div>
'@ @'
  <div style="font-size:13px;color:var(--ash);letter-spacing:.12em;margin-top:16px">HOW DID THAT RUN FEEL</div>
'@

SubRx @'
  <div style="font-size:11px;color:var(--ash);margin-top:8px;max-width:774px;line-height:1.5;margin-bottom:26px">Copy report puts this raid, and every raid before it, on your clipboard. Paste it to Daniel and the game gets fixed from it.</div>
'@ @'
  <div style="font-size:13px;color:var(--ash);margin-top:8px;max-width:774px;line-height:1.5;margin-bottom:26px">Copy report puts this raid, and every raid before it, on your clipboard. Paste it to Daniel and the game gets fixed from it.</div>
'@

SubRx @'
    <div style="font-size:12px;letter-spacing:.14em;color:var(--steel-hi);font-weight:700;margin-bottom:6px">THE GAMBLE</div>
'@ @'
    <div style="font-size:13px;letter-spacing:.14em;color:var(--steel-hi);font-weight:700;margin-bottom:6px">THE GAMBLE</div>
'@

SubRx @'
    <div style="font-size:12px;letter-spacing:.14em;color:var(--amber);font-weight:700;margin-bottom:6px">LIMITED TIME OFFER</div>
'@ @'
    <div style="font-size:13px;letter-spacing:.14em;color:var(--amber);font-weight:700;margin-bottom:6px">LIMITED TIME OFFER</div>
'@

SubRx @'
    <div id="partylen" style="font-size:12px;letter-spacing:.14em;color:var(--amber);font-weight:700;margin-bottom:6px"></div>
'@ @'
    <div id="partylen" style="font-size:13px;letter-spacing:.14em;color:var(--amber);font-weight:700;margin-bottom:6px"></div>
'@

SubRx @'
  <div style="padding:0 0 7px"><button id="mapbtn" style="width:100%;font-size:11px">Map: GREYWATER DAM</button></div>
  <div style="padding:0 0 7px"><button id="tunebtn2" style="width:100%;font-size:11px">Tuning console (all the dials)</button></div>
  <div id="simprog" style="font-size:11px;color:var(--ash);padding:0 0 7px;display:none"></div>
'@ @'
  <div style="padding:0 0 7px"><button id="mapbtn" style="width:100%;font-size:13px">Map: GREYWATER DAM</button></div>
  <div style="padding:0 0 7px"><button id="tunebtn2" style="width:100%;font-size:13px">Tuning console (all the dials)</button></div>
  <div id="simprog" style="font-size:13px;color:var(--ash);padding:0 0 7px;display:none"></div>
'@

SubRx @'
    <select id="buildsel" style="flex:1;background:rgba(17,19,21,.92);color:var(--bone);border:1px solid var(--steel-hi);font-family:'Rubik',system-ui,sans-serif;font-size:12px;padding:6px"></select>
'@ @'
    <select id="buildsel" style="flex:1;background:rgba(17,19,21,.92);color:var(--bone);border:1px solid var(--steel-hi);font-family:var(--f-body);font-size:13px;padding:6px"></select>
'@

SubRx @'
    <div id="seasonhead" style="font-size:12px;letter-spacing:.14em;color:var(--amber);padding:0 0 6px"></div>
'@ @'
    <div id="seasonhead" style="font-size:13px;letter-spacing:.14em;color:var(--amber);padding:0 0 6px"></div>
'@

SubRx @'
        style="flex:1;background:rgba(17,19,21,.92);color:var(--bone);border:1px solid var(--steel-hi);font-family:'Rubik',system-ui,sans-serif;font-size:14px;padding:7px">
'@ @'
        style="flex:1;background:rgba(17,19,21,.92);color:var(--bone);border:1px solid var(--steel-hi);font-family:var(--f-body);font-size:14px;padding:7px">
'@

SubRx @'
    <div style="margin-top:9px;font-size:11px;letter-spacing:.34em;color:var(--ash)">
'@ @'
    <div style="margin-top:9px;font-size:13px;letter-spacing:.12em;color:var(--ash)">
'@

SubRx @'
    <div id="titleres" style="margin-top:7px;font-size:10.5px;letter-spacing:.18em;color:var(--steel-hi);
'@ @'
    <div id="titleres" style="margin-top:7px;font-size:13px;letter-spacing:.12em;color:var(--steel-hi);
'@

SubRx @'
      <button id="titlefs" style="padding:5px 14px;font-size:10.5px;letter-spacing:.18em">GO FULLSCREEN</button></div>
'@ @'
      <button id="titlefs" style="padding:5px 14px;font-size:13px;letter-spacing:.12em">GO FULLSCREEN</button></div>
'@

SubRx @'
    <div class="kbrow" style="margin-top:22px;font-size:11.5px;color:var(--ash);letter-spacing:.05em;line-height:2">
'@ @'
    <div class="kbrow" style="margin-top:22px;font-size:13px;color:var(--ash);letter-spacing:.05em;line-height:2">
'@

SubRx @'
    <div class="padrow" style="margin-top:22px;font-size:11.5px;color:var(--ash);letter-spacing:.05em;line-height:2">
'@ @'
    <div class="padrow" style="margin-top:22px;font-size:13px;color:var(--ash);letter-spacing:.05em;line-height:2">
'@

SubRx @'
        style="padding:13px 46px;font-size:15px;letter-spacing:.2em">1 PLAYER</button>
'@ @'
        style="padding:13px 46px;font-size:15px;letter-spacing:.12em">1 PLAYER</button>
'@

SubRx @'
      <div style="font-size:10.5px;letter-spacing:.2em;color:var(--amber)">SAVES</div>
'@ @'
      <div style="font-size:13px;letter-spacing:.12em;color:var(--amber)">SAVES</div>
'@

SubRx @'
      <div id="slotnote" style="margin-top:6px;font-size:10.5px;color:var(--ash);letter-spacing:.06em">Changing save reloads the game, which is why it leaves fullscreen.</div>
      <div id="fsback" style="display:none;margin-top:6px;font-size:11px;color:var(--amber);letter-spacing:.06em">You were in fullscreen. The reload dropped it, as it always does. GO FULLSCREEN is above.</div>
'@ @'
      <div id="slotnote" style="margin-top:6px;font-size:13px;color:var(--ash);letter-spacing:.06em">Changing save reloads the game, which is why it leaves fullscreen.</div>
      <div id="fsback" style="display:none;margin-top:6px;font-size:13px;color:var(--amber);letter-spacing:.06em">You were in fullscreen. The reload dropped it, as it always does. GO FULLSCREEN is above.</div>
'@

SubRx @'
          style="flex:1;background:rgba(0,0,0,.3);border:1px solid var(--steel-hi);border-radius:3px;color:var(--bone);padding:7px 10px;font-size:12px;letter-spacing:.08em"
'@ @'
          style="flex:1;background:rgba(0,0,0,.3);border:1px solid var(--steel-hi);border-radius:3px;color:var(--bone);padding:7px 10px;font-size:13px;letter-spacing:.08em"
'@

SubRx @'
      <div style="font-size:10.5px;letter-spacing:.2em;color:var(--amber)">RESTORE A CHARACTER</div>
'@ @'
      <div style="font-size:13px;letter-spacing:.12em;color:var(--amber)">RESTORE A CHARACTER</div>
'@

SubRx @'
        <span id="reswhat" style="font-size:11px;color:var(--ash)"></span>
'@ @'
        <span id="reswhat" style="font-size:13px;color:var(--ash)"></span>
'@

SubRx @'
        <span style="color:var(--hazard);font-size:11px">Type the word restore to replace the save you are playing with <b id="reswho"></b>.</span>
'@ @'
        <span style="color:var(--hazard);font-size:13px">Type the word restore to replace the save you are playing with <b id="reswho"></b>.</span>
'@

SubRx @'
          <input id="resword" autocomplete="off" spellcheck="false" style="flex:1;background:rgba(0,0,0,.3);border:1px solid var(--hazard);border-radius:3px;color:var(--bone);padding:5px 9px;font-size:12px">
'@ @'
          <input id="resword" autocomplete="off" spellcheck="false" style="flex:1;background:rgba(0,0,0,.3);border:1px solid var(--hazard);border-radius:3px;color:var(--bone);padding:5px 9px;font-size:13px">
'@

SubRx @'
    <span id="cfgcopied" style="font-size:11px;color:var(--coolant);display:none">Copied</span>
'@ @'
    <span id="cfgcopied" style="font-size:13px;color:var(--coolant);display:none">Copied</span>
'@

SubRx @'
      <div id="floordrop" data-drop="floor" style="display:none;margin:6px 12px 0;padding:8px 12px;border:1px dashed var(--amber);border-radius:6px;font-size:11px;color:var(--ash);align-items:center;gap:10px">
        <button id="floordropbtn" style="padding:5px 12px;font-size:11px;letter-spacing:.14em">DROP HERE</button>
'@ @'
      <div id="floordrop" data-drop="floor" style="display:none;margin:6px 12px 0;padding:8px 12px;border:1px dashed var(--amber);border-radius:6px;font-size:13px;color:var(--ash);align-items:center;gap:10px">
        <button id="floordropbtn" style="padding:5px 12px;font-size:13px;letter-spacing:.14em">DROP HERE</button>
'@

SubRx @'
  <div id="reportline" style="margin-top:8px;font-size:11px;padding:7px 10px;display:none;
'@ @'
  <div id="reportline" style="margin-top:8px;font-size:13px;padding:7px 10px;display:none;
'@

SubRx @'
        _p2l.style.cssText='font-size:11px;color:var(--ash);letter-spacing:.06em';
'@ @'
        _p2l.style.cssText='font-size:13px;color:var(--ash);letter-spacing:.06em';
'@

SubRx @'
           (me?' <span style="font-size:10px;letter-spacing:.14em">'+((inf&&inf.runs>0)?'CONTINUING':'NEW')+'</span>':(blk?' <span style="font-size:10px;letter-spacing:.14em;color:var(--ash)">IN USE BY PLAYER '+((typeof NETP2!=='undefined'&&NETP2)?'1':'2')+'</span>':''))+'</b>'+
           '<span style="color:var(--ash);font-size:11px">'+
'@ @'
           (me?' <span style="font-size:13px;letter-spacing:.12em">'+((inf&&inf.runs>0)?'CONTINUING':'NEW')+'</span>':(blk?' <span style="font-size:13px;letter-spacing:.12em;color:var(--ash)">IN USE BY PLAYER '+((typeof NETP2!=='undefined'&&NETP2)?'1':'2')+'</span>':''))+'</b>'+
           '<span style="color:var(--ash);font-size:13px">'+
'@

SubRx @'
           ((me||blk)?'':' <button data-del="'+key+'" class="deploy ghost" style="margin-left:8px;padding:2px 8px;font-size:10px">DELETE</button>')+
'@ @'
           ((me||blk)?'':' <button data-del="'+key+'" class="deploy ghost" style="margin-left:8px;padding:2px 8px;font-size:13px">DELETE</button>')+
'@

SubRx @'
         '<span style="color:var(--hazard);font-size:11px">Type the word delete to erase <b id="delwho"></b> forever.</span>'+
'@ @'
         '<span style="color:var(--hazard);font-size:13px">Type the word delete to erase <b id="delwho"></b> forever.</span>'+
'@

SubRx @'
         '<input id="delword" autocomplete="off" spellcheck="false" style="flex:1;background:rgba(0,0,0,.3);border:1px solid var(--hazard);border-radius:3px;color:var(--bone);padding:5px 9px;font-size:12px">'+
'@ @'
         '<input id="delword" autocomplete="off" spellcheck="false" style="flex:1;background:rgba(0,0,0,.3);border:1px solid var(--hazard);border-radius:3px;color:var(--bone);padding:5px 9px;font-size:13px">'+
'@

SubRx @'
var VER='23.84';
'@ @'
var VER='23.85';
'@

$pat = "(?m)^  now:'v23\.84:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.85: Menu text now uses one condensed caps face for titles and buttons and a plain face for reading, with tight letter spacing and nothing under 13px. Check 23.85 fails on v23.84',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
