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

# prompts follow the last input device (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var keys={},mouse={x:0,y:0,down:false},pauseOpen=false,tuneOpen=false;
'@ @'
var keys={},mouse={x:0,y:0,down:false},pauseOpen=false,tuneOpen=false;
// v30.xx (cw-glyphs), HIS ORDER (2026-10-18): "player should get key prompts if that is the last input they used -- xbox controller
// prompts should only pop up if player is actively using the controller -- e.g. real time glyph switching -- fortnite does a great
// job with this". INDEV.dev is the last input device THIS window saw: 'kb' (a key press, a mouse click or wheel turn, or a mouse move
// of more than INDEV_MOVE pixels) or 'pad' (a pad button newly pressed, or a stick pushed past INDEV_DZ). padOn() is the one reader
// every prompt asks and it is true only while a pad is connected AND it is the last device used: a pad that is merely plugged in or
// drifting never puts its glyphs up, and a key press takes them down on the very next frame. Each window is one player with its own
// tracker. The player 2 window of a same machine pair has no keyboard or mouse of its own (it hands every key to player 1, netKeyFwd),
// so it ignores both and keeps the pad prompts while its pad is there. Mouse events count only when real (the pad's own synthetic
// presses must not flip it back); key events always count (the keys player 2 hands over arrive as synthetic keydowns and are player 1
// on the keyboard). INDEV.legacy is for the test fixture only: it keeps the older checks, which set PAD.on by hand, meaning what they meant.
var INDEV={dev:'kb',legacy:false,ax:null,ay:null,lx:null,ly:null,pb:[],pa:[]}, INDEV_MOVE=6, INDEV_DZ=0.4;
function indevP2(){ try{ return !!((typeof NET==='object'&&NET&&NET.same==='p2')||(typeof ARCADE==='object'&&ARCADE&&ARCADE.on&&ARCADE.role==='p2')); }catch(_ip){ return false; } }
function indevSet(d){
  if(INDEV.dev===d) return false;
  INDEV.dev=d;
  if(d==='pad'){ INDEV.ax=INDEV.lx; INDEV.ay=INDEV.ly; }   // the mouse is judged from where it lay when the pad took over
  try{ if(typeof padBodyCls==='function') padBodyCls(); }catch(_ib){}   // the DOM hints (body.padon) switch in the same breath
  return true;
}
function indevKey(){ if(!indevP2()) indevSet('kb'); }
function indevMouse(x,y,mx,my){
  INDEV.lx=x; INDEV.ly=y;
  if(indevP2()) return;
  if(INDEV.dev==='kb'||INDEV.ax===null){ INDEV.ax=x; INDEV.ay=y; return; }
  if(mx===0&&my===0) return;   // a move the browser made up (the page moved under a still cursor) is not a hand on the mouse
  if(Math.hypot(x-INDEV.ax,y-INDEV.ay)>INDEV_MOVE) indevSet('kb');
}
function indevPadTick(gp){
  var b=(gp&&gp.buttons)||[], a=(gp&&gp.axes)||[], i, v, av, hit=false, th=INDEV_DZ;
  try{ th=Math.max(INDEV_DZ,padDz()+0.15); }catch(_pd){}
  for(i=0;i<b.length&&i<32;i++){   // a button counts on its press, not while it is held
    v=b[i]; av=v?((v.value!==undefined)?+v.value:(v.pressed?1:0)):0;
    if(v&&(v.pressed||av>0.5)){ if(!INDEV.pb[i]) hit=true; INDEV.pb[i]=1; }
    else if(!v||(!v.pressed&&av<0.3)) INDEV.pb[i]=0;
  }
  for(i=0;i<a.length&&i<4;i++){   // a stick counts when it crosses the line, not while it sits past it (drift never flips)
    av=Math.abs(+a[i]||0);
    if(av>th){ if(!INDEV.pa[i]) hit=true; INDEV.pa[i]=1; }
    else if(av<th*0.6) INDEV.pa[i]=0;
  }
  if(hit) indevSet('pad');
  return hit;
}
try{
  window.addEventListener('keydown',function(){ indevKey(); },true);
  window.addEventListener('mousedown',function(e){ if(e.isTrusted) indevKey(); },true);
  window.addEventListener('wheel',function(e){ if(e.isTrusted) indevKey(); },{capture:true,passive:true});
  window.addEventListener('mousemove',function(e){ if(e.isTrusted) indevMouse(e.clientX,e.clientY,e.movementX,e.movementY); },true);
}catch(_ig){}
'@

SubRx @'
function padOn(){ return !!(typeof PAD!=='undefined'&&PAD&&PAD.on); }
'@ @'
// v30.xx (cw-glyphs), HIS ORDER (2026-10-18): "xbox controller prompts should only pop up if player is actively using the controller". A pad that is only
// connected no longer counts: it must also be the last device used (INDEV, above). The player 2 window has no other device, so it keeps the pad prompts.
function padOn(){ return !!(typeof PAD!=='undefined'&&PAD&&PAD.on&&(typeof INDEV==='undefined'||!INDEV||INDEV.dev==='pad'||INDEV.legacy||indevP2())); }
'@

