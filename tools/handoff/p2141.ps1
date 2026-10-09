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

# THE MAP MARKERS GROW AT 4K (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    ctx.moveTo(cqx,cqy-9); ctx.lineTo(cqx+9,cqy); ctx.lineTo(cqx,cqy+9); ctx.lineTo(cqx-9,cqy); ctx.closePath();
'@ @'
    // v21.41, from the 4K visual pass of 2026-10-09 (W-D4): THE MAP MARKERS GROW WITH THE SCREEN. The words on the sector map, the
    // cache rings and his own marker have grown with the screen since v19.63, v19.65 and v10.92, but this diamond, the keyhole, the
    // intel key and elite dots, the seal, the strongbox, a revealed cache, the survivor, the Peddler, the dot in an open ring and the
    // waypoint kept their 1080p size in pixels. At 4K the Peddler was a speck under a big PEDDLER and the encampment a small diamond
    // under a big ENCAMPMENT. They, and the gaps to their names, grow by the map zoom (_MZ) now. At 1080p _MZ is 1 and nothing moves.
    ctx.moveTo(cqx,cqy-9*_MZ); ctx.lineTo(cqx+9*_MZ,cqy); ctx.lineTo(cqx,cqy+9*_MZ); ctx.lineTo(cqx-9*_MZ,cqy); ctx.closePath();
'@

SubRx @'
    var kcx=lqx+lqw/2,kcy=lqy+lqh/2-3;
    ctx.fillStyle=LKM.open?'rgba(127,196,160,.9)':'#ffc04a';
    ctx.beginPath(); ctx.arc(kcx,kcy,3.2*_MZ,0,6.2832); ctx.fill();
    ctx.beginPath(); ctx.moveTo(kcx-2.2,kcy+7.5); ctx.lineTo(kcx+2.2,kcy+7.5); ctx.lineTo(kcx,kcy+1); ctx.closePath(); ctx.fill();
'@ @'
    var kcx=lqx+lqw/2,kcy=lqy+lqh/2-3*_MZ;   // v21.41 (W-D4): the keyhole at the map zoom
    ctx.fillStyle=LKM.open?'rgba(127,196,160,.9)':'#ffc04a';
    ctx.beginPath(); ctx.arc(kcx,kcy,3.2*_MZ,0,6.2832); ctx.fill();
    ctx.beginPath(); ctx.moveTo(kcx-2.2*_MZ,kcy+7.5*_MZ); ctx.lineTo(kcx+2.2*_MZ,kcy+7.5*_MZ); ctx.lineTo(kcx,kcy+_MZ); ctx.closePath(); ctx.fill();
'@

SubRx @'
      ctx.beginPath(); ctx.arc(ikx,iky-3,2.6,0,6.2832); ctx.fill();
      ctx.fillRect(ikx-1,iky-2,2,6);
'@ @'
      ctx.beginPath(); ctx.arc(ikx,iky-3*_MZ,2.6*_MZ,0,6.2832); ctx.fill();   // v21.41 (W-D4): the intel key at the map zoom
      ctx.fillRect(ikx-_MZ,iky-2*_MZ,2*_MZ,6*_MZ);
'@

SubRx @'
ctx.arc(ox+IEE.x*sc,oy+IEE.y*sc,3.4,0,6.2832); ctx.fill();
'@ @'
ctx.arc(ox+IEE.x*sc,oy+IEE.y*sc,3.4*_MZ,0,6.2832); ctx.fill();   // v21.41 (W-D4): at the map zoom
'@

