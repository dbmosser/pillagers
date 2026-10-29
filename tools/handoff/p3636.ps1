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

# UNDERCROFT WITHOUT HINT BARS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
// v28.xx (cw-cx-hubfloor): 16px words and 28px key chips; bindings and last-input pad labels stay live.
function hubFloorHints(line){
  var R=Math.max(1,(typeof hudRes==='function')?hudRes():1), rows;
  if(padOn()) rows=[[padB('L STICK'),'WALK'],[padB('LS'),'JOG'],[keyLabel('KeyE','E'),'USE STATION']];
  else rows=[[keyLabel('KeyW','W')+keyLabel('KeyA','A')+keyLabel('KeyS','S')+keyLabel('KeyD','D'),'WALK'],[keyLabel('ShiftLeft','SHIFT'),'JOG'],[keyLabel('KeyE','E'),'USE STATION']];
  if(HB&&HB.drops&&HB.drops.length) rows.push([keyLabel('KeyE','E'),'TAKE THE DROPPED ITEM']);
  if(!padOn()&&typeof line==='string'){
    rows=line.split(/\s+\u00b7\s+/).map(function(s){ var m=/^(.*?) (WALK|JOG|USE STATION|TAKE THE DROPPED ITEM)$/.exec(s); return m?[m[1],m[2]]:null; }).filter(function(s){return !!s;});
  }
  if(!padOn()) rows.push([keyLabel('KeyM','M'),'MAP']);   // cw-beltswap: M opens the lift map on the floor (35.12)
  ctx.save(); ctx.font=uiFont('label',R); ctx.textAlign='left';
  var total=32*R, i;
  for(i=0;i<rows.length;i++){
    rows[i].push(Math.max(28*R,ctx.measureText(rows[i][0]).width+16*R),ctx.measureText(rows[i][1]).width);
    total+=rows[i][2]+8*R+rows[i][3]+(i?24*R:0);
  }
  // v28.xx (cw-cx-hubfloorclear): 8px above the belt frame; the toast sits another 8px above this row or the focused prompt.
  var x=(W-total)/2, y=hubFootY()-48*R, toast=document.getElementById('hubtoast');
  if(toast){
    var scale=cv.getBoundingClientRect().height/Math.max(1,H), zoom=parseFloat(toast.style.zoom)||1;
    var ceiling=HB.near?Math.min(y,hubFootY()-100*R):y;
    var bottom=(Math.ceil((H-ceiling+8*R)*scale/zoom))+'px';
    if(toast.style.getPropertyValue('--hub-floor-toast-bottom')!==bottom) toast.style.setProperty('--hub-floor-toast-bottom',bottom);
  }
  uiPanel(ctx,x,y,total,44*R); x+=16*R;
  for(i=0;i<rows.length;i++){
    var row=rows[i];
    ctx.fillStyle=UIC.ui_raised; ctx.fillRect(x,y+8*R,row[2],28*R);
    ctx.strokeStyle=UIC.ui_line_hi; ctx.lineWidth=R; ctx.strokeRect(x+.5*R,y+8.5*R,row[2]-R,27*R);
    ctx.fillStyle=UIC.tx_1; ctx.textAlign='center'; ctx.fillText(row[0],x+row[2]/2,y+27*R);
    x+=row[2]+8*R; ctx.textAlign='left'; ctx.fillStyle=UIC.tx_2; ctx.fillText(row[1],x,y+27*R);
    x+=row[3]+24*R;
  }
  ctx.restore();
}
'@ @'
// v28.xx (cw-cx-hubnohint), his 2026-10-28 note: "get rid of all this shit in the undercroft, none of it is helpful". Keep toast clearance without drawing a key bar.
function hubFloorToast(){
  var R=Math.max(1,(typeof hudRes==='function')?hudRes():1), y=hubFootY()-48*R, toast=document.getElementById('hubtoast');
  if(toast){
    var scale=cv.getBoundingClientRect().height/Math.max(1,H), zoom=parseFloat(toast.style.zoom)||1;
    var ceiling=HB.near?Math.min(y,hubFootY()-100*R):y;
    var bottom=(Math.ceil((H-ceiling+8*R)*scale/zoom))+'px';
    if(toast.style.getPropertyValue('--hub-floor-toast-bottom')!==bottom) toast.style.setProperty('--hub-floor-toast-bottom',bottom);
  }
}

'@

SubRx @'
    // v10.93, HIS NOTE: this was #8a96a1, which is the dimmest grey in the file.
    ctx.font=uiFont('label',_hpR); ctx.fillStyle=UIC.tx_2; // v28.xx (cw-cx-hubfloor): guide size and muted colour.
    ctx.fillText(typeof s.sub==='function'?s.sub():s.sub,W/2,_hpF-52*_hpR);
'@ @'
    // v28.xx (cw-cx-hubnohint): his 2026-10-28 removal applies to every station option row, keyboard and pad. The E prompt above stays.
'@

SubRx @'
  // v28.xx (cw-cx-hubfloor): the existing words and bindings feed the 16px control pill.
  hubFloorHints(hubFootKeys(
'@ @'
  hubFloorToast();   // v28.xx (cw-cx-hubnohint): toast placement survives the removed footer. Retired footer arguments: 
'@

SubRx @'
    _lg.push('F1','close this');   if(!padOn()) for(var _li=0;_li<_lg.length;_li+=2) _lg[_li]=legendKeys(_lg[_li]);   // v25.xx (keyremap): and the Undercroft list names the keys as set
'@ @'
    _lg.push('F1','close this');   if(!padOn()) for(var _li=0;_li<_lg.length;_li+=2) _lg[_li]=legendKeys(_lg[_li]);   // v25.xx (keyremap): and the Undercroft list names the keys as set
    // v28.xx (cw-cx-hubnohint): the removed lift options remain discoverable in the requested controls list.
    _lg.push(keyLabel('KeyR','R'),'lift: quick ascent',keyLabel('KeyT','T'),'lift: the terms',keyLabel('KeyF','F'),'lift: party');
'@

SubRx @'
var VER='36.35';
'@ @'
var VER='36.36';
'@

$pat = "(?m)^  now:'v36\.35:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.36: the undercroft has no key bars. Station prompts remain and the lift shortcuts are in F1 help. Check 36.36 fails on v36.35',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
