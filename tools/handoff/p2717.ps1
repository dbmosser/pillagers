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

# THE GUN CARD HAS A SPOT OF ITS OWN (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var GUNCARD_T=4;
'@ @'
var GUNCARD_T=4;
// v27.17 (gcfix), HIS NOTE (2026-10-14): "gun cards on the right are causing collisions now". THE GUN CARD HAS A SPOT OF ITS OWN. It sat
// at the right edge with its bottom at 60 percent of the screen, which is where CONDITIONS (grown by its contracts), the run goals,
// the co-op kill feed and the pickup rows (six since v27.14) all end up, so on a pickup the card landed on top of one or more of
// them. It now stands on the gear readout (its bottom a margin above the top of that panel) and just left of the right column
// (CONDITIONS and the run goals), where nothing else is drawn; if the kill feed or a wide pickup row reaches it anyway it steps
// left of that. The ring badge already slides clear of the card (EDGEBOX.gun). Drawing only.
function gunCardSpot(cmp,tag){
  var rs=Math.max(1,hudRes()), m=Math.round(LH(8)*rs), sz=gunCardSize(cmp,tag), xR=W-m, yB=Math.round(H*0.6), B, i, j, moved, bs;
  B=HUDBOX.gear; if(B&&B.h>0&&B.y>H*0.4) yB=Math.round(B.y-m);
  yB=Math.max(sz.h+m,Math.min(H-m,yB));
  B=HUDBOX.cond; xR=Math.min(xR,((B&&B.w>0&&B.x>W*0.5)?B.x:(W-Math.round(LH(190)*rs)))-m);
  for(j=0;j<4;j++){
    moved=false; bs=[EDGEBOX.goals,EDGEBOX.feed,EDGEBOX.pick];
    for(i=0;i<bs.length;i++){ B=bs[i]; if(B&&B.w>0&&B.x<xR&&B.x+B.w>xR-sz.w&&B.y<yB&&B.y+B.h>yB-sz.h){ xR=Math.round(B.x-m); moved=true; } }
    if(!moved) break;
  }
  xR=Math.max(sz.w+m,xR);
  return {xR:xR,yB:yB};
}
'@

SubRx @'
  var _gch=gunCardDraw(gunCompare(C.w,C.vs),W-8*rs,Math.round(H*0.6),Math.max(0,Math.min(1,(GUNCARD_T-age)/0.5)),C.route);
'@ @'
  var _gcm=gunCompare(C.w,C.vs), _gsp=gunCardSpot(_gcm,C.route);   // v27.17 (gcfix): its own spot, left of the right column and on the gear readout
  var _gch=gunCardDraw(_gcm,_gsp.xR,_gsp.yB,Math.max(0,Math.min(1,(GUNCARD_T-age)/0.5)),C.route);
'@

SubRx @'
  try{ if(flowOn()) goalsHud(ctx); }catch(_gh){}
'@ @'
  EDGEBOX.goals=null; try{ if(flowOn()) goalsHud(ctx); }catch(_gh){}
'@

SubRx @'
  hudPanel(x,y,w,h,0.84);
  c.textBaseline='alphabetic'; c.textAlign='left'; c.font=hudFS(TYPE.micro);
'@ @'
  hudPanel(x,y,w,h,0.84);
  EDGEBOX.goals={x:x,y:y,w:w,h:h};   // v27.17 (gcfix): where the run goals are, so the gun card and the kill feed keep clear of them
  c.textBaseline='alphabetic'; c.textAlign='left'; c.font=hudFS(TYPE.micro);
'@

SubRx @'
  var _fy0=H*0.46, _fcb=HUDBOX.cond, _fn=Math.max(1,(NET.feed||[]).length), _fbh=_fn*LH(22)*_fhr;
'@ @'
  var _fy0=H*0.46, _fcb=HUDBOX.cond, _fn=Math.max(1,(NET.feed||[]).length), _fbh=_fn*LH(22)*_fhr, _fgb=EDGEBOX.goals;
  // v27.17 (gcfix): the run goals sit under CONDITIONS, so the panel the feed keeps clear of is the two of them together
  if(_fgb&&_fgb.w>0) _fcb=_fcb?{x:Math.min(_fcb.x,_fgb.x),y:Math.min(_fcb.y,_fgb.y),w:Math.max(_fcb.x+_fcb.w,_fgb.x+_fgb.w)-Math.min(_fcb.x,_fgb.x),h:Math.max(_fcb.y+_fcb.h,_fgb.y+_fgb.h)-Math.min(_fcb.y,_fgb.y)}:_fgb;
'@

SubRx @'
var VER='27.16';
'@ @'
var VER='27.17';
'@

$pat = "(?m)^  now:'v27\.16:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.17: The gun card on pickup now has its own spot above the gear readout, clear of CONDITIONS, the run goals, the kill feed and the pickup rows. Check 27.17 fails on v27.16',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
