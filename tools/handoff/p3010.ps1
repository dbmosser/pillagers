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

# Arcade drop controls card is the how to play table (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
body #attract .arcpage .aprt{ margin-left:calc(var(--sp-1) * var(--attz,1)); font-size:calc(var(--fs-label) * var(--attz,1)); font-weight:600; color:var(--tx-2); }
'@ @'
body #attract .arcpage .aprt{ margin-left:calc(var(--sp-1) * var(--attz,1)); font-size:calc(var(--fs-label) * var(--attz,1)); font-weight:600; color:var(--tx-2); }
/* v30.xx (cw-partyhud), the critic on v30.04 (46, 55 = 3): "amber text is banned, the glyph carries the amber"; "a 50px dead gap between the stats and the footer"; "the run over title is as loud as the hero". The prompt words are the light text colour (the button glyph stays accent), the card footer is 104px again, the run over title is the muted text colour so the score leads. Restyle only. */
body #attract[style*="block"]:has(.arcpage[style*="block"]) .attpress, body #attract[style*="block"]:has(.arcover[style*="block"]) .attpress{ color:var(--tx-1); }
body #attract[style*="block"]:has(.arcpage[style*="block"]) .arcpage, body #attract[style*="block"]:has(.arcover[style*="block"]) .arcover{ padding-bottom:calc((var(--sp-3) * 2 + var(--btn-h)) * var(--attz,1)); }
body #attract .arcover .aoh:first-child{ color:var(--tx-2); }
'@

SubRx @'
function arcadeCardHud(){
  var a=arcadeCardOn(), rows, i, j, w=[0,0,0], x, y, lh, pd, gp, hh, pw, ph, cx;
  if(!(a>0)||!ctx) return;
  rows=arcadeCardRows();
  ctx.save(); ctx.globalAlpha=a; ctx.textAlign='left'; ctx.textBaseline='alphabetic';
  for(i=0;i<rows.length;i++) for(j=0;j<3;j++){ ctx.font=j?FS(TYPE.label):FS(TYPE.head); w[j]=Math.max(w[j],ctx.measureText(rows[i][j]).width); }
  ctx.font=FS(TYPE.micro); w[1]=Math.max(w[1],ctx.measureText('KEYBOARD').width); w[2]=Math.max(w[2],ctx.measureText('CONTROLLER').width);
  lh=LH(26); pd=LH(14); gp=LH(18); hh=LH(20);
  pw=Math.round(pd*2+w[0]+w[1]+w[2]+gp*2); ph=Math.round(pd*2+hh+lh*rows.length);
  x=LH(24); y=Math.round(H*0.5-ph/2);
  ctx.fillStyle='rgba(6,9,13,.80)'; ctx.fillRect(x,y,pw,ph);
  ctx.strokeStyle='rgba(255,192,74,.55)'; ctx.lineWidth=2; ctx.strokeRect(x+1,y+1,pw-2,ph-2);
  cx=[x+pd,x+pd+w[0]+gp,x+pd+w[0]+gp+w[1]+gp];
  ctx.font=FS(TYPE.micro); ctx.fillStyle='#9a8f78';
  hudText('KEYBOARD',Math.round(cx[1]),Math.round(y+pd+LH(10))); hudText('CONTROLLER',Math.round(cx[2]),Math.round(y+pd+LH(10)));
  for(i=0;i<rows.length;i++){
    var ry=Math.round(y+pd+hh+lh*i+LH(17));
    ctx.font=FS(TYPE.head); ctx.fillStyle='#ffc04a'; hudText(rows[i][0],Math.round(cx[0]),ry);
    ctx.font=FS(TYPE.label); ctx.fillStyle='#e8eef2'; hudText(rows[i][1],Math.round(cx[1]),ry);
    ctx.fillStyle='#7fe3d4'; hudText(rows[i][2],Math.round(cx[2]),ry);
  }
  ctx.restore();
}
'@ @'
// v30.xx (cw-partyhud), the critic on the arcade drop (47 48 = 2): "an amber headed table that buries the playfield, amber row names, a two pixel amber box". The card is the how to play page on the HUD: Panel P with the accent bar, light action names, key caps (1px line, 4px radius) for every key, the extract ring as a teal ring glyph, a 1px line under every row.
function arcadeChip(c,x,y,w,h){ var r=UIT.rad; c.beginPath(); c.moveTo(x+r,y); c.arcTo(x+w,y,x+w,y+h,r); c.arcTo(x+w,y+h,x,y+h,r); c.arcTo(x,y+h,x,y,r); c.arcTo(x,y,x+w,y,r); c.closePath(); }
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
'@

SubRx @'
var VER='30.09';
'@ @'
var VER='30.10';
'@

$pat = "(?m)^  now:'v30\.09:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v30.10: The controls card at the arcade drop looks like the how to play page. Check 30.10 fails on v30.09',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
