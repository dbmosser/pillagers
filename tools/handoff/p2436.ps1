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

# MUZZLE FLASH ON THE FIRST FRAME (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function gfxShot(sh,wep,ang,fromPlayer){ return gfxHook('shot'); }   // D: the first-frame muzzle flash
'@ @'
// v23.xx (gfx24), HIS ORDER (2026-10-12) on the graphics program: "add ALL of this stuff", item 7, shot detail. THE MUZZLE FLASH IS
// ON THE FIRST FRAME. A shot set a 0.06 second muzzle timer, and the flash was drawn only while that timer was still running when
// a frame was drawn, so on a slow or uneven frame the timer ran out first and the shot had no flash at all; a teammate shot never
// had one in the other window (his tracers arrive with no muzzle). Each shot now leaves a flash event that the NEXT drawn frame
// paints at full strength at the barrel tip, however long that frame took: a baked star per weapon family (short for pistols and
// rifles, long for the heavy guns, wide for shotguns) in the gun tint, then gone within 0.05 seconds. A teammate tracer arriving
// in this window makes one at its start. Someone you cannot see shows no flash (the seen list, or a line of sight for a tracer).
// Render only: nothing here touches the raid stream, and a bot raid records nothing.
var GFXMUZ=[];
var MUZSPR=gfxStore('muz');
function muzFam(wep){ return (wep&&(wep.pellets||1)>1)?'wide':((wep&&wep.dmg>40)?'long':'short'); }
function muzTint(t){ return ((/^#[0-9a-fA-F]{6}$/).test(String(t)))?String(t):'#ffc27a'; }
function muzSprite(fam,tint){
  var key=fam+'|'+tint, s=MUZSPR.m[key], c, Ln, Wd, sa, sg;
  if(s) return s;
  s=document.createElement('canvas'); s.width=128; s.height=64; c=s.getContext('2d');
  c.scale(4,4);   // 32 by 16 units, the barrel tip at (4,8), pointing along +x
  Ln=(fam==='long')?27:((fam==='wide')?17:21); Wd=(fam==='wide')?5.5:3.4; sa=(fam==='wide')?0.42:0.6;
  c.globalCompositeOperation='lighter';
  sg=c.createRadialGradient(4,8,0,4,8,7.5);
  sg.addColorStop(0,'rgba(255,255,240,1)'); sg.addColorStop(0.35,tint); sg.addColorStop(1,'rgba(0,0,0,0)');
  c.fillStyle=sg; c.beginPath(); c.arc(4,8,7.5,0,6.2832); c.fill();
  function spike(a,len,w){
    c.beginPath(); c.moveTo(4+Math.cos(a+1.5708)*w,8+Math.sin(a+1.5708)*w); c.lineTo(4+Math.cos(a)*len,8+Math.sin(a)*len);
    c.lineTo(4+Math.cos(a-1.5708)*w,8+Math.sin(a-1.5708)*w); c.closePath(); c.fill();
  }
  c.fillStyle=tint; spike(0,Ln,Wd*0.5); spike(sa,Ln*0.42,Wd*0.35); spike(-sa,Ln*0.42,Wd*0.35);
  if(fam==='wide'){ spike(sa*2,Ln*0.3,Wd*0.25); spike(-sa*2,Ln*0.3,Wd*0.25); }
  c.fillStyle='rgba(255,255,235,.95)'; spike(0,Ln*0.6,Wd*0.22);
  MUZSPR.m[key]=s; MUZSPR.n++;
  return s;
}
function gfxShot(sh,wep,ang,fromPlayer){
  if(!gfxHook('shot')||!sh) return false;
  if(GFXMUZ.length>=24) GFXMUZ.shift();
  GFXMUZ.push({g:G,x:sh.x+Math.cos(ang)*17,y:sh.y+Math.sin(ang)*17-12,a:ang,f:muzFam(wep),c:muzTint(wep&&wep.tint),sh:sh,me:!!fromPlayer,n:0,age:0});
  return true;
}
function gfxShotFx(x,y,ang,tint){   // a teammate tracer: one flash per shot, not one per pellet
  var i, m;
  if(GFX.bypass||!G||G.sim||!isFinite(x)||!isFinite(y)||!isFinite(ang)) return false;
  for(i=0;i<GFXMUZ.length;i++){ m=GFXMUZ[i]; if(m.g===G&&m.n===0&&!m.sh&&Math.abs(m.x-x)<5&&Math.abs(m.y-(y-12))<5) return false; }
  if(GFXMUZ.length>=24) GFXMUZ.shift();
  GFXMUZ.push({g:G,x:x,y:y-12,a:ang,f:'short',c:muzTint(tint),sh:null,me:false,n:0,age:0});
  return true;
}
function gfxMuzzleFx(dt){
  var i, m, al, s, k=0.62, p=G&&G.player, vis, n=0;
  if(!GFXMUZ.length) return 0;
  if(GFX.bypass||!G||G.sim){ GFXMUZ.length=0; return 0; }
  wc.save();
  try{
    wc.globalCompositeOperation='lighter';
    for(i=GFXMUZ.length-1;i>=0;i--){
      m=GFXMUZ[i];
      if(m.g!==G){ GFXMUZ.splice(i,1); continue; }
      if(m.n===0) al=1; else { m.age+=Math.max(0,+dt||0); al=1-m.age/0.05; }
      m.n++;
      if(al<=0){ GFXMUZ.splice(i,1); continue; }
      vis=m.me||(m.sh?(VIS.indexOf(m.sh)>=0||m.sh===p):(!!p&&canSee(p.x,p.y,p.face,m.x,m.y+12,G.vseg)));
      if(!vis) continue;
      s=muzSprite(m.f,m.c);
      wc.globalAlpha=Math.min(1,al);
      wc.save(); wc.translate(m.x,m.y); wc.rotate(m.a); wc.drawImage(s,-4*k,-8*k,32*k,16*k); wc.restore();
      n++;
    }
  } finally { wc.restore(); }
  return n;
}
'@

SubRx @'
  try{ gfxBodyFx(dt); }catch(_gbf){}   // v23.xx (gfx2): body and air effects hook
'@ @'
  try{ gfxBodyFx(dt); }catch(_gbf){}   // v23.xx (gfx2): body and air effects hook
  try{ gfxMuzzleFx(dt); }catch(_gmz){}   // v23.xx (gfx24): the muzzle flash of every shot since the last frame, at full strength
'@

SubRx @'
    if(G.fxBullets.length<80) G.fxBullets.push({x:+a[0]||0,y:+a[1]||0,vx:+a[2]||0,vy:+a[3]||0,life:Math.min(3,Math.max(0,+a[4]||0)),tint:(/^#[0-9a-fA-F]{3,8}$/).test(a[5])?a[5]:'#ffd48a',owner:1,fx:1});
'@ @'
    if(G.fxBullets.length<80) G.fxBullets.push({x:+a[0]||0,y:+a[1]||0,vx:+a[2]||0,vy:+a[3]||0,life:Math.min(3,Math.max(0,+a[4]||0)),tint:(/^#[0-9a-fA-F]{3,8}$/).test(a[5])?a[5]:'#ffd48a',owner:1,fx:1});
    if(!G.sim){ try{ gfxShotFx(+a[0]||0,+a[1]||0,Math.atan2(+a[3]||0,+a[2]||0),a[5]); }catch(_gsx){} }   // v23.xx (gfx24): and its muzzle flash
'@

SubRx @'
var VER='24.35';
'@ @'
var VER='24.36';
'@

$pat = "(?m)^  now:'v24\.35:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v24.36: Every shot now shows a sharp muzzle flash on the very next frame, teammate shots included. Check 24.36 fails on v24.35',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
