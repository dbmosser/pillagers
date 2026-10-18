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

# THE SECTOR MAP, THIRD PASS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  function hits(a,ic){ for(var h=0;h<placed.length;h++){ var b=placed[h]; if(a.l<b.r+2&&b.l<a.r+2&&a.t<b.b+1&&b.t<a.b+1) return true; }
'@ @'
  function hits(a,ic,own){ var _ax=Math.max(2,(a.b-a.t)*0.3); for(var h=0;h<placed.length;h++){ var b=placed[h]; if(a.l<b.r+_ax&&b.l<a.r+_ax&&a.t<b.b+1&&b.t<a.b+1) return true; }   /* v31.xx (cw-mapstyle3): a tag keeps a third of its height of air from a tag beside it (blast freezer, locked touched strongbox) */
'@

SubRx @'
if(ic) for(var h2=0;h2<MAPICONS.length;h2++){ var b2=MAPICONS[h2];
'@ @'
if(ic) for(var h2=0;h2<MAPICONS.length;h2++){ if(own&&own.indexOf(h2)>=0) continue; var b2=MAPICONS[h2];
'@

SubRx @'
if(!hits(r,_pass===0)){ ok=true;
'@ @'
if(!hits(r,_pass===0,dy<=0?g.own:null)){ ok=true;
'@

SubRx @'
g.r=u; });
'@ @'
g.r=u; });
  /* v31.xx (cw-mapstyle3): the mark a tag is anchored to (the tag sits just above it) is no obstacle for that tag, so the tag keeps its place at the mark and is not pushed off it (the critic: labels float away from their icons) */
  var _mz=(typeof hudRes==='function')?hudRes():1;
  G2.forEach(function(g){ var L0=g.items[0], sx=L0.x*L0.m.a+L0.m.e, sy=L0.y*L0.m.d+L0.m.f, q, I; g.own=[]; for(q=0;q<MAPICONS.length;q++){ I=MAPICONS[q]; if(sx>=I.l&&sx<=I.r&&sy>=I.t-30*_mz&&sy<=(I.t+I.b)/2) g.own.push(q); } });
'@

SubRx @'
    ctx.fillStyle='rgba(229,72,47,.78)';
    ctx.fillText('richer, and busier',hx,hy-hr-5+Math.max(12,_hgf*1.15));
'@ @'
    // v31.xx (cw-mapstyle3): the second line (richer, and busier) is gone, an explaining line (his Q8, logged in changes.md): the ring, the warning mark and the name already say it, and it printed across the ring edge
'@

SubRx @'
    ctx.font=FS('600 13.5px '+HUDF);   // v31.xx (cw-mapstyle2): zone names a size under the extraction names and not bold, so the map has a hierarchy (the critic: flat, everything one weight)
'@ @'
    ctx.font=FS(TYPE.label);   // v31.xx (cw-mapstyle3): zone names at the label size, under the extraction names (the critic: still too loud against the marks)
'@

SubRx @'
  ctx.fillStyle='#3b4247';   // v31.xx (cw-mapstyle2): the walls a step darker, between the style guide's two line colours, so the perimeter is not a second frame inside the card
'@ @'
  ctx.fillStyle='#30363a';   // v31.xx (cw-mapstyle3): the walls another step darker so the tags and zone names stand out from them
'@

SubRx @'
    ttl=nm||'SECTOR MAP'; ctx.fillText(ttl,x0,hy); hx=x0+hudRawW(ttl)+Math.round(16*u);
'@ @'
    ttl=nm||'SECTOR MAP'; var _tfp=parseFloat(((/([\d.]+)px/).exec(ctx.font)||[0,24])[1])||24, _tby=Math.round(hy+_tfp*0.34); ctx.textBaseline='alphabetic'; ctx.fillText(ttl,x0,_tby); hx=x0+hudRawW(ttl)+Math.round(16*u);   // v31.xx (cw-mapstyle3): the sector name and the muted words sit on one baseline
'@

SubRx @'
    if(nm){ ctx.font=FSz('500 15.4px '+HUDF,z); ctx.fillStyle=UIC.tx_2; ctx.fillText('SECTOR MAP',hx,hy); hx+=hudRawW('SECTOR MAP')+Math.round(24*u); }
'@ @'
    if(nm){ ctx.font=FSz('500 15.4px '+HUDF,z); ctx.fillStyle=UIC.tx_2; ctx.fillText('SECTOR MAP',hx,_tby); hx+=hudRawW('SECTOR MAP')+Math.round(24*u); }  ctx.textBaseline='middle';
'@

SubRx @'
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
'@ @'
function mapContractsDraw(cd,rows){
  var c=cd.col, z=cd.z, u=cd.u, q=Math.round(20*u), th=Math.round(52*u), r=Math.max(2,Math.round(4*z)), lw=Math.max(1,Math.round(z)), n=rows.length, nd=0, i, row, ry, pitch, two,
      y0, avail, nat=Math.round(76*u), mid, mid2, wRew, wCnt, maxW, barW, bh=Math.max(3,Math.round(4*z)), txt, cnt, cc, ch, fr, fcol,
      nameFont=FSz('600 15.4px '+HUDF,z), cntFont=FSz(TYPE.label,z), rewFont=FSz('600 12px '+HUDF,z);
  for(i=0;i<n;i++) if(rows[i].done) nd++;
  y0=c.y+th; avail=c.h-th-Math.round(8*u); pitch=Math.min(nat,Math.floor(avail/n));
  ch=Math.min(c.h,th+n*pitch+Math.round(8*u));
  if(th+n*nat+Math.round(8*u)>=0.7*c.h){ pitch=Math.floor(avail/n); ch=c.h; }   // v31.xx (cw-mapstyle3): a list that fills the column runs to the bottom of the map frame (the panel ended 6 px short of it)
  two=(pitch>=Math.round(58*u));
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
      fr=row.rule?((row.rule==='holding'||row.rule==='open')?0:1):(row.p/row.n);   // a rule contract has the same bar: empty while it holds, full when it is ready or broken
      fcol=(row.done||row.rule==='ready')?UIC.ok:((row.rule==='broken')?UIC.danger:UIC.acc);
      txt=row.pay?('$'+row.pay.toLocaleString()):'';
      ctx.font=rewFont; wRew=txt?hudRawW(txt):0;
      ctx.font=cntFont; wCnt=hudRawW(cnt);
      mid=two?(ry+pitch*0.34):(ry+pitch*0.40); mid2=ry+pitch*0.74;
      maxW=c.w-2*q-(wRew?(wRew+q):0)-(two?0:(wCnt+q));
      ctx.font=nameFont; ctx.fillStyle=UIC.tx_1; ctx.textAlign='left'; ctx.fillText(mapFit(row.name,maxW),c.x+q,mid);
      if(txt){ ctx.font=rewFont; ctx.fillStyle=UIC.tx_2; ctx.textAlign='right'; ctx.fillText(txt,c.x+c.w-q,mid); ctx.textAlign='left'; }
      if(two){
        barW=c.w-2*q-wCnt-Math.round(12*u);
        ctx.fillStyle=UIC.ui_line_hi; ctx.fillRect(c.x+q,mid2-bh/2,barW,bh);
        if(fr>0){ ctx.fillStyle=fcol; ctx.fillRect(c.x+q,mid2-bh/2,barW*fr,bh); }
        ctx.font=cntFont; ctx.fillStyle=cc; ctx.textAlign='right'; ctx.fillText(cnt,c.x+c.w-q,mid2); ctx.textAlign='left';
      } else {
        ctx.font=cntFont; ctx.fillStyle=cc; ctx.textAlign='right'; ctx.fillText(cnt,c.x+c.w-q-(wRew?(wRew+q):0),mid); ctx.textAlign='left';
        barW=c.w-2*q; ctx.fillStyle=UIC.ui_line_hi; ctx.fillRect(c.x+q,ry+pitch-bh-Math.round(2*z),barW,bh);
        if(fr>0){ ctx.fillStyle=fcol; ctx.fillRect(c.x+q,ry+pitch-bh-Math.round(2*z),barW*fr,bh); }
      }
      if(i<n-1&&two){ ctx.strokeStyle=UIC.ui_line; ctx.lineWidth=lw; ctx.beginPath(); ctx.moveTo(c.x+q,ry+pitch); ctx.lineTo(c.x+c.w-q,ry+pitch); ctx.stroke(); }
    }
  } finally { ctx.restore(); }
}

'@

SubRx @'
var VER='31.54';
'@ @'
var VER='31.55';
'@

$pat = "(?m)^  now:'v31\.54:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.55: The sector map tags sit at their marks, every contract has a bar, the contracts list runs to the bottom of the map, and the hot ground says only its name. Check 31.55 fails on v31.54',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
