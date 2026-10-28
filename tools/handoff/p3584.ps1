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

# FINAL RUSH HUD CLEARANCE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  return {a:a,hl:hl,sl:sl,bl:bl,hf:hf,lf:lf,hp:hp,gs:gs,w:Math.ceil(LH(12)+gs+LH(7)+w+LH(10)),h:y+Math.round((sl.length?lp:hp)*0.3)+LH(5)};
'@ @'
  // v28.xx (cw-cx-rushlayout): the rush uses a 416px minimum panel and a 16px inset at the normal text scale.
  if(a.key==='finalrush'){
    for(i=0;i<bl.length;i++) bl[i]+=LH(7);
    return {a:a,hl:hl,sl:sl,bl:bl,hf:hf,lf:lf,hp:hp,gs:gs,w:Math.max(LH(320),Math.ceil(LH(12)+gs+LH(7)+w+LH(12))),h:y+Math.round((sl.length?lp:hp)*0.3)+LH(24)};
  }
  return {a:a,hl:hl,sl:sl,bl:bl,hf:hf,lf:lf,hp:hp,gs:gs,w:Math.ceil(LH(12)+gs+LH(7)+w+LH(10)),h:y+Math.round((sl.length?lp:hp)*0.3)+LH(5)};
'@

SubRx @'
  hudPlate(x0,y0,L.w,L.h,col,(a.k==='crit'||a.k==='warn')?HUDC.dangerPlate:HUDC.plate);
'@ @'
  hudPlate(x0,y0,L.w,L.h,col,a.key==='finalrush'?'rgba(17,19,21,.96)':((a.k==='crit'||a.k==='warn')?HUDC.dangerPlate:HUDC.plate));   // v28.xx (cw-cx-rushlayout): red marks the rush title, with quiet graphite behind its detail.
'@

SubRx @'
  ALERTY=LH(96); if(G&&(G.arcade||G.career)&&!G.over&&HUDTOPB>0) ALERTY=Math.max(ALERTY,Math.ceil(HUDTOPB/z)+LH(6));   // v35.xx (cw-clockcard): under the clock card, the score card, the extract pill and its arrow (the stack grew by the clock card)
'@ @'
  ALERTY=LH(96); if(G&&(G.arcade||G.career)&&!G.over&&HUDTOPB>0) ALERTY=Math.max(ALERTY,Math.ceil(HUDTOPB/z)+LH(6));   // v35.xx (cw-clockcard): under the clock card, the score card, the extract pill and its arrow (the stack grew by the clock card)
  if(arcadeRushOn()) ALERTY=Math.max(ALERTY,Math.ceil(HUDTOPB/z)+LH(18));   // v28.xx (cw-cx-rushlayout): 24px clear space above the rush callout.
'@

SubRx @'
  var _tz=hudRes();
'@ @'
  var _tz=hudRes(), _rushUI=arcadeRushOn(), _compX=W/2;   // v28.xx (cw-cx-rushlayout): the rush keeps navigation beside the clock, clear of the callout.
'@

SubRx @'
    var _epw=Math.round(ctx.measureText(TX(_xpt)).width+LH(20)), _eph=Math.round(_hCmp*1.5), _xpk=extPillPulse(_xps), _xpx=Math.round(W/2-_epw/2), _xpy=Math.round(_yCmp-_hCmp*1.05);
'@ @'
    var _epw=Math.round(ctx.measureText(TX(_xpt)).width+LH(20)), _eph=Math.round(_hCmp*1.5), _xpk=extPillPulse(_xps), _xpx=Math.round(W/2-_epw/2), _xpy=Math.round(_yCmp-_hCmp*1.05);
    // v28.xx (cw-cx-rushlayout): move the existing extraction chip and arrow together, without duplicating a navigation control.
    if(_rushUI&&CLOCKBOX.g===G){
      _compX=Math.round(CLOCKBOX.x-24*_tz-_epw/2);
      _yCmp=Math.round(CLOCKBOX.y+CLOCKBOX.h/2+_hCmp*0.35);
      _yArw=Math.round(_yCmp+_hCmp*1.2);
      _xpx=Math.round(_compX-_epw/2); _xpy=Math.round(_yCmp-_hCmp*1.05);
    }
'@

SubRx @'
    if(_xpk>0){ var _xsc=1+0.12*Math.sin(Math.PI*_xpk); ctx.translate(W/2,_xpy+_eph/2); ctx.scale(_xsc,_xsc); ctx.translate(-W/2,-(_xpy+_eph/2)); }
'@ @'
    if(_xpk>0){ var _xsc=1+0.12*Math.sin(Math.PI*_xpk); ctx.translate(_compX,_xpy+_eph/2); ctx.scale(_xsc,_xsc); ctx.translate(-_compX,-(_xpy+_eph/2)); }
