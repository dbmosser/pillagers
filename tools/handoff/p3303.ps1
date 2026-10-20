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

# EXPERIMENTAL: TWO MORE SWITCHES (RAID DIRECTOR, AIR STRIKE) (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  // XF_ROWS_END

'@ @'
  ['xfDir','raid director','waves ease off and ambush','w'],
  ['xfAir','air strike','damage charges an air strike','w'],
  // XF_ROWS_END

'@

SubRx @'
  if(!D) D=S.dir={st:0,hp:hp,quiet:0,ph:'build',phT:0,waves:0,amb:0,lastAmb:-999,pace:1};

'@ @'
  if(!D) D=S.dir={st:0,hp:hp,quiet:0,ph:'build',phT:0,waves:0,amb:0,lastAmb:-999,pace:1};
  if(!xf('xfDir')){ D.ph='build'; D.pace=1; return D; }   // v32.xx (cw-expmenu5): switched off, the wave clock runs at its fixed rate (D stays, the 3 waves goal reads D.waves)

'@

SubRx @'
function flowAmbushOk(D,q){

'@ @'
function flowAmbushOk(D,q){
  if(!xf('xfDir')) return false;   // v32.xx (cw-expmenu5): switched off, no ambush pack

'@

SubRx @'
  if(flowZoneNear(x,y,DIR.ring)) return false;   // v26.xx (flow1)
'@ @'
  if(xf('xfDir')&&flowZoneNear(x,y,DIR.ring)) return false;   // v26.xx (flow1); v32.xx (cw-expmenu5): the ring rule came with the director
'@

SubRx @'
function airScan(){
  var A=airS(), i, e, h, drop;

'@ @'
function airScan(){
  var A=airS(), i, e, h, drop;
  if(!xf('xfAir')) return;   // v32.xx (cw-expmenu5): switched off, no meter

'@

SubRx @'
function airKey(){
  var A=airS(), p=G&&G.player;

'@ @'
function airKey(){
  var A=airS(), p=G&&G.player;
  if(!xf('xfAir')) return false;   // v32.xx (cw-expmenu5): switched off, G does nothing

'@

SubRx @'
function airCharge(e,dmg){
  var A, add;

'@ @'
function airCharge(e,dmg){
  var A, add;
  if(!xf('xfAir')) return 0;   // v32.xx (cw-expmenu5): switched off, player 2 charges nothing

'@

SubRx @'
Math.abs(PAD.lbAt-PAD.rbAt)<0.3&&typeof flowOn==='function'&&flowOn()){
'@ @'
Math.abs(PAD.lbAt-PAD.rbAt)<0.3&&typeof flowOn==='function'&&flowOn()&&xf('xfAir')){   // v32.xx (cw-expmenu5): switched off, the bumpers keep their own jobs
'@

SubRx @'
  if(m.k==='air'){

'@ @'
  if(m.k==='air'){
    if(!xf('xfAir')) return 'off';   // v32.xx (cw-expmenu5)

'@

SubRx @'
  if(!(G.map&&G.map.locked&&G.map.locked.length)){ ix=pool.indexOf('vault'); if(ix>=0) pool.splice(ix,1); }

'@ @'
  if(!(G.map&&G.map.locked&&G.map.locked.length)){ ix=pool.indexOf('vault'); if(ix>=0) pool.splice(ix,1); }
  if(!xf('xfAir')){ ix=pool.indexOf('air1'); if(ix>=0) pool.splice(ix,1); }   // v32.xx (cw-expmenu5): the air strike goal can never be met with the strike off

'@

SubRx @'
var VER='33.02';
'@ @'
var VER='33.03';
'@

$pat = "(?m)^  now:'v33\.02:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v33.03: The experimental page switches the raid director and the air strike. Check 33.03 fails on v33.02',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
