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

# CONTROLLER LAYOUT PRESETS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var PAD_BTN=['A','B','X','Y','LB','RB','LT','RT','VIEW','MENU','LS','RS','D-UP','D-DOWN','D-LEFT','D-RIGHT'];
'@ @'
// v28.xx (cw-cx-padpresets), his 2026-10-19 order: "several preset controller configs"; "it always needs to be twin stick". Tables: tools/handoff/pad-research/presets-and-aim-assist.md, action -> physical button.
var PAD_PRESETS=[
  {name:'pillagers',map:[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]},
  {name:'call of duty',map:[0,1,2,13,4,3,6,7,8,9,10,11,12,5,14,15]},
  {name:'fortnite',map:[0,11,2,1,4,5,6,7,12,9,10,3,8,13,14,15]},
  {name:'arc raiders',map:[0,1,2,11,15,3,6,7,8,9,10,14,5,4,13,12]},
  {name:'top-down',map:[6,1,2,0,3,5,4,7,8,9,10,11,12,13,14,15]},
  {name:'lefty',map:[5,1,2,3,0,4,7,6,8,9,11,10,12,13,14,15],sticks:'swap'}
];
function padPresetName(){
  var m=padMapArr(), i, q;
  if(P.padPreset==='custom') return 'custom';
  for(i=0;i<PAD_PRESETS.length;i++){
    q=PAD_PRESETS[i];
    if(m.join(',')===q.map.join(',')&&(P.padSticks==='swap')===(q.sticks==='swap')) return q.name;
  }
  return 'custom';
}
function padPresetLoad(){
  if(!P.padPreset){ P.padSticks=''; P.padPreset=padPresetName(); }
  if(P.padSticks!=='swap') P.padSticks='';
}
function padPresetApply(ix){
  var q=PAD_PRESETS[ix], i;
  if(!q||!P) return false;
  padRelease(); P.padmap={};
  for(i=0;i<16;i++) if(q.map[i]!==i) P.padmap[i]=q.map[i];
  P.padmapV=1; P.padPreset=q.name; P.padSticks=q.sticks||'';
  PADB.waiting=null; PADB.note=null; padLabelsApply();
  try{ saveProfile(); }catch(_pps){}
  if(typeof KEYS==='object'&&KEYS.pad) keysRender();
  return true;
}
function padPresetCycle(dir){
  var name=padPresetName(), ix=-1, i;
  for(i=0;i<PAD_PRESETS.length;i++) if(PAD_PRESETS[i].name===name) ix=i;
  if(ix<0) ix=dir>0?-1:0;
  padPresetApply((ix+(dir>0?1:-1)+PAD_PRESETS.length)%PAD_PRESETS.length);
  var el=document.getElementById('padlayout'); if(el) padSetFocus(el);
}
// v28.xx (cw-cx-padpresets): both local and handed-over pads arrive as raw axes. Each receiving window applies its own profile once; menus and the Undercroft keep raw axes.
function padRaidAxes(ax){
  if(P.padSticks!=='swap'||state!=='raid'||!G||G.over||padOpenModal()||(typeof ATT==='object'&&ATT&&ATT.on)) return ax;
  var a=[].slice.call(ax); a[0]=ax[2]||0; a[1]=ax[3]||0; a[2]=ax[0]||0; a[3]=ax[1]||0; return a;
}
var PAD_PICTURE_ACTIONS=['roll','crouch','reload / search','ring search','belt -','belt +','focus','fire','backpack','pause','sprint','focus toggle','ping / map','item wheel','aim -','aim +'];
function padPictureLabel(button){
  var m=padMapArr(), i; for(i=0;i<16;i++) if(m[i]===button) return PAD_PICTURE_ACTIONS[i]; return '';
}
function padPictureHtml(){
  var m=padMapArr(), swap=P.padSticks==='swap', h, i, b, label;
  var left=[[6,64,342,222],[4,120,334,254],[10,232,354,332],[8,288,440,302],[12,400,408,385],[14,456,386,408],[13,512,408,431],[15,568,430,408]];
  var right=[[7,64,618,222],[5,120,626,254],[3,176,624,310],[2,232,600,334],[1,288,648,334],[0,344,624,358],[9,400,520,302],[11,568,526,422]];
  h='<figure class="padpicture"><svg viewBox="0 0 960 640" role="img" aria-label="controller layout">'+
    '<path d="M332 238 Q308 228 288 290 L244 464 Q236 516 280 524 Q300 528 324 494 L376 444 L584 444 L636 494 Q660 528 680 524 Q724 516 716 464 L672 290 Q652 228 628 238 L570 216 L390 216 Z" fill="var(--ui-panel,#16191b)" stroke="var(--ui-line-hi,#4a5257)" stroke-width="4"/>'+
    '<g fill="var(--ui-raised,#1e2225)" stroke="var(--ui-line-hi,#4a5257)" stroke-width="3">'+
    '<rect x="312" y="206" width="60" height="24" rx="8"/><rect x="588" y="206" width="60" height="24" rx="8"/>'+
    '<path d="M310 246 L374 236 M586 236 L650 246"/><circle cx="354" cy="332" r="34"/><circle cx="526" cy="422" r="34"/>'+
    '<path d="M398 375 H418 V398 H440 V418 H418 V440 H398 V418 H376 V398 H398 Z"/>'+
    '<circle cx="624" cy="310" r="15"/><circle cx="600" cy="334" r="15"/><circle cx="648" cy="334" r="15"/><circle cx="624" cy="358" r="15"/>'+
    '<rect x="429" y="294" width="22" height="16" rx="4"/><rect x="509" y="294" width="22" height="16" rx="4"/></g>';
  function tag(button,y,x,py,isRight){
    var tx=isRight?944:16, edge=isRight?714:246, end=isRight?728:232;
    return '<path d="M'+x+' '+py+' L'+edge+' '+(y-8)+' H'+end+'" fill="none" stroke="var(--ui-line-hi,#4a5257)" stroke-width="2"/>'+
      '<text data-pad-button="'+button+'" x="'+tx+'" y="'+y+'" text-anchor="'+(isRight?'end':'start')+'">'+
      '<tspan fill="var(--acc,#e6ff3d)">'+PAD_BTN[button].toLowerCase()+'</tspan><tspan dx="10">'+padPictureLabel(button)+'</tspan></text>';
  }
  h+='<g font-family="Barlow Condensed,Bahnschrift,Arial,sans-serif" font-size="26" font-weight="600" fill="var(--tx-1,#efe9dc)">';
  for(i=0;i<left.length;i++){ b=left[i]; h+=tag(b[0],b[1],b[2],b[3],false); }
  for(i=0;i<right.length;i++){ b=right[i]; h+=tag(b[0],b[1],b[2],b[3],true); }
  h+='<text x="354" y="340" text-anchor="middle" data-pad-stick="left">'+(swap?'aim':'move')+'</text>'+
    '<text x="526" y="430" text-anchor="middle" data-pad-stick="right">'+(swap?'move':'aim')+'</text></g></svg></figure>';
  return h;
}
function padLayoutHtml(){
  return '<div class="padlayoutrow"><b>layout</b><div class="padlayoutpick"><button id="padlayoutprev" aria-label="previous layout">&lt;</button>'+
    '<button id="padlayout" aria-label="layout" aria-valuetext="'+padPresetName()+'">'+padPresetName()+'</button>'+
    '<button id="padlayoutnext" aria-label="next layout">&gt;</button></div></div>';
}
function padLayoutStep(cur,dy){
  // v28.xx (cw-cx-padpresets): cw-keysclean makes the keycap the only rebind control; the duplicate .rebind buttons stay hidden. Visit the visible caps and both footer controls.
  var km=document.getElementById('keysmodal'), q=km.querySelectorAll('.keybtn');
  var a=[document.getElementById('padlayout')], i, ix=0;
  for(i=0;i<q.length;i++) a.push(q[i]);
  a.push(document.getElementById('keysreset'),document.getElementById('closekeys'));
  for(i=0;i<a.length;i++) if(a[i]===cur) ix=i;
  return a[Math.max(0,Math.min(a.length-1,ix+dy))];
}
var PAD_BTN=['A','B','X','Y','LB','RB','LT','RT','VIEW','MENU','LS','RS','D-UP','D-DOWN','D-LEFT','D-RIGHT'];
'@

