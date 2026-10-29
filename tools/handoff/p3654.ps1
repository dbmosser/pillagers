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

# CACHES OFF THE MAP (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  // Meridian caches are marked, because a guaranteed jackpot you never find is the
  // same as no jackpot. Marked whether or not you have been there, so the route
  // choice is available from the first second of the raid: the near one is on
  // your way out, the far ones are a decision.
  for(i=0;i<G.containers.length;i++){
    var CQ=G.containers[i];
    if(!CQ.cache||(mapFirstOn()&&CQ.strong)) continue;   // v28.xx (cw-cx-mapstart-clear): the strongbox keeps its dedicated icon, without a second cache ring.
    var qx=ox+CQ.x*sc, qy=oy+CQ.y*sc;
    var qp=.6+.4*Math.sin(G.t*2.6+i);
    ctx.globalAlpha=CQ.opened?.35:1;
    ctx.strokeStyle=UIC.tx_1; ctx.lineWidth=2*_MZ;
    ctx.beginPath(); ctx.arc(qx,qy,(mapFirstOn()?4:(6.5+1.5*qp))*_MZ,0,6.2832); ctx.stroke();   // v28.xx (cw-cx-mapstart-clear): 4px cache rings keep every location visible in packed rooms.
    ctx.fillStyle=UIC.tx_1;
    ctx.beginPath(); ctx.arc(qx,qy,(mapFirstOn()?1.6:2.6)*_MZ,0,6.2832); ctx.fill();
    mapIcon(qx,qy,(mapFirstOn()?7:13)*_MZ);
    // v28.xx (cw-nocachelbl), HIS ORDER (2026-10-20): "map on this second preraid screen should not have caches labelled, makes the whole thing look messy". The raid start map keeps the cache ring and icon but no word; the m key map keeps its words.
    if(!mapFirstOn()) mapLabel(CQ.opened?'LOOTED':'CACHE',qx,qy-20*_MZ,UIC.tx_1,null,qy);   // v28.xx (cw-cx-sectorhold-o03): one label per cache, including the two inside a locked room.
    ctx.globalAlpha=1;
  }
  // Encampments in red:
'@ @'
  // v28.xx (cw-cx-mapnocaches), his order 2026-10-29: "quit showing caches on the map, even if player burns a data slot. It makes the map super messy."
  // v28.xx (cw-cx-mapnocaches): cache loot stays in the world; only the Stray reward ring and the named strongbox have map marks.
  // Encampments in red:
'@

SubRx @'
  // A cache the Stray told you about. This is his whole payment, so it is drawn
  // large and named: without it, being decent to him buys nothing you can see.
  for(i=0;i<G.containers.length;i++){
    var rc=G.containers[i];
    if(!rc.revealed||rc.opened||(mapFirstOn()&&rc.cache)) continue;   // v28.xx (cw-cx-mapstart-clear): a revealed cache already has its small icon.
    var rmx=ox+rc.x*sc,rmy=oy+rc.y*sc; mapIcon(rmx,rmy,10*_MZ);   // v21.41 (W-D4): at the map zoom
    ctx.strokeStyle=UIC.tx_1; ctx.lineWidth=1.6*_MZ;
    ctx.beginPath(); ctx.arc(rmx,rmy,6*_MZ,0,6.2832); ctx.stroke();
    ctx.fillStyle=UIC.tx_1;
    ctx.beginPath(); ctx.arc(rmx,rmy,2.6*_MZ,0,6.2832); ctx.fill();
    ctx.textAlign='center'; ctx.font=FS(TYPE.micro);
    if(!mapFirstOn()) ctx.fillText('CACHE',rmx,rmy-12*_MZ); ctx.textAlign='left';   // v28.xx (cw-cx-mapstart-clear): revealed caches obey the same no-words rule.
  }
  // The survivor, but only once
'@ @'
  // v28.xx (cw-cx-mapnocaches): the Stray reward keeps one plain ring, without a dot, icon or word, on both maps.
  for(i=0;i<G.containers.length;i++){
    var rc=G.containers[i];
    if(!rc.revealed||rc.opened||rc.strong) continue;
    var rmx=ox+rc.x*sc,rmy=oy+rc.y*sc;
    ctx.strokeStyle=UIC.tx_1; ctx.lineWidth=1.6*_MZ;
    ctx.beginPath(); ctx.arc(rmx,rmy,6*_MZ,0,6.2832); ctx.stroke();
  }
  // The survivor, but only once
'@

SubRx @'
function flowMm(at,R,sc){
  var M=flowMarks(), i, m, s, rad;
'@ @'
// v28.xx (cw-cx-mapnocaches): cleared strongholds also advertise their cache through event loot marks; hide those on both maps only.
function mapFlowMarks(){
  return flowMarks().filter(function(m){
    return m.kind!=='loot'||!(G.containers||[]).some(function(c){ return c.cache&&!c.strong&&c.x===m.x&&c.y===m.y; });
  });
}
function flowMm(at,R,sc){
  var M=mapFlowMarks(), i, m, s, rad;
'@

SubRx @'
function flowMap(c,ox,oy,sc,MZ,FSf){
  var M=flowMarks(), i, m, x, y, rad;
'@ @'
function flowMap(c,ox,oy,sc,MZ,FSf){
  var M=mapFlowMarks(), i, m, x, y, rad;
'@

SubRx @'
var VER='36.53';
'@ @'
var VER='36.54';
'@

$pat = "(?m)^  now:'v36\.53:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.54: Both maps hide cache marks and words with or without intel. The Stray reward keeps one plain ring. Strongbox, locked rooms and other objectives stay. LOCAL: no linked review. Retargets: cw-nocachelbl 33.42, cw-cx-sectorhold-o03 32.27, cw-cx-mapstart-clear 33.54, cw-cx-mapquiet-o03 32.33 and cw-cx-mapspace-o03 32.30 accept old cache marks or the new hidden caches while preserving their other checks. Check 36.54 fails on v36.53',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
