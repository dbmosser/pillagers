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

# SECTOR MAP POLISH (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function hits(a,ic,own){ var _ax=16*_mz, _ay=16*_mz;
'@ @'
var _rx=1;   /* v28.xx (cw-mappolish): air scale; an anchored tag that finds no strict spot beside its icon tries again with half the air before it is sent across the map (the strongbox word floated 70 px off at 4K) */ function hits(a,ic,own){ var _ax=16*_mz*_rx, _ay=16*_mz*(_rx<1?0.375:1);
'@

SubRx @'
if(a.l<b2.r+12*_mz&&b2.l<a.r+12*_mz&&a.t<b2.b+12*_mz&&b2.t<a.b+12*_mz) return true;
'@ @'
var _im=12*_mz*_rx; if(a.l<b2.r+_im&&b2.l<a.r+_im&&a.t<b2.b+_im&&b2.t<a.b+_im) return true;
'@

SubRx @'
_pass<(g.items[0].mark?1:2)&&!ok
'@ @'
_pass<2&&!ok
'@

SubRx @'
if(!hits(r,_pass===0,(!g.items[0].mark&&dy<=0)?g.own:null)){
'@ @'
_rx=(g.items[0].mark&&_pass===1)?0.5:1; if(!(g.items[0].mark&&tries[k][3]>22*_mz)&&!hits(r,(g.items[0].mark||_pass===0),(!g.items[0].mark&&dy<=0)?g.own:null)){
'@

SubRx @'
if(!ok&&g.items[0].mark){
'@ @'
_rx=1; if(!ok&&g.items[0].mark){
'@

SubRx @'
dy=Math.max(0,I.t-(g.r.b+q[1]),g.r.t+q[1]-I.b); return (dx*dx+dy*dy)*1000+q[0]*q[0]+q[1]*q[1]; }
'@ @'
dy=Math.max(0,I.t-(g.r.b+q[1]),g.r.t+q[1]-I.b); q[3]=Math.sqrt(dx*dx+dy*dy); return (dx*dx+dy*dy)*1000+q[0]*q[0]+q[1]*q[1]; }
'@

SubRx @'
clusterMarks.forEach(function(I){ localX.push(I.l-12*_mz-g.r.r,I.r+12*_mz-g.r.l); localY.push(I.t-12*_mz-g.r.b,I.b+12*_mz-g.r.t); });
'@ @'
clusterMarks.forEach(function(I){ localX.push(I.l-12*_mz-g.r.r,I.r+12*_mz-g.r.l,I.l-6*_mz-g.r.r,I.r+6*_mz-g.r.l); localY.push(I.t-12*_mz-g.r.b,I.b+12*_mz-g.r.t,I.t-6*_mz-g.r.b,I.b+6*_mz-g.r.t); });
'@

SubRx @'
localX.push(B.l-xpad-g.r.r,B.r+xpad-g.r.l); localY.push(B.t-ypad-g.r.b,B.b+ypad-g.r.t);
'@ @'
localX.push(B.l-xpad-g.r.r,B.r+xpad-g.r.l,B.l-xpad/2-g.r.r,B.r+xpad/2-g.r.l); localY.push(B.t-ypad-g.r.b,B.b+ypad-g.r.t,B.t-ypad*0.375-g.r.b,B.b+ypad*0.375-g.r.t);
'@

SubRx @'
ctx.fillStyle=mapFirstOn()?UIC.tx_2:'rgba(239,233,220,.66)';
'@ @'
ctx.fillStyle=mapFirstOn()?UIC.tx_2:'rgba(239,233,220,.78)';   /* v28.xx (cw-mappolish): zone names a step brighter on the sector map (the critic: zone label contrast) */
'@

SubRx @'
if(txt){ ctx.font=rewFont; ctx.fillStyle=mapFirstOn()?UIC.tx_1:UIC.tx_2;
'@ @'
if(txt){ ctx.font=rewFont; ctx.fillStyle=UIC.tx_1; /* v28.xx (cw-mappolish): the reward is the main text colour on both maps, the name and the count stay quiet (the critic: contracts hierarchy) */
'@

SubRx @'
bh=Math.max(3,Math.round(4*z))
'@ @'
bh=Math.max(4,Math.round(5*z))/* v28.xx (cw-mappolish): the progress track is a step thicker so it reads as a track (the critic: progress tracks) */
'@

SubRx @'
var VER='36.90';
'@ @'
var VER='36.91';
'@

$pat = "(?m)^  now:'v36\.90:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.91: Sector map: the strongbox word is placed first so it sits right beside its icon, zone names are brighter, the contract reward uses the main text colour and the progress track is 5 px (10 px at 4K). No caches, no new features. LOCAL: no linked review. Retarget: check 31.48 accepts zone names up to 82 percent. Check 36.91 fails on v36.90',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
