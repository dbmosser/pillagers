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

# MAP LOOT TAGS TAKE A BACK SEAT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(typeof markY==='number'){
    var saveTag=MAPTAG; MAPTAG={x:x,y:markY,m:ctx.getTransform()};
    ctx.font=font||hudFS(TYPE.label); ctx.textAlign='center'; ctx.fillStyle=mapLabelCol(col);
    try{ ctx.fillText(txt,x,y); }finally{ MAPTAG=saveTag; ctx.textAlign='left'; } return;
  }
'@ @'
  if(typeof markY==='number'){
    // v28.xx (cw-cx-mapquiet-o03): loot is secondary to exits and rooms, with the guide 16px floor and a lighter halo.
    var saveTag=MAPTAG, saveHalo=_mapHalo, zs=Math.max(1,hudRes()), tf=hudFS(TYPE.label).replace(/^600 /,'500 ');
    tf=tf.replace(/([\d.]+)px/,function(a,n){ return Math.max(16*zs,parseFloat(n)).toFixed(1)+'px'; });
    MAPTAG={x:x,y:markY,m:ctx.getTransform()}; _mapHalo=2*zs;
    ctx.font=tf; ctx.textAlign='center'; ctx.fillStyle=UIC.tx_2;
    try{ ctx.fillText(txt,x,y); }finally{ MAPTAG=saveTag; _mapHalo=saveHalo; ctx.textAlign='left'; } return;
  }
'@

SubRx @'
  function hits(a,ic,own){ var _ax=12*_mz, _ay=12*_mz; for(var h=0;h<placed.length;h++){ var b=placed[h]; if(a.l<b.r+_ax&&b.l<a.r+_ax&&a.t<b.b+_ay&&b.t<a.b+_ay) return true; }   /* v31.xx (cw-mapstyle3): a tag keeps a third of its height of air from a tag beside it (blast freezer, locked touched strongbox) */
'@ @'
  function hits(a,ic,own){ var _ax=16*_mz, _ay=16*_mz; for(var h=0;h<placed.length;h++){ var b=placed[h]; if(a.l<b.r+_ax&&b.l<a.r+_ax&&a.t<b.b+_ay&&b.t<a.b+_ay) return true; }   /* v31.xx (cw-mapstyle3): a tag keeps a third of its height of air from a tag beside it (blast freezer, locked touched strongbox) */
'@

SubRx @'
    if(ic) for(var h2=0;h2<MAPICONS.length;h2++){ if(own&&own.indexOf(h2)>=0) continue; var b2=MAPICONS[h2]; if(a.l<b2.r+5&&b2.l<a.r+5&&a.t<b2.b+5&&b2.t<a.b+5) return true; }   // v31.xx (cw-mapstyle): a label never sits on a mark
'@ @'
    if(ic) for(var h2=0;h2<MAPICONS.length;h2++){ if(own&&own.indexOf(h2)>=0) continue; var b2=MAPICONS[h2]; if(a.l<b2.r+12*_mz&&b2.l<a.r+12*_mz&&a.t<b2.b+12*_mz&&b2.t<a.b+12*_mz) return true; }   // v31.xx (cw-mapstyle): a label never sits on a mark
'@

SubRx @'
          leftX=px-20*_mz-g.r.r, rightX=px+20*_mz-g.r.l, pitch=gh+12*_mz, clusterL=px-15*_mz, clusterR=px+15*_mz,
'@ @'
          leftX=px-20*_mz-g.r.r, rightX=px+20*_mz-g.r.l, pitch=gh+16*_mz, clusterL=px-15*_mz, clusterR=px+15*_mz,
'@

SubRx @'
      var localX=[0,leftX,rightX,clusterLeft,clusterRight,_bL-g.r.l,_bW-g.r.r], localY=[0,sideY], xpad=12*_mz, ypad=12*_mz;
'@ @'
      var localX=[0,leftX,rightX,clusterLeft,clusterRight,_bL-g.r.l,_bW-g.r.r], localY=[0,sideY], xpad=16*_mz, ypad=16*_mz;
'@

SubRx @'
      var clusterLeft=clusterL-6*_mz-g.r.r, clusterRight=clusterR+6*_mz-g.r.l;
'@ @'
      var clusterLeft=clusterL-12*_mz-g.r.r, clusterRight=clusterR+12*_mz-g.r.l;
'@

SubRx @'
      clusterMarks.forEach(function(I){ localX.push(I.l-6*_mz-g.r.r,I.r+6*_mz-g.r.l); localY.push(I.t-6*_mz-g.r.b,I.b+6*_mz-g.r.t); });
'@ @'
      clusterMarks.forEach(function(I){ localX.push(I.l-12*_mz-g.r.r,I.r+12*_mz-g.r.l); localY.push(I.t-12*_mz-g.r.b,I.b+12*_mz-g.r.t); });
'@

SubRx @'
      var best=null, score=Infinity, step=gh+12*_mz;
'@ @'
      var best=null, score=Infinity, step=gh+16*_mz;
'@

SubRx @'
      if(len>cut+2){ ctx.save(); ctx.setTransform(1,0,0,1,0,0); ctx.strokeStyle=UIC.tx_2; ctx.lineWidth=Math.max(1,_mz); ctx.beginPath(); ctx.moveTo(ax+vx*cut/len,ay+vy*cut/len); ctx.lineTo(ex,ey); ctx.stroke(); ctx.restore(); }
'@ @'
      if(len>cut+20*_mz){ ctx.save(); ctx.setTransform(1,0,0,1,0,0); ctx.strokeStyle=UIC.tx_2; ctx.lineWidth=Math.max(1,_mz); ctx.beginPath(); ctx.moveTo(ax+vx*cut/len,ay+vy*cut/len); ctx.lineTo(ex,ey); ctx.stroke(); ctx.restore(); }   // v28.xx (cw-cx-mapquiet-o03): nearby tags need no tiny leader; longer leaders retain exact ownership.
'@

SubRx @'
      mid=two?(ry+pitch*0.34):(ry+pitch*0.40); mid2=ry+pitch*0.74;
'@ @'
      mid=two?(ry+pitch*0.30):(ry+pitch*0.40); mid2=ry+pitch*0.82;   // v28.xx (cw-cx-mapquiet-o03): status sits above a full-width track.
'@

SubRx @'
        barW=c.w-2*q-wCnt-Math.round(12*u);
'@ @'
        barW=c.w-2*q;   // v28.xx (cw-cx-mapquiet-o03): one right edge for reward, status and track.
'@

SubRx @'
        ctx.font=cntFont; ctx.fillStyle=cc; ctx.textAlign='right'; ctx.fillText(cnt,c.x+c.w-q,mid2); ctx.textAlign='left';
'@ @'
        ctx.font=cntFont; ctx.fillStyle=cc; ctx.textAlign='right'; ctx.fillText(cnt,c.x+c.w-q,ry+pitch*0.60); ctx.textAlign='left';
'@

SubRx @'
var VER='32.32';
'@ @'
var VER='32.33';
'@

$pat = "(?m)^  now:'v32\.32:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.33: Loot tags use medium muted type, wider spacing and shorter halos. Nearby tags lose tiny leaders. Contract bars reach the same edge as status and rewards. Check 32.33 fails on v32.32',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
