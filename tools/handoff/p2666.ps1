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

# RICOCHET OFF STEEL (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function updateBullets(dt){
'@ @'
// v26.xx (feel18), HIS ORDER (2026-10-14): "ricochet off steel ok". A ROUND OF YOURS GLANCES OFF STEEL ONCE. A round the player fired that reaches a metal
// wall (a locked-room wall, a keyed door or a vehicle wreck: matOf says metal) at a glancing angle, no closer to head-on than RICO_MAXDOT of the wall
// face (about 35 degrees off the face normal or more), does not die there: it turns about the face, keeps RICO_DMG of its damage, flies on for
// at most RICO_LIFE seconds more, and throws a bright spark and a ping. Once per round (b._rico). A head-on round, a round on concrete or wood,
// any round an enemy fires and every round in a sim raid behave exactly as before; a glancing round at a wreck that would have punched through now
// glances instead. The wall is still damaged by the strike. Live play only; no seeded draw.
var RICO_MAXDOT=0.82, RICO_DMG=0.6, RICO_LIFE=0.4;
function ricoFace(b,w,ux,uy){
  var dN, dS, dW, dE, m, nx=0, ny=0, dot;
  if(!b||!w||!G||G.sim||!b.player||b._rico||matOf(w)!=='metal') return null;
  dN=Math.abs(b.y-w.y); dS=Math.abs(b.y-(w.y+w.h)); dW=Math.abs(b.x-w.x); dE=Math.abs(b.x-(w.x+w.w));
  m=Math.min(dN,dS,dW,dE);
  if(m===dN) ny=-1; else if(m===dS) ny=1; else if(m===dW) nx=-1; else nx=1;
  dot=ux*nx+uy*ny;
  if(!(dot<0)||-dot>RICO_MAXDOT) return null;
  return {nx:nx,ny:ny};
}
function ricoPing(x,y){
  var a, out, t, o, g, d;
  if((G&&G.sim)||(typeof NET==='object'&&NET&&NET.specTick)) return;
  d=dist(G.player,{x:x,y:y}); if(d>900) return;
  a=ac(); if(!a) return; out=sndBus('gun'); if(!out) return;
  try{
    t=a.currentTime; o=a.createOscillator(); g=a.createGain();
    o.type='sine'; o.frequency.setValueAtTime(3200,t); o.frequency.exponentialRampToValueAtTime(1900,t+0.16);
    g.gain.setValueAtTime(0.0001,t); g.gain.linearRampToValueAtTime(0.06*(1-d/1000),t+0.004); g.gain.exponentialRampToValueAtTime(0.001,t+0.18);
    o.connect(g); g.connect(out); o.start(t); o.stop(t+0.2);
  }catch(e){}
}
function ricochetOff(b,w,ux,uy){
  var F=ricoFace(b,w,ux,uy), dv;
  if(!F) return false;
  dv=b.vx*F.nx+b.vy*F.ny;
  b.vx-=2*dv*F.nx; b.vy-=2*dv*F.ny;
  b.x+=F.nx*2; b.y+=F.ny*2;
  b.dmg*=RICO_DMG; b._rico=1; b.life=Math.min(b.life,RICO_LIFE);
  try{ spark(b.x,b.y,'#fff0c0',12,320); ricoPing(b.x,b.y); }catch(_r){}
  return true;
}
function updateBullets(dt){
'@

SubRx @'
        var _pf=penFactor(_struck);
'@ @'
        var _pf=ricoFace(b,_struck,ux,uy)?null:penFactor(_struck);   // v26.xx (feel18): a glancing round at steel glances, it does not punch through
'@

SubRx @'
          sfx("clank",b.x,b.y,matOf(_struck)); hit=true;
'@ @'
          sfx("clank",b.x,b.y,matOf(_struck));
          if(ricochetOff(b,_struck,ux,uy)) punched=true; else hit=true;   // v26.xx (feel18): off steel once
'@

SubRx @'
var VER='26.65';
'@ @'
var VER='26.66';
'@

$pat = "(?m)^  now:'v26\.65:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.66: Your rounds glance once off steel walls at a shallow angle, with a spark and a ping. Check 26.66 fails on v26.65',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
