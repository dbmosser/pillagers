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

# END CARDS: HAUL STRIP IN ONE ROW, WHAT IS NEW CARD GETS AN X AND THREE SHORT NOTES (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  #root .ocwin .haulstrip{ text-wrap:balance; }

'@ @'
  #root .ocwin .haulstrip{ text-wrap:balance; }
  /* v28.xx (cw-endrow), the critic on 76 and 77 (2 and 3 of 5): "haul slots should be one row of 64px tiles, items reveal in place, +n more inside the row". The strip is one centred row of up to eight tiles (the JS cap is eight now, was twelve in two ragged rows) with the +n more count at its end. */
  #root .ocwin .haulstrip{ display:flex !important; flex-wrap:nowrap; justify-content:center; align-items:center; gap:6px; margin:16px 0 8px !important; }
  #root .ocwin .haulstrip .haulit{ margin:0 !important; flex:0 0 auto; }
  #root .ocwin .haulstrip>span:not(.haulit){ margin:0 0 0 6px !important; color:var(--tx-2) !important; font-size:16px; white-space:nowrap; }
'@

SubRx @'
for(k=0;k<keys.length&&k<12;k++)
'@ @'
for(k=0;k<keys.length&&k<8;k++)
'@

SubRx @'
if(keys.length>12) s+='<span style="color:var(--ash);margin-left:6px">+'+(keys.length-12)
'@ @'
if(keys.length>8) s+='<span style="color:var(--ash);margin-left:6px">+'+(keys.length-8)
'@

SubRx @'
var WNSEEN=1;
'@ @'
var WNX=null;   // v28.xx (cw-endrow): the card's X and Got it boxes in canvas pixels, set when the card draws, read by the click handler
// v28.xx (cw-endrow), the critic on 40 (2 of 5): "five paragraphs of two lines; cut to short one-line bullets". Q8, reason in notes/ui/changes.md: the card shows the headline sentence of each of the newest three notes (the whole note when it is short); the pause window still shows the longer notes.
function wnHead(s){
  var t=String(s||''), i=t.indexOf('. ');
  if(i<0) return wnShort(t);
  if(t.length<=60) return t;
  return t.slice(0,i+1);
}
var WNSEEN=1;
'@

SubRx @'
for(var wm=0;wm<Math.min(WN_SHOW,wnL.length);wm++){
'@ @'
for(var wm=0;wm<Math.min(3,wnL.length);wm++){
'@

SubRx @'
var wWords=TX((wm+1)+'. '+wnShort(wnL[wm]))
'@ @'
var wWords=TX((wm+1)+'. '+wnHead(wnL[wm]))
'@

SubRx @'
    ctx.fillStyle=UIC.ui_line_hi; ctx.fillRect(wnX+LH(22),wnY+LH(44),wnW-LH(44),1);

'@ @'
    ctx.fillStyle=UIC.ui_line_hi; ctx.fillRect(wnX+LH(22),wnY+LH(44),wnW-LH(44),1);
    // v28.xx (cw-endrow), the critic on 40: "no X, no accent tab" (Q43: a card gets an X; the guide: a 3px lime tab). The X is the same job as Got it.
    ctx.fillStyle=UIC.acc; ctx.fillRect(wnX,wnY,LH(3),wnH);
    var _wxs=LH(40), _wxx=wnX+wnW-LH(14)-_wxs, _wxy=wnY+LH(14);
    ctx.strokeStyle=UIC.ui_line_hi; ctx.strokeRect(_wxx+0.5,_wxy+0.5,_wxs-1,_wxs-1);
    ctx.textAlign='center'; ctx.font=FS(TYPE.title); ctx.fillStyle=UIC.tx_1; ctx.fillText('\u00d7',_wxx+_wxs/2,_wxy+_wxs*0.72); ctx.textAlign='left';
    WNX={x:_wxx*_wnr,y:_wxy*_wnr,w:_wxs*_wnr,h:_wxs*_wnr};
'@

SubRx @'
    ctx.fillText('Got it',_gbX+_gbW/2,_gbY+_gbH*0.68);

'@ @'
    ctx.fillText('Got it',_gbX+_gbW/2,_gbY+_gbH*0.68);
    WNX.gx=_gbX*_wnr; WNX.gy=_gbY*_wnr; WNX.gw=_gbW*_wnr; WNX.gh=_gbH*_wnr;
'@

SubRx @'
  if(G&&G.mapFirst&&!G.over){ if(e.button===0) mapFirstGo('click'); return; }
'@ @'
  if(e.button===0&&!WNSEEN&&WNX){   // v28.xx (cw-endrow): a click on the what is new card's X or Got it closes it
    var _wr=cv.getBoundingClientRect(), _wcx=(e.clientX-_wr.left)*cv.width/Math.max(1,_wr.width), _wcy=(e.clientY-_wr.top)*cv.height/Math.max(1,_wr.height);
    if((_wcx>=WNX.x&&_wcx<=WNX.x+WNX.w&&_wcy>=WNX.y&&_wcy<=WNX.y+WNX.h)||(WNX.gw&&_wcx>=WNX.gx&&_wcx<=WNX.gx+WNX.gw&&_wcy>=WNX.gy&&_wcy<=WNX.gy+WNX.gh)){ WNSEEN=1; WNX=null; try{ blip('pick'); }catch(_wb){} return; }
  }  if(G&&G.mapFirst&&!G.over){ if(e.button===0) mapFirstGo('click'); return; }
'@

SubRx @'
var VER='31.93';
'@ @'
var VER='31.94';
'@

$pat = "(?m)^  now:'v31\.93:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.94: The haul strip is one row of up to eight tiles with a count at its end. The what is new card has a lime tab, an X and Got it that both close it by click, and three short notes. Check 31.94 fails on v31.93',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
