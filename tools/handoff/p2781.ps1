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

# RELOAD BAR: RED ACTIVE ZONE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function tickReload(dt){
'@ @'
// v27.xx (feel2c), HIS WORDS (2026-10-14): "keep -- bar needs a clear red line for when the active reload happens". THE RELOAD BAR SHOWS THE ACTIVE RELOAD IN RED. The bar over the
// head had no sweet spot at all (only the ring on the cursor did, in green). Now the bar is a little wider and taller, the stretch of it from AR_A to AR_B is a solid RED ZONE with a red
// line at each end that reaches past the bar, a white playhead runs along it, and while the playhead is inside the zone (the moment R counts) the zone goes light red and its lines white;
// once it is missed the zone dims. The sweet spot on the cursor ring is red too, with a red tick across the ring at each end, the same cue in the same colours. Cosmetic only.
function reloadBarDraw(x,y,p){
  var tot=(p.rlTot>0)?p.rlTot:p.wep.reload, f=clamp(1-p.reloading/tot,0,1), BW=LH(88), BH=LH(8), x0=Math.round(x-BW/2), y0=Math.round(y-LH(18)), zx=Math.round(x0+BW*AR_A), zw=Math.round(BW*(AR_B-AR_A));
  var inz=(f>=AR_A&&f<=AR_B), miss=(f>AR_B), lw=Math.max(2,Math.round(LH(2))), ex=Math.round(LH(3));
  ctx.fillStyle='rgba(6,9,13,.78)';
  ctx.fillRect(x0-2,y0-2,BW+4,BH+4);
  bar(x0,y0,BW,BH,f,'#ffc04a');
  ctx.fillStyle=miss?'rgba(150,40,32,.60)':(inz?'rgb(255,150,138)':'rgb(232,58,44)');
  if(inz){ ctx.shadowColor='rgba(255,90,70,.95)'; ctx.shadowBlur=LH(9); }   // lit while R counts
  ctx.fillRect(zx,y0,zw,BH);
  ctx.shadowBlur=0; ctx.shadowColor='rgba(0,0,0,0)';
  ctx.fillStyle=miss?'rgba(255,69,56,.45)':(inz?'rgb(255,255,255)':'rgb(255,69,56)');
  ctx.fillRect(zx-1,y0-ex,lw,BH+2*ex);
  ctx.fillRect(zx+zw-1,y0-ex,lw,BH+2*ex);
  if(f>0&&f<1){ ctx.fillStyle='rgb(255,255,255)'; ctx.fillRect(Math.round(x0+BW*f)-1,y0-1,2,BH+2); }
}
function tickReload(dt){
'@

SubRx @'
      ctx.fillStyle='rgba(6,9,13,.72)';
      ctx.fillRect(_rb.x-27,_rb.y-LH(10),54,LH(8));
      bar(_rb.x-25,_rb.y-LH(9),50,LH(5),clamp(1-p.reloading/p.wep.reload,0,1),'#ffc04a');
'@ @'
      reloadBarDraw(_rb.x,_rb.y,p);   // v27.xx (feel2c): the bar with its red active reload zone
'@

SubRx @'
      ctx.strokeStyle=(_rlf>AR_B)?'rgba(150,240,170,.30)':((_rlf>=AR_A)?'rgba(235,255,240,1)':'rgba(150,240,170,.92)'); ctx.lineWidth=((_rlf>=AR_A&&_rlf<=AR_B)?6.4:5.2)*_wz; ctx.lineCap='butt';
'@ @'
      ctx.strokeStyle=(_rlf>AR_B)?'rgba(255,69,56,.40)':((_rlf>=AR_A)?'rgb(255,150,138)':'rgb(232,58,44)'); ctx.lineWidth=((_rlf>=AR_A&&_rlf<=AR_B)?6.8:5.4)*_wz; ctx.lineCap='butt';   // v27.xx (feel2c): the sweet spot is red
'@

SubRx @'
      ctx.beginPath(); ctx.arc(rx0,ry0,_rlr,-1.5708+6.2832*AR_A,-1.5708+6.2832*AR_B); ctx.stroke();
'@ @'
      if(_rlf>=AR_A&&_rlf<=AR_B){ ctx.shadowColor='rgba(255,90,70,.95)'; ctx.shadowBlur=9*_wz; }   // lit while R counts
      ctx.beginPath(); ctx.arc(rx0,ry0,_rlr,-1.5708+6.2832*AR_A,-1.5708+6.2832*AR_B); ctx.stroke();
      ctx.shadowBlur=0; ctx.shadowColor='rgba(0,0,0,0)';
      // v27.xx (feel2c): and the red line: a tick across the ring at each end of the zone, white while the ring is inside it
      ctx.strokeStyle=(_rlf>AR_B)?'rgba(255,69,56,.45)':((_rlf>=AR_A)?'rgb(255,255,255)':'rgb(255,69,56)'); ctx.lineWidth=2.4*_wz;
      for(var _rq=0;_rq<2;_rq++){
        var _rqa=-1.5708+6.2832*(_rq?AR_B:AR_A), _rqc=Math.cos(_rqa), _rqs=Math.sin(_rqa);
        ctx.beginPath(); ctx.moveTo(rx0+_rqc*(_rlr-7*_wz),ry0+_rqs*(_rlr-7*_wz)); ctx.lineTo(rx0+_rqc*(_rlr+7*_wz),ry0+_rqs*(_rlr+7*_wz)); ctx.stroke();
      }
'@

SubRx @'
var VER='27.80';
'@ @'
var VER='27.81';
'@

$pat = "(?m)^  now:'v27\.80:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.81: The reload bar shows the active reload as a red zone with red lines and a playhead, and the cursor ring shows it in red too. Check 27.81 fails on v27.80',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
