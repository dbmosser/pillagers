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

# ARCADE: THE MODE ROW AND BOTH WINDOWS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
      <button class="deploy ghost moderow" id="modecoop" data-mode="coop">2 PLAYER CO-OP (SAME MACHINE)</button>
'@ @'
      <button class="deploy ghost moderow" id="modecoop" data-mode="coop">2 PLAYER CO-OP (SAME MACHINE)</button>
      <button class="deploy ghost moderow" id="modearcade" data-mode="arcade">2 PLAYER ARCADE DEMO</button>
'@

SubRx @'
function netPairOf(q){ var m=(/[?&]pair=([a-z0-9]{4,16})(&|$)/).exec(String(q||'')); return m?m[1]:''; }
'@ @'
function netPairOf(q){ var m=(/[?&]pair=([a-z0-9]{4,16})(&|$)/).exec(String(q||'')); return m?m[1]:''; }
function netArcOf(q){ return (/[?&]arc=1(&|$)/).test(String(q||''))?1:0; }   // v23.24 (arcade5): the player 2 window of the arcade demo
'@

SubRx @'
function netModeName(m){ return (m==='pvp')?'2 PLAYER PVP (SAME MACHINE)':((m==='coop')?'2 PLAYER CO-OP (SAME MACHINE)':''); }
'@ @'
// v23.24 (arcade5): the arcade demo travels as co-op (NET.mode stays coop, so every coop|pvp test is untouched); only its name differs.
function netModeName(m){ if(m==='coop'&&((typeof ARCADE==='object'&&ARCADE&&ARCADE.on)||NET.arcPick||NET.arcBoot)) return '2 PLAYER ARCADE DEMO'; return (m==='pvp')?'2 PLAYER PVP (SAME MACHINE)':((m==='coop')?'2 PLAYER CO-OP (SAME MACHINE)':''); }
'@

SubRx @'
  return base+'?p2=1&mode='+((mode==='pvp')?'pvp':'coop')+'&pair='+String(pair||'');
'@ @'
  return base+'?p2=1&mode='+((mode==='pvp')?'pvp':'coop')+'&pair='+String(pair||'')+((NET.arcPick&&mode!=='pvp')?'&arc=1':'');   // v23.24 (arcade5): &arc=1
'@

SubRx @'
  if(m.t==='snd'){ NET.sndOther=(m.on===1||m.on===true)?1:0; netRefresh(); return 'snd'; }   // v15.78: the other window says whether its sound is on
'@ @'
  if(m.t==='snd'){ NET.sndOther=(m.on===1||m.on===true)?1:0; netRefresh(); return 'snd'; }   // v15.78: the other window says whether its sound is on
  if(m.t.indexOf('arc')===0) return arcadeOnMsg(m);   // v23.24 (arcade5): the arcade words (arcon, arcoff, arcbusy, arcjoin and the later ones)
'@

SubRx @'
      netSndPost();   // v15.78: and whether this window's sound is on
'@ @'
      netSndPost();   // v15.78: and whether this window's sound is on
      if(typeof ARCADE==='object'&&ARCADE&&ARCADE.on&&ARCADE.role==='host') netSamePost({t:'arcon',pair:NET.pair});   // v23.24 (arcade5): so a rebooted player 2 window always rejoins the arcade
'@

SubRx @'
  NET.mode=(mode==='coop'||mode==='pvp')?mode:(netModeOf(q)||'coop');
'@ @'
  NET.mode=(mode==='coop'||mode==='pvp')?mode:(netModeOf(q)||'coop');
  NET.arcBoot=netArcOf(q);   // v23.24 (arcade5): opened by the arcade row, so the window is named the arcade demo until arcon comes
'@

SubRx @'
  var co=g('modecoop'), pv=g('modepvp'), rt=g('moderetry'), st=g('titlestart'), pl=g('p2line'), hide=['modecoop','modecoopsrv','modepvp','modepvpsrv'], i, el, r;
  NET.start=(typeof startFn==='function')?startFn:null;
  if(co) co.onclick=function(){ netSamePick('coop'); };
  if(pv) pv.onclick=function(){ netSamePick('pvp'); };
  if(rt) rt.onclick=function(){ netSamePick(NET.pick||'coop'); };
'@ @'
  // v23.24 (arcade5): the 2 PLAYER ARCADE DEMO row (arcadePick), its RETRY, and hidden in the player 2 window like the other rows.
  var co=g('modecoop'), pv=g('modepvp'), ar=g('modearcade'), rt=g('moderetry'), st=g('titlestart'), pl=g('p2line'), hide=['modecoop','modecoopsrv','modepvp','modepvpsrv','modearcade'], i, el, r;
  NET.start=(typeof startFn==='function')?startFn:null;
  if(co) co.onclick=function(){ NET.arcPick=0; netSamePick('coop'); };
  if(pv) pv.onclick=function(){ NET.arcPick=0; netSamePick('pvp'); };
  if(ar) ar.onclick=function(){ arcadePick(); };
  if(rt) rt.onclick=function(){ if(NET.arcPick) arcadePick(); else netSamePick(NET.pick||'coop'); };
