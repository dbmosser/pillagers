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

# CROSSHAIR SHAPE, COLOUR AND SIZE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  {k:'rumble', label:'Controller rumble',
'@ @'
  // v26.xx (settings6), HIS ORDER 2026-10-14 ("ok add all this stuff to settings"): THE CROSSHAIR, its shape, its colour and its size, in DISPLAY. The
  // defaults are today: the four arm cross, the soft white (amber while aiming down sights), the size it was. The colours are four a colour-blind eye
  // reads: white, green, cyan and magenta. A colour of his own is used for the aim state too; the gun states (jammed, dry, empty, reloading) keep their
  // own warning colours, as the magazine and reload rings do.
  {k:'xhStyle', label:'CROSSHAIR', sec:'DISPLAY',
   hint:'THE SHAPE: CROSS, DOT, CIRCLE OR T. THE MAGAZINE AND RELOAD RINGS STAY AROUND IT.',
   opts:[
     {n:'CROSS',  cfg:{xhStyle:0}},
     {n:'DOT',    cfg:{xhStyle:1}},
     {n:'CIRCLE', cfg:{xhStyle:2}},
     {n:'T',      cfg:{xhStyle:3}}
   ], def:0},
  {k:'xhCol', label:'CROSSHAIR COLOUR', sec:'DISPLAY',
   hint:'WHITE IS THE USUAL, AMBER WHILE AIMING. THE OTHERS HOLD ONE COLOUR FOR BOTH.',
   opts:[
     {n:'WHITE',   cfg:{xhCol:0}},
     {n:'GREEN',   cfg:{xhCol:1}},
     {n:'CYAN',    cfg:{xhCol:2}},
     {n:'MAGENTA', cfg:{xhCol:3}}
   ], def:0},
  {k:'xhSz', label:'CROSSHAIR SIZE', sec:'DISPLAY',
   hint:'HOW BIG THE CROSSHAIR IS, WITH THE RINGS ROUND IT.',
   opts:[
     {n:'SMALL',    cfg:{xhSz:0.8}},
     {n:'STANDARD', cfg:{xhSz:1}},
     {n:'LARGE',    cfg:{xhSz:1.3}},
     {n:'HUGE',     cfg:{xhSz:1.6}}
   ], def:1},
  {k:'rumble', label:'Controller rumble',
'@

SubRx @'
function shakeK(){ var s=+CFG.shake; return (isFinite(s)&&s>=0&&s<=3)?s:1; }
'@ @'
function shakeK(){ var s=+CFG.shake; return (isFinite(s)&&s>=0&&s<=3)?s:1; }
// v26.xx (settings6), HIS ORDER 2026-10-14: THE CROSSHAIR ROWS. xhArms draws the four arms of the cross (or none for the dot, a ring for the circle, three
// for the T), xhDot the middle (a plain 2 pixel square, or a round dot for the dot and the circle), xhCol the neutral colour and xhSize the factor on the
// gap, the arm and the rings. The defaults draw exactly what the HUD drew before.
var XHCOL=[null,'rgba(61,255,122,.95)','rgba(53,230,255,.95)','rgba(255,79,216,.95)'];
function xhCol(ads){ var c=XHCOL[CFG.xhCol|0]; return c||(ads?'rgba(255,190,90,.95)':'rgba(230,240,246,.85)'); }
function xhSize(){ var s=+CFG.xhSz; return (s>=0.5&&s<=2)?s:1; }
function xhArms(c,x,y,gap,len){
  var st=CFG.xhStyle|0;
  c.beginPath();
  if(st===1){ c.stroke(); return; }
  if(st===2){ c.arc(x,y,gap+len*0.5,0,6.2832); c.stroke(); return; }
  c.moveTo(x-gap-len,y); c.lineTo(x-gap,y);
  c.moveTo(x+gap,y); c.lineTo(x+gap+len,y);
  if(st!==3){ c.moveTo(x,y-gap-len); c.lineTo(x,y-gap); }
  c.moveTo(x,y+gap); c.lineTo(x,y+gap+len);
  c.stroke();
}
function xhDot(c,x,y,rs,col,rz){
  var st=CFG.xhStyle|0;
  c.fillStyle=rs?col:(((CFG.xhCol|0)&&XHCOL[CFG.xhCol|0])?XHCOL[CFG.xhCol|0]:'rgba(230,240,246,.9)');
  if(st===1||st===2){ c.beginPath(); c.arc(x,y,(st===1?2.4:1.6)*rz,0,6.2832); c.fill(); }
  else c.fillRect(x-1,y-1,2,2);
}
'@

SubRx @'
:(p.ads?'rgba(255,190,90,.95)':'rgba(230,240,246,.85)');
'@ @'
:xhCol(p.ads);   // v26.xx (settings6): CROSSHAIR COLOUR (white, amber aiming, as it was)
'@

SubRx @'
var gap=(p.ads?3.5:(8+(p.recoil>0?p.recoil*7:0)+(G.sprinting?5:0)))*_rz;
'@ @'
var gap=(p.ads?3.5:(8+(p.recoil>0?p.recoil*7:0)+(G.sprinting?5:0)))*_rz*xhSize();   // v26.xx (settings6): CROSSHAIR SIZE
'@

SubRx @'
if(rState) gap=Math.max(gap,11*_rz);
'@ @'
if(rState) gap=Math.max(gap,11*_rz*xhSize());
'@

SubRx @'
var len=(p.ads?5:7)*_rz;
'@ @'
var len=(p.ads?5:7)*_rz*xhSize();
'@

SubRx @'
    ctx.beginPath();
    ctx.moveTo(rx0-gap-len,ry0); ctx.lineTo(rx0-gap,ry0);
    ctx.moveTo(rx0+gap,ry0); ctx.lineTo(rx0+gap+len,ry0);
    ctx.moveTo(rx0,ry0-gap-len); ctx.lineTo(rx0,ry0-gap);
    ctx.moveTo(rx0,ry0+gap); ctx.lineTo(rx0,ry0+gap+len);
    ctx.stroke();
'@ @'
    xhArms(ctx,rx0,ry0,gap,len);   // v26.xx (settings6): CROSSHAIR, the arms as the row says (the cross, as it was, by default)
'@

SubRx @'
ctx.fillStyle=rState?rCol:'rgba(230,240,246,.9)'; ctx.fillRect(rx0-1,ry0-1,2,2);
'@ @'
xhDot(ctx,rx0,ry0,rState,rCol,_rz);   // v26.xx (settings6): the middle, the 2 pixel square it was by default
'@

SubRx @'
var VER='26.46';
'@ @'
var VER='26.47';
'@

$pat = "(?m)^  now:'v26\.46:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.47: Display has crosshair shape, colour and size. Check 26.47 fails on v26.46',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
