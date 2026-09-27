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

# KID FIRING FOR PLAYER 2 (stability pass, 2026-09-27; drafted by a review agent, reviewed by a second).

SubRx @'
// v16.43, THE CO-OP LIST (item 3): A PING. N or the middle mouse button (both bumpers on a controller) marks the point under the
'@ @'
// v16.83, HIS ORDER: AUTO-FIRE FOR PLAYER 2. A Settings row beside Kid mode, OFF out of the box, saved with the profile like kid
// mode (P.p2Auto). Either window can set it: the host sends its choice in the world word twice a second (m.af, netWorldSend) and a
// linked window keeps it as NET.afHost, so the mode is on when either window has it on. It acts only in a linked window with
// NET.role join: every raid frame netAutoFire (called from updatePlayer before the face is read) puts the cursor on the nearest
// enemy in gun range with a clear line, the way the controller places its virtual cursor (a screen point off the camera, so aim,
// focus aim and the shot all follow), and holds the trigger the way RT does (mouse.down, marked PAD.afire so letting go clears
// only what it set). A gun that is not automatic gets the trigger released for one frame after each round, so the next pull
// comes at the rate the mouse path already enforces. Nothing fires under the open backpack or map, paused, downed, over,
// reloading, jammed, cooking a grenade, with no rounds anywhere, or with anything but a gun cell up; the Peddler, a survivor, a
// merc, a teammate and a peaceful pillager are never targets. Player 2 still moves, rolls, loots and reloads; player 1 and the
// host window never reach any of it.
function afOwn(){ return !!(typeof P!=='undefined'&&P&&P.p2Auto); }
function netAfOn(){ return !!(typeof NET==='object'&&NET&&NET.on&&NET.role==='join'&&(afOwn()||NET.afHost===1)); }
function afCycle(){ P.p2Auto=afOwn()?0:1; saveProfile(); return P.p2Auto; }
function afRowHtml(){
  var on=afOwn();
  return '<div class="row"><div style="flex:1"><b>Kid firing</b><div class="hint">Player 2 aims at the nearest enemy in sight and shoots by itself, until he aims with the right stick himself. Moving, rolling, looting and reloading stay on the controller. Player 1 is not changed. Either window can set it, and it changes the raid at once.</div></div>'+
    '<button id="set_af" style="padding:6px 12px;min-width:92px'+(on?';color:var(--amber)':'')+'">'+(on?'ON':'OFF')+'</button></div>';
}
function afTarget(p){
  var i, e, d, best=null, bd, segs;
  if(!p||!p.wep||!(p.wep.rng>0)||typeof G==='undefined'||!G||!G.ents) return null;
  bd=p.wep.rng; segs=G.vseg||(G.map&&G.map.segs)||[];
  for(i=0;i<G.ents.length;i++){
    e=G.ents[i];
    if(!e||!(e.hp>0)||e.downed||e.finished||e.merc||e.friendlyPC||e.neutral||e.kind==='peddler'||e.kind==='stray') continue;
    if(e.kind==='raider'&&!e.hostile) continue;   // a peaceful man is not in your fight; a machine has no hostile word on the host and reads false on a linked window (bit 16 of the host flags), so it is read for pillagers only
    d=dist(p,e); if(d>=bd) continue;
    if(!losClear(p.x,p.y,e.x,e.y,segs)) continue;
    bd=d; best=e;
  }
  return best;
}
function netAutoFire(p){
  var e=null, pz, cx, cy, held, hs;
  if(!netAfOn()){ if(PAD.afire){ PAD.afire=0; if(!PAD.firing) mouse.down=false; } return null; }
  if(PAD.aiming) PAD.afRsT=G.t;   // v16.83, his rule: player 2 aiming with the right stick takes over from kid firing
  if(PAD.afRsT!=null&&G.t-PAD.afRsT<0.6){ if(PAD.afire){ PAD.afire=0; if(!PAD.firing) mouse.down=false; } return null; }   // and for a moment after he lets go
  if(p&&!G.over&&!G.paused&&!G.mapOpen&&!G.bagOpen&&!p.downed&&!(p.reloading>0)&&!(p.jam>0)&&!p.cooking&&p.wep&&p.wep.mag>0&&(p.ammo>0||p.reserve>0)){
    hs=hotbarSlots()[hotSel()];
    if(hs&&hs.kind==='gun') e=afTarget(p);
  }
  if(!e){ if(PAD.afire){ PAD.afire=0; if(!PAD.firing) mouse.down=false; } return null; }
  pz=ZOOM();
  cx=(G.camX===undefined?p.x-W/(2*pz):G.camX);
  cy=(G.camY===undefined?p.y-H/pz*0.54:G.camY);
  mouse.x=(e.x-cx)*pz; mouse.y=(e.y-cy)*pz; mouse.init=true;
  held=!(!p.wep.auto&&p.fired&&(G.t*1000-(p.lastShot||0))>p.wep.rof);   // not automatic: let go for a frame after each round, so the next pull comes at the gun rate
  mouse.down=held||!!PAD.firing; PAD.afire=1; PAD.adsT=0.35;
  return e;
}
// v16.43, THE CO-OP LIST (item 3): A PING. N or the middle mouse button (both bumpers on a controller) marks the point under the
'@

SubRx @'
  var _aw=mouseWorld();
'@ @'
  netAutoFire(p);   // v16.83, his order: auto-fire for player 2 puts the cursor and the trigger down before the face is read
  var _aw=mouseWorld();
'@

SubRx @'
  m.kd=kidMulOwn();   // v16.44: kid mode as the host has it, live
'@ @'
  m.kd=kidMulOwn();   // v16.44: kid mode as the host has it, live
  m.af=afOwn()?1:0;   // v16.83, his order: auto-fire for player 2 as the host has it, live
'@

SubRx @'
  if(typeof m.kd==='number'&&isFinite(m.kd)) NET.kidHost=clamp(m.kd,0.1,1);   // v16.44: kid mode as the host has it
'@ @'
  if(typeof m.kd==='number'&&isFinite(m.kd)) NET.kidHost=clamp(m.kd,0.1,1);   // v16.44: kid mode as the host has it
  if(m.af===0||m.af===1) NET.afHost=m.af;   // v16.83, his order: auto-fire for player 2 as the host has it
'@

SubRx @'
  host.innerHTML=_go+kidRowHtml()+
'@ @'
  host.innerHTML=_go+kidRowHtml()+afRowHtml()+
'@

SubRx @'
  (function(){ var _kb=document.getElementById('set_kid'); if(_kb) _kb.onclick=function(){ kidCycle(); renderSettings(); }; })();   // v16.44
'@ @'
  (function(){ var _kb=document.getElementById('set_kid'); if(_kb) _kb.onclick=function(){ kidCycle(); renderSettings(); }; })();   // v16.44
  (function(){ var _ab=document.getElementById('set_af'); if(_ab) _ab.onclick=function(){ afCycle(); renderSettings(); }; })();   // v16.83, his order: auto-fire for player 2
'@

SubRx @'
var VER='16.82';
'@ @'
var VER='16.83';
'@

$pat = "(?m)^  now:'v16\.82:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.83: KID FIRING FOR PLAYER 2. His order during his co-op session: a Settings row beside Kid mode, off out of the box, that player 2 usually turns on himself. With it on, player 2 aims at the nearest enemy in sight and in range and shoots by itself, and the moment he aims with the right stick himself it lets go and he aims, coming back half a second after he rests the stick. Player 1 is never changed. Check 16.83 fails on v16.82',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
