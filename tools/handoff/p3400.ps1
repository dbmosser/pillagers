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

# UNDERCROFT FLOOR CLEARANCE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function hubStationNames(S,ox,oy){
  if(titleOn()||tskOn()) return;
  var R=Math.max(1,(typeof hudRes==='function')?hudRes():1), z=R/S, pad=8*z, margin=34;
  wc.save(); wc.scale(S,S); wc.translate(-ox,-oy); wc.textAlign='center';
  for(var i=0;i<HB.stations.length;i++){
    var s3=HB.stations[i], on=HB.near===s3, hero=s3.id==='lift';
    wc.font=uiFont(hero?'hero':'body',z);
    var tw=wc.measureText(s3.label).width, lx=clamp(s3.x,margin+tw/2+pad,HUBW-margin-tw/2-pad);
    var ly=(s3.labelBelow?s3.y+s3.r+4:s3.y-56)+10;
    var met=wc.measureText(s3.label), asc=Math.max(8*z,met.actualBoundingBoxAscent||((hero?42:15)*z)), dsc=Math.max(2*z,met.actualBoundingBoxDescent||4*z);
    wc.fillStyle=UIC.ui_panel;
    wc.fillRect(lx-tw/2-pad,ly-asc-pad,tw+2*pad,asc+dsc+2*pad);
    wc.fillStyle=hero?UIC.acc:(on?UIC.tx_1:UIC.tx_2);
    wc.fillText(s3.label,lx,ly);
    if(hero||on){
      wc.fillStyle=UIC.acc; wc.fillRect(lx-tw/2-pad,ly+dsc+pad-2*z,tw+2*pad,2*z);
    }
    if(s3.id==='bar'){
      wc.font=uiFont('label',z); wc.fillStyle=UIC.warn;
      var caption='***EXPERIMENTAL***', ew=wc.measureText(typeof TX==='function'?TX(caption):caption).width;
      var ex=clamp(lx,margin+ew/2+pad,HUBW-margin-ew/2-pad), ey=ly+dsc+pad+24*z;
      wc.fillStyle=UIC.ui_panel; wc.fillRect(ex-ew/2-pad,ey-18*z,ew+2*pad,26*z);
      wc.fillStyle=UIC.warn; wc.fillText(caption,ex,ey);
    }
    if(s3.season){
      var ready=seasonReady();
      if(ready){
        var reward=ready+' REWARD'+(ready===1?'':'S')+' WAITING';
        wc.font=uiFont('label',z); var rw=wc.measureText(reward).width;
        var rx=clamp(s3.x,margin+rw/2+pad,HUBW-margin-rw/2-pad), ry=ly-asc-pad-12*z;
        wc.fillStyle=UIC.ui_panel; wc.fillRect(rx-rw/2-pad,ry-18*z,rw+2*pad,26*z);
        wc.fillStyle=UIC.tx_1; wc.fillText(reward,rx,ry);
      }
    }
  }
  wc.restore();
}

'@ @'
// v28.xx (cw-cx-hubfloorclear): critic 03/39, bordered plates with 16px side padding keep station names readable over the crowd.
function hubSignPlate(x,y,w,h,z,border){
  wc.save(); wc.beginPath();
  if(wc.roundRect) wc.roundRect(x,y,w,h,4*z); else wc.rect(x,y,w,h);
  wc.save(); wc.clip(); wc.globalAlpha=.9; wc.fillStyle=UIC.ui_panel; wc.fillRect(x,y,w,h); wc.restore();
  wc.lineWidth=z; wc.strokeStyle=border||UIC.ui_line_hi; wc.stroke(); wc.restore();
}
function hubStationNames(S,ox,oy){
  if(titleOn()||tskOn()) return;
  var R=Math.max(1,(typeof hudRes==='function')?hudRes():1), z=R/S, pad=16*z, vp=8*z, margin=34;
  wc.save(); wc.scale(S,S); wc.translate(-ox,-oy); wc.textAlign='center';
  for(var i=0;i<HB.stations.length;i++){
    var s3=HB.stations[i], on=HB.near===s3, hero=s3.id==='lift';
    wc.font=uiFont(hero?'hero':'body',z);
    var tw=wc.measureText(s3.label).width, lx=clamp(s3.x,margin+tw/2+pad,HUBW-margin-tw/2-pad);
    var ly=(s3.labelBelow?s3.y+s3.r+4:s3.y-56)+10;
    var met=wc.measureText(s3.label), asc=Math.max(8*z,met.actualBoundingBoxAscent||((hero?42:15)*z)), dsc=Math.max(2*z,met.actualBoundingBoxDescent||4*z);
    hubSignPlate(lx-tw/2-pad,ly-asc-vp,tw+2*pad,asc+dsc+2*vp,z,on?UIC.acc:null);
    wc.fillStyle=hero?UIC.acc:UIC.tx_1; wc.fillText(s3.label,lx,ly);
    if(s3.id==='bar'){
      // v28.xx (cw-cx-hubfloorclear): his v7.74 words and asterisks stay, despite the critic asking to remove them.
      wc.font=uiFont('label',z);
      var caption='***EXPERIMENTAL***', ew=wc.measureText(typeof TX==='function'?TX(caption):caption).width;
      var ex=clamp(lx,margin+ew/2+pad,HUBW-margin-ew/2-pad), ey=ly+dsc+vp+24*z;
      hubSignPlate(ex-ew/2-pad,ey-18*z,ew+2*pad,26*z,z);
      wc.fillStyle=UIC.warn; wc.fillText(caption,ex,ey);
    }
    if(s3.season){
      var ready=seasonReady();
      if(ready){
        var reward=ready+' REWARD'+(ready===1?'':'S')+' WAITING';
        wc.font=uiFont('label',z); var rw=wc.measureText(reward).width;
        var rx=clamp(s3.x,margin+rw/2+pad,HUBW-margin-rw/2-pad), ry=ly-asc-vp-12*z;
        hubSignPlate(rx-rw/2-pad,ry-18*z,rw+2*pad,26*z,z);
        wc.fillStyle=UIC.tx_1; wc.fillText(reward,rx,ry);
      }
    }
  }
  wc.restore();
}

