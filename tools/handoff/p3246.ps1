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

# PRE-RAID PAGE REBUILT AS DESIGN A, MAP FIRST: AN ICE BLUE MAP, CONDITIONS BESIDE IT, KIT AND PACK AND ASCEND PLATE IN THE RIGHT COLUMN, ONE PRESS ON A PAD (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
<div class="modal" id="sectormodal">
  <h3>PRE-RAID</h3>
  <!-- v9.53, his instruction, verbatim: "this language is useless, delete it
       completely". The blurb that stood here since v8.76 is gone. The two sector
       cards below carry their own description and their own measured numbers,
       which is the part he reads. -->
  <div id="sectorlist"></div>
  <!-- v9.97, HIS NOTE: day or night is chosen here, on the way up. -->
  <div id="sectorcond" style="display:flex;align-items:center;gap:8px;margin-top:11px">
    <!-- v19.81, seen on a 4K menu text scan (2026-10-08): SURFACE and WEATHER were 11px beside 14px hints; 13 now -->
    <!-- v21.33, from the whole-game bug hunt of 2026-10-08 (W-B3), seen on the 4K lift picture: THE TWO CHOICE ROWS SHARE ONE COLUMN.
         SURFACE is a little narrower than WEATHER, so DAY started a few pixels left of SURPRISE ME under it. Both row names now take
         the same width, a little wider than WEATHER, so the first button of each row starts in the same place. -->
    <span style="font-size:13px;letter-spacing:.14em;color:var(--ash);min-width:5.8em">SURFACE</span>
    <button class="deploy ghost" id="condday" data-cond="day" style="flex:0 0 auto;padding:7px 18px">DAY</button>
    <button class="deploy ghost" id="condnight" data-cond="night" style="flex:0 0 auto;padding:7px 18px">NIGHT</button>
    <span id="condhint" style="font-size:14px;color:var(--ash)"></span>
  </div>
  <!-- v11.00, HIS NOTE 16: and the weather, chosen the same way, on the same
       page, at the same moment. SURPRISE ME is the old behaviour and stays the
       default; Partly Cloudy is only reachable through it, because it is the one
       state that exists to TURN into another. -->
  <div id="sectorwx" style="display:flex;align-items:center;gap:8px;margin-top:9px;flex-wrap:wrap">
    <span style="font-size:13px;letter-spacing:.14em;color:var(--ash);min-width:5.8em">WEATHER</span>
    <button class="deploy ghost wxb" data-wx="any" style="flex:0 0 auto;padding:7px 14px">SURPRISE ME</button>
    <button class="deploy ghost wxb" data-wx="clear" style="flex:0 0 auto;padding:7px 14px">CLEAR</button>
    <button class="deploy ghost wxb" data-wx="rain" style="flex:0 0 auto;padding:7px 14px">RAIN</button>
    <button class="deploy ghost wxb" data-wx="fog" style="flex:0 0 auto;padding:7px 14px">FOG</button>
    <button class="deploy ghost wxb" data-wx="blackout" style="flex:0 0 auto;padding:7px 14px">BLACKOUT</button>
    <button class="deploy ghost wxb" data-wx="storm" style="flex:0 0 auto;padding:7px 14px">STORM</button>
    <span id="wxhint" style="font-size:14px;color:var(--ash)"></span>
  </div>
  <!-- v19.25, seen on the 4K lift screenshot (2026-10-08): what he takes up, and the no-armour warning, were 11 px, the smallest text on
       the page and the last thing read before going up; 15 now, and the day and weather hints 14 -->
  <!-- v26.xx (kit1), HIS WORD (2026-10-14): the kit is part of the MAP SELECT screen, not a separate later card. One choice at a time, the last one kept in the save. -->
  <div id="sectorkitpick" style="display:flex;align-items:stretch;gap:8px;margin-top:9px;flex-wrap:wrap">
    <span style="font-size:13px;letter-spacing:.14em;color:var(--ash);min-width:5.8em;align-self:center">KIT</span>
    <button class="deploy ghost kitb" data-kit="mine"><span>MY LOADOUT</span><span class="kd">YOUR PACK</span></button>
    <button class="deploy ghost kitb" data-kit="free"><span>FREEBIE KIT</span><span class="kd">SCAV PISTOL &middot; 4 ITEMS</span></button>
    <button class="deploy ghost kitb" data-kit="rand"><span>RANDOM KIT</span><span class="kd">2 GUNS &middot; 1 EACH</span></button>
    <button class="deploy ghost kitb" data-kit="best"><span>BEST KIT</span><span class="kd">3 GUNS &middot; UP TO 3 EACH</span></button>
  </div>
  <!-- v28.xx (cw-preraid), HIS ORDER (2026-10-15): "On the pre-raid screen, quickly pick how much cash and how many of each wheel item to take, plus keys and guns", "Also how much ammo to take", "Slot a data core there too". The pack row: one chip per kind of thing in the stash, minus, plus and MAX, and the data core slot. -->
  <div id="sectorpack" style="margin-top:9px"></div>
  <div id="sectorkit" style="margin-top:11px;font-size:15px;line-height:1.5;padding:9px 12px;
       border:1px solid var(--steel-hi);border-radius:3px"></div>

  <div style="display:flex;gap:8px;margin-top:8px">
    <button class="deploy" id="sectordeploy" style="flex:1.4">ASCEND TO THIS SECTOR</button>
    <button id="closesector" style="padding:8px 22px">CLOSE</button>
  </div>
</div>

