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

# UNDERCROFT HUB POLISH (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  wc.save(); wc.scale(S,S); wc.translate(-ox,-oy); wc.textAlign='center';
  for(var i=0;i<HB.stations.length;i++){
    var s3=HB.stations[i]
'@ @'
  wc.save(); wc.scale(S,S); wc.translate(-ox,-oy); wc.textAlign='center';
  HB.signRects=[];   // v36.xx (cw-hubpolish): where each sign plate sits on the screen, so the floor toast can stay clear of them
  for(var i=0;i<HB.stations.length;i++){
    var s3=HB.stations[i]
'@

SubRx @'
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
'@ @'
    var met=wc.measureText(s3.label), asc=Math.max(8*z,met.actualBoundingBoxAscent||((hero?42:15)*z)), dsc=Math.max(2*z,met.actualBoundingBoxDescent||4*z);
    // v36.xx (cw-hubpolish), critic on o-00l (2 of 5): "station signs and the experimental caption need one consistent treatment". The caption is the second line of the bar sign's own plate (it was a second plate 24 below). His v7.74 words and asterisks stay.
    var capRaw=(s3.id==='bar')?'***EXPERIMENTAL***':'', capW=0, capH=0, plW=tw+2*pad, plCx=lx;
    if(capRaw){ wc.font=uiFont('label',z); capW=wc.measureText(typeof TX==='function'?TX(capRaw):capRaw).width; capH=20*z; plW=Math.max(tw,capW)+2*pad; plCx=clamp(lx,margin+plW/2,HUBW-margin-plW/2); wc.font=uiFont(hero?'hero':'body',z); }
    var plH=asc+dsc+2*vp+capH, plX=plCx-plW/2, plY=ly-asc-vp;
    hubSignPlate(plX,plY,plW,plH,z,on?UIC.acc:null);
    wc.fillStyle=hero?UIC.acc:UIC.tx_1; wc.fillText(s3.label,plCx,ly);
    if(capRaw){ wc.font=uiFont('label',z); wc.fillStyle=UIC.warn; wc.fillText(capRaw,plCx,ly+dsc+17*z); }
    HB.signRects.push({id:s3.id,x:(plX-ox)*S,y:(plY-oy)*S,w:plW*S,h:plH*S});
'@

SubRx @'
  if(HB.near){
    var s=HB.near;
    // v20.50
'@ @'
  HB.promptRect=null;
  if(HB.near){
    var s=HB.near;
    // v20.50
'@

SubRx @'
    ctx.fillText('['+keyLabel('KeyE','E')+']  '+s.label,W/2,_hpF-76*_hpR);
'@ @'
    var _hpT='['+keyLabel('KeyE','E')+']  '+s.label, _hpW=ctx.measureText(_hpT).width;
    ctx.fillText(_hpT,W/2,_hpF-76*_hpR);
    HB.promptRect={x:W/2-_hpW/2,y:_hpF-76*_hpR-22*_hpR,w:_hpW,h:30*_hpR};   // v36.xx (cw-hubpolish): for the floor toast
'@

SubRx @'
function hubFloorToast(){
  var R=Math.max(1,(typeof hudRes==='function')?hudRes():1), y=hubFootY()-48*R, toast=document.getElementById('hubtoast');
  if(toast){
    var scale=cv.getBoundingClientRect().height/Math.max(1,H), zoom=parseFloat(toast.style.zoom)||1;
    var ceiling=HB.near?Math.min(y,hubFootY()-100*R):y;
    var bottom=(Math.ceil((H-ceiling+8*R)*scale/zoom))+'px';
    if(toast.style.getPropertyValue('--hub-floor-toast-bottom')!==bottom) toast.style.setProperty('--hub-floor-toast-bottom',bottom);
  }
}
'@ @'
// v36.xx (cw-hubpolish), critic on o-00l (2 of 5): "the welcome toast stacks near the station prompt and the stash sign". On the floor the toast now sits under the title plate, left of the first station sign it would meet, where nothing else lives. hubToastSlot gives null when that corner is too narrow; the toast then keeps its old place above the prompt.
function hubToastSlot(w0,h0,R,rects){
  var x=w0*.05-16*R, y=h0*.05+74*R, lim=Math.min(300*R,w0-x-20*R), i, r;
  for(i=0;i<rects.length;i++){ r=rects[i]; if(r.y<y+64*R&&r.y+r.h>y&&r.x+r.w>x&&r.x<x+lim) lim=Math.min(lim,r.x-12*R-x); }
  return lim>=170*R?{x:x,y:y,w:lim}:null;
}
function hubFloorToast(){
  var R=Math.max(1,(typeof hudRes==='function')?hudRes():1), y=hubFootY()-48*R, toast=document.getElementById('hubtoast');
  if(!toast) return;
  function sp(n,v){ if(toast.style.getPropertyValue(n)!==v) toast.style.setProperty(n,v); }
  var cr=cv.getBoundingClientRect(), scale=cr.height/Math.max(1,H), zoom=parseFloat(toast.style.zoom)||1;
  var ceiling=HB.near?Math.min(y,hubFootY()-100*R):y;
  sp('--hub-floor-toast-bottom',(Math.ceil((H-ceiling+8*R)*scale/zoom))+'px');
  var slot=hubToastSlot(W,H,R,HB.signRects||[]);
  if(slot){
    sp('--hub-floor-toast-left',Math.round((cr.left+slot.x*scale)/zoom)+'px');
    sp('--hub-floor-toast-top',Math.round((cr.top+slot.y*scale)/zoom)+'px');
    sp('--hub-floor-toast-w',Math.floor(slot.w*scale/zoom)+'px');
    toast.classList.add('hubslot');
  } else toast.classList.remove('hubslot');
}
'@

SubRx @'
    wc.globalAlpha=.09; wc.fillStyle=L3.c;
    wc.beginPath(); wc.arc(gx,gy,gr,0,6.2832); wc.fill();
'@ @'
    // v36.xx (cw-hubpolish), critic on o-00l: "translucent lighting discs overlap each other and the station signs". The glow was a flat disc with a hard rim; it fades to nothing at the rim now (same radius, same colour, 0.12 at the centre).
    var gGl=wc.createRadialGradient(gx,gy,0,gx,gy,gr); gGl.addColorStop(0,hexA(L3.c,.12)); gGl.addColorStop(1,hexA(L3.c,0));
    wc.globalAlpha=1; wc.fillStyle=gGl;
    wc.beginPath(); wc.arc(gx,gy,gr,0,6.2832); wc.fill();
'@

SubRx @'
  el.innerHTML='$'+c+'<span class="trgap"></span>'+x+' <small>XP</small> <span class="trsub">STASH $'+sv.toLocaleString()+' BAG $'+bv.toLocaleString()+'</span>';
'@ @'
  el.innerHTML='\x24'+c+'<span class="trgap"></span>'+x+' <small>XP</small> <small class="trl">STASH</small> \x24'+sv.toLocaleString()+' <small class="trl">BAG</small> \x24'+bv.toLocaleString();   // v36.xx (cw-hubpolish), critic on o-00l: "money ($) type varies between stations". The stash and bag values were 16px 600 beside the 24px 800 credits; all three $ values are the one number style now, the words stash and bag stay the quiet label.
'@

SubRx @'
  #topright small:nth-last-child(2){ margin-right:24px; }
'@ @'
  #topright small:nth-last-child(2){ margin-right:24px; }
  #topright small.trl{ margin-left:0; margin-right:8px; }   /* v36.xx (cw-hubpolish): the stash and bag words sit tight against their $ figures */
  #topright small.trl ~ small.trl{ margin-left:24px; }
'@

SubRx @'
  body:not(:has(.modal.on)):not(:has(#hub.on)):not(:has(#title.on)):not(:has(.outcome.on)):not(:has(.pausebox.on)):not(:has(#attract.on)) #hubtoast{ bottom:var(--hub-floor-toast-bottom, 150px); } /* v28.xx (cw-cx-hubfloorclear): floor toast clears the canvas hints at any menu zoom. */
'@ @'
  body:not(:has(.modal.on)):not(:has(#hub.on)):not(:has(#title.on)):not(:has(.outcome.on)):not(:has(.pausebox.on)):not(:has(#attract.on)) #hubtoast{ bottom:var(--hub-floor-toast-bottom, 150px); } /* v28.xx (cw-cx-hubfloorclear): floor toast clears the canvas hints at any menu zoom. */
  body:not(:has(.modal.on)):not(:has(#hub.on)):not(:has(#title.on)):not(:has(.outcome.on)):not(:has(.pausebox.on)):not(:has(#attract.on)) #hubtoast.hubslot{ left:var(--hub-floor-toast-left); top:var(--hub-floor-toast-top); bottom:auto; transform:none; box-sizing:border-box; max-width:var(--hub-floor-toast-w); text-align:left; }   /* v36.xx (cw-hubpolish): the floor toast sits under the title plate, clear of the station prompt and the stash sign */
'@

SubRx @'
  var _floorToast=document.getElementById('hubtoast'); if(_floorToast) _floorToast.style.removeProperty('--hub-floor-toast-bottom');
'@ @'
  var _floorToast=document.getElementById('hubtoast'); if(_floorToast) _floorToast.style.removeProperty('--hub-floor-toast-bottom');
  if(_floorToast) _floorToast.classList.remove('hubslot');   // v36.xx (cw-hubpolish)
'@

SubRx @'
var VER='36.83';
'@ @'
var VER='36.84';
'@

$pat = "(?m)^  now:'v36\.83:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.84: the undercroft hub reads cleanly: soft station glow, the toast under the title, one money style, one sign plate for the bar. Check 36.84 fails on v36.83',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