'@

SubRx @'
  var x=(W-total)/2, y=hubFootY()-36*R;
'@ @'
  // v28.xx (cw-cx-hubfloorclear): 8px above the belt frame; the toast sits another 8px above this row or the focused prompt.
  var x=(W-total)/2, y=hubFootY()-48*R, toast=document.getElementById('hubtoast');
  if(toast){
    var scale=cv.getBoundingClientRect().height/Math.max(1,H), zoom=parseFloat(toast.style.zoom)||1;
    var ceiling=HB.near?Math.min(y,hubFootY()-100*R):y;
    var bottom=(Math.ceil((H-ceiling+8*R)*scale/zoom))+'px';
    if(toast.style.getPropertyValue('--hub-floor-toast-bottom')!==bottom) toast.style.setProperty('--hub-floor-toast-bottom',bottom);
  }
'@

SubRx @'
  body:not(:has(.modal.on)):not(:has(#hub.on)):not(:has(#title.on)):not(:has(.outcome.on)):not(:has(.pausebox.on)):not(:has(#attract.on)) #hubtoast{ bottom:150px; }
'@ @'
  body:not(:has(.modal.on)):not(:has(#hub.on)):not(:has(#title.on)):not(:has(.outcome.on)):not(:has(.pausebox.on)):not(:has(#attract.on)) #hubtoast{ bottom:var(--hub-floor-toast-bottom, 150px); } /* v28.xx (cw-cx-hubfloorclear): floor toast clears the canvas hints at any menu zoom. */
'@

SubRx @'
  ctx.save(); ctx.scale(_hhr,_hhr);
  ctx.shadowColor='rgba(4,6,9,.95)'; ctx.shadowBlur=4;
  ctx.font=uiFont('title'); ctx.fillStyle=UIC.tx_1;
'@ @'
  ctx.save(); ctx.scale(_hhr,_hhr);
  // v28.xx (cw-cx-hubfloorclear): one 72px title plate spans the wall seam without losing the five-percent inset.
  if(!hubWinOn()&&!document.getElementById('hub').classList.contains('on')){
    ctx.font=uiFont('title'); var headW=ctx.measureText('THE UNDERCROFT').width;
    ctx.font=uiFont('label'); var count=P.stash.length+' item'+(P.stash.length===1?'':'s')+' in stash  \u00b7  '+P.runs+' run'+(P.runs===1?'':'s');
    uiPanel(ctx,hx/_hhr-16,hy/_hhr-8,Math.max(headW,ctx.measureText(count).width)+32,72);
  }
  ctx.shadowColor='rgba(4,6,9,.95)'; ctx.shadowBlur=4;
  ctx.font=uiFont('title'); ctx.fillStyle=UIC.tx_1;
'@

SubRx @'
function startRaid(){
'@ @'
function startRaid(){
  // v28.xx (cw-cx-hubfloorclear): the hub-only toast clearance ends when ascending.
  var _floorToast=document.getElementById('hubtoast'); if(_floorToast) _floorToast.style.removeProperty('--hub-floor-toast-bottom');
'@

SubRx @'
var VER='33.99';
'@ @'
var VER='34.00';
'@

$pat = "(?m)^  now:'v33\.99:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v34.00: Hub toasts clear the hints, the title has a panel, and station names have cream text and padded bordered plates. Check 34.00 fails on v33.99',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