'@ @'
<div class="modal" id="sectormodal">
  <!-- v32.45 (cw-preraid-a), HIS PICK (2026-10-19), verbatim: "por-raid redesing -- i pick A, but give the map some different color so it breaks up the monotny/overwhelmingness of the screen". Design A, MAP FIRST: the map takes the left two thirds with the conditions list beside it, the right column holds the kit, the pack, the going-up chips and the ascend plate. -->
  <style>
  #sectormodal{ --srseat:#ffb02e; text-transform:lowercase; }
  #root #sectormodal h3{ align-items:center; gap:16px; padding-bottom:8px; margin-bottom:10px; }
  #sectormodal .srseat{ display:inline-flex; align-items:center; gap:10px; height:40px; padding:0 16px; border:1px solid var(--ui-line-hi); background:var(--ui-raised); border-radius:4px; font:600 20px var(--f-cond); letter-spacing:.02em; }
  #sectormodal .srseat i{ width:12px; height:12px; border-radius:50%; }
  #srbody{ flex:1 1 auto; min-height:0; display:flex; gap:16px; }
  #srmap{ flex:2 1 0; min-width:0; min-height:0; display:grid; grid-template-columns:minmax(0,1fr) 200px; grid-template-rows:40px minmax(0,1fr); column-gap:16px; padding:0 12px 10px; background:var(--ui-panel); border:1px solid var(--ui-line); border-radius:4px; }
  #root #sectormodal #sectorlist, #root #sectormodal .sectorpick{ display:contents !important; }
  #sectormodal .srmh{ grid-column:1/-1; grid-row:1; display:flex; align-items:center; gap:16px; margin:0 -12px; padding:0 12px; border-bottom:1px solid var(--ui-line); }
  #sectormodal .srmh b{ font:700 32px/1 var(--f-cond); letter-spacing:.03em; color:var(--tx-1); }
  #sectormodal .srtag{ display:inline-flex; align-items:center; gap:8px; height:36px; padding:0 14px 0 10px; border:1px solid var(--acc); background:rgba(230,255,61,.16); border-radius:4px; font:600 20px var(--f-cond); color:var(--tx-1); }
  #sectormodal .srtag svg{ width:20px; height:20px; fill:none; stroke:var(--acc); stroke-width:3; stroke-linecap:round; stroke-linejoin:round; }
  #sectormodal .srst{ margin-left:auto; font:500 20px var(--f-cond); letter-spacing:.02em; color:var(--tx-2); white-space:nowrap; }
  #sectormodal .srcv{ grid-column:1; grid-row:2; position:relative; min-height:0; margin-top:12px; background:#0c1a28; border:1px solid #1d3a55; border-radius:4px; overflow:hidden; }
  #sectormodal .srcv canvas{ position:absolute; inset:0; width:100% !important; height:100% !important; object-fit:contain; display:block; border:0 !important; background:#0c1a28 !important; }
  #srside{ grid-column:2; grid-row:2; min-height:0; margin-top:12px; display:flex; flex-direction:column; justify-content:space-between; }
  #sectormodal .srcap{ display:flex; justify-content:space-between; margin:0 0 6px; font:600 16px var(--f-cond); letter-spacing:.12em; color:var(--tx-2); }
  #sectormodal .srstack{ display:flex; flex-direction:column; gap:3px; margin-bottom:10px; }
  #root #sectormodal .srchip{ width:100%; height:36px; display:flex; align-items:center; gap:10px; padding:0 10px; background:var(--ui-raised); border:1px solid var(--ui-line-hi); border-radius:4px; color:var(--tx-1); font:600 20px var(--f-cond); letter-spacing:.02em; text-align:left; text-transform:lowercase; }
  #sectormodal .srchip em{ margin-left:auto; font:500 16px var(--f-body); font-style:normal; color:var(--tx-2); }
  #root #sectormodal .srchip.on, #root #sectormodal .kitb.on{ background:rgba(230,255,61,.16); border-color:var(--acc); box-shadow:inset 0 0 0 1px var(--acc); color:var(--tx-1); }
  #root #sectormodal .srchip:disabled{ opacity:1; color:var(--tx-2) !important; }
  #root #sectormodal .srchip.on:disabled{ color:var(--tx-1) !important; border-color:var(--acc) !important; }
  #sectormodal .srrd{ width:22px; height:22px; flex:none; border-radius:50%; border:2px solid #55524c; position:relative; }
  #sectormodal .on > .srrd{ background:var(--acc); border-color:var(--acc); }
  #sectormodal .on > .srrd::after{ content:''; position:absolute; left:6px; top:2px; width:5px; height:10px; border:solid #0b0c0d; border-width:0 3px 3px 0; transform:rotate(45deg); }
  #sectormodal .srwxh{ min-height:20px; margin:-6px 0 0; font:400 16px var(--f-body); color:var(--tx-2); }
  #sectormodal .srkey{ border-top:1px solid var(--ui-line); padding-top:10px; }
  #sectormodal .srkr{ height:34px; display:flex; align-items:center; gap:12px; font:600 20px var(--f-cond); }
  #sectormodal .srkr svg{ width:28px; height:28px; flex:none; }
  #sectormodal .srkr em{ margin-left:auto; font:500 16px var(--f-body); font-style:normal; color:var(--tx-2); }
  #srkitcol{ flex:1 1 0; min-width:0; max-width:400px; min-height:0; display:flex; flex-direction:column; gap:10px; padding:10px 12px; background:var(--ui-panel); border:1px solid var(--ui-line); border-radius:4px; }
  #sectorkitpick{ flex:none; display:grid; grid-template-columns:1fr 1fr; gap:8px; margin:0 !important; }
  #root #sectormodal .kitb{ height:52px; display:grid; grid-template-columns:22px minmax(0,1fr); column-gap:10px; align-content:center; align-items:center; padding:0 12px; background:var(--ui-raised); border:1px solid var(--ui-line-hi); border-radius:4px; color:var(--tx-1); text-align:left; white-space:nowrap; overflow:hidden; }
  #sectormodal .kitb .srrd{ grid-row:1/3; }
  #sectormodal .kitb span{ font:600 20px/1.1 var(--f-cond); }
  #root #sectormodal .kitb .kd{ font:400 16px/1.1 var(--f-body); letter-spacing:0; opacity:1; color:var(--tx-2); }
  #sectorpack{ flex:1 1 auto; min-height:150px; display:flex; flex-direction:column; margin:0 !important; }
  #sectormodal .srph{ flex:none; display:flex; align-items:center; gap:10px; height:40px; }
  #sectormodal .srph b{ font:700 20px var(--f-cond); letter-spacing:.04em; }
  #sectormodal .srph span{ font:500 16px var(--f-body); color:var(--tx-2); }
  #sectormodal .srph i{ flex:1; }
  #root #sectormodal .pkb{ height:36px; min-width:0; padding:0 14px; background:var(--ui-raised); border:1px solid var(--ui-line-hi); border-radius:4px; color:var(--tx-1); font:600 20px var(--f-cond); }
  #sectormodal .srplist{ flex:1 1 auto; min-height:0; overflow-y:auto; }
  #sectormodal .srprow{ height:38px; display:flex; align-items:center; gap:10px; border-bottom:1px solid var(--ui-line); white-space:nowrap; }
  #sectormodal .srprow.g{ margin-top:6px; }
  #sectormodal .srprow .rar{ width:4px; height:24px; flex:none; }
  #sectormodal .srprow svg{ width:24px; height:24px; flex:none; fill:none; stroke:var(--tx-2); stroke-width:1.8; stroke-linecap:round; stroke-linejoin:round; }
  #sectormodal .srprow .nm{ flex:1; min-width:0; overflow:hidden; text-overflow:ellipsis; font:600 20px var(--f-cond); color:var(--tx-2); }
  #sectormodal .srprow.on .nm{ color:var(--tx-1); }
  #sectormodal .srprow .held{ min-width:26px; font:500 16px var(--f-body); color:var(--tx-2); }
  #sectormodal .srprow .st{ display:flex; align-items:center; }
  #root #sectormodal .srprow .st .srm, #root #sectormodal .srprow .st button{ width:34px; height:32px; min-width:0; padding:0; display:grid; place-items:center; background:var(--ui-raised); border:1px solid var(--ui-line-hi); border-radius:0; color:var(--tx-1); font:700 20px var(--f-cond); cursor:pointer; }
  #sectormodal .srprow .st b{ width:30px; text-align:center; font:700 20px var(--f-cond); cursor:pointer; }
  #root #sectormodal .srprow .dis{ color:var(--tx-3); }
  #root #sectormodal button.srcore{ width:100%; height:40px; margin-top:6px; padding:0; background:none; border:0; border-bottom:1px solid var(--ui-line); border-radius:0; justify-content:flex-start; color:var(--tx-1); font:600 20px var(--f-cond); }
  #sectormodal .srcore .cb{ width:26px; height:26px; border:2px solid #55524c; border-radius:4px; margin:0 4px 0 auto; position:relative; }
  #sectormodal .srcore.on .cb{ background:var(--acc); border-color:var(--acc); }
  #sectormodal .srcore.on .cb::after{ content:''; position:absolute; left:7px; top:2px; width:6px; height:12px; border:solid #0b0c0d; border-width:0 3px 3px 0; transform:rotate(45deg); }
  #sectormodal .srcore .held{ margin-left:auto; }
  #root #sectormodal button.srcore:disabled{ color:var(--tx-3) !important; border-bottom:1px solid var(--ui-line) !important; }
  #sectorkit{ flex:none; margin:0 !important; padding:0 !important; border:0 !important; }
  #sectormodal .srsum{ display:flex; flex-wrap:wrap; gap:6px; }
  #sectormodal .gc{ flex:1 1 0; min-width:0; height:36px; display:flex; align-items:center; gap:8px; padding:0 12px; background:var(--ui-raised); border:1px solid var(--ui-line-hi); border-radius:4px; white-space:nowrap; overflow:hidden; }
  #sectormodal .gc i{ font:400 16px var(--f-body); font-style:normal; color:var(--tx-2); }
  #sectormodal .gc b{ font:700 20px var(--f-cond); }
  #sectormodal .wn{ flex:1 1 100%; height:36px; display:flex; align-items:center; gap:10px; padding:0 12px; border:1px solid var(--warn); background:rgba(245,183,59,.12); border-radius:4px; color:var(--warn); white-space:nowrap; overflow:hidden; }
  #sectormodal .wn svg{ width:24px; height:24px; flex:none; fill:none; stroke:var(--warn); stroke-width:1.8; stroke-linecap:round; stroke-linejoin:round; }
  #sectormodal .wn b{ font:700 20px var(--f-cond); }
  #sectormodal .wn i{ margin-left:auto; font:400 16px var(--f-body); font-style:normal; color:var(--tx-2); }
  #sectormodal .srplate{ flex:none; height:72px; padding:3px; background:var(--srseat); border-radius:6px; }
  #root #sectormodal #sectordeploy{ width:100%; height:100%; display:flex; align-items:center; justify-content:space-between; padding:0 24px 0 30px; background:var(--acc); color:var(--acc-ink); border:0; border-radius:4px; font:800 52px/1 var(--f-cond); letter-spacing:.05em; }
  #root #sectormodal #sectordeploy:hover{ background:var(--acc-hover); }
  #sectormodal .srsr{ position:absolute; width:1px; height:1px; overflow:hidden; clip:rect(0 0 0 0); white-space:nowrap; }
  #sectormodal .srplk{ display:flex; align-items:center; gap:8px; }
  #srhints{ flex:none; height:32px; display:flex; align-items:center; gap:24px; margin-top:4px; border-top:1px solid var(--ui-line); font:500 20px var(--f-cond); color:var(--tx-2); }
  #srhints .srk, #srhints .srp{ display:flex; align-items:center; gap:24px; }
  #srhints .hn{ display:inline-flex; align-items:center; gap:8px; white-space:nowrap; }
  #srhints .sv{ margin-left:auto; padding-right:56px; font:400 16px var(--f-body); }
  #sectormodal .kc{ display:inline-flex; align-items:center; justify-content:center; min-width:34px; height:30px; padding:0 10px; border:1px solid #55524c; border-bottom-width:3px; border-radius:4px; background:var(--ui-hover); font:600 16px var(--f-cond); font-style:normal; letter-spacing:.04em; color:var(--tx-1); }
  #sectormodal .pg{ display:inline-grid; place-items:center; min-width:30px; height:30px; padding:0 8px; border-radius:15px; border:2px solid var(--tx-2); font:700 16px var(--f-cond); font-style:normal; color:var(--tx-1); }
  #sectormodal .dk{ background:rgba(11,12,13,.1); border-color:#0b0c0d; color:#0b0c0d; }
  body:not(.padon) #sectormodal .srp{ display:none !important; }
  body.padon #sectormodal .srk{ display:none !important; }
  #root #sectormodal .padfocus{ outline:3px solid var(--srseat) !important; outline-offset:2px; }
  body:has(#sectormodal.on) #hubtoast{ display:none !important; }
  </style>
  <h3>PRE-RAID <span id="srseat"></span></h3>
  <div id="srbody">
    <div id="srmap">
      <div id="sectorlist"></div>
      <div id="srside">
        <div>
          <div class="srcap"><span>CONDITIONS</span><span id="srhost"></span></div>
          <div class="srcap">SURFACE</div>
          <div id="sectorcond" class="srstack">
            <button class="srchip" id="condday" data-cond="day" data-pan="c"><i class="srrd"></i>DAY</button>
            <button class="srchip" id="condnight" data-cond="night" data-pan="c"><i class="srrd"></i>NIGHT<em id="srnx"></em></button>
          </div>
          <div class="srcap">WEATHER</div>
          <div id="sectorwx" class="srstack">
            <button class="srchip wxb" data-wx="any" data-pan="c"><i class="srrd"></i>SURPRISE ME<em></em></button>
            <button class="srchip wxb" data-wx="clear" data-pan="c"><i class="srrd"></i>CLEAR<em></em></button>
            <button class="srchip wxb" data-wx="rain" data-pan="c"><i class="srrd"></i>RAIN<em></em></button>
            <button class="srchip wxb" data-wx="fog" data-pan="c"><i class="srrd"></i>FOG<em></em></button>
            <button class="srchip wxb" data-wx="blackout" data-pan="c"><i class="srrd"></i>BLACKOUT<em></em></button>
            <button class="srchip wxb" data-wx="storm" data-pan="c"><i class="srrd"></i>STORM<em></em></button>
          </div>
          <div class="srwxh" id="wxhint" style="font-size:16px"></div>
          <span id="condhint" style="display:none;font-size:14px"></span>
        </div>
      </div>
    </div>
    <div id="srkitcol">
      <div>
        <div class="srcap">KIT</div>
        <div id="sectorkitpick">
          <button class="deploy ghost kitb" data-kit="mine" data-pan="k"><i class="srrd"></i><span>MY LOADOUT</span><span class="kd">YOUR PACK</span></button>
          <button class="deploy ghost kitb" data-kit="free" data-pan="k"><i class="srrd"></i><span>FREEBIE KIT</span><span class="kd">SCAV PISTOL &middot; 4 ITEMS</span></button>
          <button class="deploy ghost kitb" data-kit="rand" data-pan="k"><i class="srrd"></i><span>RANDOM KIT</span><span class="kd">2 GUNS &middot; 1 EACH</span></button>
          <button class="deploy ghost kitb" data-kit="best" data-pan="k"><i class="srrd"></i><span>BEST KIT</span><span class="kd">3 GUNS &middot; UP TO 3 EACH</span></button>
        </div>
      </div>
      <div id="sectorpack"></div>
      <div id="sectorkit" style="font-size:15px"></div>
      <div class="srplate"><button class="deploy" id="sectordeploy" data-pan="a"><span>ASCEND<span class="srsr"> TO THIS SECTOR</span></span><span class="srplk"><span class="srk"><i class="kc dk">ENTER</i></span><span class="srp"><i class="pg dk" id="srplg">A</i></span></span></button></div>
    </div>
  </div>
  <div id="srhints"></div>
  <div><button id="closesector" style="padding:8px 22px">CLOSE</button></div>
</div>
'@

SubRx @'
function sectorPreviewDraw(cv,M){
  // v20.95 (V-B4): a map canvas made sharp (sectorPrevSharp below) is drawn in its page size and scaled up into its larger store
  var c=cv.getContext('2d'), _sk=!!(cv._k&&cv._lw&&cv._lh), W0=_sk?cv._lw:cv.width, H0=_sk?cv._lh:cv.height, sc=Math.min(W0/M.w,H0/M.h), ox=(W0-M.w*sc)/2, oy=(H0-M.h*sc)/2, i, z, b, e, n=0;
  if(!c) return 0;
  // v22.16, from the whole-game bug hunt of 2026-10-08 (K27): THE RINGS WHERE THE RAID PUTS THEM. The raid moves every extraction
  // ring that touches a building out into the open (extractsOutside), and this map drew them where the map file has them, so ring
  // C on COLD STORAGE sat inside the dock bays and five rings on THE COLD MILE were off, and the zone names kept clear of the wrong
  // spots. The same move is made here from the same buildings and the sector size, with no seeded draw, so the lift map and the
  // raid map agree.
  var EX=(M.extracts&&M.buildings)?extractsOutside(M.extracts,M.buildings,M.w,M.h):(M.extracts||null);
  c.setTransform(1,0,0,1,0,0); c.clearRect(0,0,cv.width,cv.height);
  if(_sk) c.setTransform(cv.width/W0,0,0,cv.height/H0,0,0);
  c.fillStyle=(M.ground&&M.ground.day)||'#55647A'; c.fillRect(ox,oy,M.w*sc,M.h*sc);
  if(M.zones) for(i=0;i<M.zones.length;i++){ z=M.zones[i]; if(typeof z.x!=='number') continue;
    c.fillStyle='rgba(255,255,255,'+(0.03+0.03*((i%3)))+')'; c.fillRect(ox+z.x*sc,oy+z.y*sc,z.w*sc,z.h*sc);
    c.strokeStyle='rgba(127,146,216,.35)'; c.lineWidth=1; c.strokeRect(ox+z.x*sc+.5,oy+z.y*sc+.5,z.w*sc-1,z.h*sc-1); n++; }
  if(M.buildings) for(i=0;i<M.buildings.length;i++){ b=M.buildings[i]; if(!b||typeof b.x!=='number'||!b.w) continue; c.fillStyle='rgba(20,24,34,.75)'; c.fillRect(ox+b.x*sc,oy+b.y*sc,b.w*sc,b.h*sc); n++; }
  if(M.landmarks) for(i=0;i<M.landmarks.length;i++){ b=M.landmarks[i]; if(!b||typeof b.x!=='number'||!b.w) continue; c.strokeStyle='rgba(255,192,74,.55)'; c.lineWidth=1; c.strokeRect(ox+b.x*sc+.5,oy+b.y*sc+.5,b.w*sc-1,b.h*sc-1); n++; }
  if(M.zones) for(i=0;i<M.zones.length;i++){ z=M.zones[i]; if(typeof z.x!=='number'||!z.name) continue;
    // v18.69, seen on the lift screenshot (2026-10-07): every zone name was 11 pixels whatever its zone, so on The Cold Mile
    // HOARFROST ROW, FROST YARD and BLAST LINE printed into each other. A name now shrinks to fit its zone (down to 8 pixels) and
    // breaks onto two lines at a space if it still does not fit.
    (function(){
      var zw=Math.max(10,z.w*sc-6), fs=11, cx=ox+(z.x+z.w/2)*sc, cy=oy+(z.y+z.h/2)*sc, nm=TX(String(z.name)), ws, k, a1, a2, best=-1, bw=1e9, w1, w2;   // v21.84: his name for the zone is what shrinks and splits
      c.fillStyle='rgba(205,214,221,.85)'; c.textAlign='center';
      // v19.97, seen on the 4K lift screenshot (2026-10-08): a zone name was printed through an extraction ring (THE LONG DOCK, BLAST
      // LINE). A name that would touch a ring moves to the nearest clear place just above or below it, inside its own zone.
      function hits(y,hh,hw){ var j,e2,rx,ry,r2,nx,ny; if(!EX) return false; for(j=0;j<EX.length;j++){ e2=EX[j]; if(!e2) continue; rx=ox+e2.x*sc; ry=oy+e2.y*sc; r2=Math.max(4,78*sc)+2; nx=Math.max(cx-hw,Math.min(rx,cx+hw)); ny=Math.max(y-hh,Math.min(ry,y+hh)); if((nx-rx)*(nx-rx)+(ny-ry)*(ny-ry)<r2*r2) return true; } return false; }
      function place(hh,hw){ var top=oy+z.y*sc+hh+1, bot=oy+(z.y+z.h)*sc-hh-1, cand=[cy], j, e2, ry, r2, k, y, best=null; if(EX) for(j=0;j<EX.length;j++){ e2=EX[j]; if(!e2) continue; ry=oy+e2.y*sc; r2=Math.max(4,78*sc)+2; cand.push(ry-r2-hh-1,ry+r2+hh+1); } for(k=0;k<cand.length;k++){ y=cand[k]; if(y<top||y>bot||hits(y,hh,hw)) continue; if(best===null||Math.abs(y-cy)<Math.abs(best-cy)) best=y; } return best===null?cy:best; }
      c.font='bold '+fs+'px "Barlow Condensed","Bahnschrift SemiCondensed","Arial Narrow",sans-serif';
      while(fs>8&&c.measureText(nm).width>zw){ fs--; c.font='bold '+fs+'px "Barlow Condensed","Bahnschrift SemiCondensed","Arial Narrow",sans-serif'; }
      if(c.measureText(nm).width>zw&&nm.indexOf(' ')>0){
        ws=nm.split(' ');
        for(k=1;k<ws.length;k++){ w1=txRawW(c,ws.slice(0,k).join(' ')); w2=txRawW(c,ws.slice(k).join(' ')); if(Math.max(w1,w2)<bw){ bw=Math.max(w1,w2); best=k; } }
        a1=ws.slice(0,best).join(' '); a2=ws.slice(best).join(' ');
        cy=place(fs+1,Math.max(c.measureText(a1).width,c.measureText(a2).width)/2+2); c.fillText(a1,cx,cy-fs*0.5+3); c.fillText(a2,cx,cy+fs*0.5+4);
        return;
      }
      cy=place(fs*0.5+1,c.measureText(nm).width/2+2); c.fillText(nm,cx,cy+3);
    })(); }
  if(EX) for(i=0;i<EX.length;i++){ e=EX[i]; if(!e) continue;
    c.strokeStyle='#4de3d0'; c.lineWidth=2; c.beginPath(); c.arc(ox+e.x*sc,oy+e.y*sc,Math.max(4,78*sc),0,6.2832); c.stroke();
    c.fillStyle='rgba(77,227,208,.25)'; c.fill(); n++; }
  c.textAlign='left';
  c.setTransform(1,0,0,1,0,0);
  return n;
}

'@ @'
function sectorPreviewDraw(cv,M){
  // v32.45 (cw-preraid-a), HIS WORDS (2026-10-19): "give the map some different color so it breaks up the monotny/overwhelmingness of the screen". The map is ICE BLUE: ground #0c1a28, each zone a slightly different blue,
  // buildings darker with a light edge, names 20 px (shrinking to 12 to fit), exits teal and keyed rooms purple. Everything is still read from the sector's own data, never a made-up shape.
  var c=cv.getContext('2d'), _sk=!!(cv._k&&cv._lw&&cv._lh), W0=_sk?cv._lw:cv.width, H0=_sk?cv._lh:cv.height, sc=Math.min(W0/M.w,H0/M.h), ox=(W0-M.w*sc)/2, oy=(H0-M.h*sc)/2, i, z, b, e, n=0, FF='"Barlow Condensed","Bahnschrift SemiCondensed","Arial Narrow",sans-serif', ZF=['#14304a','#152e3f','#182c47','#172a40','#112538'], R=Math.max(12,78*sc*1.2), L, a1, a2;
  if(!c) return 0;
  var EX=(M.extracts&&M.buildings)?extractsOutside(M.extracts,M.buildings,M.w,M.h):(M.extracts||null);   // v22.16 (K27): the rings where the raid puts them
  c.setTransform(1,0,0,1,0,0); c.clearRect(0,0,cv.width,cv.height);
  if(_sk) c.setTransform(cv.width/W0,0,0,cv.height/H0,0,0);
  function put(s,x,y){ c.lineJoin='round'; c.lineWidth=4; c.strokeStyle='rgba(8,18,28,.9)'; c.strokeText(String(s).toLowerCase(),x,y); c.fillText(s,x,y); }
  c.fillStyle='#0c1a28'; c.fillRect(ox,oy,M.w*sc,M.h*sc);
  c.strokeStyle='#2f5e86'; c.lineWidth=2; c.setLineDash([12,7]); c.strokeRect(ox+4,oy+4,M.w*sc-8,M.h*sc-8); c.setLineDash([]);
  if(M.zones) for(i=0;i<M.zones.length;i++){ z=M.zones[i]; if(typeof z.x!=='number') continue;
    c.fillStyle=ZF[i%ZF.length]; c.fillRect(ox+z.x*sc,oy+z.y*sc,z.w*sc,z.h*sc);
    c.strokeStyle='#2f5e86'; c.lineWidth=1; c.strokeRect(ox+z.x*sc+.5,oy+z.y*sc+.5,z.w*sc-1,z.h*sc-1); n++; }
  if(M.landmarks) for(i=0;i<M.landmarks.length;i++){ b=M.landmarks[i]; if(!b||typeof b.x!=='number'||!b.w) continue; c.strokeStyle='rgba(111,163,204,.35)'; c.lineWidth=1; c.strokeRect(ox+b.x*sc+.5,oy+b.y*sc+.5,b.w*sc-1,b.h*sc-1); n++; }
  if(M.buildings) for(i=0;i<M.buildings.length;i++){ b=M.buildings[i]; if(!b||typeof b.x!=='number'||!b.w) continue; c.fillStyle='#0a1622'; c.fillRect(ox+b.x*sc,oy+b.y*sc,b.w*sc,b.h*sc); c.strokeStyle='#4a7aa3'; c.lineWidth=1.5; c.strokeRect(ox+b.x*sc+.75,oy+b.y*sc+.75,b.w*sc-1.5,b.h*sc-1.5); n++; }
  if(M.locked) for(i=0;i<M.locked.length;i++){ b=M.locked[i]; if(!b||typeof b.x!=='number'||!b.w) continue;
    c.fillStyle='#1a1228'; c.fillRect(ox+b.x*sc,oy+b.y*sc,b.w*sc,b.h*sc);
    c.strokeStyle='#a866e0'; c.lineWidth=2; c.setLineDash([7,4]); c.strokeRect(ox+b.x*sc+1,oy+b.y*sc+1,b.w*sc-2,b.h*sc-2); c.setLineDash([]);
    c.font='600 16px '+FF; c.textAlign='center'; c.fillStyle='#dcc3f4';
    a1=TX(String(b.name||'')); L=a1.split(' '); a2=L.length>1?L.slice(1).join(' '):''; a1=L[0];
    put(a1,ox+(b.x+b.w/2)*sc,oy+(b.y+b.h/2)*sc-(a2?2:-6)); if(a2) put(a2,ox+(b.x+b.w/2)*sc,oy+(b.y+b.h/2)*sc+16); n++; }
  if(M.zones) for(i=0;i<M.zones.length;i++){ z=M.zones[i]; if(typeof z.x!=='number'||!z.name) continue;
    // v18.69: a name shrinks to fit its zone and breaks onto two lines at a space; v19.97: and keeps clear of an extraction ring
    (function(){
      var zw=Math.max(10,z.w*sc-6), fs=20, cx=ox+(z.x+z.w/2)*sc, cy=oy+(z.y+z.h/2)*sc, nm=TX(String(z.name)), ws, k, a1, a2, best=-1, bw=1e9, w1, w2;
      c.fillStyle='#e6f1fb'; c.textAlign='center';
      function hits(y,hh,hw){ var j,e2,rx,ry,r2,nx,ny; if(!EX) return false; for(j=0;j<EX.length;j++){ e2=EX[j]; if(!e2) continue; rx=ox+e2.x*sc; ry=oy+e2.y*sc; r2=R+2; nx=Math.max(cx-hw,Math.min(rx,cx+hw)); ny=Math.max(y-hh,Math.min(ry,y+hh)); if((nx-rx)*(nx-rx)+(ny-ry)*(ny-ry)<r2*r2) return true; } return false; }
      function place(hh,hw){ var top=oy+z.y*sc+hh+1, bot=oy+(z.y+z.h)*sc-hh-1, cand=[cy], j, e2, ry, r2, k, y, best=null; if(EX) for(j=0;j<EX.length;j++){ e2=EX[j]; if(!e2) continue; ry=oy+e2.y*sc; r2=R+2; cand.push(ry-r2-hh-1,ry+r2+hh+1); } for(k=0;k<cand.length;k++){ y=cand[k]; if(y<top||y>bot||hits(y,hh,hw)) continue; if(best===null||Math.abs(y-cy)<Math.abs(best-cy)) best=y; } return best===null?cy:best; }
      c.font='bold '+fs+'px '+FF;
      while(fs>12&&c.measureText(nm).width>zw){ fs--; c.font='bold '+fs+'px '+FF; }
      if(c.measureText(nm).width>zw&&nm.indexOf(' ')>0){
        ws=nm.split(' ');
        for(k=1;k<ws.length;k++){ w1=txRawW(c,ws.slice(0,k).join(' ')); w2=txRawW(c,ws.slice(k).join(' ')); if(Math.max(w1,w2)<bw){ bw=Math.max(w1,w2); best=k; } }
        a1=ws.slice(0,best).join(' '); a2=ws.slice(best).join(' ');
        cy=place(fs+1,Math.max(c.measureText(a1).width,c.measureText(a2).width)/2+2); put(a1,cx,cy-fs*0.5+3); put(a2,cx,cy+fs*0.5+4);
        return;
      }
      cy=place(fs*0.5+1,c.measureText(nm).width/2+2); put(nm,cx,cy+5);
    })(); }
  if(EX) for(i=0;i<EX.length;i++){ e=EX[i]; if(!e) continue;
    c.strokeStyle='rgba(71,216,198,.3)'; c.lineWidth=2; c.setLineDash([3,5]); c.beginPath(); c.arc(ox+e.x*sc,oy+e.y*sc,R+7,0,6.2832); c.stroke(); c.setLineDash([]);
    c.strokeStyle='#47d8c6'; c.lineWidth=3; c.beginPath(); c.arc(ox+e.x*sc,oy+e.y*sc,R,0,6.2832); c.stroke();
    c.fillStyle='#47d8c6'; c.beginPath(); c.arc(ox+e.x*sc,oy+e.y*sc,6,0,6.2832); c.fill();
    c.font='600 16px '+FF; c.textAlign='center'; c.fillStyle='#47d8c6'; put(TX('exit '+String.fromCharCode(97+i)),ox+e.x*sc,oy+e.y*sc+R+22); n++; }
  c.textAlign='left';
  c.setTransform(1,0,0,1,0,0);
  return n;
}
'@

SubRx @'
function renderSector(){
  var host=document.getElementById('sectorlist');
  var cur=clamp(P.mapIx||0,0,FIXED_MAPS.length-1),h='';
  for(var i=0;i<FIXED_MAPS.length;i++){
    var M=FIXED_MAPS[i],R=sealRec(i),sel=(i===cur);
    if(!mapOffered(M)) continue;   // v23.6x (feat0b): a frozen map gets no card on the sector page
    var MS=SECTOR_MEAS[i]||{};
var _myR=0;
    for(var _mr=0;_mr<P.log.length;_mr++) if(P.log[_mr].mapName===M.name) _myR++;
    // v15.88, sector audit finding: THE SECTOR CARD COUNTS EVERY RUN HE HAS MADE THERE. The loop above counts only the sixty
    // runs the log still holds, so a long career read too few here, or YOU HAVE NEVER RAIDED HERE on a map whose raids had
    // all aged out. The per-map tally commitRun keeps outlives the log, and the card shows the larger of the two; a save
    // with no tally yet reads the log as before.
    if(P.mapRunN) _myR=P.mapRunN[M.name]|0;   // v16.13, backcheck: once there is a tally it is the count (seeded from the log, never below it); the log is read only before one exists, so a restored character does not show the replaced character's runs
    var facts=[(_myR>0?('you: '+_myR+' run'+(_myR===1?'':'s')+' here'):'YOU HAVE NEVER RAIDED HERE'),
               // v8.58, audit: metres, and the right magnitude. This divided by
               // 100 where U_PER_M is 10, and labelled a DIMENSION with an area
               // unit. COLD STORAGE read "42 by 34 hectares" and is 420 by 340
               // metres, 14.3 hectares of ground.
               metres(M.w)+' by '+metres(M.h)+' metres, '+
                 ((M.w/U_PER_M)*(M.h/U_PER_M)/10000).toFixed(1)+' hectares',
               (M.zones?M.zones.length:0)+' named zones',
               (M.locked?M.locked.length:0)+' keyed rooms'];
    // Real numbers, labelled as the bot's, replacing the fabricated loot
    // percentage that came off an inert constant.
    // v13.26, HIS WORDING FOR EVERY PLAYER: his baked edits of this line matched
    // only his own run counts, so a new player saw the long version he cut on one
    // map and his on the other. The figures he dropped stay in SECTOR_MEAS.
    if(MS.ext!==undefined) facts.push('the test robot extracts '+MS.ext+'% of its raids in '+sectorTitle(M.name)+'.');
    if(R.tier>0||R.cut>0) facts.push('seal tier '+(R.tier+1)+', '+Math.round(R.cut)+' of '+sealNeed(R.tier)+'s cut');

    h+='<div class="row sectorpick" data-map="'+i+'" style="display:block;overflow:hidden;cursor:pointer;'+
       (sel?'border-left:3px solid var(--amber);background:rgba(255,192,74,.10)':'border-left:3px solid transparent')+'">'+
       '<canvas class="secprev" data-map="'+i+'" width="420" height="'+Math.round(420*M.h/M.w)+'" style="float:right;margin:0 0 8px 16px;border:1px solid var(--steel-hi);border-radius:4px;background:#0b1020"></canvas>'+   // v17.79: the sector map
       // v18.65, seen on the lift screenshot (2026-10-07): each sector card is as tall as its map, and the name and facts were
       // 16 and 13 pixel lines across the top of it, a big empty card. The name is a heading now and the lines under it read
       // at a glance; the words are his, untouched.
       '<div><b style="font-size:28px;letter-spacing:.04em;line-height:1.15;color:'+(sel?'var(--amber)':'var(--bone)')+'">'+M.name+'</b>'+
       ' <span style="color:var(--ash);font-size:14px;letter-spacing:.08em">'+sizeTag(i)+'</span>'+
       (sel?' <span style="color:var(--amber);font-size:14px;letter-spacing:.08em">ASCENDING HERE</span>':'')+
       // v19.26, seen on the 4K lift screenshot (2026-10-08): he blanked both sector lines (his text edits), which left an empty
       // band between the name and the facts. A blank line takes no room now; with Edit the words on it stays, to be clicked back.
       '<div class="hint" style="'+((CFG.textEdit!==1&&!String(TX(SECTOR_CHAR[i])||'').trim())?'display:none;':'')+'margin:10px 0 0;padding-left:0;font-size:17px;line-height:1.5">'+SECTOR_CHAR[i]+'</div>'+
       // v21.32, from the whole-game bug hunt of 2026-10-08 (W-B2), seen on the 4K lift picture: THE SECTOR LINES START UNDER THE NAME.
       // Both lines under a sector name are hint lines, and a hint line carries a 12 px inner margin, so on every sector card the
       // facts (and the description line, when it has words) started 12 px right of the name above them, as if indented. They start
       // at the left edge of the name now. The words are untouched.
       '<div class="hint" style="margin:8px 0 0;padding-left:0;font-size:16px;line-height:1.6;color:var(--ash)">'+facts.join('  &middot;  ')+'</div></div></div>';
  }
  host.innerHTML=h;
  try{ sectorPreviews(host); }catch(_sv){}   // v17.79: the sector maps
  var rows=host.querySelectorAll('.sectorpick');
  for(var r=0;r<rows.length;r++){
    rows[r].onclick=function(){
      var _px=parseInt(this.getAttribute('data-map'),10);
      if(!mapOffered(FIXED_MAPS[_px])) return;
      P.mapIx=_px;
      saveProfile(); syncMapBtn(); renderSector();
    };
  }
  syncSectorCond();
  syncSectorKit();
  try{ syncSectorKitPick(); }catch(_skp){}   // v26.xx (kit1)
}
// v9.97, HIS NOTE: day or night is chosen on the sector page. The chosen one
// is drawn the way the chosen map is, amber, so the page reads as one choice
// of where and one of when.
function syncSectorCond(){
  var d=document.getElementById('condday'), nt=document.getElementById('condnight'), hint=document.getElementById('condhint');
  if(!d||!nt) return;
  var day=isDay();
  d.style.borderColor=day?'var(--amber)':''; d.style.color=day?'var(--amber)':'';
  d.style.background=day?'rgba(255,192,74,.10)':'';
  nt.style.borderColor=!day?'var(--amber)':''; nt.style.color=!day?'var(--amber)':'';
  nt.style.background=!day?'rgba(255,192,74,.10)':'';
  if(hint) hint.textContent=day?'You go up in daylight.':('You go up in the dark. XP pays '+(Math.round(nightXpMul()*100)/100)+'x.');
  try{ syncSectorWx(); }catch(_sw2){}
}
// v11.00, HIS NOTE 16: the chosen weather is drawn amber like the chosen map and
// the chosen surface, so the page reads as three choices of one shape.
function syncSectorWx(){
  var host=document.getElementById('sectorwx'); if(!host) return;
  var want=wxPicked(), bs=host.querySelectorAll('.wxb'), i, hard=0, nm='';
  for(i=0;i<bs.length;i++){
    var on=(bs[i].getAttribute('data-wx')===want);
    bs[i].style.borderColor=on?'var(--amber)':'';
    bs[i].style.color=on?'var(--amber)':'';
    bs[i].style.background=on?'rgba(255,192,74,.10)':'';
  }
  var hint=document.getElementById('wxhint'); if(!hint) return;
  if(want==='any'){ hint.textContent='Whatever the surface gives you.'; return; }
  for(i=0;i<WEATHER.length;i++) if(WEATHER[i].id===want){ nm=WEATHER[i].name; hard=wxHardId(want); }
  // v11.05, HIS QUESTION: a blackout is only harder if the lamps were on, and in
  // daylight whether they are depends on an hour that is rolled at the drop. Say
  // that, rather than promising a bonus that will not arrive.
  var lampsOnly=(function(){ for(var q=0;q<WEATHER.length;q++) if(WEATHER[q].id===want)
      return !(WEATHER[q].view!==undefined&&WEATHER[q].view<1)&&(WEATHER[q].lights!==undefined&&WEATHER[q].lights<1);
    return false; })();
  var payLine='. Harder going, so XP pays '+(Math.round(wxXpMul()*100)/100)+'x.';
  if(lampsOnly){
    // v14.66, ascent audit finding 2: UNDER BLACKOUT PROTOCOL THE HINT PROMISES NO BONUS. Since v14.28 lamp-killing weather under
    // the term is never hard weather, because the term places no lamps, but this hint still said the XP pays 1.1x at night and
    // that daylight depended on the hour. It says there is no bonus.
    if(typeof hasTerm==='function'&&hasTerm('blackout')){ hint.textContent=nm+'. No bonus: under Blackout Protocol there are no lamps to kill.'; return; }
    hint.textContent=nm+(isDay()
      ? '. Only harder if the lamps were on, and in daylight that depends on the hour you land at.'
      : payLine);
    return;
  }
  hint.textContent=nm+(hard?payLine:'. No bonus for an easy sky.');
}
(function(){
  var wb=document.querySelectorAll('#sectorwx .wxb');
  for(var i=0;i<wb.length;i++) wb[i].onclick=function(){
    P.wxPick=this.getAttribute('data-wx')||'any';
    saveProfile(); syncSectorWx();
  };
})();
(function(){
  var bs=[document.getElementById('condday'),document.getElementById('condnight')];
  for(var i=0;i<bs.length;i++) if(bs[i]) bs[i].onclick=function(){
    P.cond=(this.getAttribute('data-cond')==='night')?'night':'day';
    saveProfile(); syncSectorCond(); try{ syncSectorWx(); }catch(_sw){}
    try{ syncCond(); }catch(_sc){}
    // the ground is baked once per raid, so the next deploy picks up the palette
    hubGround=null;
  };
})();
// What he is actually taking up there, stated at the last moment he can change it.
// v28.xx (cw-preraid), HIS ORDER (2026-10-15): "On the pre-raid screen (the map select screen, renamed PRE-RAID), quickly pick how much cash and how many of each wheel item to take, plus keys and guns. Also how much ammo to take. Slot a data core there too."
// The map select screen is headed PRE-RAID and has a PACK row under the surface and weather rows: every kind of item the stash holds that can be carried (wheel items in wheel order, then ammo, keys, guns,
// the rest) as a chip with minus, plus and MAX that packs it for this raid (P.kit, the same list the stash and the ascent check edit), ALL and NONE, and the data core slot (P.intel, burns on ascent).
// It shows with MY LOADOUT only; a kit pick fills the pack itself. Cash is not here yet (a raid has no cash to carry in).
function packList(){
  var cnt={}, i, k, it, out=[], seen={}, ord=[], rest, rk;
  for(i=0;i<(P.stash||[]).length;i++){ k=P.stash[i]; it=ITEMS[k]; if(it&&it.use) cnt[k]=(cnt[k]||0)+1; }
  try{ ord=wheelOrderTable().slice(); }catch(_pw){ ord=[]; }
  for(i=0;i<ord.length;i++) if(cnt[ord[i]]&&!seen[ord[i]]){ seen[ord[i]]=1; out.push(ord[i]); }
  rest=Object.keys(cnt).filter(function(x){ return !seen[x]; });
  rk=function(x){ var u=ITEMS[x].use; return u==='ammo'?0:(u==='key'?1:(u==='gun'?2:3)); };
  rest.sort(function(a,b){ return (rk(a)-rk(b))||(ITEMS[a].name<ITEMS[b].name?-1:1); });
  return out.concat(rest);
}
function packSet(key,n){
  var held=heldCount(key), cur;
  if(P.freeKit) kitApply('mine');   // the freebie kit is set aside first, as MY LOADOUT does
  n=Math.max(0,Math.min(held,n)); cur=packedCount(key);
  if(n>cur) packSome(key,n-cur); else if(n<cur) unpackSome(key,cur-n);
  saveProfile();
}
function packCore(){
  if(P.intel){ P.intel=0; P.stash.push('core'); }
  else if(heldCount('core')>0){ spendHeld('core',1); P.intel=1; }
  else return false;
  saveProfile(); return true;
}
careerStyle('careercsspk',
  '.pkc{display:inline-flex;align-items:center;gap:5px;padding:4px 8px;border:1px solid var(--steel-hi);border-radius:3px;font-size:14px}'+
  '.pkc.on{border-color:var(--amber)}'+
  '.pkc .pkn{letter-spacing:.08em;color:var(--ash);margin-right:3px}'+
  '.pkc.on .pkn{color:var(--amber)}'+
  '.pkc button,.pkb{padding:2px 9px;font-size:14px;min-width:0}'+
  '.pkc b{min-width:1.4em;text-align:center}');
function syncSectorPack(){
  var host=document.getElementById('sectorpack'), keys, i, k, h, held, got, nc;
  if(!host) return;
  if(kitPickOf()!=='mine'){ host.style.display='none'; host.innerHTML=''; return; }
  host.style.display='';
  keys=packList();
  h='<div style="display:flex;flex-wrap:wrap;gap:6px 8px;align-items:center"><span style="font-size:13px;letter-spacing:.14em;color:var(--ash);min-width:5.8em">PACK</span><button class="pkb" data-pa="all">PACK ALL</button><button class="pkb" data-pa="none">CLEAR</button>';
  for(i=0;i<keys.length;i++){
    k=keys[i]; held=heldCount(k); got=packedCount(k);
    h+='<span class="pkc'+(got?' on':'')+'" data-pk="'+escHtml(k)+'"><span class="pkn">'+escHtml(String(ITEMS[k].name).toUpperCase())+'</span>'+
       '<button data-pd="-1">-</button><b>'+got+'</b><span style="color:var(--ash)">/'+held+'</span><button data-pd="1">+</button><button data-pd="max">MAX</button></span>';
  }
  nc=heldCount('core');
  // v28.xx (cw-cx-stashraid): pack only items and the data core; stash money stays available in the raid.
  h+='<button class="pkb" data-core="1"'+((!P.intel&&!nc)?' disabled':'')+(P.intel?' style="border-color:var(--amber);color:var(--amber)"':'')+'>'+
     (P.intel?'DATA CORE SLOTTED':(nc?('SLOT DATA CORE ('+nc+')'):'NO DATA CORE'))+'</button></div>';
  host.innerHTML=h;
  host.onclick=function(ev){
    var b=ev.target&&ev.target.closest?ev.target.closest('button'):null, ch, pk, d, pa, j, ks;
    if(!b||b.disabled) return;
    ch=b.closest('[data-pk]'); pk=ch?ch.getAttribute('data-pk'):null; d=b.getAttribute('data-pd'); pa=b.getAttribute('data-pa');
    if(b.getAttribute('data-core')){ if(!packCore()) return; }
    else if(pa){ ks=packList(); for(j=0;j<ks.length;j++) packSet(ks[j],pa==='all'?heldCount(ks[j]):0); }
    else if(pk&&d){ packSet(pk,d==='max'?heldCount(pk):packedCount(pk)+(+d)); }
    else return;
    try{ sndUi('click'); }catch(_ps){}
    syncSectorPack(); try{ syncSectorKit(); }catch(_pk){} try{ refreshInv(); }catch(_pr){}
  };
}
function syncSectorKit(){
  var el=document.getElementById('sectorkit');
  if(!el) return;
  try{ syncSectorPack(); }catch(_sp){}   // v28.xx (cw-preraid)
  if(kitPickOf()!=='mine'){ var _kp=kitPickOf(); el.innerHTML='<b>Going up with:</b> '+KIT_INFO[_kp][0]+'  \u00b7  '+KIT_INFO[_kp][1]+'  \u00b7  THIS RAID ONLY'; return; }   // v26.xx (kit1): a kit picked on this page is what goes up
  var w=null;
  try{ w=(P.equipped&&P.equipped!=='fists')?WEAPONS[P.equipped]:null; }catch(_gw){ w=null; }
  if(w) w=hubForged(w);   // v23.xx (forge13): going up with the Auto Rifle MK III
  // v12.75, 2026-09-08 first-hour audit: THIS BOX NOW SAYS WHAT ACTUALLY
  // HAPPENS. It used to say "an issued sidearm" when nothing is equipped, which
  // is what a brand new character has, and the deploy does not issue a sidearm:
  // it rolls a PRIMARY out of the starter list into gun one and leaves gun two
  // deliberately empty, so the line named the wrong slot and promised a second
  // gun that was not coming. And it printed the name of his rig, which has been
  // the same constant for everybody since v5.77 and whose name is the bare word
  // Armour, directly above an amber line saying he ascends with no armour on.
  // That half is gone rather than reworded: the amber line under this one is
  // already the true and useful version of it.
  var line='<b>Going up with:</b> '+(w?escHtml(w.name):'a Scav Pistol');
  // v14.67, ascent audit finding 3: AND HIS OWN GUN 2. With gun 1 emptied and his own gun put in gun 2, the raid issues a loaner
  // in hand and brings his gun as gun 2, riding the gun rules, so a death can lose it; the last screen before the lift named
  // only the loaner. Gun 2 is named whenever it is his own gun and not the gun in slot 1.
  var _s2=P.equippedSec;
  if(_s2&&_s2!=='none'&&_s2!=='fists'&&WEAPONS[_s2]&&(P.weapons||[]).indexOf(_s2)>=0&&_s2!==P.equipped) line+=', and your '+escHtml(WEAPONS[_s2].name)+' as gun 2';
  // v13.31: since his ruling the pack guns wait in the stash with nothing equipped.
  // Say he owns one, and how to take it, on the last screen before the lift.
  if(!w&&(P.stash||[]).some(function(k){ var it=ITEMS[k]; return it&&it.use==='gun'&&it.gk&&WEAPONS[it.gk]; }))
    line+='<div style="margin-top:5px">Your gun is in your stash. Equip it first.</div>';
  // v10.13, his answer 7: the armour warning lives here, on the way up. It
  // used to be copied off the stash screen's readiness line, which v9.98
  // removed, so it had been nowhere since. Same numbers as the line had.
  try{
    var RG=myRig(), cap=rigCeil(RG);
    line+='<div style="margin-top:5px;color:var(--amber)">You ascend with <b>no armour on</b>. Equip plates on the surface.</div>';
  }catch(_rh){}
  el.innerHTML=line;
}

'@ @'
// v32.45 (cw-preraid-a), HIS PICK (2026-10-19): design A, map first. The sector row is now a header strip (name, ascending here tag, real stats) over the drawn map; the page keeps its old ids and classes
// (#sectorlist .sectorpick canvas.secprev, #condday, #condnight, .wxb, .kitb, #sectorpack, #sectorkit, #sectordeploy, #closesector). Cut with the reason in notes/ui/changes.md (his Q8): the description line, the
// "never raided here" and hectares facts and the test robot line (a dev figure a guest cannot use), and the hint sentences the xp badges replace.
function srGuest(){ try{ return !!(typeof NET==='object'&&NET&&NET.on&&NET.role==='join'&&netInCount()>0); }catch(_g){ return false; } }
function srHints(){
  var el=document.getElementById('srhints'), pg=document.getElementById('srplg'), g, k;
  if(!el) return;
  g=function(s){ return '<i class="pg">'+escHtml(padB(s))+'</i>'; }; k=function(s){ return '<i class="kc">'+s+'</i>'; };
  el.innerHTML='<span class="srk"><span class="hn">'+k('ESC')+'CLOSE</span><span class="hn">'+k('ENTER')+'ASCEND</span><span class="hn">'+k('CLICK')+'PICK</span></span>'+
    '<span class="srp"><span class="hn">'+g('A')+'ASCEND</span><span class="hn">'+g('B')+'CLOSE</span><span class="hn">'+g('X')+'PACK ALL</span><span class="hn">'+g('Y')+'CLEAR</span><span class="hn"><i class="pg">'+escHtml(padB('LB'))+'</i><i class="pg">'+escHtml(padB('RB'))+'</i>PANEL</span></span>'+
    '<span class="sv">SAVES AS YOU GO</span>';
  if(pg) pg.textContent=padB('A');
}
function srChrome(){
  var m=document.getElementById('sectormodal'), s=-1, el, role='';
  try{ s=seatHere(); }catch(_s){ s=-1; }
  if(m) m.style.setProperty('--srseat',SEATCOL[s>=0?(s&3):0]);
  try{ role=(typeof NET==='object'&&NET&&NET.role==='join')?' \u00b7 joined':((typeof NET==='object'&&NET&&NET.role==='host')?' \u00b7 host':''); }catch(_r){ role=''; }
  el=document.getElementById('srseat');
  if(el) el.innerHTML=s>=0?('<span class="srseat"><i style="background:'+SEATCOL[s&3]+'"></i>p'+((s&3)+1)+role+'</span>'):'';
  el=document.getElementById('srhost'); if(el) el.textContent=srGuest()?'HOST SETS':'';
  srHints();
}
function renderSector(){
  var host=document.getElementById('sectorlist');
  var cur=clamp(P.mapIx||0,0,FIXED_MAPS.length-1),h='', i, M, R, sel, facts, nx=0, nk=0;
  for(i=0;i<FIXED_MAPS.length;i++){
    M=FIXED_MAPS[i]; R=sealRec(i); sel=(i===cur);
    if(!mapOffered(M)) continue;   // v23.6x (feat0b): a frozen map gets no card on the sector page
    // the real numbers of the sector: size in metres, then the counts the map holds
    nx=M.extracts?M.extracts.length:0; nk=M.locked?M.locked.length:0;
    facts=[metres(M.w)+' x '+metres(M.h)+' m',(M.zones?M.zones.length:0)+' zones',nk+' keyed rooms',nx+' exits'];
    if(R.tier>0||R.cut>0) facts.push('seal tier '+(R.tier+1)+', '+Math.round(R.cut)+' of '+sealNeed(R.tier)+'s cut');
    h+='<div class="row sectorpick'+(sel?' sel':'')+'" data-map="'+i+'">'+
       '<div class="srmh"><b>'+M.name+'</b>'+
       (sel?'<span class="srtag"><svg viewBox="0 0 24 24"><path d="M5 12.5l4.5 4.5L19 7.5"/></svg>ASCENDING HERE</span>':'')+
       '<span class="srst">'+facts.join('  &middot;  ')+'</span></div>'+
       '<div class="srcv"><canvas class="secprev" data-map="'+i+'" width="840" height="'+Math.round(840*M.h/M.w)+'"></canvas></div></div>';
  }
  host.innerHTML=h;
  try{ sectorPreviews(host); }catch(_sv){}   // v17.79: the sector maps
  var rows=host.querySelectorAll('.sectorpick');
  for(var r=0;r<rows.length;r++){
    rows[r].onclick=function(){
      var _px=parseInt(this.getAttribute('data-map'),10);
      if(!mapOffered(FIXED_MAPS[_px])) return;
      P.mapIx=_px;
      saveProfile(); syncMapBtn(); renderSector();
    };
  }
  syncSectorCond();
  syncSectorKit();
  try{ syncSectorKitPick(); }catch(_skp){}   // v26.xx (kit1)
  try{ srChrome(); }catch(_sc){}
}
// v9.97, HIS NOTE: day or night is chosen on the sector page. v32.45 (cw-preraid-a): the chosen one is a filled chip with a check (selected is a fill, never the focus ring) and the xp bonus is a small badge, not a sentence.
function syncSectorCond(){
  var d=document.getElementById('condday'), nt=document.getElementById('condnight'), nx=document.getElementById('srnx'), day=isDay(), g=srGuest();
  if(!d||!nt) return;
  d.classList.toggle('on',day); nt.classList.toggle('on',!day);
  d.disabled=g; nt.disabled=g;
  if(nx) nx.textContent='+'+Math.round((nightXpMul()-1)*100)+'%';
  try{ syncSectorWx(); }catch(_sw2){}
}
// v11.00, HIS NOTE 16: the weather is chosen the same way, on the same page. The badge is the xp bonus the weather pays right now (hard weather, and a lamp killer only when the lamps would be on); no badge when it pays nothing.
function srWxBonus(id){
  var i, lamps=false, hard=0;
  if(id==='any') return '';
  for(i=0;i<WEATHER.length;i++) if(WEATHER[i].id===id){ hard=wxHardId(id); lamps=!(WEATHER[i].view!==undefined&&WEATHER[i].view<1)&&(WEATHER[i].lights!==undefined&&WEATHER[i].lights<1); }
  if(lamps){ if(typeof hasTerm==='function'&&hasTerm('blackout')) return ''; return isDay()?'':('+'+Math.round((wxXpMul()-1)*100)+'%'); }
  return hard?('+'+Math.round((wxXpMul()-1)*100)+'%'):'';
}
function syncSectorWx(){
  var host=document.getElementById('sectorwx'); if(!host) return;
  var want=wxPicked(), bs=host.querySelectorAll('.wxb'), i, em, g=srGuest(), hint=document.getElementById('wxhint'), bn='', lamps=false;
  for(i=0;i<bs.length;i++){
    bs[i].classList.toggle('on',bs[i].getAttribute('data-wx')===want);
    bs[i].disabled=g;
    em=bs[i].querySelector('em'); if(em) em.textContent=srWxBonus(bs[i].getAttribute('data-wx'));
  }
  if(!hint) return;
  if(want==='any'){ hint.textContent='whatever the surface gives you'; return; }
  bn=srWxBonus(want);
  for(i=0;i<WEATHER.length;i++) if(WEATHER[i].id===want) lamps=!(WEATHER[i].view!==undefined&&WEATHER[i].view<1)&&(WEATHER[i].lights!==undefined&&WEATHER[i].lights<1);
  hint.textContent=bn?'':(lamps?((typeof hasTerm==='function'&&hasTerm('blackout'))?'no bonus under blackout protocol':'pays after dark only'):'no bonus');
}
(function(){
  var wb=document.querySelectorAll('#sectorwx .wxb');
  for(var i=0;i<wb.length;i++) wb[i].onclick=function(){
    if(srGuest()) return;
    P.wxPick=this.getAttribute('data-wx')||'any';
    saveProfile(); syncSectorWx();
  };
})();
(function(){
  var bs=[document.getElementById('condday'),document.getElementById('condnight')];
  for(var i=0;i<bs.length;i++) if(bs[i]) bs[i].onclick=function(){
    if(srGuest()) return;
    P.cond=(this.getAttribute('data-cond')==='night')?'night':'day';
    saveProfile(); syncSectorCond(); try{ syncSectorWx(); }catch(_sw){}
    try{ syncCond(); }catch(_sc){}
    // the ground is baked once per raid, so the next deploy picks up the palette
    hubGround=null;
  };
})();
// What he is actually taking up there, stated at the last moment he can change it.
// v28.xx (cw-preraid), HIS ORDER (2026-10-15): "On the pre-raid screen (the map select screen, renamed PRE-RAID), quickly pick how much cash and how many of each wheel item to take, plus keys and guns. Also how much ammo to take. Slot a data core there too."
// The pack: every kind of item the stash holds that can be carried (wheel items in wheel order, then ammo, keys, guns, the rest) with a count and a plus and minus that pack it for this raid (P.kit, the same list the stash
// and the ascent check edit), pack all and clear, and the data core slot (P.intel, burns on ascent). It shows with MY LOADOUT only; a kit pick fills the pack itself. There is no cash control: a raid has no cash to carry in (his order of 2026-10-19).
// v32.45 (cw-preraid-a): grouped rows (heals, throwables, armour, guns, then ammo and keys), a rarity edge and an icon, ONE stepper each, and the list scrolls inside its own box so a big pack never pushes the ascend plate off the card.
function packList(){
  var cnt={}, i, k, it, out=[], seen={}, ord=[], rest, rk;
  for(i=0;i<(P.stash||[]).length;i++){ k=P.stash[i]; it=ITEMS[k]; if(it&&it.use) cnt[k]=(cnt[k]||0)+1; }
  try{ ord=wheelOrderTable().slice(); }catch(_pw){ ord=[]; }
  for(i=0;i<ord.length;i++) if(cnt[ord[i]]&&!seen[ord[i]]){ seen[ord[i]]=1; out.push(ord[i]); }
  rest=Object.keys(cnt).filter(function(x){ return !seen[x]; });
  rk=function(x){ var u=ITEMS[x].use; return u==='ammo'?0:(u==='key'?1:(u==='gun'?2:3)); };
  rest.sort(function(a,b){ return (rk(a)-rk(b))||(ITEMS[a].name<ITEMS[b].name?-1:1); });
  return out.concat(rest);
}
function packSet(key,n){
  var held=heldCount(key), cur;
  if(P.freeKit) kitApply('mine');   // the freebie kit is set aside first, as MY LOADOUT does
  n=Math.max(0,Math.min(held,n)); cur=packedCount(key);
  if(n>cur) packSome(key,n-cur); else if(n<cur) unpackSome(key,cur-n);
  saveProfile();
}
function packCore(){
  if(P.intel){ P.intel=0; P.stash.push('core'); }
  else if(heldCount('core')>0){ spendHeld('core',1); P.intel=1; }
  else return false;
  saveProfile(); return true;
}
var SR_RANK={heal:0,throw:1,armor:2,gun:3,ammo:4,key:5};
var SR_RC={common:'#9da3a8',uncommon:'#5fbf6a',rare:'#3f9de9',elite:'#a866e0',epic:'#a866e0',legendary:'#ffc72e',gold:'#ffc72e'};
var SR_IC={
  heal:'<path d="M3 7h18v13H3zM9 7V4.5h6V7M12 10.5v6M9 13.5h6"/>',
  throw:'<circle cx="12" cy="14.5" r="7"/><path d="M9.5 7.5h5M12 7.5V4h3.5"/>',
  armor:'<path d="M12 3l7.5 3v6c0 4-3.2 7-7.5 9-4.3-2-7.5-5-7.5-9V6z"/><path d="M12 7v10"/>',
  gun:'<path d="M2 12h13l2-2h5v3.5h-3.5l-1 1.5h-4l-1 3.5H8l1-3.5H2z"/>',
  ammo:'<rect x="5" y="8" width="14" height="12" rx="1.5"/><path d="M8 8V4.5h8V8M9 12h6"/>',
  key:'<circle cx="8" cy="12" r="4"/><path d="M12 12h9M18 12v3.5M21 12v2.5"/>',
  other:'<rect x="5" y="5" width="14" height="14" rx="2"/><path d="M9 12h6"/>',
  core:'<rect x="6" y="6" width="12" height="12" rx="1.5"/><path d="M9 3v3M12 3v3M15 3v3M9 18v3M12 18v3M15 18v3M3 9h3M3 12h3M3 15h3M18 9h3M18 12h3M18 15h3"/>'
};
function srGroup(k){ var r=SR_RANK[ITEMS[k].use]; return r===undefined?6:r; }
function srPackBulk(all){
  var ks=packList(), j;
  if(kitPickOf()!=='mine') return false;
  for(j=0;j<ks.length;j++) packSet(ks[j],all?heldCount(ks[j]):0);
  try{ sndUi('click'); }catch(_ps){}
  syncSectorKit(); try{ refreshInv(); }catch(_pr){}
  return true;
}
function syncSectorPack(){
  var host=document.getElementById('sectorpack'), keys, i, k, h, held, got, nc, tot=0, lastG=-1, g, u;
  if(!host) return;
  if(kitPickOf()!=='mine'){ host.style.display='none'; host.innerHTML=''; return; }
  host.style.display='';
  keys=packList().map(function(x,ix){ return [srGroup(x),ix,x]; }).sort(function(a,b){ return (a[0]-b[0])||(a[1]-b[1]); }).map(function(x){ return x[2]; });
  for(i=0;i<keys.length;i++) tot+=packedCount(keys[i]);
  h='<div class="srph"><b>PACK</b><span>'+tot+' PACKED</span><i></i><button class="pkb" data-pa="all" data-pan="p">PACK ALL</button><button class="pkb" data-pa="none" data-pan="p">CLEAR</button></div><div class="srplist">';
  for(i=0;i<keys.length;i++){
    k=keys[i]; held=heldCount(k); got=packedCount(k); g=srGroup(k); u=ITEMS[k].use;
    h+='<div class="srprow'+(got?' on':'')+((lastG>=0&&g!==lastG)?' g':'')+'" data-pk="'+escHtml(k)+'"><i class="rar" style="background:'+(SR_RC[ITEMS[k].r]||SR_RC.common)+'"></i>'+
       '<svg viewBox="0 0 24 24">'+(SR_IC[u]||SR_IC.other)+'</svg><span class="nm">'+escHtml(String(ITEMS[k].name).toUpperCase())+'</span><span class="held">/'+held+'</span>'+
       '<span class="st"><i class="srm'+(got?'':' dis')+'" data-pd="-1">-</i><b data-pd="max">'+got+'</b><button data-pd="1" data-pan="p"'+(got>=held?' class="dis"':'')+'>+</button></span></div>';
    lastG=g;
  }
  nc=heldCount('core');
  h+='<button class="srprow srcore'+(P.intel?' on':'')+'" data-core="1" data-pan="p"'+((!P.intel&&!nc)?' disabled':'')+'><svg viewBox="0 0 24 24">'+SR_IC.core+'</svg><span class="nm" style="color:inherit">'+
     (P.intel?'DATA CORE SLOTTED':(nc?('SLOT DATA CORE ('+nc+')'):'NO DATA CORE'))+'</span><span class="held">BURNS ON ASCENT</span><i class="cb"></i></button></div>';
  host.innerHTML=h;
  host.onclick=function(ev){
    var t=ev.target&&ev.target.closest?ev.target.closest('[data-pd],[data-pa],[data-core]'):null, ch, pk, d, pa, hd, gt, n;
    if(!t||t.disabled) return;
    pa=t.getAttribute('data-pa');
    if(t.getAttribute('data-core')){ if(!packCore()) return; }
    else if(pa){ srPackBulk(pa==='all'); return; }
    else{
      ch=t.closest('[data-pk]'); pk=ch?ch.getAttribute('data-pk'):null; d=t.getAttribute('data-pd');
      if(!pk||!d) return;
      hd=heldCount(pk); gt=packedCount(pk);
      if(d==='max') packSet(pk,gt<hd?hd:0);
      else{ n=gt+(+d); if(n<0||n>hd) return; packSet(pk,n); }
    }
    try{ sndUi('click'); }catch(_ps){}
    try{ syncSectorKit(); }catch(_pk){} try{ refreshInv(); }catch(_pr){}
  };
}
function syncSectorKit(){
  var el=document.getElementById('sectorkit');
  if(!el) return;
  try{ syncSectorPack(); }catch(_sp){}   // v28.xx (cw-preraid)
  var chip=function(a,b){ return '<span class="gc">'+(a?'<i>'+a+'</i>':'')+(b?'<b>'+b+'</b>':'')+'</span>'; };
  if(kitPickOf()!=='mine'){ var _kp=kitPickOf(); el.innerHTML='<div class="srsum"><span class="gc" style="flex-basis:100%"><b>'+KIT_INFO[_kp][0]+'</b><i>'+KIT_INFO[_kp][1]+'</i></span>'+chip('THIS RAID ONLY','')+'</div>'; return; }   // v26.xx (kit1): a kit picked on this page is what goes up
  var w=null;
  try{ w=(P.equipped&&P.equipped!=='fists')?WEAPONS[P.equipped]:null; }catch(_gw){ w=null; }
  if(w) w=hubForged(w);   // v23.xx (forge13): going up with the Auto Rifle MK III
  // v12.75: this says what actually happens: with nothing equipped the raid issues a scav pistol into gun 1 and leaves gun 2 empty.
  var line='<div class="srsum">'+chip('gun',w?escHtml(w.name):'a scav pistol');
  // v14.67: and his own gun 2, whenever it is his own gun and not the gun in slot 1
  var _s2=P.equippedSec;
  if(_s2&&_s2!=='none'&&_s2!=='fists'&&WEAPONS[_s2]&&(P.weapons||[]).indexOf(_s2)>=0&&_s2!==P.equipped) line+=chip('gun 2',escHtml(WEAPONS[_s2].name));
  // v13.31: a gun waiting in the stash with nothing equipped is said in one chip
  if(!w&&(P.stash||[]).some(function(k){ var it=ITEMS[k]; return it&&it.use==='gun'&&it.gk&&WEAPONS[it.gk]; })) line+=chip('','NO GUN EQUIPPED');
  // v10.13, his answer 7: the armour warning lives here, on the way up, and only when it is true: a packed armour item takes it away
  var armed=false;
  try{ packList().forEach(function(k){ if(ITEMS[k].use==='armor'&&packedCount(k)>0) armed=true; }); }catch(_rh){}
  if(!armed) line+='<span class="wn"><svg viewBox="0 0 24 24"><path d="M12 3.5l9.5 16.5h-19z"/><path d="M12 10v4.5M12 17v.5"/></svg><b>NO ARMOUR EQUIPPED</b><i>EQUIP PLATES ON THE SURFACE</i></span>';
  el.innerHTML=line+'</div>';
}
// v32.45 (cw-preraid-a): THE PAD FLOW. Focus opens on ascend, so a normal ascent is one press. LB and RB jump between the conditions, the kit tiles and the pack; the d-pad moves up and down inside each one
// (left and right change a pack row by one); X packs all and Y clears. Panels are marked data-pan: c conditions, k kit, p pack, a ascend.
function srPan(el){ var p=(el&&el.closest)?el.closest('[data-pan]'):null; return p?p.getAttribute('data-pan'):''; }
function srPanJump(list,dir){
  var order=['c','k','p'], cur=PAD.focus, pan=srPan(cur), ix=order.indexOf(pan), ni, i, want, c=[], tgt;
  if(!PAD.srLast) PAD.srLast={};
  if(cur&&pan) PAD.srLast[pan]=cur;
  ni=(ix<0)?(dir>0?0:order.length-1):((ix+dir+order.length)%order.length);
  for(i=0;i<order.length;i++){
    want=order[(ni+i*dir+order.length*3)%order.length];
    c=list.filter(function(x){ return srPan(x)===want; });
    if(c.length) break;
  }
  if(!c.length) return false;
  tgt=PAD.srLast[want]; if(!tgt||c.indexOf(tgt)<0) tgt=c.filter(function(x){ return x.classList.contains('on'); })[0]||c[0];
  padSetFocus(tgt); return true;
}
function srPadNav(list,cur,mv){
  var pan=srPan(cur), row, pk, nx, sub, nb;
  if(!cur) return false;
  row=cur.closest?cur.closest('.srprow[data-pk]'):null;
  if(row&&mv[0]){
    pk=row.getAttribute('data-pk'); packSet(pk,packedCount(pk)+mv[0]);
    try{ sndUi('click'); }catch(_c){}
    syncSectorKit(); try{ refreshInv(); }catch(_r){}
    nb=document.querySelector('#sectorpack [data-pk="'+pk+'"] button[data-pd="1"]'); if(nb) padSetFocus(nb);
    return true;
  }
  if(pan==='a'){
    if(mv[1]<0){ sub=list.filter(function(x){ return srPan(x)==='p'; }); if(!sub.length) sub=list.filter(function(x){ return srPan(x)==='k'; }); nx=PAD.srLast&&PAD.srLast.p&&sub.indexOf(PAD.srLast.p)>=0?PAD.srLast.p:sub[sub.length-1]; if(nx) padSetFocus(nx); }
    return true;
  }
  sub=list.filter(function(x){ return srPan(x)===pan; });
  nx=padStep(sub,cur,mv[0],mv[1]);
  if(nx){ padSetFocus(nx); if(!PAD.srLast) PAD.srLast={}; PAD.srLast[pan]=nx; }
  else if(mv[1]>0&&pan!=='c'){ nx=document.getElementById('sectordeploy'); if(nx){ if(!PAD.srLast) PAD.srLast={}; PAD.srLast[pan]=cur; padSetFocus(nx); } }
  return true;
}
// v32.45 (cw-preraid-a): ENTER ascends from the page when nothing that takes ENTER itself has the focus
document.addEventListener('keydown',function(e){
  var m=document.getElementById('sectormodal'), t=e.target, d;
  if(e.key!=='Enter'||e.repeat||e.isComposing||!m||!m.classList.contains('on')) return;
  if(t&&t.closest&&t.closest('button,input,select,textarea,[tabindex]')) return;
  d=document.getElementById('sectordeploy'); if(d&&!d.disabled){ e.preventDefault(); d.click(); }
});
'@

SubRx @'
'.kitb{display:flex;flex-direction:column;align-items:flex-start;gap:3px;padding:7px 16px;flex:0 0 auto}'+
  '.kitb .kd{font-size:12px;letter-spacing:.12em;opacity:.72;font-weight:600}'+
  '.kitb.on{border-color:var(--amber);color:var(--amber);background:rgba(255,192,74,.10)}');
