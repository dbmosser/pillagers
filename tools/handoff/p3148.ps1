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

# THE SECTOR MAP CARD, SECOND PASS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function mapContractsDraw(cd,rows){
  var c=cd.col, z=cd.z, u=cd.u, q=Math.round(16*u), th=Math.round(48*u), r=Math.max(2,Math.round(4*z)), lw=Math.max(1,Math.round(z)), n=rows.length, nd=0, i, row, ry, pitch, two,
      y0, avail, nat=Math.round(68*u), mid, mid2, wRew, wCnt, maxW, barW, bh=Math.max(3,Math.round(6*z)), txt, cnt, cc,
      nameFont=FSz('600 15.4px '+HUDF,z), cntFont=FSz(TYPE.label,z);
  for(i=0;i<n;i++) if(rows[i].done) nd++;
  ctx.save();
  try{
    mapRR(c.x+lw/2,c.y+lw/2,c.w-lw,c.h-lw,r); ctx.fillStyle=UIC.ui_raised; ctx.fill(); ctx.lineWidth=lw; ctx.strokeStyle=UIC.ui_line; ctx.stroke();
    ctx.textBaseline='middle'; ctx.textAlign='left';
    ctx.font=nameFont; ctx.fillStyle=UIC.tx_1; ctx.fillText('contracts',c.x+q,c.y+th/2);
    ctx.font=cntFont; ctx.fillStyle=UIC.tx_2; ctx.textAlign='right'; ctx.fillText(nd+' of '+n+' done',c.x+c.w-q,c.y+th/2); ctx.textAlign='left';
    ctx.strokeStyle=UIC.ui_line; ctx.lineWidth=lw; ctx.beginPath(); ctx.moveTo(c.x+lw,c.y+th); ctx.lineTo(c.x+c.w-lw,c.y+th); ctx.stroke();
    y0=c.y+th; avail=c.h-th-Math.round(8*u); pitch=Math.min(nat,Math.floor(avail/n)); two=(pitch>=Math.round(58*u));
    for(i=0;i<n;i++){
      row=rows[i]; ry=y0+i*pitch;
      cnt=row.done?'done':(row.rule?row.rule:(row.p+'/'+row.n));
      cc=row.done?UIC.ok:((row.rule==='broken')?UIC.danger:((row.rule==='ready')?UIC.ok:UIC.tx_2));
      txt=row.pay?('$'+row.pay.toLocaleString()):'';
      ctx.font=nameFont; wRew=txt?hudRawW(txt):0;
      ctx.font=cntFont; wCnt=hudRawW(cnt);
      mid=two?(ry+pitch*0.32):(ry+pitch*0.40); mid2=ry+pitch*0.72;
      maxW=c.w-2*q-(wRew?(wRew+q):0)-(two?0:(wCnt+q));
      ctx.font=nameFont; ctx.fillStyle=row.done?UIC.tx_2:UIC.tx_1; ctx.textAlign='left'; ctx.fillText(mapFit(row.name,maxW),c.x+q,mid);
      if(txt){ ctx.textAlign='right'; ctx.fillText(txt,c.x+c.w-q,mid); ctx.textAlign='left'; }
      if(two){
        if(row.rule){ ctx.font=cntFont; ctx.fillStyle=cc; ctx.fillText(cnt,c.x+q,mid2); }
        else {
          barW=c.w-2*q-wCnt-Math.round(12*u);
          ctx.fillStyle=UIC.ui_line; ctx.fillRect(c.x+q,mid2-bh/2,barW,bh);
          ctx.fillStyle=row.done?UIC.ok:UIC.acc; ctx.fillRect(c.x+q,mid2-bh/2,barW*(row.p/row.n),bh);
          ctx.font=cntFont; ctx.fillStyle=cc; ctx.textAlign='right'; ctx.fillText(cnt,c.x+c.w-q,mid2); ctx.textAlign='left';
        }
      } else {
        ctx.font=cntFont; ctx.fillStyle=cc; ctx.textAlign='right'; ctx.fillText(cnt,c.x+c.w-q-(wRew?(wRew+q):0),mid); ctx.textAlign='left';
        if(!row.rule){
          barW=c.w-2*q; ctx.fillStyle=UIC.ui_line; ctx.fillRect(c.x+q,ry+pitch-bh-Math.round(2*z),barW,bh);
          ctx.fillStyle=row.done?UIC.ok:UIC.acc; ctx.fillRect(c.x+q,ry+pitch-bh-Math.round(2*z),barW*(row.p/row.n),bh);
        }
      }
      if(i<n-1&&two){ ctx.strokeStyle=UIC.ui_line; ctx.lineWidth=lw; ctx.beginPath(); ctx.moveTo(c.x+q,ry+pitch); ctx.lineTo(c.x+c.w-q,ry+pitch); ctx.stroke(); }
    }
  } finally { ctx.restore(); }
}

