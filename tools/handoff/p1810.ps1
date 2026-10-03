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

# THE GUNS ARE PAINTED LIKE OBJECTS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function gunIcon(c,id,cx,cy,S,tint){
  var W=WEAPONS[id]||WEAPONS.pistol, fam=GUN_FAMILY[id]||'rifle';
  // v7.99: rarity IS the weapon colour, everywhere this painter serves.
  var col=RCOL[gunRarity(W.id)]||tint||W.tint||'#ffd48a';
  var dk=darkHex(col,0.55), ink='#0a0c10', wood='#7a4a28', glass='#bfe8ff';
  c.save(); c.translate(cx,cy);
  // Every part is a rounded rect drawn twice: the outline one unit bigger in
  // ink, then the fill. That outline is what makes a shape a shape at 22px.
  var parts=[];
  function part(x,y,w,h,fill){ parts.push([x,y,w,h,fill]); }
  function rr(x,y,w,h,r){ c.beginPath(); c.moveTo(x+r,y); c.lineTo(x+w-r,y); c.quadraticCurveTo(x+w,y,x+w,y+r); c.lineTo(x+w,y+h-r); c.quadraticCurveTo(x+w,y+h,x+w-r,y+h); c.lineTo(x+r,y+h); c.quadraticCurveTo(x,y+h,x,y+h-r); c.lineTo(x,y+r); c.quadraticCurveTo(x,y,x+r,y); c.closePath(); c.fill(); }
  var u=S/40;                                   // one unit: the icon is 40 wide
  if(fam==='hand'||fam==='revolver'){
    var rev=(fam==='revolver');
    part(-14*u,-7*u,(rev?30:26)*u,7*u,col);          // slide
    part(-12*u,-2*u,14*u,4*u,dk);                    // frame
    part(-10*u,1*u,7*u,13*u,dk);                     // grip, raked back
    part(-3*u,1*u,4*u,4*u,ink);                      // trigger guard
    if(rev) part(-6*u,-3*u,9*u,8*u,dk);              // cylinder
    else part(-14*u,-5*u,5*u,3*u,dk);                // slide serrations
    part((rev?12:8)*u,-6*u,4*u,3*u,dk);              // front sight
  } else if(fam==='smg'){
    part(-19*u,-3*u,8*u,5*u,dk);                     // folded stock
    part(-12*u,-7*u,22*u,10*u,col);                  // stubby receiver
    part(9*u,-4*u,9*u,4*u,dk);                       // short barrel
    part(-5*u,3*u,5*u,15*u,dk);                      // long stick magazine
    part(-11*u,3*u,4*u,8*u,dk);                      // grip
    part(2*u,3*u,4*u,6*u,dk);                        // foregrip
  } else if(fam==='rifle'){
    var can=(id==='whisper');
    part(-20*u,-5*u,9*u,9*u,dk);                     // full stock
    part(-11*u,-7*u,18*u,10*u,col);                  // receiver
    part(6*u,-4*u,(can?8:14)*u,4*u,dk);              // barrel
    if(can) part(13*u,-6*u,8*u,8*u,ink);             // the Whisper's fat can
    part(-2*u,3*u,5*u,9*u,dk);                       // curved box magazine
    part(-1*u,10*u,6*u,4*u,dk);
    part(-9*u,3*u,4*u,9*u,dk);                       // pistol grip
    if(W.optic&&W.optic>1.2) part(-8*u,-11*u,12*u,4*u,dk);   // low optic
  } else if(fam==='shotgun'){
    part(-20*u,-4*u,10*u,9*u,wood);                  // wood stock
    part(-11*u,-6*u,12*u,9*u,col);                   // receiver
    part(0*u,-5*u,20*u,3*u,dk);                      // long barrel
    part(0*u,0*u,16*u,3*u,dk);                       // tube magazine under it
    part(4*u,-1*u,7*u,6*u,wood);                     // pump
    part(-8*u,3*u,4*u,8*u,dk);                       // grip
  } else if(fam==='lmg'){
    part(-20*u,-5*u,8*u,9*u,dk);                     // stock
    part(-13*u,-8*u,20*u,11*u,col);                  // big receiver
    part(-6*u,-12*u,10*u,3*u,dk);                    // carry handle
    part(6*u,-5*u,14*u,4*u,dk);                      // barrel
    part(-7*u,2*u,11*u,11*u,dk);                     // drum
    part(-4*u,4*u,5*u,5*u,col);                      // drum face
    part(8*u,-1*u,2*u,10*u,ink); part(13*u,-1*u,2*u,10*u,ink);   // bipod
    part(-11*u,3*u,4*u,8*u,dk);                      // grip
  } else if(fam==='marksman'){
    var sn=(id==='sniper');
    part(-20*u,-4*u,9*u,8*u,dk);                     // stock with cheek riser
    part(-19*u,-6*u,6*u,3*u,dk);
    part(-12*u,-6*u,14*u,8*u,col);                   // receiver
    part(1*u,-4*u,19*u,3*u,dk);                      // long barrel
    if(sn) part(17*u,-6*u,4*u,7*u,ink);              // muzzle brake
    part(-9*u,-12*u,14*u,5*u,dk);                    // big scope
    part(2*u,-11*u,3*u,3*u,glass);                   // scope glass
    part(-4*u,2*u,5*u,8*u,dk);                       // magazine
    part(-10*u,2*u,4*u,8*u,dk);                      // grip
    if(sn){ part(7*u,-1*u,2*u,9*u,ink); part(12*u,-1*u,2*u,9*u,ink); }   // bipod
  } else {                                           // lance: a rail with a lit tip
    part(-18*u,-4*u,8*u,7*u,dk);                     // stock
    part(-11*u,-6*u,14*u,9*u,col);                   // body
    part(2*u,-3*u,16*u,4*u,dk);                      // rail
    part(-6*u,-10*u,10*u,4*u,dk);                    // optic
    part(0*u,-9*u,3*u,2*u,glass);
    part(16*u,-5*u,5*u,8*u,'#e6c8ff');               // the lit tip
    part(-8*u,3*u,4*u,8*u,dk);                       // grip
  }
  // outline pass, then the fills, so every edge is dark against anything
  c.fillStyle=ink;
  for(var i=0;i<parts.length;i++){ var q=parts[i]; rr(q[0]-u,q[1]-u,q[2]+2*u,q[3]+2*u,1.5*u); }
  for(var j=0;j<parts.length;j++){ var g=parts[j]; c.fillStyle=g[4]; rr(g[0],g[1],g[2],g[3],1.2*u); }
  c.restore();
}