'@ @'
'.kitb{flex:0 0 auto}');   /* v32.45 (cw-preraid-a): the kit tiles are drawn by the page's own stylesheet in #sectormodal */
'@

SubRx @'
if(md.id==='outcome'&&(!PAD.focus||!md.contains(PAD.focus))){ var _ocb=document.getElementById('oc_btn'); if(_ocb&&list.indexOf(_ocb)>=0) padSetFocus(_ocb); }
'@ @'
if(md.id==='outcome'&&(!PAD.focus||!md.contains(PAD.focus))){ var _ocb=document.getElementById('oc_btn'); if(_ocb&&list.indexOf(_ocb)>=0) padSetFocus(_ocb); }
  // v32.45 (cw-preraid-a): the pre-raid page opens on ASCEND, so a normal ascent is one press. The A that opened the page is spent (the edge is taken here) so it cannot ascend by itself.
  if(md.id==='sectormodal'&&(!PAD.focus||!md.contains(PAD.focus))){ var _sdb=document.getElementById('sectordeploy'); if(_sdb&&list.indexOf(_sdb)>=0){ padSetFocus(_sdb); PAD.prev[0]=!!pressed(0); } }
'@

SubRx @'
if(mv){ var nx=(md.id==='keysmodal'&&KEYS.pad&&mv[1])?padLayoutStep(PAD.focus,mv[1]):padStep(list,PAD.focus,mv[0],mv[1]); if(nx){ padSetFocus(nx); if(GRAB&&GRAB.pad){ GRAB.moved=1; stashPadGhost(); } } }
'@ @'
if(md.id==='sectormodal'){   // v32.45 (cw-preraid-a): LB and RB jump between the conditions, the kit tiles and the pack; up and down stay inside a panel; X packs all, Y clears
    try{
      if(lb||rb) srPanJump(list,rb?1:-1);
      if(mv){ srPadNav(list,PAD.focus,mv); mv=null; }
      if(tap(2)) srPackBulk(true);
      if(tap(3)) srPackBulk(false);
    }catch(_srp){}
  }
  if(mv){ var nx=(md.id==='keysmodal'&&KEYS.pad&&mv[1])?padLayoutStep(PAD.focus,mv[1]):padStep(list,PAD.focus,mv[0],mv[1]); if(nx){ padSetFocus(nx); if(GRAB&&GRAB.pad){ GRAB.moved=1; stashPadGhost(); } } }
'@

SubRx @'
var VER='32.45';
'@ @'
var VER='32.46';
'@

$pat = "(?m)^  now:'v32\.45:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.46: The pre-raid page is rebuilt: a big ice blue map of cold storage with its zones, exits and keyed rooms, conditions beside it, and the kit, pack and ascend button in a column on the right. On a pad you press A once to go up. Check 32.46 fails on v32.45',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