SubRx @'
  var ax=gp.axes||[],bt=gp.buttons||[];
'@ @'
  var rawAx=gp.axes||[], ax=padRaidAxes(rawAx),bt=gp.buttons||[]; // v28.xx (cw-cx-padpresets): the receiving profile owns the raid sticks.
'@

SubRx @'
  PAD.ax=ax;
'@ @'
  PAD.ax=rawAx; // v28.xx (cw-cx-padpresets): menu navigation always uses the physical left stick.
'@

SubRx @'
  P.padmap={}; for(i=0;i<16;i++) if(m[i]!==i) P.padmap[i]=m[i];
  P.padmapV=1;
'@ @'
  P.padmap={}; for(i=0;i<16;i++) if(m[i]!==i) P.padmap[i]=m[i];
  P.padmapV=1; P.padPreset='custom'; // v28.xx (cw-cx-padpresets): a single rebind leaves the preset.
'@

SubRx @'
function padReset(){ if(P){ P.padmap={}; P.padmapV=1; } PADB.note={t:'set',s:'ALL BUTTONS ARE BACK ON THEIR DEFAULTS.'}; try{ saveProfile(); }catch(_pr){} padLabelsApply(); return true; }
'@ @'
function padReset(){ padPresetApply(0); PADB.note={t:'set',s:'buttons reset'}; return true; } // v28.xx (cw-cx-padpresets): defaults clear lefty too.
'@