'@ @'
function mapContractsDraw(cd,rows){
  var c=cd.col, z=cd.z, u=cd.u, q=Math.round(20*u), th=Math.round(52*u), r=Math.max(2,Math.round(4*z)), lw=Math.max(1,Math.round(z)), n=rows.length, nd=0, i, row, ry, pitch, two,
      y0, avail, nat=Math.round(76*u), mid, mid2, wRew, wCnt, maxW, barW, bh=Math.max(3,Math.round(4*z)), txt, cnt, cc, ch,
      nameFont=FSz('600 15.4px '+HUDF,z), cntFont=FSz(TYPE.label,z), rewFont=FSz('600 12px '+HUDF,z);
  for(i=0;i<n;i++) if(rows[i].done) nd++;
  y0=c.y+th; avail=c.h-th-Math.round(8*u); pitch=Math.min(nat,Math.floor(avail/n)); two=(pitch>=Math.round(58*u));
  ch=Math.min(c.h,th+n*pitch+Math.round(8*u));
  ctx.save();
  try{
    mapRR(c.x+lw/2,c.y+lw/2,c.w-lw,ch-lw,r); ctx.fillStyle=UIC.ui_raised; ctx.fill(); ctx.lineWidth=lw; ctx.strokeStyle=UIC.ui_line; ctx.stroke();
    ctx.textBaseline='middle'; ctx.textAlign='left';
    ctx.font=nameFont; ctx.fillStyle=UIC.tx_1; ctx.fillText('contracts',c.x+q,c.y+th/2);
    ctx.font=cntFont; ctx.fillStyle=UIC.tx_2; ctx.textAlign='right'; ctx.fillText(nd+' of '+n+' done',c.x+c.w-q,c.y+th/2); ctx.textAlign='left';
    ctx.strokeStyle=UIC.ui_line; ctx.lineWidth=lw; ctx.beginPath(); ctx.moveTo(c.x+lw,c.y+th); ctx.lineTo(c.x+c.w-lw,c.y+th); ctx.stroke();
    for(i=0;i<n;i++){
      row=rows[i]; ry=y0+i*pitch;
      cnt=row.done?'done':(row.rule?row.rule:(row.p+'/'+row.n));
      cc=row.done?UIC.ok:((row.rule==='broken')?UIC.danger:((row.rule==='ready')?UIC.ok:UIC.tx_2));
      txt=row.pay?('$'+row.pay.toLocaleString()):'';
      ctx.font=rewFont; wRew=txt?hudRawW(txt):0;
      ctx.font=cntFont; wCnt=hudRawW(cnt);
      mid=two?(ry+pitch*0.34):(ry+pitch*0.40); mid2=ry+pitch*0.74;
      maxW=c.w-2*q-(wRew?(wRew+q):0)-(two?0:(wCnt+q));
      ctx.font=nameFont; ctx.fillStyle=UIC.tx_1; ctx.textAlign='left'; ctx.fillText(mapFit(row.name,maxW),c.x+q,mid);
      if(txt){ ctx.font=rewFont; ctx.fillStyle=UIC.tx_2; ctx.textAlign='right'; ctx.fillText(txt,c.x+c.w-q,mid); ctx.textAlign='left'; }
      if(two){
        if(row.rule){ ctx.font=cntFont; ctx.fillStyle=cc; ctx.fillText(cnt,c.x+q,mid2); }
        else {
          barW=c.w-2*q-wCnt-Math.round(12*u);
          ctx.fillStyle=UIC.ui_line_hi; ctx.fillRect(c.x+q,mid2-bh/2,barW,bh);
          ctx.fillStyle=row.done?UIC.ok:UIC.acc; ctx.fillRect(c.x+q,mid2-bh/2,barW*(row.p/row.n),bh);
          ctx.font=cntFont; ctx.fillStyle=cc; ctx.textAlign='right'; ctx.fillText(cnt,c.x+c.w-q,mid2); ctx.textAlign='left';
        }
      } else {
        ctx.font=cntFont; ctx.fillStyle=cc; ctx.textAlign='right'; ctx.fillText(cnt,c.x+c.w-q-(wRew?(wRew+q):0),mid); ctx.textAlign='left';
        if(!row.rule){
          barW=c.w-2*q; ctx.fillStyle=UIC.ui_line_hi; ctx.fillRect(c.x+q,ry+pitch-bh-Math.round(2*z),barW,bh);
          ctx.fillStyle=row.done?UIC.ok:UIC.acc; ctx.fillRect(c.x+q,ry+pitch-bh-Math.round(2*z),barW*(row.p/row.n),bh);
        }
      }
      if(i<n-1&&two){ ctx.strokeStyle=UIC.ui_line; ctx.lineWidth=lw; ctx.beginPath(); ctx.moveTo(c.x+q,ry+pitch); ctx.lineTo(c.x+c.w-q,ry+pitch); ctx.stroke(); }
    }
  } finally { ctx.restore(); }
}
'@