'@

SubRx @'
    if(ATT.on){ try{ e.preventDefault(); e.stopImmediatePropagation(); }catch(_x){} }   // the press that stops the clip does nothing else
'@ @'
    if(typeof ARCADE==='object'&&ARCADE&&ARCADE.on){ try{ arcadeKeyAtt(e); }catch(_ak){} return; }   // v23.24 (arcade5): in the arcade a press drops the host in
    if(ATT.on){ try{ e.preventDefault(); e.stopImmediatePropagation(); }catch(_x){} }   // the press that stops the clip does nothing else
'@

SubRx @'
try{ window.addEventListener('mousemove',function(e){ if(ATT.mx<0||
'@ @'
// v23.24 (arcade5): in the arcade a mousemove never drops in and never stops the demo.
try{ window.addEventListener('mousemove',function(e){ if(typeof ARCADE==='object'&&ARCADE&&ARCADE.on) return; if(ATT.mx<0||
'@

SubRx @'
function attTick(){
  var gp, i, j, a;
'@ @'
function attTick(){
  var gp, i, j, a;
  if(typeof ARCADE==='object'&&ARCADE&&ARCADE.on){ try{ arcadeAttTick(); }catch(_aat){} return; }   // v23.24 (arcade5)
'@

SubRx @'
  if(typeof ATT!=='undefined'&&ATT&&ATT.on){
    var _atb=false, _ati;
'@ @'
  if(typeof ATT!=='undefined'&&ATT&&ATT.on){
    var _atb=false, _ati;
    // v23.24 (arcade5): in the arcade attract a new press on this window pad drops the host in (any button) or joins player 2 (A),
    // with its own PAD.prev latch so the press does nothing else.
    if(typeof ARCADE==='object'&&ARCADE&&ARCADE.on){
      var _arn=false, _ar0=pressed(0)&&!PAD.prev[0];
      for(_ati=0;_ati<bt.length;_ati++) if(pressed(_ati)&&!PAD.prev[_ati]) _arn=true;
      for(_ati=0;_ati<bt.length;_ati++) PAD.prev[_ati]=pressed(_ati);
      padRelease();
      try{ arcadePadAtt(_arn,_ar0); }catch(_apa){}
      return;
    }
'@

SubRx @'
// Leaving the arcade: the arcade raid stops, then the sandbox out puts his profile and his dials back.
function arcadeLeave(){
  if(!ARCADE.on) return false;
  var hadRaid=arcadeRaidStop('leave'), r=arcadeSandboxOut();
  if(hadRaid){ try{ showScreen('hub'); }catch(_sh2){} }
  return r;
}
'@ @'
// v23.24, HIS ORDER (2026-10-11), build 5 of 20 (arcade5): THE MODE ROW AND BOTH WINDOWS IN ARCADE. The title has a 2 PLAYER ARCADE
// DEMO row under the co-op row. It opens the player 2 window exactly as co-op does (netSamePick, NET.mode stays coop, the address
// gains &arc=1), takes the title down and enters the arcade (arcadeEnter): the sandbox, the dial overlay, his last sector, no
// what is new card, and the arcade attract over everything. The host tells the player 2 window arcon on entry and again on every
// ready, and player 2 enters the arcade on arcon (or answers arcbusy from the middle of a normal raid) and leaves on arcoff.
// In the host window any key, click, touch or pad button drops straight into an arcade raid; F1 to F12, the modifier keys and
// browser shortcuts do not, and a mousemove or the wheel never does. In the player 2 window only A on its own pad counts (it
// asks to join with arcjoin, answered in a later build), and its keys still go on to player 1.
function arcadePick(){
  NET.arcPick=1;
  var r=netSamePick('coop',function(){ WNSEEN=1; try{ if(typeof NET.start==='function') NET.start(); }catch(_ns){} arcadeEnter('host'); });
  if(r==='p2'||r==='unsupported') NET.arcPick=0;
  return r;
}
function arcadeEnter(role){
  role=(role==='p2')?'p2':'host';
  var mi=(P&&typeof P.mapIx==='number')?P.mapIx:0;
  WNSEEN=1;
  if(!ARCADE.on){
    if(role==='p2'&&titleOn()&&typeof NET.start==='function'){ try{ NET.start(); }catch(_ns2){} }   // player 2 leaves its title for the floor first
    if(!arcadeSandboxIn(role)) return false;
    ARCADE.mapIx=clamp(mi|0,0,FIXED_MAPS.length-1);   // his last sector
  }
  arcadeCfgIn();
  ARCADE.wantIn=0;
  if(ARCADE.role==='host') netSamePost({t:'arcon',pair:NET.pair});
  arcadeAttShow();
  return true;
}
// The arcade words on the pair channel (netSameOnMsg hands every word starting arc here, pair already checked).
function arcadeOnMsg(m){
  if(!m||typeof m.t!=='string') return 'bad';
  if(NET.same==='p2'){
    if(m.t==='arcon'){
      if(G&&!G.arcade&&!G.over&&!G.sim){ netSamePost({t:'arcbusy',pair:NET.pair}); return 'busy'; }
      return arcadeEnter('p2')?'arcon':'fail';
    }
    if(m.t==='arcoff') return arcadeLeave()?'arcoff':'ignored';
    return 'ignored';
  }
  if(NET.same==='host'){
    if(m.t==='arcbusy'){ try{ say('PLAYER 2 IS IN A RAID','warn'); }catch(_sb){} return 'busy'; }
    return 'ignored';
  }
  return 'off';
}
// The arcade attract: the attract overlay with the clip when there is one, PRESS ANY BUTTON (host) or PLAYER 2: PRESS A, up
// whenever this window has no arcade raid.
function arcadeAttShow(){
  var d=attEl(), v=d.querySelector('video'), ap=d.querySelector('.attpress'), w=(ARCADE.role==='p2')?'PLAYER 2: PRESS A':'PRESS ANY BUTTON', pr;
  if(ap&&ap.textContent!==w) ap.textContent=w;
  ATT.on=true; if(d.style.display!=='block') d.style.display='block';
  if(ATT.src){
    if(v.getAttribute('src')!==ATT.src) v.setAttribute('src',ATT.src);
    if(v.paused){ try{ pr=v.play(); if(pr&&pr.catch) pr.catch(function(){}); }catch(_vp){} }
  } else if(!ATT.tried){ try{ attStart(); }catch(_st){} }
  return true;
}
function arcadeAttTick(){
  if(!ARCADE.on) return;
  if(G&&G.arcade){ if(ATT.on) attStop(); return; }
  arcadeAttShow();
}
// A key, click, touch or wheel in this window while the arcade is on. Returns whether it was taken.
function arcadeKeyAtt(e){
  if(!ARCADE.on||!e) return false;
  if(G&&G.arcade) return false;            // a raid is on here: the key plays
  if(ARCADE.role!=='host') return false;   // player 2 joins with A on its own pad; its keys go on to player 1 (netKeyFwd)
  var ty=String(e.type||''), cd=String(e.code||''), ky=String(e.key||'');
  if(ty==='wheel') return false;
  if(ty==='keydown'){
    if(/^F([1-9]|1[0-2])$/.test(cd)) return false;   // F9 records, F11 fullscreens
    if(e.ctrlKey||e.altKey||e.metaKey) return false;  // browser shortcuts
    if(/^(Shift|Control|Alt|Meta|OS|CapsLock|NumLock|ScrollLock|ContextMenu)/.test(cd)||/^(Shift|Control|Alt|Meta|OS|CapsLock)$/.test(ky)) return false;
  }
  try{ e.preventDefault(); e.stopImmediatePropagation(); }catch(_x){}   // the press that drops in does nothing else
  if(ty==='keydown'&&e.repeat) return true;
  arcadeDropIn();
  return true;
}
// A new press on this window pad in the arcade attract.
function arcadePadAtt(anyNew,aNew){
  if(!ARCADE.on) return false;
  if(ARCADE.role==='p2'){ if(!aNew) return false; ARCADE.wantIn=1; netSamePost({t:'arcjoin',pair:NET.pair}); return true; }
  return anyNew?arcadeDropIn():false;
}
// The host drops straight into an arcade raid: no title, no character select, no kit question.
function arcadeDropIn(){
  if(!ARCADE.on||ARCADE.role!=='host') return false;
  if(G&&(G.arcade||!G.over)) return false;
  var ok=false;
  try{ attStop(); }catch(_as){}
  try{ ok=arcadeDeploy({role:'host'}); }catch(_ad){ ok=false; }
  if(!ok){ try{ arcadeAttShow(); }catch(_ar){} }
  return ok;
}
// Leaving the arcade: the arcade raid stops, then the sandbox out puts his profile and his dials back. v23.24: the host tells
// player 2 (arcoff), and the attract goes.
function arcadeLeave(){
  if(!ARCADE.on) return false;
  if(ARCADE.role==='host') netSamePost({t:'arcoff',pair:NET.pair});
  var hadRaid=arcadeRaidStop('leave'), r=arcadeSandboxOut();
  try{ if(ATT.on) attStop(); ATT.last=Date.now(); }catch(_at){}
  NET.arcPick=0; NET.arcBoot=0; ARCADE.wantIn=0;
  if(hadRaid){ try{ showScreen('hub'); }catch(_sh2){} }
  return r;
}
'@

SubRx @'
var VER='23.23';
'@ @'
var VER='23.24';
'@

$pat = "(?m)^  now:'v23\.23:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.24: The title has a 2 PLAYER ARCADE DEMO row: any key or button drops you straight into an arcade raid. Check 23.24 fails on v23.23',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