SubRx @'
  var sig=padMapArr().join(','), m, k;
'@ @'
  var sig=padMapArr().join(',')+'|'+(P.padSticks||''), m, k; // v28.xx (cw-cx-padpresets): legends follow the sticks too.
'@

SubRx @'
function padLegendBuild(){
  var n=pln, dl=n(14), dr=n(15);
  return [
    ['MOVE',[['L STICK','move, analog'],[n(10),'sprint'],[n(1),'crouch'],[n(0),'dodge roll']]],
    ['FIGHT',[['R STICK','aim'],[n(7),'fire / use selected'],[n(6)+' / '+n(11),'focus aim, hold / toggle'],[(dl==='D-LEFT'&&dr==='D-RIGHT')?'D-LEFT/RIGHT':(dl+' / '+dr),'aim distance'],[n(2),'reload']]],
    ['GEAR',[[n(4)+'/'+n(5)+' tap','change tactical belt slot'],[n(4)+'/'+n(5)+' hold','zoom out / in'],[n(13),'item wheel (hold), revive when down'],[n(8),'backpack']]],
    ['WORLD',[[n(2),'search / open / call for extraction'],[n(3),'search in a ring; hold to finish a pillager bot'],[n(12),'ping (twice: danger); hold: map'],[n(9),'pause']]],
    ['TEAM',[[n(3),'backpack open: drop an item for a teammate'],[n(12),'ping, twice for danger']]]
  ];
}
'@ @'
function padLegendBuild(){
  var n=pln, dl=n(14), dr=n(15);
  return [
    ['MOVE',[[(P.padSticks==='swap'?'R STICK':'L STICK'),'move, analog'],[n(10),'sprint'],[n(1),'crouch'],[n(0),'dodge roll']]],
    ['FIGHT',[[(P.padSticks==='swap'?'L STICK':'R STICK'),'aim'],[n(7),'fire / use selected'],[n(6)+' / '+n(11),'focus aim, hold / toggle'],[(dl==='D-LEFT'&&dr==='D-RIGHT')?'D-LEFT/RIGHT':(dl+' / '+dr),'aim distance'],[n(2),'reload']]],
    ['GEAR',[[n(4)+'/'+n(5)+' tap','change tactical belt slot'],[n(4)+'/'+n(5)+' hold','zoom out / in'],[n(13),'item wheel (hold), revive when down'],[n(8),'backpack']]],
    ['WORLD',[[n(2),'search / open / call for extraction'],[n(3),'search in a ring; hold to finish a pillager bot'],[n(12),'ping (twice: danger); hold: map'],[n(9),'pause']]],
    ['TEAM',[[n(3),'backpack open: drop an item for a teammate'],[n(12),'ping, twice for danger']]]
  ];
}
'@

SubRx @'
function padMiniBuild(){
  var b=pbn, dl=b(14), dr=b(15);
  return [['L STICK','move'],[b(10),'sprint'],[b(1),'crouch'],[b(0),'roll'],[b(7),'fire / use'],[b(6)+' / '+b(11),'focus aim'],[b(2),'reload'],
    [(dl==='D-LEFT'&&dr==='D-RIGHT')?'D-L / D-R':(dl+' / '+dr),'aim distance'],[b(4)+' / '+b(5),'tactical belt'],[b(8),'backpack'],[b(12),'ping, hold: map'],[b(9),'pause']];
}
'@ @'
function padMiniBuild(){
  var b=pbn, dl=b(14), dr=b(15);
  return [[(P.padSticks==='swap'?'R STICK':'L STICK'),'move'],[b(10),'sprint'],[b(1),'crouch'],[b(0),'roll'],[b(7),'fire / use'],[b(6)+' / '+b(11),'focus aim'],[b(2),'reload'],
    [(dl==='D-LEFT'&&dr==='D-RIGHT')?'D-L / D-R':(dl+' / '+dr),'aim distance'],[b(4)+' / '+b(5),'tactical belt'],[b(8),'backpack'],[b(12),'ping, hold: map'],[b(9),'pause']];
}
'@

