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

# RIGHT STICK CROWBAR (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  // aim, as a virtual cursor placed off the player in the stick direction
'@ @'
  // v28.xx (cw-cx-rsmelee): his 3.11 b and J6: RS swings; keep the pre-click angle for 80 ms.
  var _rsBtn=bt[padMapArr()[11]], _rsDown=!!(_rsBtn&&(_rsBtn.pressed||_rsBtn.value>0.5));
  var _rsNow=netPadNow(), _rsLive=!!(G&&!G.over&&!G.paused&&state==='raid'&&!G.bagOpen&&!G.mapOpen&&!G.wheel&&!G.trade&&!G.forgeUI&&!padOpenModal());
  if(_rsLive&&_rsDown&&!PAD.meleeDown){ PAD.meleeAimUntil=_rsNow+0.08; PAD.meleeAimA=PAD.aimA===undefined?G.player.face:PAD.aimA; }
  PAD.meleeDown=_rsDown;
  var _rsFreeze=!!(_rsLive&&PAD.meleeAimUntil>_rsNow);
  if(_rsFreeze) PAD.aimA=PAD.meleeAimA;
  // aim, as a virtual cursor placed off the player in the stick direction
'@

SubRx @'
  if(G&&!G.over&&!rx&&!ry&&(PAD.mx||PAD.my)){
'@ @'
  if(G&&!G.over&&!_rsFreeze&&!rx&&!ry&&(PAD.mx||PAD.my)){
'@

SubRx @'
  if(G&&!G.over&&!G.wheel&&(rx||ry)){   // wheel5pad: and not while the item wheel is open
'@ @'
  if(G&&!G.over&&!G.wheel&&!_rsFreeze&&(rx||ry)){   // v28.xx (cw-cx-rsmelee): freeze the click nudge, never the wheel.
'@

SubRx @'
  if(G&&!G.over&&state==='raid'&&G.player&&PAD.curOwn&&!rx&&!ry&&!PAD.mx&&!PAD.my&&!G.mapOpen&&!G.bagOpen){
'@ @'
  if(G&&!G.over&&state==='raid'&&G.player&&(PAD.curOwn||_rsFreeze)&&((_rsFreeze)||(!rx&&!ry&&!PAD.mx&&!PAD.my))&&!G.mapOpen&&!G.bagOpen){
'@

SubRx @'
PAD.xSearched=false; PAD.mx=0; PAD.my=0; padBodyCls(); return;
'@ @'
PAD.xSearched=false; PAD.meleeDown=false; PAD.meleeAimUntil=0; PAD.mx=0; PAD.my=0; padBodyCls(); return;
'@

SubRx @'
  if(pressed(11)&&!PAD.prev[11]&&!G.over&&!G.paused) PAD.adsTog=!PAD.adsTog;   // v16.72, his order: RS click toggles focus aim
  if(G.over) PAD.adsTog=false;
  PAD.adsAim=!!(PAD.adsTog||(trig(6)>0.35&&!G.over&&!G.paused));   // v19.08, from the review (2026-10-07): a deliberate aim (LT or the RS toggle), apart from the steadying after each RT pull
  if((PAD.adsT>0||PAD.adsTog||(trig(6)>0.35&&!G.over&&!G.paused))&&!(pressed(10)&&G.player&&G.player.moving)){ G.player.ads=true; PAD.adsing=1; }   // v16.81: never while sprinting   // v16.72, his order: LT held or RS toggled is focus aim
'@ @'
  // v28.xx (cw-cx-rsmelee): his 3.11 b: "a click of the right stick"; LT hold stays focus aim.
  if(pressed(11)&&!PAD.prev[11]&&_rsLive) meleeStrike();
  PAD.adsTog=false;
  PAD.adsAim=!!(trig(6)>0.35&&!G.over&&!G.paused);
  if((PAD.adsT>0||PAD.adsAim)&&!(pressed(10)&&G.player&&G.player.moving)){ G.player.ads=true; PAD.adsing=1; }
'@

SubRx @'
KeyQ:'D-DOWN',KeyV:'Y',
'@ @'
KeyQ:'D-DOWN',KeyV:'RS',
'@

SubRx @'
KeyI:8,KeyV:3};
'@ @'
KeyI:8,KeyV:11};
'@

SubRx @'
[11,'focus aim (toggle)','FIGHT']
'@ @'
[11,'melee (crowbar)','FIGHT']
'@

SubRx @'
'sprint','focus toggle','ping / map'
'@ @'
'sprint','crowbar','ping / map'
'@

SubRx @'
[n(6)+' / '+n(11),'focus aim, hold / toggle']
'@ @'
[n(6),'focus aim (hold)'],[n(11),'melee (crowbar)']
'@

SubRx @'
[b(6)+' / '+b(11),'focus aim']
'@ @'
[b(6),'focus aim'],[b(11),'crowbar']
'@

SubRx @'
['LT / RS','focus aim']
'@ @'
['LT','focus aim'],['RS','crowbar']
'@

SubRx @'
['LT / RS CLICK','focus aim, hold / toggle']
'@ @'
['LT','focus aim (hold)'],['RS CLICK','melee (crowbar)']
'@

SubRx @'
keyLabel('KeyV','V')+'] FINISH'
'@ @'
(padOn()?padB(pbn(3)):keyLabel('KeyV','V'))+'] FINISH'
'@

SubRx @'
var VER='31.86';
'@ @'
var VER='31.87';
'@

$pat = "(?m)^  now:'v31\.86:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.87: RS swings once per click with an 80 ms aim hold. LT still focuses. Check 31.87 fails on v31.86',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