SubRx @'
    wxs=(isDay()?tod().name:'night')+'  '+g.wx.name+(g.wxNext?('  \u2192 '+g.wxNext.name+'  '+Math.round(g.wxT*100)+'%'):'');
'@ @'
    wxs=(isDay()?tod().name:'night')+' \u00b7 '+g.wx.name+(g.wxNext?(' \u2192 '+g.wxNext.name+' '+Math.round(g.wxT*100)+'%'):'');   // v31.xx (cw-mapstyle2): one separator between the hour and the weather, no double spaces
'@

SubRx @'
    if(f!==null&&isFinite(f)) ctx.fillText('SURVEYED  '+Math.round(f*100)+'%',x1,fyc);
'@ @'
    if(f!==null&&isFinite(f)) ctx.fillText('SURVEYED  '+Math.round(f*100)+'%',x1,fyc);
    if(!g.mapFirst){   // v31.xx (cw-mapstyle2): the close hint, the key of this device and the word, at the right of the footer (the opening map has the start button there)
      ctx.save();
      try{
        ctx.translate(cd.x+cd.w-p,fyc); ctx.scale(z,z);
        ctx.font=FS(TYPE.label); ctx.textBaseline='alphabetic'; ctx.textAlign='right';
        var _cfp=parseFloat(((/([\d.]+)px/).exec(ctx.font)||[0,16])[1])||16, _ca=Math.round(_cfp*0.7), _ck=padOn()?String(padB('B')):String(keyLabel('KeyM','M')), _ckw=Math.max(_ca+LH(7),hudRawW(_ck)+LH(12)), _ctw=hudRawW('close'), _cby=Math.round(_ca/2);
        ctx.fillStyle=UIC.tx_2; ctx.fillText('close',0,_cby);
        ctx.textAlign='left'; hudKey(_ck,-_ctw-LH(10)-_ckw,_cby,_ca,_ckw);
      } finally { ctx.restore(); }
    }
'@

SubRx @'
  MAPBOX={l:ox,t:oy,r:ox+WORLD_W*sc,b:oy+WORLD_H*sc}; _mapHalo=5*_MZ;