SubRx @'
    var slx=ox+G.seal.x*sc,sly=oy+G.seal.y*sc;
    var SRm=sealHere(),needM=sealNeed(SRm.tier);
    var pctM=clamp((SRm.cut+G.seal.gained)/needM,0,1);
    ctx.strokeStyle=G.seal.done?'#ffc04a':'#8fd0ff'; ctx.lineWidth=2;
    ctx.beginPath(); ctx.arc(slx,sly,12,0,6.2832); ctx.stroke();
    ctx.strokeStyle=G.seal.done?'#ffc04a':'#4de3d0'; ctx.lineWidth=3;
    ctx.beginPath(); ctx.arc(slx,sly,12,-1.5708,-1.5708+6.2832*pctM); ctx.stroke();
    ctx.textAlign='center'; ctx.font=FS(TYPE.micro);
    ctx.fillStyle=G.seal.done?'#ffc04a':'#8fd0ff';
    ctx.fillText(G.seal.done?'SEAL BROKEN':('SEAL '+Math.round(pctM*100)+'%'),slx,sly-16);
'@ @'
    var slx=ox+G.seal.x*sc,sly=oy+G.seal.y*sc;   // v21.41 (W-D4): the seal ring at the map zoom
    var SRm=sealHere(),needM=sealNeed(SRm.tier);
    var pctM=clamp((SRm.cut+G.seal.gained)/needM,0,1);
    ctx.strokeStyle=G.seal.done?'#ffc04a':'#8fd0ff'; ctx.lineWidth=2*_MZ;
    ctx.beginPath(); ctx.arc(slx,sly,12*_MZ,0,6.2832); ctx.stroke();
    ctx.strokeStyle=G.seal.done?'#ffc04a':'#4de3d0'; ctx.lineWidth=3*_MZ;
    ctx.beginPath(); ctx.arc(slx,sly,12*_MZ,-1.5708,-1.5708+6.2832*pctM); ctx.stroke();
    ctx.textAlign='center'; ctx.font=FS(TYPE.micro);
    ctx.fillStyle=G.seal.done?'#ffc04a':'#8fd0ff';
    ctx.fillText(G.seal.done?'SEAL BROKEN':('SEAL '+Math.round(pctM*100)+'%'),slx,sly-16*_MZ);
'@

SubRx @'
    var sbx=ox+sbm.x*sc,sby=oy+sbm.y*sc;
    ctx.strokeStyle='#ffc04a'; ctx.lineWidth=2;
    ctx.beginPath(); ctx.arc(sbx,sby,10,0,6.2832); ctx.stroke();
    ctx.beginPath(); ctx.moveTo(sbx-14,sby); ctx.lineTo(sbx-10,sby);
    ctx.moveTo(sbx+10,sby); ctx.lineTo(sbx+14,sby);
    ctx.moveTo(sbx,sby-14); ctx.lineTo(sbx,sby-10);
    ctx.moveTo(sbx,sby+10); ctx.lineTo(sbx,sby+14); ctx.stroke();
    ctx.fillStyle='#ffc04a';
    ctx.beginPath(); ctx.arc(sbx,sby,3.6,0,6.2832); ctx.fill();
    ctx.textAlign='center'; ctx.font=FS(TYPE.micro);
    ctx.fillText('STRONGBOX',sbx,sby-15); ctx.textAlign='left';
'@ @'
    var sbx=ox+sbm.x*sc,sby=oy+sbm.y*sc;   // v21.41 (W-D4): the strongbox mark at the map zoom
    ctx.strokeStyle='#ffc04a'; ctx.lineWidth=2*_MZ;
    ctx.beginPath(); ctx.arc(sbx,sby,10*_MZ,0,6.2832); ctx.stroke();
    ctx.beginPath(); ctx.moveTo(sbx-14*_MZ,sby); ctx.lineTo(sbx-10*_MZ,sby);
    ctx.moveTo(sbx+10*_MZ,sby); ctx.lineTo(sbx+14*_MZ,sby);
    ctx.moveTo(sbx,sby-14*_MZ); ctx.lineTo(sbx,sby-10*_MZ);
    ctx.moveTo(sbx,sby+10*_MZ); ctx.lineTo(sbx,sby+14*_MZ); ctx.stroke();
    ctx.fillStyle='#ffc04a';
    ctx.beginPath(); ctx.arc(sbx,sby,3.6*_MZ,0,6.2832); ctx.fill();
    ctx.textAlign='center'; ctx.font=FS(TYPE.micro);
    ctx.fillText('STRONGBOX',sbx,sby-15*_MZ); ctx.textAlign='left';
