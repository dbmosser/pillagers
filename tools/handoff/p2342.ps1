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

# ARCADE: THE CONTROLS CARD (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function arcadeShieldOff(){
  if(!G||!G.player||!G.player.arcSh) return false;
  G.player.arcSh=0;
  return true;
}
'@ @'
function arcadeShieldOff(){
  if(!G||!G.player||!G.player.arcSh) return false;
  G.player.arcSh=0;
  G.player.arcShT=+G.t||0;   // v23.42 (arcade19): when it dropped, for the controls card
  return true;
}
// v23.42, HIS ORDER (2026-10-11), build 19 of 20 (arcade19): THE CONTROLS CARD. A walk-up player has never seen the game, so every arcade
// drop, respawn and re-drop puts a big controls card at the left of the screen while the spawn shield is up and for 4 s after it
// drops (game time), fading out over the last 0.6 s. arcadeCardRows gives the 8 rows with a KEYBOARD and a CONTROLLER column: MOVE,
// AIM, FIRE, ROLL, RELOAD, SWITCH GUN, HEAL and EXTRACT. The keyboard names follow CHANGE KEYS (keysOf, keyName) and the pad names
// go through padB, so a PlayStation pad reads its own buttons (only the button word, so the A of IN A TEAL RING stays a word). The
// HOW TO PLAY attract page now draws the same rows. Only an arcade raid draws the card, so a normal raid is unchanged.
var ARCADE_CARD_T=4;   // seconds the card stays after the shield drops
function arcadeCardRows(){
  function kn(c){ try{ return keyName(keysOf(c)); }catch(_k){ return keyName(c); } }
  var mv=[kn('KeyW'),kn('KeyA'),kn('KeyS'),kn('KeyD')], m=(mv.join('').length===4)?mv.join(''):mv.join(' ');
  return [['MOVE',m,padB('L STICK')],['AIM','MOUSE',padB('R STICK')],['FIRE','LEFT CLICK',padB('RT')],['ROLL',kn('Space'),padB('A')],
    ['RELOAD',kn('KeyR'),padB('X')],['SWITCH GUN','1-4',padB('LB')+' / '+padB('RB')],['HEAL','+ ON THE BELT, THEN FIRE','+ ON THE BELT, THEN FIRE'],
    ['EXTRACT','HOLD '+kn('KeyE')+' IN A TEAL RING','HOLD '+padB('X')+' IN A TEAL RING']];
}
// how much of the card shows now, 0 to 1: full while shielded, then 4 s, fading over the last 0.6 s
function arcadeCardOn(){
  var p=G&&G.player, t;
  if(!G||!G.arcade||G.over||!p||p.specOut) return 0;
  if(p.arcSh) return 1;
  t=(+G.t||0)-(+p.arcShT);
  if(!(t>=0&&t<ARCADE_CARD_T)) return 0;
  return Math.max(0,Math.min(1,(ARCADE_CARD_T-t)/0.6));
}
// the card on the HUD canvas, at the left, centred on the screen height
function arcadeCardHud(){
  var a=arcadeCardOn(), rows, i, j, w=[0,0,0], x, y, lh, pd, gp, hh, pw, ph, cx;
  if(!(a>0)||!ctx) return;
  rows=arcadeCardRows();
  ctx.save(); ctx.globalAlpha=a; ctx.textAlign='left'; ctx.textBaseline='alphabetic';
  for(i=0;i<rows.length;i++) for(j=0;j<3;j++){ ctx.font=j?FS(TYPE.label):FS(TYPE.head); w[j]=Math.max(w[j],ctx.measureText(rows[i][j]).width); }
  ctx.font=FS(TYPE.micro); w[1]=Math.max(w[1],ctx.measureText('KEYBOARD').width); w[2]=Math.max(w[2],ctx.measureText('CONTROLLER').width);
  lh=LH(26); pd=LH(14); gp=LH(18); hh=LH(20);
  pw=Math.round(pd*2+w[0]+w[1]+w[2]+gp*2); ph=Math.round(pd*2+hh+lh*rows.length);
  x=LH(24); y=Math.round(H*0.5-ph/2);
  ctx.fillStyle='rgba(6,9,13,.80)'; ctx.fillRect(x,y,pw,ph);
  ctx.strokeStyle='rgba(255,192,74,.55)'; ctx.lineWidth=2; ctx.strokeRect(x+1,y+1,pw-2,ph-2);
  cx=[x+pd,x+pd+w[0]+gp,x+pd+w[0]+gp+w[1]+gp];
  ctx.font=FS(TYPE.micro); ctx.fillStyle='#9a8f78';
  hudText('KEYBOARD',Math.round(cx[1]),Math.round(y+pd+LH(10))); hudText('CONTROLLER',Math.round(cx[2]),Math.round(y+pd+LH(10)));
  for(i=0;i<rows.length;i++){
    var ry=Math.round(y+pd+hh+lh*i+LH(17));
    ctx.font=FS(TYPE.head); ctx.fillStyle='#ffc04a'; hudText(rows[i][0],Math.round(cx[0]),ry);
    ctx.font=FS(TYPE.label); ctx.fillStyle='#e8eef2'; hudText(rows[i][1],Math.round(cx[1]),ry);
    ctx.fillStyle='#7fe3d4'; hudText(rows[i][2],Math.round(cx[2]),ry);
  }
  ctx.restore();
}
'@

SubRx @'
  try{ arcadeDropHud(); }catch(_adh){}   // v23.35 (arcade13)
'@ @'
  try{ arcadeDropHud(); }catch(_adh){}   // v23.35 (arcade13)
  try{ arcadeCardHud(); }catch(_ach){}   // v23.42 (arcade19): the controls card while shielded and 4 s after
'@

SubRx @'
var ARCADE_HOW=[['MOVE','WASD','L STICK'],['AIM','MOUSE','R STICK'],['FIRE','LEFT CLICK','RT'],['ROLL','SPACE','A'],['RELOAD','R','X'],['EXTRACT','HOLD E IN A TEAL RING','HOLD X IN A TEAL RING']];
'@ @'
// v23.42 (arcade19): the HOW TO PLAY rows are arcadeCardRows, the same 8 rows as the controls card at a drop
'@

SubRx @'
  for(i=0;i<ARCADE_HOW.length;i++){
    rw=ARCADE_HOW[i]; tr=t.insertRow();
    c=tr.insertCell(); c.className='apk'; c.textContent=rw[0];
    c=tr.insertCell(); c.textContent=rw[1];
    c=tr.insertCell(); c.textContent=padB(rw[2]);
  }
'@ @'
  var rows=arcadeCardRows();   // v23.42 (arcade19): the controls card rows (the pad names are already through padB)
  for(i=0;i<rows.length;i++){
    rw=rows[i]; tr=t.insertRow();
    c=tr.insertCell(); c.className='apk'; c.textContent=rw[0];
    c=tr.insertCell(); c.textContent=rw[1];
    c=tr.insertCell(); c.textContent=rw[2];
  }
'@

SubRx @'
var VER='23.41';
'@ @'
var VER='23.42';
'@

$pat = "(?m)^  now:'v23\.41:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.42: In the arcade a big controls card with keyboard and controller buttons sits at the left at every drop while the shield is up and for 4 seconds after, and the HOW TO PLAY page shows the same 8 rows. Check 23.42 fails on v23.41',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