'@ @'
  MAPBOX={l:ox+10*_MZ,t:oy+10*_MZ,r:ox+WORLD_W*sc-10*_MZ,b:oy+WORLD_H*sc-10*_MZ}; _mapHalo=5*_MZ;   // v31.xx (cw-mapstyle2): a moved label keeps 10 px off the frame (extract b touched it)
'@

SubRx @'
    if(ic) for(var h2=0;h2<MAPICONS.length;h2++){ var b2=MAPICONS[h2]; if(a.l<b2.r+1&&b2.l<a.r+1&&a.t<b2.b+1&&b2.t<a.b+1) return true; }
'@ @'
    if(ic) for(var h2=0;h2<MAPICONS.length;h2++){ var b2=MAPICONS[h2]; if(a.l<b2.r+5&&b2.l<a.r+5&&a.t<b2.b+5&&b2.t<a.b+5) return true; }
'@

SubRx @'
    ctx.font=FS(TYPE.head);
    ctx.fillStyle='rgba(239,233,220,.74)';
'@ @'
    ctx.font=FS('600 13.5px '+HUDF);   // v31.xx (cw-mapstyle2): zone names a size under the extraction names and not bold, so the map has a hierarchy (the critic: flat, everything one weight)
    ctx.fillStyle='rgba(239,233,220,.66)';
'@

SubRx @'
  ctx.fillStyle=UIC.ui_line_hi;   // v31.xx (cw-mapstyle): the walls are a quiet neutral, the marks and the names are what the eye finds
'@ @'
  ctx.fillStyle='#3b4247';   // v31.xx (cw-mapstyle2): the walls a step darker, between the style guide's two line colours, so the perimeter is not a second frame inside the card
'@

SubRx @'
    ctx.fillStyle='rgba(63,157,233,.30)';
'@ @'
    ctx.fillStyle='rgba(63,157,233,.16)';
'@

SubRx @'
    ctx.strokeStyle='rgba(229,72,47,.90)'; ctx.lineWidth=2*_MZ;
'@ @'
    ctx.strokeStyle='rgba(229,72,47,.75)'; ctx.lineWidth=2*_MZ;
'@

SubRx @'
    ctx.fillStyle='rgba(229,72,47,.12)';
'@ @'
    ctx.fillStyle='rgba(229,72,47,.08)';
'@

SubRx @'
    ctx.beginPath(); ctx.arc(qx,qy,(9+2*qp)*_MZ,0,6.2832); ctx.stroke();
'@ @'
    ctx.beginPath(); ctx.arc(qx,qy,(6.5+1.5*qp)*_MZ,0,6.2832); ctx.stroke();   // v31.xx (cw-mapstyle2): a cache ring a size smaller, so a stack of them is not a pile
'@

SubRx @'
    ctx.beginPath(); ctx.arc(qx,qy,3.5*_MZ,0,6.2832); ctx.fill();
'@ @'
    ctx.beginPath(); ctx.arc(qx,qy,2.6*_MZ,0,6.2832); ctx.fill();
'@

SubRx @'
    ctx.beginPath(); ctx.arc(rmx,rmy,8*_MZ,0,6.2832); ctx.stroke();
'@ @'
    ctx.beginPath(); ctx.arc(rmx,rmy,6*_MZ,0,6.2832); ctx.stroke();
'@

SubRx @'
    ctx.beginPath(); ctx.arc(rmx,rmy,3.4*_MZ,0,6.2832); ctx.fill();
'@ @'
    ctx.beginPath(); ctx.arc(rmx,rmy,2.6*_MZ,0,6.2832); ctx.fill();
'@

SubRx @'
var VER='31.47';
'@ @'
var VER='31.48';
'@

$pat = "(?m)^  now:'v31\.47:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.48: The sector map is calmer: quieter zone names, labels clear of the frame, an even contracts list and a close hint. Check 31.48 fails on v31.47',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
