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

# THE BOSS BAR STAYS IN SIGHT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function drawGiftLine(){
  var gi, go, t, s=null, it, w, y;
  if(typeof G==='undefined'||!G||G.over||!G.player) return null;
'@ @'
// v20.55, from the whole-game bug hunt of 2026-10-08 (H38): THE TOP CENTRE STACKS, ONE BAND EACH: THE MESSAGE, THE BOSS BAR, THE
// OFFER LINE, THE CONTROLLER WORD. The boss bar sat at the height of the message plate, which is painted after it, so every
// message (a pickup, a kill, a warning) covered THE OVERSEER's name and bar for three seconds; and the CONTROLLER PAUSED word
// and this offer line shared one band and printed on top of each other. Each now starts below the one above it and notes its
// own bottom edge, in screen pixels, for the next (HUDBOSSB, HUDGIFTB; 0 when it was not drawn). With no boss bar and no
// offer up, nothing moves.
var HUDBOSSB=0, HUDGIFTB=0;
function drawGiftLine(){
  var gi, go, t, s=null, it, w, y;
  HUDGIFTB=0;
  if(typeof G==='undefined'||!G||G.over||!G.player) return null;
'@

SubRx @'
  y=Math.round(LH(132)*hudRes());   // v18.49: below the boss bar and above the message plate (was LH(104), on the toast)
'@ @'
  y=Math.round(LH(132)*hudRes());   // v18.49: below the boss bar and above the message plate (was LH(104), on the toast)
  if(HUDBOSSB>0) y=Math.max(y,HUDBOSSB+LH(4)+LH(15));   // v20.55 (H38): its plate starts under the boss bar when the bar is up
'@

SubRx @'
  ctx.fillStyle='#ffc04a'; ctx.fillText(s,W/2,y);
  ctx.restore();
  return s;
}// v17.45, his pick 21
'@ @'
  ctx.fillStyle='#ffc04a'; ctx.fillText(s,W/2,y);
  ctx.restore();
  HUDGIFTB=y+LH(7);   // v20.55 (H38): the bottom of this plate, for the controller word
  return s;
}// v17.45, his pick 21
'@

SubRx @'
function drawBossBar(){
  var e=null, p=G&&G.player, i, w, x, y, f;
  if(!G||G.over||!p||!G.ents) return;
'@ @'
function drawBossBar(){
  var e=null, p=G&&G.player, i, w, x, y, f;
  HUDBOSSB=0;   // v20.55 (H38): nothing drawn yet this frame
  if(!G||G.over||!p||!G.ents) return;
'@

SubRx @'
  w=Math.min(520,W*0.4); x=W/2-w/2; y=Math.round(LH(108)*hudRes());   // v18.49: below the clock, the compass and the extract arrow, scaled with them (was LH(64), inside the stack)
'@ @'
  w=Math.min(520,W*0.4); x=W/2-w/2; y=Math.round(LH(108)*hudRes());   // v18.49: below the clock, the compass and the extract arrow, scaled with them (was LH(64), inside the stack)
  y=Math.round((LH(96)+LH(17))*(HUDZ.msg||1)*hudRes()*hudUserZ('msg'))+LH(4)+LH(16);   // v20.55 (H38): the plate starts under the message plate, at every screen size and message size
'@

SubRx @'
  ctx.font=FS(TYPE.label); ctx.textAlign='center'; ctx.fillStyle='#ffc04a'; ctx.fillText(e.name,W/2,y-LH(4));
'@ @'
  ctx.font=FS(TYPE.label); ctx.textAlign='center'; ctx.fillStyle='#ffc04a'; ctx.fillText(e.name,W/2,y-LH(4));
  HUDBOSSB=y+10;   // v20.55 (H38): the bottom of the boss plate, for the offer line and the controller word
'@

SubRx @'
    ctx.fillStyle='rgba(6,9,13,.62)'; ctx.fillRect(W/2-w/2-LH(8),LH(120),w+LH(16),LH(17));
    ctx.fillStyle='#ffc04a'; ctx.fillText(t,W/2,LH(133));
'@ @'
    // v20.55 (H38): and under the boss bar and the offer line when they are up. Their bottoms are screen pixels and this plate
    // is drawn under the message scale, so the gap is divided by that scale. With neither up it stays at LH(120).
    var _pz=(HUDZ.msg||1)*hudRes()*hudUserZ('msg'), _py=Math.max(LH(120),Math.ceil((Math.max(HUDBOSSB,HUDGIFTB)+LH(4))/_pz));
    ctx.fillStyle='rgba(6,9,13,.62)'; ctx.fillRect(W/2-w/2-LH(8),_py,w+LH(16),LH(17));
    ctx.fillStyle='#ffc04a'; ctx.fillText(t,W/2,_py+LH(133)-LH(120));
'@

SubRx @'
var VER='20.54';
'@ @'
var VER='20.55';
'@

$pat = "(?m)^  now:'v20\.54:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.55: Messages no longer cover the health bar of THE OVERSEER, and the trade offer and controller lines no longer overlap. Check 20.55 fails on v20.54',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