SubRx @'
function padListBody(){
  var h='', secs=['MOVE','FIGHT','GEAR','WORLD'], s, i, lk=[['MOVE','L STICK'],['AIM','R STICK'],['MENUS: SELECT','A'],['MENUS: BACK','B']];
  for(s=0;s<secs.length;s++){ h+='<div class="keysec">'+secs[s]+'</div>'; for(i=0;i<PAD_ACTS.length;i++) if(PAD_ACTS[i][2]===secs[s]) h+=padRow1(PAD_ACTS[i]); }
  h+='<div class="keysec">LOCKED: THESE KEEP THEIR JOBS</div>';
  for(i=0;i<lk.length;i++) h+='<div class="row"><div style="flex:1"><b>'+lk[i][0]+'</b></div><span class="keyfixed">'+padB(lk[i][1])+'</span></div>';
  return h;
}
'@ @'
function padListBody(){
  // v28.xx (cw-cx-padpresets): one picker, live diagram, original per-action controls below.
  var h='', secs=['MOVE','FIGHT','GEAR','WORLD'], s, i;
  for(s=0;s<secs.length;s++){ h+='<div class="keysec">'+secs[s]+'</div>'; for(i=0;i<PAD_ACTS.length;i++) if(PAD_ACTS[i][2]===secs[s]) h+=padRow1(PAD_ACTS[i]); }
  return padLayoutHtml()+'<div class="padeditgrid"><div class="padactions" data-lint-scroll>'+h+'</div>'+padPictureHtml()+'</div>';
}
'@

SubRx @'
  list.innerHTML=(KEYS.pad?padListBody():keysListHtml()); keysNoteShow();   // v26.xx (padbind): the same window lists the pad buttons in pad mode
'@ @'
  // v28.xx (cw-cx-padpresets): rebuilding the diagram preserves the focused rebind and its scroll position.
  var km=document.getElementById('keysmodal'), old=PAD.focus, keep=old&&list.contains(old)?{id:old.id,k:old.getAttribute('data-k'),rebind:old.classList.contains('rebind')}:null;
  var sc=list.querySelector('.padactions'), st=sc?sc.scrollTop:0;
  if(km) km.classList.toggle('padlayouts',!!KEYS.pad);
  list.innerHTML=(KEYS.pad?padListBody():keysListHtml()); keysNoteShow();
  if(KEYS.pad){
    document.getElementById('padlayout').onclick=function(){ padPresetCycle(1); };
    document.getElementById('padlayoutprev').onclick=function(){ padPresetCycle(-1); };
    document.getElementById('padlayoutnext').onclick=function(){ padPresetCycle(1); };
    sc=list.querySelector('.padactions'); if(sc) sc.scrollTop=st;
    if(keep){ var next=keep.id?document.getElementById(keep.id):list.querySelector((keep.rebind?'.rebind':'.keybtn')+'[data-k="'+keep.k+'"]'); if(next) padSetFocus(next); }
  }
'@

SubRx @'
  if(mv){ var nx=padStep(list,PAD.focus,mv[0],mv[1]); if(nx){ padSetFocus(nx); if(GRAB&&GRAB.pad){ GRAB.moved=1; stashPadGhost(); } } }   // v16.80: a held pad grab moves with the highlight
'@ @'
  // v28.xx (cw-cx-padpresets): the layout row owns horizontal input; the rebind rows remain in the normal pad navigation.
  var lp=md.id==='keysmodal'&&KEYS.pad&&PAD.focus&&/^padlayout/.test(PAD.focus.id||''), lb=tap(4), rb=tap(5);
  if(lp&&((mv&&mv[0])||lb||rb)){ padPresetCycle((mv&&mv[0])?mv[0]:(rb?1:-1)); mv=null; list=padFocusables(md); }
  if(mv){ var nx=(md.id==='keysmodal'&&KEYS.pad&&mv[1])?padLayoutStep(PAD.focus,mv[1]):padStep(list,PAD.focus,mv[0],mv[1]); if(nx){ padSetFocus(nx); if(GRAB&&GRAB.pad){ GRAB.moved=1; stashPadGhost(); } } }
'@

SubRx @'
  try{ var _kh=m.querySelector('h3'), _ks=m.querySelector('.msub'); if(_kh) _kh.textContent=pad?'Pad buttons':'Keys'; if(_ks) _ks.textContent=pad?'Put any action on the pad button you want. The sticks and the menus keep their standard buttons.':'Rebind any action to a keyboard key or a mouse button (middle or side). The controller has its own window: CHANGE PAD BUTTONS.'; }catch(_kt){}