SubRx @'
function padBodyCls(){ var on=!!(PAD&&PAD.on), r;
'@ @'
function padBodyCls(){ var on=padOn(), r; /* v30.xx (cw-glyphs): body.padon follows the last input device, not just a connected pad */
'@

SubRx @'
PAD.on=true; padBodyCls();   // v19.70: the page knows the pad is on (body.padon)
'@ @'
indevPadTick(gp);   // v30.xx (cw-glyphs): this window's pad, own or handed over, is read for use before anything else
  PAD.on=true; padBodyCls();   // v19.70: the page knows the pad is on (body.padon)
'@

SubRx @'
if(PAD&&PAD.on&&(typeof G==='undefined'||!G||state==='hub'))
'@ @'
if(padOn()&&(typeof G==='undefined'||!G||state==='hub'))
'@

SubRx @'
if(PAD&&PAD.on&&typeof LEGEND_PAD!=='undefined'&&LEGEND_PAD)
'@ @'
if(padOn()&&typeof LEGEND_PAD!=='undefined'&&LEGEND_PAD)
'@

SubRx @'
_fLEG=(PAD&&PAD.on)?LEGEND_PAD:LEGEND;
'@ @'
_fLEG=padOn()?LEGEND_PAD:LEGEND;
'@

SubRx @'
if(!(PAD&&PAD.on)&&!(typeof arcadeCardOn==='function'&&arcadeCardOn()>0)) ctx.fillText(legendKeys('F1')+'  controls'
'@ @'
if(!padOn()&&!(typeof arcadeCardOn==='function'&&arcadeCardOn()>0)) ctx.fillText(legendKeys('F1')+'  controls'
'@

SubRx @'
var MN=((PAD&&PAD.on)?LEGEND_MINI_PAD:LEGEND_MINI).slice(),mi;
'@ @'
var MN=(padOn()?LEGEND_MINI_PAD:LEGEND_MINI).slice(),mi;
'@

SubRx @'
if(PAD&&PAD.on) MN.push(['Y','drop to trade'])
'@ @'
if(padOn()) MN.push(['Y','drop to trade'])
'@

SubRx @'
if(!(PAD&&PAD.on)) for(mi=0;mi<MN.length;mi++)
'@ @'
if(!padOn()) for(mi=0;mi<MN.length;mi++)
'@

SubRx @'
MH=MROW*_mr+((PAD&&PAD.on)?LH(6):LH(16));
'@ @'
MH=MROW*_mr+(padOn()?LH(6):LH(16));
'@

SubRx @'
if(!(PAD&&PAD.on)) ctx.fillText(legendKeys('F1')+'  full list'
'@ @'
if(!padOn()) ctx.fillText(legendKeys('F1')+'  full list'
'@

SubRx @'
var LEG=(PAD&&PAD.on)?LEGEND_PAD:LEGEND;
'@ @'
var LEG=padOn()?LEGEND_PAD:LEGEND;
'@

SubRx @'
padB((PAD&&PAD.on)?_lgk[0]:legendKeys(_lgk[0]))
'@ @'
padB(padOn()?_lgk[0]:legendKeys(_lgk[0]))
'@

SubRx @'
padB((PAD&&PAD.on)?k[0]:legendKeys(k[0]))
'@ @'
padB(padOn()?k[0]:legendKeys(k[0]))
'@

SubRx @'
if(!(PAD&&PAD.on)) ctx.fillText(legendKeys('F1')+'  hide'
'@ @'
if(!padOn()) ctx.fillText(legendKeys('F1')+'  hide'
'@

SubRx @'
var _bh=(PAD&&PAD.on)?((state==='hub')?padB('VIEW to close')
'@ @'
var _bh=padOn()?((state==='hub')?padB('VIEW to close')
'@

SubRx @'
_bo=((PAD&&PAD.on)?padB('Y'):'Z')+' drop for teammate   '
'@ @'
_bo=(padOn()?padB('Y'):'Z')+' drop for teammate   '
'@

SubRx @'
_bh=((PAD&&PAD.on)?padB('Y'):'Z')+' drop   '
'@ @'
_bh=(padOn()?padB('Y'):'Z')+' drop   '
'@

SubRx @'
((PAD&&PAD.on)?'':'drag to tactical belt')
'@ @'
(padOn()?'':'drag to tactical belt')
'@

SubRx @'
:(PAD&&PAD.on)?padB('DPAD move, past the ends to the tactical belt
'@ @'
:padOn()?padB('DPAD move, past the ends to the tactical belt
'@

SubRx @'
if(!(PAD&&PAD.on)&&G.bagCells)
'@ @'
if(!padOn()&&G.bagCells)
'@

SubRx @'
ctx.fillText((PAD&&PAD.on)?'walk to dismiss'
'@ @'
ctx.fillText(padOn()?'walk to dismiss'
'@

SubRx @'
say2((PAD&&PAD.on)?padB('TACTICAL BELT
'@ @'
say2(padOn()?padB('TACTICAL BELT
'@

SubRx @'
var VER='30.65';
'@ @'
var VER='30.66';
'@

$pat = "(?m)^  now:'v30\.65:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v30.66: Prompts follow what you used last: press a key and you see keys, touch the controller and you see its buttons. Check 30.66 fails on v30.65',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
