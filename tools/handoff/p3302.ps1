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

# EXPERIMENTAL: FIVE MORE SWITCHES (WARDEN ARMOUR, EXPLOSIVE BARRELS, WAVES GROW, AIM LANES, SEARCH RINGS) (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  // XF_ROWS_END

'@ @'
  ['xfWarden','warden armour','a warden soaks hits from the front','w'],
  ['xfBarrel','explosive barrels','red barrels that chain','w'],
  ['xfRamp','waves grow','waves grow the longer you stay','w'],
  ['xfTell','aim lanes','a machine paints its aim','w'],
  ['xfSearch','search rings','searchers widen their rings','w'],
  // XF_ROWS_END

'@

SubRx @'
} else if((en.kind==='bulwark'||(en.kind==='warden'&&!en.boss))&&(function(){
'@ @'
} else if((en.kind==='bulwark'||(xf('xfWarden')&&en.kind==='warden'&&!en.boss))&&(function(){
'@

SubRx @'
function brlPlace(g){
  g.brl=[];

'@ @'
function brlPlace(g){
  g.brl=[];
  if(!xf('xfBarrel')) return;   // v32.xx (cw-expmenu4): switched off, the raid places no barrels

'@

SubRx @'
tt=Math.max(0,Math.min(4,Math.floor((+elapsed()||0)/120)));
'@ @'
tt=xf('xfRamp')?Math.max(0,Math.min(4,Math.floor((+elapsed()||0)/120))):0;   // v32.xx (cw-expmenu4): switched off, the tier is the score alone
'@

SubRx @'
function telegraphLane(e){
  var tot, f, a, ux, uy, reach, t, p, d;

'@ @'
function telegraphLane(e){
  var tot, f, a, ux, uy, reach, t, p, d;
  if(!xf('xfTell')) return null;   // v32.xx (cw-expmenu4): switched off, no machine paints its aim

'@

SubRx @'
    wc.beginPath(); wc.ellipse(SHD.tx,SHD.ty,RR3*_sf,RR3*_sf,0,0,6.2832); wc.fill();
    wc.strokeStyle='rgba(255,90,60,.14)'; wc.lineWidth=1;
    wc.beginPath(); wc.ellipse(SHD.tx,SHD.ty,RR3,RR3,0,0,6.2832); wc.stroke();

'@ @'
    if(xf('xfTell')){   // v32.xx (cw-expmenu4): the landing circle fills and its full size is marked only while aim lanes are on
      wc.beginPath(); wc.ellipse(SHD.tx,SHD.ty,RR3*_sf,RR3*_sf,0,0,6.2832); wc.fill();
      wc.strokeStyle='rgba(255,90,60,.14)'; wc.lineWidth=1;
      wc.beginPath(); wc.ellipse(SHD.tx,SHD.ty,RR3,RR3,0,0,6.2832); wc.stroke();
    }

'@

SubRx @'
function searchCone(e){
  var L, sight, reach, half, chid, t;

'@ @'
function searchCone(e){
  var L, sight, reach, half, chid, t;
  if(!xf('xfSearch')) return null;   // v32.xx (cw-expmenu4): switched off, no scan cone

'@

SubRx @'
function searchAdvance(e){

'@ @'
function searchAdvance(e){
  if(!xf('xfSearch')) return false;   // v32.xx (cw-expmenu4): switched off, a searcher gives up at the first point

'@

SubRx @'
if(_sd>40&&_srch){ if(_sd<(e.srchBest
'@ @'
if(_sd>40&&_srch&&xf('xfSearch')){ if(_sd<(e.srchBest
'@

SubRx @'
if(_sd>40&&!(_srch&&(e.srchT||0)>1.5)) navSeek
'@ @'
if(_sd>40&&!(_srch&&xf('xfSearch')&&(e.srchT||0)>1.5)) navSeek
'@

SubRx @'
var VER='33.01';
'@ @'
var VER='33.02';
'@

$pat = "(?m)^  now:'v33\.01:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v33.02: The experimental page switches warden armour, explosive barrels, waves grow, aim lanes and search rings. Check 33.02 fails on v33.01',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