'@ @'
  // v28.xx (cw-cx-padpresets): short labels, no tutorial paragraph above the layout.
  try{ var _kh=m.querySelector('h3'), _ks=m.querySelector('.msub'); if(_kh) _kh.textContent=pad?'pad buttons':'Keys'; if(_ks){ _ks.style.display=pad?'none':''; if(!pad) _ks.textContent='Rebind any action to a keyboard key or a mouse button (middle or side).'; } }catch(_kt){}
'@

SubRx @'
  else s='CLICK REBIND, THEN PRESS THE BUTTON YOU WANT. A BUTTON IN USE SWAPS WITH THE ACTION ON IT. THE UNDERCROFT AND THE MENUS KEEP THE STANDARD BUTTONS.';
'@ @'
  else s=''; // v28.xx (cw-cx-padpresets): the controls name their jobs.
'@

SubRx @'
if(!P.log)P.log=[]; if(!P.contracts)P.contracts=[]; if(!P.pack)P.pack=0; if(!P.hotAssign)P.hotAssign={};
'@ @'
if(!P.log)P.log=[]; if(!P.contracts)P.contracts=[]; if(!P.pack)P.pack=0; if(!P.hotAssign)P.hotAssign={};
padPresetLoad(); // v28.xx (cw-cx-padpresets): legacy profiles keep their button map, with standard sticks.
'@

SubRx @'
var P={credits:900,stash:[],weapons:['pistol'],equipped:'fists',runs:0,ext:0,died:0,best:0,dayMigrated:1,
'@ @'
var P={credits:900,stash:[],weapons:['pistol'],equipped:'fists',runs:0,ext:0,died:0,best:0,dayMigrated:1,
  padPreset:'pillagers',padSticks:'', // v28.xx (cw-cx-padpresets): layouts belong to each profile.
'@

SubRx @'
  #root #keyslist{ max-width:1500px; display:grid; grid-template-columns:repeat(2,minmax(0,1fr)); column-gap:36px; align-content:start; }
'@ @'
  #root #keyslist{ max-width:1500px; display:grid; grid-template-columns:repeat(2,minmax(0,1fr)); column-gap:36px; align-content:start; }
  /* v28.xx (cw-cx-padpresets): 48px layout controls, a scrollable rebind column and a live controller at 1080p. */
  #root #keysmodal.padlayouts #keyslist{display:flex;flex-direction:column;max-width:none;overflow:hidden!important;gap:24px;}
  #root #keysmodal.padlayouts #keysnote:not(.wait):not(.set):not(.clash){display:none;}
  #root #keysmodal.padlayouts .padlayoutrow{display:flex;align-items:center;justify-content:space-between;flex:none;border-bottom:1px solid var(--ui-line);padding:8px 16px 24px;font:600 20px var(--f-cond);}
  #root #keysmodal.padlayouts .padlayoutpick{display:flex;gap:8px;align-items:center;}
  #root #keysmodal.padlayouts .padlayoutpick button{height:48px;min-width:48px;font:600 20px var(--f-cond);}
  #root #keysmodal.padlayouts #padlayout{min-width:240px;color:var(--acc);}
  #root #keysmodal.padlayouts .padeditgrid{display:grid;grid-template-columns:minmax(0,1fr) minmax(0,1.3fr);gap:32px;min-height:0;flex:1;}
  #root #keysmodal.padlayouts .padactions{overflow-y:auto;min-height:0;padding-right:16px;}
  #root #keysmodal.padlayouts .row{min-height:48px;padding:4px 8px;}
  #root #keysmodal.padlayouts .row b{font-size:20px;letter-spacing:0;}
  #root #keysmodal.padlayouts .keybtn{min-width:88px!important;font-size:16px;}
  #root #keysmodal.padlayouts .rebind{min-width:88px;font-size:16px;letter-spacing:0;}
  #root #keysmodal.padlayouts .padpicture{margin:0;min-width:0;display:flex;align-items:center;justify-content:center;background:var(--ui-panel,#16191b);border:1px solid var(--ui-line);border-radius:4px;}
  #root #keysmodal.padlayouts .padpicture svg{width:100%;max-height:100%;}
'@

SubRx @'
var VER='31.83';
'@ @'
var VER='31.84';
'@

$pat = "(?m)^  now:'v31\.83:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.84: Six controller layouts with a live labelled pad, individual rebinds and lefty sticks. Check 31.84 fails on v31.83',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