'@ @'
// v18.10, HIS ORDER (2026-10-03, "item graphics like the guns still look terrible and need massive improvements"): THE GUNS
// ARE PAINTED LIKE OBJECTS. The old painter laid flat rounded rectangles in two colours. Every part now has a material (the
// receiver in the rarity colour, barrels and sights in gunmetal, stocks and grips in dark furniture or wood), a bevel (a light
// top edge and a dark underside, so it reads as a solid), a soft ground shadow under the whole gun, and on icons 36 px and
// larger the small things that make a gun a gun: rail ticks, an ejection port, a muzzle, a front sight, a trigger, a
// magazine base plate and grip lines. At 22 px the parts and bevel alone keep it readable. Same families, same silhouettes.
function gunIcon(c,id,cx,cy,S,tint){
  var W=WEAPONS[id]||WEAPONS.pistol, fam=GUN_FAMILY[id]||'rifle';
  var col=RCOL[gunRarity(W.id)]||tint||W.tint||'#ffd48a';
  var dk=darkHex(col,0.55), ink='#0a0c10', wood='#7a4a28', glass='#bfe8ff', metal='#5e6878', mdk=darkHex(metal,0.62);
  var u=S/40, fine=(u>=0.9), parts=[], i, q;
  if(!(u>0)) return;
  c.save(); c.translate(cx,cy);
  function part(x,y,w,h,fill,kind){ parts.push({x:x*u,y:y*u,w:w*u,h:h*u,f:fill,k:kind||''}); }
  function rrP(x,y,w,h,r){ r=Math.max(0,Math.min(r,w/2,h/2)); c.beginPath(); c.moveTo(x+r,y); c.lineTo(x+w-r,y); c.quadraticCurveTo(x+w,y,x+w,y+r); c.lineTo(x+w,y+h-r); c.quadraticCurveTo(x+w,y+h,x+w-r,y+h); c.lineTo(x+r,y+h); c.quadraticCurveTo(x,y+h,x,y+h-r); c.lineTo(x,y+r); c.quadraticCurveTo(x,y,x+r,y); c.closePath(); }
  if(fam==='hand'||fam==='revolver'){
    var rev=(fam==='revolver');
    part(-14,-7,(rev?30:26),7,col,'rec');          // slide
    part(-12,-2,14,4,dk,'frame');                   // frame
    part(-10,1,7,13,dk,'grip');                     // grip, raked back
    part(-3,1,4,4,ink,'guard');                     // trigger guard
    if(rev) part(-6,-3,9,8,dk,'cyl'); else part(-14,-5,5,3,mdk,'serr');
    part((rev?12:8),-6,4,3,metal,'sight');          // front sight
  } else if(fam==='smg'){
    part(-19,-3,8,5,dk,'stock');                    // folded stock
    part(-12,-7,22,10,col,'rec');                   // stubby receiver
    part(9,-4,9,4,metal,'barrel');                  // short barrel
    part(-5,3,5,15,dk,'mag');                       // long stick magazine
    part(-11,3,4,8,dk,'grip');                      // grip
    part(2,3,4,6,dk,'fore');                        // foregrip
  } else if(fam==='rifle'){
    var can=(id==='whisper');
    part(-20,-5,9,9,dk,'stock');                    // full stock
    part(-11,-7,18,10,col,'rec');                   // receiver
    part(6,-4,(can?8:14),4,metal,'barrel');         // barrel
    if(can) part(13,-6,8,8,ink,'can');              // the Whisper's fat can
    part(-2,3,5,9,dk,'mag');                        // curved box magazine
    part(-1,10,6,4,dk,'mag2');
    part(-9,3,4,9,dk,'grip');                       // pistol grip
    if(W.optic&&W.optic>1.2) part(-8,-11,12,4,mdk,'optic');   // low optic
  } else if(fam==='shotgun'){
    part(-20,-4,10,9,wood,'stock');                 // wood stock
    part(-11,-6,12,9,col,'rec');                    // receiver
    part(0,-5,20,3,metal,'barrel');                 // long barrel
    part(0,0,16,3,mdk,'tube');                      // tube magazine under it
    part(4,-1,7,6,wood,'pump');                     // pump
    part(-8,3,4,8,dk,'grip');                       // grip
  } else if(fam==='lmg'){
    part(-20,-5,8,9,dk,'stock');                    // stock
    part(-13,-8,20,11,col,'rec');                   // big receiver
    part(-6,-12,10,3,dk,'handle');                  // carry handle
    part(6,-5,14,4,metal,'barrel');                 // barrel
    part(-7,2,11,11,dk,'drum');                     // drum
    part(-4,4,5,5,col,'drumf');                     // drum face
    part(8,-1,2,10,ink,'bipod'); part(13,-1,2,10,ink,'bipod');
    part(-11,3,4,8,dk,'grip');                      // grip
  } else if(fam==='marksman'){
    var sn=(id==='sniper');
    part(-20,-4,9,8,dk,'stock');                    // stock with cheek riser
    part(-19,-6,6,3,dk,'cheek');
    part(-12,-6,14,8,col,'rec');                    // receiver
    part(1,-4,19,3,metal,'barrel');                 // long barrel
    if(sn) part(17,-6,4,7,ink,'brake');             // muzzle brake
    part(-9,-12,14,5,mdk,'optic');                  // big scope
    part(2,-11,3,3,glass,'glass');                  // scope glass
    part(-4,2,5,8,dk,'mag');                        // magazine
    part(-10,2,4,8,dk,'grip');                      // grip
    if(sn){ part(7,-1,2,9,ink,'bipod'); part(12,-1,2,9,ink,'bipod'); }
  } else {                                          // lance: a rail with a lit tip
    part(-18,-4,8,7,dk,'stock');                    // stock
    part(-11,-6,14,9,col,'rec');                    // body
    part(2,-3,16,4,metal,'barrel');                 // rail
    part(-6,-10,10,4,mdk,'optic');                  // optic
    part(0,-9,3,2,glass,'glass');
    part(16,-5,5,8,'#e6c8ff','tip');                // the lit tip
    part(-8,3,4,8,dk,'grip');                       // grip
  }
  // the ground shadow and, on a big icon, a faint glow in the rarity colour behind the gun
  c.fillStyle='rgba(0,0,0,.26)'; c.beginPath(); c.ellipse(0,14*u,19*u,3*u,0,0,6.2832); c.fill();
  if(fine){ try{ var gl=c.createRadialGradient(0,0,2*u,0,0,25*u); gl.addColorStop(0,hexA(col,.20)); gl.addColorStop(1,hexA(col,0)); c.fillStyle=gl; c.fillRect(-27*u,-27*u,54*u,54*u); }catch(_gl){} }
  // outline pass: every part one unit bigger in ink, so each edge is dark against anything
  c.fillStyle=ink;
  for(i=0;i<parts.length;i++){ q=parts[i]; rrP(q.x-u,q.y-u,q.w+2*u,q.h+2*u,1.7*u); c.fill(); }
  // fills with a bevel: the base colour, a light top edge, a dark underside, each clipped to the part
  for(i=0;i<parts.length;i++){
    q=parts[i];
    c.save(); rrP(q.x,q.y,q.w,q.h,1.2*u); c.clip();
    c.fillStyle=q.f; c.fillRect(q.x,q.y,q.w,q.h);
    if(q.f!==ink&&q.f!==glass){
      c.fillStyle=litHex(q.f,0.30,true); c.fillRect(q.x,q.y,q.w,Math.max(0.8*u,q.h*0.30));
      c.fillStyle=darkHex(q.f,0.70); c.fillRect(q.x,q.y+q.h*0.74,q.w,q.h*0.26);
    } else if(q.f===glass){ c.fillStyle='#ffffff'; c.fillRect(q.x,q.y,q.w*0.45,Math.max(0.6*u,q.h*0.35)); }
    c.restore();
  }
  // the small things, on icons 36 px and larger
  if(fine){
    var mag0=null;
    for(i=0;i<parts.length;i++){
      q=parts[i];
      if(q.k==='rec'){
        c.fillStyle=darkHex(q.f,0.45); c.fillRect(q.x+q.w*0.58,q.y+q.h*0.30,q.w*0.16,q.h*0.30);          // ejection port
        if(fam!=='hand'&&fam!=='revolver'&&fam!=='shotgun'){ c.fillStyle=ink; var tk; for(tk=0;tk<3;tk++) c.fillRect(q.x+q.w*0.22+tk*q.w*0.18,q.y-0.8*u,1.2*u,1.6*u); }   // rail ticks
      } else if(q.k==='grip'){
        c.fillStyle=darkHex(q.f,0.62); c.fillRect(q.x+0.8*u,q.y+q.h*0.34,q.w-1.6*u,0.8*u); c.fillRect(q.x+0.8*u,q.y+q.h*0.58,q.w-1.6*u,0.8*u);   // grip lines
        c.fillStyle=ink; c.fillRect(q.x+q.w+0.5*u,q.y+0.6*u,1.0*u,2.6*u);                            // trigger
      } else if(q.k==='mag'&&!mag0){ mag0=q; c.fillStyle=litHex(q.f,0.26,true); c.fillRect(q.x,q.y+q.h-1.6*u,q.w,1.6*u); }   // base plate
      else if(q.k==='barrel'){ c.fillStyle=mdk; c.fillRect(q.x+q.w-2.2*u,q.y-0.7*u,2.2*u,q.h+1.4*u); c.fillStyle=metal; c.fillRect(q.x+q.w-4.6*u,q.y-1.8*u,1.2*u,1.8*u); }   // muzzle, front sight
      else if(q.k==='stock'){ c.fillStyle=litHex(q.f,0.18,true); c.fillRect(q.x+1*u,q.y+1*u,q.w-2*u,1*u); }   // cheek line
    }
  }
  c.restore();
}

'@

SubRx @'
var VER='18.09';
'@ @'
var VER='18.10';
'@

$pat = "(?m)^  now:'v18\.09:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.10: Gun icons are painted like real objects now: materials, shading, a shadow and the small details, in every menu and on the belt. Check 18.10 fails on v18.09',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