'@

SubRx @'
    hudText(_xpt,W/2,_yCmp);
'@ @'
    hudText(_xpt,_compX,_yCmp);
'@

SubRx @'
    ctx.save(); ctx.translate(W/2,_yArw+(G.arcade?Math.round(8*_tz):0)); ctx.rotate(za+Math.PI/2);
'@ @'
    ctx.save(); ctx.translate(_compX,_yArw+(G.arcade?Math.round(8*_tz):0)); ctx.rotate(za+Math.PI/2);
'@

SubRx @'
  HUDTOPB=(G.arcade||G.career)?Math.max((SCOREBOX.g===G)?SCOREBOX.y+SCOREBOX.h:0,Math.round(_yCmp+_hCmp*0.3)):0;   // v35.xx (cw-clockcard): the alert band starts under the top centre stack
'@ @'
  HUDTOPB=(G.arcade||G.career)?Math.max((SCOREBOX.g===G)?SCOREBOX.y+SCOREBOX.h:0,Math.round(_yCmp+_hCmp*0.3)):0;   // v35.xx (cw-clockcard): the alert band starts under the top centre stack
  if(_rushUI&&SCOREBOX.g===G) HUDTOPB=SCOREBOX.y+SCOREBOX.h;   // v28.xx (cw-cx-rushlayout): the side compass no longer occupies the alert column.
'@

SubRx @'
  if(!G||!(G.arcade||G.career)||!ctx) return;
'@ @'
  if(!G||!(G.arcade||G.career)||!ctx) return;
  var rushUI=arcadeRushOn();   // v28.xx (cw-cx-rushlayout): keep the larger clock above a quieter score window throughout the final rush.
'@

SubRx @'
      fb=FSz(TYPE.title,z),fs=FSz(TYPE.label,z),h=parseFloat((/([\d.]+)px/.exec(fb)||[0,20])[1]),lh=parseFloat((/([\d.]+)px/.exec(fs)||[0,16])[1]),
'@ @'
      fb=FSz(rushUI?TYPE.head:TYPE.title,z),fs=FSz(TYPE.label,z),h=parseFloat((/([\d.]+)px/.exec(fb)||[0,20])[1]),lh=parseFloat((/([\d.]+)px/.exec(fs)||[0,16])[1]),
'@

SubRx @'
    top=cBot+Math.round(6*z);
'@ @'
    top=cBot+Math.round((rushUI?16:6)*z);   // v28.xx (cw-cx-rushlayout): a full 16px gap between the separate clock and score windows.
'@

SubRx @'
  bot=Math.ceil(scoreY+h*.25+pad);
'@ @'
  bot=Math.ceil(scoreY+Math.max(h*.25,rushUI?lh:0)+pad);   // v28.xx (cw-cx-rushlayout): the partner figure keeps its descent and bottom inset with the quieter score font.
'@

SubRx @'
  hudPlate(cx-pw,top,pw*2,bot-top,null,HUDC.plate);
'@ @'
  hudPlate(cx-pw,top,pw*2,bot-top,null,rushUI?'rgba(17,19,21,.96)':HUDC.plate);   // v28.xx (cw-cx-rushlayout): score labels stay legible over a wall or rain.
'@

SubRx @'
  var z=WTX.z, X=(x-WTX.ox)*z, Y=(y-WTX.oy)*z, X1=X+w*z, Y1=Y+h*z, s=SCOREBOX;
'@ @'
  var z=WTX.z, X=(x-WTX.ox)*z, Y=(y-WTX.oy)*z, X1=X+w*z, Y1=Y+h*z, s=SCOREBOX;
  // v28.xx (cw-cx-rushlayout): keep world nameplates out of the rush banner, as they already clear the score and clock.
  if(ALERTL&&G&&G.alert===ALERTL.a&&ALERTL.a.key==='finalrush'){
    var az=(HUDZ.msg||1)*hudRes()*hudUserZ('msg'), aw=ALERTL.w*az, ay=ALERTY*az;
    if(X1>W/2-aw/2-8&&X<W/2+aw/2+8&&Y1>ay-8&&Y<ay+ALERTL.h*az+8) return true;
  }
'@

SubRx @'
  var _lanes=function(){
'@ @'
  if(arcadeRushOn()) msgLayout();   // v28.xx (cw-cx-rushlayout): the header was just measured; use this frame when drawing the rush, including its first frame.
  var _lanes=function(){
'@

SubRx @'
var VER='35.83';
'@ @'
var VER='35.84';
'@

$pat = "(?m)^  now:'v35\.83:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.84: The final rush banner has more space, a wide graphite panel and clear red title. The smaller score stays below the larger clock; extraction sits beside the clock during the rush. Check 35.84 fails on v35.83',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
