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

# EXPERIMENTAL: FIVE MORE SWITCHES (PILLAGER ROLES, SUPPRESSION, MACHINES VS PILLAGERS, ELITE AFFIXES, OVERSEER PHASES) (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
setSecsHtml(_SEC,{CONTROLS:keysRowHtml(),CONTROLLER:padRowHtml(),ACCESSIBILITY:expRowHtml()})
'@ @'
setSecsHtml(_SEC,{CONTROLS:keysRowHtml(),CONTROLLER:padRowHtml()})
'@

SubRx @'
  if(SETSUB==='exp'){ expPage(host,_SEC); return; }   // v32.xx (cw-expmenu1): the experimental page replaces the list until back

'@ @'
  if(SETSUB==='exp'){ expPage(host,_SEC); return; }   // v32.xx (cw-expmenu1): the experimental page replaces the list until back
  _SEC['THE RAID']=(_SEC['THE RAID']||'')+expRowHtml();   // v32.xx (cw-expmenu2): the open row ends THE RAID, where the features it switches are

'@

SubRx @'
  // XF_ROWS_END

'@ @'
  ['xfRoles','pillager roles','roles by gun and rig','w'],
  ['xfSupp','suppression','heavy fire pins a pillager','w'],
  ['xfFeud','machines vs pillagers','they fight on sight','w'],
  ['xfAffix','elite affixes','shielded, fast, volatile, mender','w'],
  ['xfOvPh','overseer phases','crawler calls and a laser sweep','w'],
  // XF_ROWS_END

'@

SubRx @'
function raiderRole(e){
  var w, h;

'@ @'
function raiderRole(e){
  var w, h;
  if(!xf('xfRoles')) return null;   // v32.xx (cw-expmenu2): switched off, a pillager has no role

'@

SubRx @'
function suppHit(en){

'@ @'
function suppHit(en){
  if(!xf('xfSupp')) return false;   // v32.xx (cw-expmenu2): switched off, rounds past a pillager pin nobody

'@

SubRx @'
function machFoe(o){

'@ @'
function machFoe(o){
  if(!xf('xfFeud')) return false;   // v32.xx (cw-expmenu2): switched off, a pillager does not pick a machine as a foe

'@

SubRx @'
  if(e.kind!=='sentry'&&e.kind!=='crawler'&&e.kind!=='bulwark'&&!(e.kind==='warden'&&!e.boss)) return false;   // v26.xx (ai23): and a plain Warden or a Bulwark

'@ @'
  if(e.kind!=='sentry'&&e.kind!=='crawler'&&!(xf('xfFeud')&&(e.kind==='bulwark'||(e.kind==='warden'&&!e.boss)))) return false;   // v26.xx (ai23): and a plain Warden or a Bulwark; v32.xx (cw-expmenu2): only while machines vs pillagers is on

'@

SubRx @'
function affixApply(e,ix){
  var k;

'@ @'
function affixApply(e,ix){
  var k;
  if(!xf('xfAffix')) return null;   // v32.xx (cw-expmenu2): switched off, an elite machine is a plain elite

'@

SubRx @'
function overseerTick(e,p,sees,dt){
  var ph, i, pl, pls, L, dx, dy, al, pp;

'@ @'
function overseerTick(e,p,sees,dt){
  var ph, i, pl, pls, L, dx, dy, al, pp;
  if(!xf('xfOvPh')) return false;   // v32.xx (cw-expmenu2): switched off, the overseer is one long health bar with a cannon

'@

SubRx @'
if(en.boss&&en.overheat>0){ edmg*=1.5;
'@ @'
if(xf('xfOvPh')&&en.boss&&en.overheat>0){ edmg*=1.5;
'@

SubRx @'
WK.mult*((en.boss&&en.overheat>0)?1.5:1)
'@ @'
WK.mult*((xf('xfOvPh')&&en.boss&&en.overheat>0)?1.5:1)
'@

SubRx @'
var VER='32.99';
'@ @'
var VER='33.00';
'@

$pat = "(?m)^  now:'v32\.99:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v33.00: The experimental page switches pillager roles, suppression, machines vs pillagers, elite affixes and the overseer phases. Check 33.00 fails on v32.99',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
