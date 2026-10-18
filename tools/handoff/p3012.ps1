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

# Arcade controls card: a title, clear of the feed and the F1 hint (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function arcadeCardHud(){
  var a=arcadeCardOn(), rows, i, j, k, w=[0,0,0], x, y, lh, pd, gp, hh, ch, cp, pw, ph, cx, ry, c, tw, px;
  if(!(a>0)||!ctx) return;
  rows=arcadeCardRows();
  ch=LH(24); cp=LH(8); gp=LH(24); lh=LH(30); pd=LH(18); hh=LH(26);
  function cell(s){ s=String(s); return {p:s.replace(/ IN A TEAL RING$/i,'').split(' / '), ring:/ IN A TEAL RING$/i.test(s)}; }
  function cwid(s){ var q=cell(s), t=0, n; for(n=0;n<q.p.length;n++) t+=ctx.measureText(q.p[n]).width+cp*3; if(q.ring) t+=LH(20); return t; }
  ctx.save(); ctx.globalAlpha=a; ctx.textAlign='left'; ctx.textBaseline='middle';
  ctx.font=FS(TYPE.head); for(i=0;i<rows.length;i++) w[0]=Math.max(w[0],ctx.measureText(rows[i][0]).width);
  ctx.font=FS(TYPE.label); w[1]=ctx.measureText('KEYBOARD').width; w[2]=ctx.measureText('CONTROLLER').width;
  for(i=0;i<rows.length;i++) for(j=1;j<3;j++) w[j]=Math.max(w[j],cwid(rows[i][j]));
  pw=Math.round(pd*2+w[0]+w[1]+w[2]+gp*2); ph=Math.round(pd*2+hh+lh*rows.length);
  x=LH(24); y=Math.round(H*0.5-ph/2);
  uiPanel(ctx,x,y,pw,ph,UIC.acc);
  cx=[x+pd,x+pd+w[0]+gp,x+pd+w[0]+gp+w[1]+gp];
  ctx.font=FS(TYPE.label); ctx.fillStyle=UIC.tx_2;
  ctx.fillText('KEYBOARD',Math.round(cx[1]),Math.round(y+pd+hh*0.5)); ctx.fillText('CONTROLLER',Math.round(cx[2]),Math.round(y+pd+hh*0.5));
  ctx.fillStyle=UIC.ui_line_hi; ctx.fillRect(Math.round(x+pd),Math.round(y+pd+hh-1),pw-pd*2,1);
  for(i=0;i<rows.length;i++){
    ry=Math.round(y+pd+hh+lh*i+lh*0.5);
    ctx.font=FS(TYPE.head); ctx.fillStyle=UIC.tx_1; ctx.fillText(rows[i][0],Math.round(cx[0]),ry);
    for(j=1;j<3;j++){
      c=cell(rows[i][j]); px=cx[j]; ctx.font=FS(TYPE.label);
      for(k=0;k<c.p.length;k++){
        tw=ctx.measureText(c.p[k]).width;
        arcadeChip(ctx,Math.round(px),Math.round(ry-ch/2),Math.round(tw+cp*2),ch); ctx.fillStyle=UIC.ui_raised; ctx.fill(); ctx.lineWidth=1; ctx.strokeStyle=UIC.ui_line_hi; ctx.stroke();
        ctx.fillStyle=UIC.tx_1; ctx.fillText(c.p[k],Math.round(px+cp),ry); px+=tw+cp*3;
      }
      if(c.ring){ ctx.beginPath(); ctx.arc(Math.round(px+LH(5)),ry,LH(8),0,6.2832); ctx.lineWidth=3; ctx.strokeStyle=UIC.extract; ctx.stroke(); }
    }
    if(i<rows.length-1){ ctx.fillStyle=UIC.ui_line; ctx.fillRect(Math.round(cx[0]),Math.round(y+pd+hh+lh*(i+1)-1),pw-pd*2,1); }
  }
  ctx.restore();
}
'@ @'
function arcadeCardHud(){
  var a=arcadeCardOn(), rows, i, j, k, w=[0,0,0], x, y, lh, pd, gp, hh, tt, ch, cp, pw, ph, cx, ry, c, tw, px, y0;
  if(!(a>0)||!ctx) return;
  rows=arcadeCardRows();
  ch=LH(24); cp=LH(8); gp=LH(24); lh=LH(30); pd=LH(18); hh=LH(26); tt=LH(34);
  function cell(s){ s=String(s); return {p:s.replace(/ IN A TEAL RING$/i,'').split(' / '), ring:/ IN A TEAL RING$/i.test(s)}; }
  function cwid(s){ var q=cell(s), t=0, n; for(n=0;n<q.p.length;n++) t+=ctx.measureText(q.p[n]).width+cp*3; if(q.ring) t+=LH(20); return t; }
  ctx.save(); ctx.globalAlpha=a; ctx.textAlign='left'; ctx.textBaseline='middle';
  ctx.font=FS(TYPE.head); for(i=0;i<rows.length;i++) w[0]=Math.max(w[0],ctx.measureText(rows[i][0]).width);
  ctx.font=FS(TYPE.label); w[1]=ctx.measureText('KEYBOARD').width; w[2]=ctx.measureText('CONTROLLER').width;
  for(i=0;i<rows.length;i++) for(j=1;j<3;j++) w[j]=Math.max(w[j],cwid(rows[i][j]));
  pw=Math.round(pd*2+w[0]+w[1]+w[2]+gp*2); ph=Math.round(pd*2+tt+hh+lh*rows.length);
  x=LH(24); y=Math.round(Math.min(H*0.5-ph/2,H*0.68-ph));   // v30.xx (cw-partyhud2): centred, but never down over the feed
  uiPanel(ctx,x,y,pw,ph,UIC.acc);
  cx=[x+pd,x+pd+w[0]+gp,x+pd+w[0]+gp+w[1]+gp]; y0=y+pd+tt;
  ctx.font=FS(TYPE.title); ctx.fillStyle=UIC.tx_1; ctx.fillText('HOW TO PLAY',Math.round(cx[0]),Math.round(y+pd+tt*0.5));
  ctx.font=FS(TYPE.label); ctx.fillStyle=UIC.tx_2;
  ctx.fillText('KEYBOARD',Math.round(cx[1]),Math.round(y0+hh*0.5)); ctx.fillText('CONTROLLER',Math.round(cx[2]),Math.round(y0+hh*0.5));
  ctx.fillStyle=UIC.ui_line_hi; ctx.fillRect(Math.round(x+pd),Math.round(y0+hh-1),pw-pd*2,1);
  for(i=0;i<rows.length;i++){
    ry=Math.round(y0+hh+lh*i+lh*0.5);
    ctx.font=FS(TYPE.head); ctx.fillStyle=UIC.tx_1; ctx.fillText(rows[i][0],Math.round(cx[0]),ry);
    for(j=1;j<3;j++){
      c=cell(rows[i][j]); px=cx[j]; ctx.font=FS(TYPE.label);
      for(k=0;k<c.p.length;k++){
        tw=ctx.measureText(c.p[k]).width;
        arcadeChip(ctx,Math.round(px),Math.round(ry-ch/2),Math.round(tw+cp*2),ch); ctx.fillStyle=UIC.ui_raised; ctx.fill(); ctx.lineWidth=1; ctx.strokeStyle=UIC.ui_line_hi; ctx.stroke();
        ctx.fillStyle=UIC.tx_1; ctx.fillText(c.p[k],Math.round(px+cp),ry); px+=tw+cp*3;
      }
      if(c.ring){ ctx.beginPath(); ctx.arc(Math.round(px+LH(5)),ry,LH(8),0,6.2832); ctx.lineWidth=3; ctx.strokeStyle=UIC.extract; ctx.stroke(); }
    }
    if(i<rows.length-1){ ctx.fillStyle=UIC.ui_line; ctx.fillRect(Math.round(cx[0]),Math.round(y0+hh+lh*(i+1)-1),pw-pd*2,1); }
  }
  ctx.restore();
}
'@

SubRx @'
    if(!(PAD&&PAD.on)) ctx.fillText(legendKeys('F1')+'  controls',14,_hy);   // v25.xx (keyswap): F1
'@ @'
    if(!(PAD&&PAD.on)&&!(typeof arcadeCardOn==='function'&&arcadeCardOn()>0)) ctx.fillText(legendKeys('F1')+'  controls',14,_hy);   // v25.xx (keyswap): F1; v30.xx (cw-partyhud2): not while the arcade controls card is up (it showed through the card)
'@

SubRx @'
var VER='30.11';
'@ @'
var VER='30.12';
'@

$pat = "(?m)^  now:'v30\.11:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v30.12: The controls card at the arcade drop has a title and nothing behind it. Check 30.12 fails on v30.11',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