'@

SubRx @'
    var rmx=ox+rc.x*sc,rmy=oy+rc.y*sc;
    ctx.strokeStyle='#e6b4ff'; ctx.lineWidth=1.6;
    ctx.beginPath(); ctx.arc(rmx,rmy,8,0,6.2832); ctx.stroke();
    ctx.fillStyle='#e6b4ff';
    ctx.beginPath(); ctx.arc(rmx,rmy,3.4,0,6.2832); ctx.fill();
    ctx.textAlign='center'; ctx.font=FS(TYPE.micro);
    ctx.fillText('CACHE',rmx,rmy-12); ctx.textAlign='left';
'@ @'
    var rmx=ox+rc.x*sc,rmy=oy+rc.y*sc;   // v21.41 (W-D4): at the map zoom
    ctx.strokeStyle='#e6b4ff'; ctx.lineWidth=1.6*_MZ;
    ctx.beginPath(); ctx.arc(rmx,rmy,8*_MZ,0,6.2832); ctx.stroke();
    ctx.fillStyle='#e6b4ff';
    ctx.beginPath(); ctx.arc(rmx,rmy,3.4*_MZ,0,6.2832); ctx.fill();
    ctx.textAlign='center'; ctx.font=FS(TYPE.micro);
    ctx.fillText('CACHE',rmx,rmy-12*_MZ); ctx.textAlign='left';
'@

SubRx @'
    var smx=ox+sm.x*sc,smy=oy+sm.y*sc;
    ctx.fillStyle='#120e0c'; ctx.beginPath(); ctx.arc(smx,smy,6,0,6.2832); ctx.fill();
    ctx.fillStyle=sm.helped?'#5a9a6a':'#7fc4a0';
    ctx.beginPath(); ctx.arc(smx,smy,4,0,6.2832); ctx.fill();
    ctx.textAlign='center'; ctx.font=FS(TYPE.micro);
    ctx.fillText(sm.helped?'SURVIVOR':'SURVIVOR (NEEDS)',smx,smy-11); ctx.textAlign='left';
'@ @'
    var smx=ox+sm.x*sc,smy=oy+sm.y*sc;   // v21.41 (W-D4): at the map zoom
    ctx.fillStyle='#120e0c'; ctx.beginPath(); ctx.arc(smx,smy,6*_MZ,0,6.2832); ctx.fill();
    ctx.fillStyle=sm.helped?'#5a9a6a':'#7fc4a0';
    ctx.beginPath(); ctx.arc(smx,smy,4*_MZ,0,6.2832); ctx.fill();
    ctx.textAlign='center'; ctx.font=FS(TYPE.micro);
    ctx.fillText(sm.helped?'SURVIVOR':'SURVIVOR (NEEDS)',smx,smy-11*_MZ); ctx.textAlign='left';
'@

SubRx @'
    var pmx=ox+pdm.x*sc,pmy=oy+pdm.y*sc;
    ctx.fillStyle='#120e0c'; ctx.beginPath(); ctx.arc(pmx,pmy,6.4,0,6.2832); ctx.fill();
    ctx.fillStyle=pedOpen()?'#ffc04a':'#8a5a4a';
    ctx.beginPath(); ctx.arc(pmx,pmy,4.4,0,6.2832); ctx.fill();
    ctx.textAlign='center'; ctx.font=FS(TYPE.micro);
    ctx.fillStyle=pedOpen()?'#ffc04a':'#8a5a4a';
    ctx.fillText(pedOpen()?'PEDDLER':'PEDDLER (CLOSED)',pmx,pmy-11);
