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

# GROUND STAMPS THAT STAY (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function scarStamp(kind,x,y,o){ return gfxHook('scar'); }   // D: scorch, cracks and debris into G.ground
'@ @'
// v23.xx (gfx22), HIS ORDER (2026-10-12) on the graphics program: "add ALL of this stuff", item 12, richer ground. GROUND STAMPS
// THAT STAY. Every mark a fight left on the floor was a decal: a list capped at 420 that faded after 45 seconds, redrawn every
// frame, so a firefight left nothing behind a minute later and a busy one pushed its own oldest marks off. scarStamp paints a mark
// straight into the baked floor (G.ground, one pixel per world unit), so a scorch, a crack, a scatter of debris or a settled casing
// costs nothing a frame however many there are, and nothing fades it. Each stamp is also written to G.scarLog (the last 6000), and
// gfxScarReplay paints the log again over a freshly baked floor, so a lost graphics context, which rebakes the floor, no longer
// wipes the raid history off the ground. Every shape comes from a hash of where it landed and its place in the log, never from
// the raid stream; a bot raid has no floor and stamps nothing. This build adds the stamp; the builds after it give it callers.
var SCARMAX=6000;
function scarH(s,i){ return grit((s|0)+i*7919,((s>>>3)|0)+i*104729); }
function scarA(a){ return (Math.max(0,Math.min(1,a))).toFixed(3); }
function scarPaint(c,s){
  var k=s.k, x=s.x, y=s.y, r=s.r, a=s.a, i, n, q, ang, len, px, py, aa, sg;
  c.save();
  try{
    c.globalAlpha=1; c.globalCompositeOperation='source-over';
    if(k==='scorch'){
      sg=c.createRadialGradient(x,y,0,x,y,r);
      sg.addColorStop(0,'rgba(12,9,7,'+scarA(0.74*a)+')'); sg.addColorStop(0.55,'rgba(14,11,9,'+scarA(0.48*a)+')'); sg.addColorStop(1,'rgba(14,11,9,0)');
      c.fillStyle=sg; c.beginPath(); c.ellipse(x,y,r,r*0.86,0,0,6.2832); c.fill();
      c.fillStyle='rgba(8,6,5,'+scarA(0.5*a)+')';
      for(i=0;i<10;i++){ ang=scarH(s.s,i)*6.2832; len=r*(0.35+0.85*scarH(s.s,i+40)); q=0.8+2.2*scarH(s.s,i+80);
        c.fillRect(x+Math.cos(ang)*len-q/2,y+Math.sin(ang)*len*0.86-q/2,q,q); }
    } else if(k==='crack'){
      n=4+Math.floor(scarH(s.s,1)*4);
      c.strokeStyle='rgba(10,8,8,'+scarA(0.62*a)+')'; c.lineWidth=Math.max(0.8,Math.min(2.2,r*0.05)); c.lineCap='round'; c.lineJoin='round';
      for(i=0;i<n;i++){
        ang=(i/n)*6.2832+scarH(s.s,i+10)*0.9; len=r*(0.55+0.6*scarH(s.s,i+20)); px=x; py=y;
        c.beginPath(); c.moveTo(px,py);
        for(q=1;q<=3;q++){ aa=ang+(scarH(s.s,i*5+q+30)-0.5)*0.8; px+=Math.cos(aa)*len/3; py+=Math.sin(aa)*len/3*0.86; c.lineTo(px,py); }
        c.stroke();
      }
    } else if(k==='debris'){
      n=Math.max(3,Math.min(18,Math.round(r/2)));
      for(i=0;i<n;i++){
        ang=scarH(s.s,i)*6.2832; len=r*Math.sqrt(scarH(s.s,i+50)); q=1.2+2.8*scarH(s.s,i+90);
        px=x+Math.cos(ang)*len; py=y+Math.sin(ang)*len*0.8;
        c.fillStyle='rgba(6,6,8,'+scarA(0.38*a)+')'; c.fillRect(px-q/2+0.8,py-q/3+0.8,q,q*0.66);
        c.globalAlpha=a; c.fillStyle=s.c||'#5c5854'; c.fillRect(px-q/2,py-q/3,q,q*0.66); c.globalAlpha=1;
      }
    } else if(k==='brass'){
      c.translate(x,y); c.rotate(s.rot||0);
      c.fillStyle='rgba(40,30,14,'+scarA(0.35*a)+')'; c.fillRect(-1.1,-0.1,3.2,1.4);
      c.globalAlpha=0.9*a; c.fillStyle=s.c||'#b08c3c'; c.fillRect(-1.6,-0.7,3.2,1.4);
    }
  } finally { c.restore(); }
}
function scarStamp(kind,x,y,o){
  if(!gfxHook('scar')) return false;
  var g=G, gr=g&&g.ground, s;
  if(!gr||!gr.getContext||!(x>=0&&y>=0&&x<gr.width&&y<gr.height)) return false;
  o=o||{};
  if(!g.scarLog) g.scarLog=[];
  if(!(g.scarN>=0)) g.scarN=0;
  s={k:String(kind),x:+x,y:+y,r:(o.r>0)?+o.r:8,a:(o.a>0)?Math.min(1,+o.a):1,s:((Math.round(x)*73856093)^(Math.round(y)*19349663)^(g.scarN*83492791))>>>0};
  if(o.rot!==undefined) s.rot=+o.rot||0;
  if(o.c) s.c=String(o.c);
  g.scarN++;
  scarPaint(gr.getContext('2d'),s);
  g.scarLog.push(s);
  if(g.scarLog.length>SCARMAX) g.scarLog.splice(0,g.scarLog.length-SCARMAX);
  return true;
}
function gfxScarReplay(){
  var g=G, gr=g&&g.ground, Lg=g&&g.scarLog, c, i, n=0;
  if(!gr||!gr.getContext||!Lg||!Lg.length) return 0;
  c=gr.getContext('2d');
  for(i=0;i<Lg.length;i++){ try{ scarPaint(c,Lg[i]); n++; }catch(_sp){} }
  return n;
}
'@

SubRx @'
  if(G&&G.map&&!G.sim){ try{ G.ground=bakeGround(G.map); }catch(e){} }
'@ @'
  if(G&&G.map&&!G.sim){ try{ G.ground=bakeGround(G.map); }catch(e){} try{ gfxScarReplay(); }catch(_gsr){} }   // v23.xx (gfx22): and the stamps the raid left go back on the new floor
'@

SubRx @'
var VER='23.99';
'@ @'
var VER='24.00';
'@

$pat = "(?m)^  now:'v23\.99:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v24.00: Marks on the ground can now be painted into the floor itself and stay for the whole raid. Check 24.00 fails on v23.99',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
