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

# SETTINGS IN SECTIONS, WITH THREE NEW SOUND ROWS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  {k:'rumble', label:'Controller rumble',
'@ @'
  // v26.xx (settings1), HIS ORDER 2026-10-14 ("ok add all this stuff to settings"): THE AUDIO ROWS. Effects volume (Guns, footsteps, hits and the
  // world) is the SFX slider and stays; these add the menu and HUD sounds on their own level, the footsteps on their own level (yours and
  // the ones you hear), and a MONO switch for one ear or one speaker. Defaults are today: full, full, off. UI rides the HUD bus (volApply),
  // the footsteps scale inside blip, and MONO folds the output to one channel and drops every pan.
  {k:'volUi', label:'UI VOLUME', sec:'AUDIO',
   hint:'MENU CLICKS AND HUD PINGS: PICKUPS, HIT TICKS AND THE CLOCK. ON TOP OF EFFECTS VOLUME.',
   opts:[
     {n:'OFF',  cfg:{volUi:0}},
     {n:'25%',  cfg:{volUi:0.25}},
     {n:'50%',  cfg:{volUi:0.5}},
     {n:'75%',  cfg:{volUi:0.75}},
     {n:'FULL', cfg:{volUi:1}}
   ], def:4},
  {k:'volFoot', label:'FOOTSTEPS VOLUME', sec:'AUDIO',
   hint:'YOUR STEPS AND THE STEPS YOU HEAR. LOWER IS QUIETER FEET ALL ROUND.',
   opts:[
     {n:'OFF',  cfg:{volFoot:0}},
     {n:'25%',  cfg:{volFoot:0.25}},
     {n:'50%',  cfg:{volFoot:0.5}},
     {n:'75%',  cfg:{volFoot:0.75}},
     {n:'FULL', cfg:{volFoot:1}}
   ], def:4},
  {k:'mono', label:'MONO AUDIO', sec:'AUDIO',
   hint:'ONE CHANNEL FOR EVERYTHING, NO LEFT OR RIGHT. FOR ONE EAR OR ONE SPEAKER.',
   opts:[
     {n:'OFF', cfg:{mono:0}},
     {n:'ON',  cfg:{mono:1}}
   ], def:0},
  {k:'rumble', label:'Controller rumble',
'@

SubRx @'
var VOL_LAST='';
'@ @'
var VOL_LAST='';
// v26.xx (settings1): MONO. One channel for the whole output (the destination mixes down to one, so music, world and menus all come out the same
// on both sides), and every pan the game places goes to the middle (earsOf, blip, the machine voices). Not in a same machine pair, whose split
// speakers are the point of that mode.
function monoOn(){ return CFG.mono===1&&!(typeof NET==='object'&&NET&&NET.same); }
function monoApply(){
  var d=(typeof AC!=='undefined'&&AC&&AC.destination)?AC.destination:null, want;
  if(!d) return false;
  want=monoOn()?1:Math.max(1,Math.min(2,+d.maxChannelCount||2));
  try{ if(d.channelCount!==want) d.channelCount=want; }catch(_mc){ return false; }
  return true;
}
'@

SubRx @'
  if(BUS&&BUS.gain){ try{ if(BUS.gain.value!==m*f) BUS.gain.value=m*f; }catch(_vb){} }
'@ @'
  if(BUS&&BUS.gain){ try{ if(BUS.gain.value!==m*f) BUS.gain.value=m*f; }catch(_vb){} }
  try{ if(SND&&SND.bus&&SND.bus.ui&&SND.bus.ui.gain){ var _vu=volOf('volUi'); if(SND.bus.ui.gain.value!==_vu) SND.bus.ui.gain.value=_vu; } }catch(_vu2){}   // v26.xx (settings1): UI VOLUME is the HUD bus, which nothing ducks
  try{ monoApply(); }catch(_vm2){}   // v26.xx (settings1): MONO AUDIO
'@

SubRx @'
gn=a.createGain(); gn.gain.value=1; gn.connect((c==='ui'||c==='sting')?B:S.world);
'@ @'
gn=a.createGain(); gn.gain.value=(c==='ui')?volOf('volUi'):1; gn.connect((c==='ui'||c==='sting')?B:S.world);
'@

SubRx @'
return {d:d,pan:clamp(dx/520,-1,1)};
'@ @'
return {d:d,pan:(CFG.mono===1)?0:clamp(dx/520,-1,1)};   // v26.xx (settings1): MONO AUDIO
'@

SubRx @'
pn.pan.value=clamp(pan*(SND_CTX?SND_CTX.panK:1),-1,1);
'@ @'
pn.pan.value=clamp(pan*(SND_CTX?SND_CTX.panK:1)*(CFG.mono===1?0:1),-1,1);
'@

SubRx @'
v.pn.pan.setTargetAtTime(clamp((near.x-p.x)/520*(pl.panK||1),-1,1),t,0.08);
'@ @'
v.pn.pan.setTargetAtTime(clamp((near.x-p.x)/520*(pl.panK||1)*(CFG.mono===1?0:1),-1,1),t,0.08);
'@

SubRx @'
if(vol<=.02) return;
'@ @'
vol*=((type==='foot'||type==='step'||type==='stepHeavy')?volOf('volFoot'):1);   // v26.xx (settings1): FOOTSTEPS VOLUME, the steps you make and the ones you hear
  if(vol<=.02) return;
'@

SubRx @'
function renderSettingsInner(host){
'@ @'
// v26.xx (settings1), HIS ORDER 2026-10-14 ("ok add all this stuff to settings, including rebinding keys and controller"): SETTINGS IN SECTIONS.
// The page was one list under THE RAID, with the sound, picture and pad rows in the order they were added. It reads in sections now: THE RAID
// first (how the game plays), then AUDIO, CONTROLS, CONTROLLER, DISPLAY and ACCESSIBILITY, each with a head like THE RAID has, under a jump bar
// that scrolls to a section (one with no rows is not drawn). A GAMEOPTS row names its section (sec); the rows older builds added are listed in
// SETSEC_OF; the rows that are not GAMEOPTS (Keys, Text size, Stash layout, Music) are put in theirs by data-mv. The kid menu, the backup and the
// tools follow under SAVES AND TOOLS. Nothing about a row changed: the same ids, the same clicks, the same saves.
var SETSEC=['THE RAID','AUDIO','CONTROLS','CONTROLLER','DISPLAY','ACCESSIBILITY'];
var SETSEC_OF={textEdit:'THE RAID',superhot:'THE RAID',sharedSight:'THE RAID',raiders:'THE RAID',robots:'THE RAID',hits:'THE RAID',clock:'THE RAID',loot:'THE RAID',ext:'THE RAID',
  volMaster:'AUDIO',volMusic:'AUDIO',volFx:'AUDIO',rumble:'CONTROLLER',
  gfxScale:'DISPLAY',gfxAuto:'DISPLAY',fpsCap:'DISPLAY',fxLevel:'DISPLAY',gfxLight:'DISPLAY',gfxPost:'DISPLAY',fxInt:'DISPLAY',hudTv:'DISPLAY',minimap:'DISPLAY'};
function setSecOf(r){ return (r&&r.sec)||SETSEC_OF[r&&r.k]||'THE RAID'; }
function setSecId(n){ return 'setsec_'+String(n).replace(/ /g,'_'); }
function setSecHead(n){ return '<div class="row" id="'+setSecId(n)+'" style="opacity:.7"><div style="flex:1"><b>'+n+'</b></div></div>'; }
function setSecsHtml(S,X){
  var h='', j='', i, n, b;
  for(i=0;i<SETSEC.length;i++){
    n=SETSEC[i]; b=(S[n]||'')+((X&&X[n])||'');
    if(!b) continue;
    h+=setSecHead(n)+b; j+='<button type="button" data-sec="'+n+'">'+n+'</button>';
  }
  return '<div class="row setjump"><div class="sj">'+j+'</div></div>'+h+'<div id="setsec_end"></div>';
}
function setSecJump(host,n){
  // measured in the same pixels the rectangles use (the menu zoom makes a scrollTop pixel and a rectangle pixel differ), a few passes to settle
  var h=document.getElementById(setSecId(n)), bar=host.querySelector('.setjump'), i, d, s0;
  if(!h) return false;
  for(i=0;i<6;i++){
    d=h.getBoundingClientRect().top-host.getBoundingClientRect().top-(bar?bar.getBoundingClientRect().height:0);
    if(Math.abs(d)<1.5) break;
    s0=host.scrollTop; host.scrollTop=s0+d;
    if(host.scrollTop===s0) break;
  }
  return true;
}
function setSecMove(host){
  var mv=host.querySelectorAll('[data-mv]'), i, r, s, n, nx;
  for(i=0;i<mv.length;i++){
    r=mv[i]; s=r.getAttribute('data-mv'); r.removeAttribute('data-mv'); nx=null;
    for(n=SETSEC.indexOf(s)+1;n<SETSEC.length&&!nx;n++) nx=document.getElementById(setSecId(SETSEC[n]));
    if(!nx) nx=document.getElementById('setsec_end');
    if(nx&&nx.parentNode) nx.parentNode.insertBefore(r,nx);
  }
  [].forEach.call(host.querySelectorAll('.setjump button'),function(b){ b.onclick=function(){ setSecJump(host,b.getAttribute('data-sec')); }; });
}
function renderSettingsInner(host){
'@

SubRx @'
var _go='<div class="row" style="opacity:.7"><div style="flex:1"><b>THE RAID</b></div></div>';
'@ @'
  var _go='', _SEC={};   // v26.xx (settings1): the rows are gathered by section (setSecsHtml), THE RAID head is one of them now
'@

SubRx @'
if(_gr.k==='textEdit'&&!DEV_LOCAL) continue;
'@ @'
if(_gr.k==='textEdit'&&!DEV_LOCAL) continue;
    if(typeof _gr.show==='function'&&!_gr.show()) continue;   // v26.xx (settings1): a row that does not apply here (no vibration) is not drawn
'@

SubRx @'
    _go+='<div class="row"><div style="flex:1"><b>'+_gr.label+'</b>'+
'@ @'
    var _sk=setSecOf(_gr); _SEC[_sk]=(_SEC[_sk]||'')+'<div class="row"><div style="flex:1"><b>'+_gr.label+'</b>'+
'@

SubRx @'
host.innerHTML=_go+keysRowHtml()+kidHeadHtml()
'@ @'
host.innerHTML=setSecsHtml(_SEC,{CONTROLS:keysRowHtml()})+kidHeadHtml()
'@

SubRx @'
<div class="row"><div style="flex:1"><b>Text size</b>
'@ @'
<div class="row" data-mv="DISPLAY"><div style="flex:1"><b>Text size</b>
'@

SubRx @'
<div class="row"><div style="flex:1"><b>Stash layout</b>
'@ @'
<div class="row" data-mv="DISPLAY"><div style="flex:1"><b>Stash layout</b>
'@

SubRx @'
<div class="row"><div style="flex:1"><b>Music</b>
'@ @'
<div class="row" data-mv="AUDIO"><div style="flex:1"><b>Music</b>
'@

SubRx @'
'<div class="row"><div style="flex:1"><b>Auto-export the flight recorder</b>
'@ @'
setSecHead('SAVES AND TOOLS')+'<div class="row"><div style="flex:1"><b>Auto-export the flight recorder</b>
'@

SubRx @'
  document.getElementById('set_tune').onclick=function(){ toggleTune(true); };
'@ @'
  setSecMove(host);   // v26.xx (settings1): Text size, Stash layout and Music go to their sections; the jump bar is wired
  document.getElementById('set_tune').onclick=function(){ toggleTune(true); };
'@

SubRx @'
  #root #setdetail .sdh{ margin-top:18px; font-size:17px; line-height:1.6; color:var(--tx-2); }
'@ @'
  #root #setdetail .sdh{ margin-top:18px; font-size:17px; line-height:1.6; color:var(--tx-2); }
  /* v26.xx (settings1), HIS ORDER 2026-10-14: SETTINGS IN SECTIONS. A jump bar sticks to the top of the list (one chamfered chip a section, as the
     REBIND controls are cut), and every section head after the first has a hairline over it and room to breathe. */
  #root #setlist .setjump{ position:sticky; top:0; z-index:3; display:block; min-height:0; padding:10px 16px; border-bottom:1px solid var(--ui-line); background:var(--ui-panel); }
  #root #setlist .setjump .sj{ display:flex; flex-wrap:wrap; gap:8px; }
  #root #setlist .setjump button{ min-width:0 !important; min-height:34px; padding:4px 18px; border:1px solid var(--ui-line-hi); background:rgba(0,0,0,.35); color:var(--tx-2);
    font-family:var(--f-cond); font-weight:700; font-size:14px; letter-spacing:.16em; clip-path:polygon(9px 0,100% 0,100% 100%,0 100%,0 9px); }
  #root #setlist .setjump button:hover:not(:disabled){ color:var(--acc); border-color:var(--acc); background:var(--ui-hover); }
  #root #setlist .row[style*="opacity:.7"]{ margin-top:14px; border-top:1px solid var(--ui-line); padding-top:24px; }
  #root #setlist .setjump + .row[style*="opacity:.7"]{ margin-top:0; border-top:0; padding-top:16px; }
'@

SubRx @'
var VER='26.37';
'@ @'
var VER='26.38';
'@

$pat = "(?m)^  now:'v26\.37:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.38: Settings is in sections with a jump bar, and AUDIO has UI volume, footsteps volume and mono. Check 26.38 fails on v26.37',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
