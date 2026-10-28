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

# ONE READABLE TARGET PING LABEL (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function netPingLabel(lbl,x,y,r){
'@ @'
// v28.xx (cw-cx-pingmerge): one name for a live pinged target; keep its health and crew marks. The peddler keeps the deal prompt.
function netPingForEntity(e){
  if(!e||e.hp<=0||e.kind==='peddler'||!G||G.ents.indexOf(e)<0)return null;
  var i,p,now=Date.now();
  for(i=(NET.pings||[]).length-1;i>=0;i--){
    p=NET.pings[i];
    if(!p.pl&&now-p.at<=NET_PING_T*1000&&(p.target===e||(p.id&&NET.entMap&&NET.entMap[p.id]===e)))return p;
  }
  return null;
}
function netPingLabel(lbl,x,y,r){
'@

SubRx @'
    wc.font=FS(TYPE.micro);
    var tw=wc.measureText(plate).width;
'@ @'
    // v28.xx (cw-cx-pingmerge): the HUD ping owns the target name while it is live; crew and health still draw here.
    var pingPlate=netPingForEntity(ne);
    wc.font=FS(TYPE.micro);
    var tw=wc.measureText(plate).width;
'@

SubRx @'
    wc.fillRect(ne.x-tw/2-4,ne.y-lift-ph2+3,tw+8,ph2);
'@ @'
    if(!pingPlate) wc.fillRect(ne.x-tw/2-4,ne.y-lift-ph2+3,tw+8,ph2); // v28.xx (cw-cx-pingmerge): no empty duplicate plate.
'@

SubRx @'
    wc.fillText(plate,ne.x-tw/2,ne.y-lift);   // v8.39: inside its plate, not off the right of it
'@ @'
    if(!pingPlate) wc.fillText(plate,ne.x-tw/2,ne.y-lift); // v28.xx (cw-cx-pingmerge): the ping plate carries this same name.
'@

SubRx @'
    lbl=nm+(p.w?('  \u00b7  '+p.w):(p.dg?'  \u00b7  DANGER':''))+'  \u00b7  '+((G&&G.player)?metres(dist(G.player,p)):0)+'m';   // v22.xx (R43): 120m   // v22.xx (R49): no colon labels; NAME, what, distance
'@ @'
    // v28.xx (cw-cx-pingmerge): retain the specific target identity and its running/friendly detail in the one readable plate.
    e=p.target||(p.id&&NET.entMap?NET.entMap[p.id]:null);
    var pingName=(e&&netPingForEntity(e)&&e.name)?e.name+(e.state==='extract'?' [running]':(e._plateTag||'')):p.w;
    lbl=nm+(pingName?('  \u00b7  '+pingName):(p.dg?'  \u00b7  DANGER':''))+'  \u00b7  '+((G&&G.player)?metres(dist(G.player,p)):0)+'m';
'@

SubRx @'
      colourCueGlyph(ctx,q.dg?'danger':q.pl?'loot':q.w?'target':'place',s.x,s.y,1.5*R,ctx.fillStyle);MMAP.ops+=3;   // v28.xx (cw-cx-pingread): 18px target shape and 21px dark backing at 1080p.
'@ @'
      colourCueGlyph(ctx,q.dg?'danger':q.pl?'loot':q.w?'target':'place',s.x,s.y,2*R,ctx.fillStyle);MMAP.ops+=3; // v28.xx (cw-cx-pingmerge): 24px target, 28px dark backing at 1080p.
'@

SubRx @'
    colourCueGlyph(ctx,p.dg?'danger':p.pl?'loot':p.w?'target':'place',px,py,1.5*Math.max(1,hudRes()),p.dg?'#ff4a3a':p.w?'#ff8a3c':'#6fe0ff'); // v28.xx (cw-cx-pingread): the same larger ping shape on the full map.
'@ @'
    colourCueGlyph(ctx,p.dg?'danger':p.pl?'loot':p.w?'target':'place',px,py,2*Math.max(1,hudRes()),p.dg?'#ff4a3a':p.w?'#ff8a3c':'#6fe0ff'); // v28.xx (cw-cx-pingmerge): match the minimap 24px ping and dark backing.
'@

SubRx @'
var VER='35.64';
'@ @'
var VER='35.65';
'@

$pat = "(?m)^  now:'v35\.64:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.65: Target pings use one readable name label and larger map markers. Check 35.65 fails on v35.64',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