'@ @'
    var pmx=ox+pdm.x*sc,pmy=oy+pdm.y*sc;   // v21.41 (W-D4): at the map zoom
    ctx.fillStyle='#120e0c'; ctx.beginPath(); ctx.arc(pmx,pmy,6.4*_MZ,0,6.2832); ctx.fill();
    ctx.fillStyle=pedOpen()?'#ffc04a':'#8a5a4a';
    ctx.beginPath(); ctx.arc(pmx,pmy,4.4*_MZ,0,6.2832); ctx.fill();
    ctx.textAlign='center'; ctx.font=FS(TYPE.micro);
    ctx.fillStyle=pedOpen()?'#ffc04a':'#8a5a4a';
    ctx.fillText(pedOpen()?'PEDDLER':'PEDDLER (CLOSED)',pmx,pmy-11*_MZ);
'@

SubRx @'
if(act){ ctx.fillStyle='#4de3d0'; ctx.beginPath(); ctx.arc(ox+zz.x*sc,oy+zz.y*sc,3,0,6.2832); ctx.fill(); }
'@ @'
if(act){ ctx.fillStyle='#4de3d0'; ctx.beginPath(); ctx.arc(ox+zz.x*sc,oy+zz.y*sc,3*_MZ,0,6.2832); ctx.fill(); }   // v21.41 (W-D4): at the map zoom
'@

SubRx @'
    var wpx=ox+G.waypoint.x*sc, wpy=oy+G.waypoint.y*sc;
    ctx.strokeStyle='#ffc04a'; ctx.lineWidth=2;
    ctx.beginPath(); ctx.arc(wpx,wpy,7,0,6.2832); ctx.stroke();
    ctx.lineWidth=1;
    ctx.beginPath();
    ctx.moveTo(wpx-11,wpy); ctx.lineTo(wpx-3,wpy);
    ctx.moveTo(wpx+3,wpy);  ctx.lineTo(wpx+11,wpy);
    ctx.moveTo(wpx,wpy-11); ctx.lineTo(wpx,wpy-3);
    ctx.moveTo(wpx,wpy+3);  ctx.lineTo(wpx,wpy+11);
    ctx.stroke();
    ctx.font=FS(TYPE.micro); ctx.fillStyle='#ffc04a'; ctx.textAlign='center';
    ctx.fillText('WAYPOINT',wpx,wpy-14); ctx.textAlign='left';
'@ @'
    var wpx=ox+G.waypoint.x*sc, wpy=oy+G.waypoint.y*sc;   // v21.41 (W-D4): the waypoint at the map zoom
    ctx.strokeStyle='#ffc04a'; ctx.lineWidth=2*_MZ;
    ctx.beginPath(); ctx.arc(wpx,wpy,7*_MZ,0,6.2832); ctx.stroke();
    ctx.lineWidth=_MZ;
    ctx.beginPath();
    ctx.moveTo(wpx-11*_MZ,wpy); ctx.lineTo(wpx-3*_MZ,wpy);
    ctx.moveTo(wpx+3*_MZ,wpy);  ctx.lineTo(wpx+11*_MZ,wpy);
    ctx.moveTo(wpx,wpy-11*_MZ); ctx.lineTo(wpx,wpy-3*_MZ);
    ctx.moveTo(wpx,wpy+3*_MZ);  ctx.lineTo(wpx,wpy+11*_MZ);
    ctx.stroke();
    ctx.font=FS(TYPE.micro); ctx.fillStyle='#ffc04a'; ctx.textAlign='center';
    ctx.fillText('WAYPOINT',wpx,wpy-14*_MZ); ctx.textAlign='left';
'@

SubRx @'
var VER='21.40';
'@ @'
var VER='21.41';
'@

$pat = "(?m)^  now:'v21\.40:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.41: On a 4K screen the Peddler, encampment, strongbox, seal and waypoint marks on the map are full size. Check 21.41 fails on v21.40',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
