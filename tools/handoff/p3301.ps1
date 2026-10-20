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

# EXPERIMENTAL: EIGHT MORE SWITCHES (STYLE MEDALS, TEAM COMBO, FUEL FIRES, FIVE RAID EVENTS) (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  // XF_ROWS_END

'@ @'
  ['xfStyle','style medals','medals and the combo ring','w'],
  ['xfTeam','team combo','2 player team multiplier','w'],
  ['xfFire','fuel fires','two fuel fires a raid','w'],
  ['xfEvDebris','event: orbital debris','debris falls in a ring','w'],
  ['xfEvConvoy','event: machine convoy','an armoured train crosses','w'],
  ['xfEvBounty','event: bounty pillager bot','a marked boss hunts you','w'],
  ['xfEvCool','event: coolant rupture','a district fogs over','w'],
  ['xfEvRamp','event: overseer rampage','the overseer sweeps the map','w'],
  // XF_ROWS_END

'@

SubRx @'
function xfL(k){ return !(CFG&&CFG[k]===0); }            // a LOCAL switch, this window, now

'@ @'
function xfL(k){ return !(CFG&&CFG[k]===0); }            // a LOCAL switch, this window, now
var XF_EV={debris:'xfEvDebris',convoy:'xfEvConvoy',bounty:'xfEvBounty',cool:'xfEvCool',rampage:'xfEvRamp'};   // v32.xx (cw-expmenu3): the raid events, by id

'@

SubRx @'
function styleKill(k,el,boss,x,y,e){
  var S, t, p, d, fresh, bl, paid=0;

'@ @'
function styleKill(k,el,boss,x,y,e){
  var S, t, p, d, fresh, bl, paid=0;
  if(!xf('xfStyle')) return 0;   // v32.xx (cw-expmenu3): switched off, no style medals are paid

'@

SubRx @'
  if(t>=S.calmAt){
    if(S.calmK>0&&!p.downed&&!p.dying) styMedal('UNTOUCHED'
'@ @'
  if(xf('xfStyle')&&t>=S.calmAt){   // v32.xx (cw-expmenu3): the untouched medal is a style medal
    if(S.calmK>0&&!p.downed&&!p.dying) styMedal('UNTOUCHED'
'@

SubRx @'
  if(s&&s.n>=2&&t>=s.t&&t-s.t<ARCADE_STREAK_GAP){
    f=1-(t-s.t)/ARCADE_STREAK_GAP; mx=arcadeStreakX(s.n);
'@ @'
  if(xf('xfStyle')&&s&&s.n>=2&&t>=s.t&&t-s.t<ARCADE_STREAK_GAP){
    f=1-(t-s.t)/ARCADE_STREAK_GAP; mx=arcadeStreakX(s.n);
'@

SubRx @'
function teamKill(x,y){
  var now=Date.now(), mk, T, n, p, paid=0, lk=0;

'@ @'
function teamKill(x,y){
  var now=Date.now(), mk, T, n, p, paid=0, lk=0;
  if(!xf('xfTeam')) return 0;   // v32.xx (cw-expmenu3): switched off, no team combo and no kill word to the partner

'@

SubRx @'
function arcadeTeamTake(m){
  var now=Date.now();

'@ @'
function arcadeTeamTake(m){
  var now=Date.now();
  if(!xf('xfTeam')) return 'ignored';   // v32.xx (cw-expmenu3)

'@

SubRx @'
function teamDraw(c,p,rx,ry){
  var T, f, z, xs, r, col='95,245,228';

'@ @'
function teamDraw(c,p,rx,ry){
  var T, f, z, xs, r, col='95,245,228';
  if(!xf('xfTeam')) return;   // v32.xx (cw-expmenu3)

'@

SubRx @'
  if(!peer){   // v27.04 (coop1): a linked player 2 window plans and lights nothing, the fires are the host's (flowNetTake)

'@ @'
  if(!peer&&xf('xfFire')){   // v32.xx (cw-expmenu3): switched off, no fuel fire is planned; the fires the debris event lights still burn;   // v27.04 (coop1): a linked player 2 window plans and lights nothing, the fires are the host's (flowNetTake)

'@

SubRx @'
if(d&&(!d.ok||d.ok())) out.push(EV_IDS[i]);
'@ @'
if(d&&(!d.ok||d.ok())&&xf(XF_EV[EV_IDS[i]])) out.push(EV_IDS[i]);
'@

SubRx @'
var VER='33.00';
'@ @'
var VER='33.01';
'@

$pat = "(?m)^  now:'v33\.00:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v33.01: The experimental page switches style medals, team combo, fuel fires and the five raid events. Check 33.01 fails on v33.00',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
