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

# ARCADE: THE ARCADE HUD (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
// The arcade layer of the HUD, drawn from drawHUD. For now the EXTRACTED! banner: 3 seconds in the centre, on game time.
function arcadeHud(){
  if(!G||!G.arcade||!ctx) return;
  var b=ARCADE.banner, k, a, y, cx=Math.round(W/2), bw, bh;
  if(!b) return;
'@ @'
// v23.35, HIS ORDER (2026-10-11), build 13 of 20 (arcade13): THE ARCADE HUD. A walk-up player needs the score, the way out and when he
// drops back in, and nothing else. In the arcade the CONDITIONS panel, the CURRENT PILLAGERS board, the notoriety stamp and the
// WANTS REVENGE callouts (host kill and player 2 kill word) are not drawn or said; the rival callout was already off (arcade2). The
// compass arrow under the EXTRACT readout is twice the size, set a little lower so it clears the label, with an ink edge. During the
// drop-in hold (ARCADE.holdT, after a respawn or a re-drop) DROPPING IN n counts down big in the centre, below the EXTRACTED! banner
// when that is up. Every change is gated on G.arcade, so a normal raid draws exactly what it drew before.
var ARCADE_ARW=2;   // the arcade compass arrow, times its normal size
function arcadeDropHud(){
  var t=+ARCADE.holdT||0, n, y, cx=Math.round(W/2), s;
  if(!(t>0)) return;
  n=Math.max(1,Math.ceil(t)); s='DROPPING IN '+n;
  y=Math.round(H*(ARCADE.banner?0.66:0.36));
  ctx.save(); ctx.textAlign='center'; ctx.textBaseline='alphabetic';
  ctx.globalAlpha=0.6+0.4*Math.max(0,Math.min(1,t-(n-1)));
  ctx.font=FSz(TYPE.huge,1.2); ctx.fillStyle='#ffc04a'; hudText(s,cx,y);
  ctx.restore();
}
// The arcade layer of the HUD, drawn from drawHUD: DROPPING IN n (arcade13), and the EXTRACTED! banner, 3 seconds in the centre, on game time.
function arcadeHud(){
  if(!G||!G.arcade||!ctx) return;
  try{ arcadeDropHud(); }catch(_adh){}   // v23.35 (arcade13)
  var b=ARCADE.banner, k, a, y, cx=Math.round(W/2), bw, bh;
  if(!b) return;
'@

SubRx @'
  ctx.save(); hudZoomIn('cond',W,0);
  (function(){
    var MW=(G.wx||WEATHER[0]), MT=tod(), rows=[], _clines=[];
'@ @'
  ctx.save(); hudZoomIn('cond',W,0);
  (function(){
    if(G.arcade){ delete HUDBOX.cond; return; }   // v23.35 (arcade13): no CONDITIONS panel in the arcade
    var MW=(G.wx||WEATHER[0]), MT=tod(), rows=[], _clines=[];
'@

SubRx @'
    ctx.save(); ctx.translate(W/2,_yArw); ctx.rotate(za+Math.PI/2);
    ctx.fillStyle=_col;
    // the arrow is geometry, so it scales with the screen like the type does
    ctx.beginPath(); ctx.moveTo(0,-8*_tz); ctx.lineTo(-5*_tz,5*_tz); ctx.lineTo(5*_tz,5*_tz); ctx.closePath(); ctx.fill();
'@ @'
    var _az=_tz*(G.arcade?ARCADE_ARW:1);   // v23.35 (arcade13): in the arcade the arrow is twice the size, set lower so it clears the label
    ctx.save(); ctx.translate(W/2,_yArw+(G.arcade?Math.round(8*_tz):0)); ctx.rotate(za+Math.PI/2);
    ctx.fillStyle=_col;
    // the arrow is geometry, so it scales with the screen like the type does
    ctx.beginPath(); ctx.moveTo(0,-8*_az); ctx.lineTo(-5*_az,5*_az); ctx.lineTo(5*_az,5*_az); ctx.closePath(); ctx.fill();
    if(G.arcade){ ctx.strokeStyle='rgba(6,9,13,.85)'; ctx.lineWidth=Math.max(1.5,1.5*_tz); ctx.lineJoin='round'; ctx.stroke(); }
'@

SubRx @'
  // the word the stats page will show him afterwards.
  if(G.notoAt!==undefined&&G.notoAt!==null){
'@ @'
  // the word the stats page will show him afterwards.
  if(!G.arcade&&G.notoAt!==undefined&&G.notoAt!==null){   // v23.35 (arcade13): not in the arcade
'@

SubRx @'
  if(!G.mapOpen&&!G.bagOpen){
    // v8.91: grows from the top left corner it already sits in.
    ctx.save(); hudZoomIn('raiders',0,0);
'@ @'
  if(G.arcade) delete HUDBOX.raiders;   // v23.35 (arcade13): no CURRENT PILLAGERS board in the arcade
  else if(!G.mapOpen&&!G.bagOpen){
    // v8.91: grows from the top left corner it already sits in.
    ctx.save(); hudZoomIn('raiders',0,0);
'@

SubRx @'
          sayWhenFree(String(e.name).toUpperCase()+' WANTS REVENGE','info');
'@ @'
          if(!G.arcade) sayWhenFree(String(e.name).toUpperCase()+' WANTS REVENGE','info');   // v23.35 (arcade13): not in the arcade.
'@

SubRx @'
    sayWhenFree(String(e.name||'He').toUpperCase()+' WANTS REVENGE','info');
'@ @'
    if(!G.arcade) sayWhenFree(String(e.name||'He').toUpperCase()+' WANTS REVENGE','info');   // v23.35 (arcade13): not in the arcade.
'@

SubRx @'
var VER='23.34';
'@ @'
var VER='23.35';
'@

$pat = "(?m)^  now:'v23\.34:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.35: In the arcade the HUD drops the conditions, the board, notoriety and the revenge lines, the extract arrow is bigger, and DROPPING IN counts down. Check 23.35 fails on v23.34',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
