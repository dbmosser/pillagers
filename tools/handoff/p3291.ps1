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

# REDUCED FLASHING STARTS ON (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var P={credits:900,stash:[],weapons:['pistol'],equipped:'fists',runs:0,ext:0,died:0,best:0,dayMigrated:1,
'@ @'
// v28.xx (cw-cx-flashdefault), his 2.61: "Yes, as a Settings switch that is on by default". New saves keep the new choice on reload.
var P={credits:900,stash:[],weapons:['pistol'],equipped:'fists',runs:0,ext:0,died:0,best:0,dayMigrated:1,gameOpts:{flashRed:1},
'@

SubRx @'
padPresetLoad(); // v28.xx (cw-cx-padpresets): legacy profiles keep their button map, with standard sticks.
'@ @'
padPresetLoad(); // v28.xx (cw-cx-padpresets): legacy profiles keep their button map, with standard sticks.
// v28.xx (cw-cx-flashdefault): existing saves keep their choice, including the old implicit off. Profile fields only; the save key stays the same.
if(!P.gameOpts||typeof P.gameOpts!=='object') P.gameOpts={};
if(!Object.prototype.hasOwnProperty.call(P.gameOpts,'flashRed')) P.gameOpts.flashRed=(P.cfg&&P.cfg.flashRed===1)?1:0;
'@

SubRx @'
  {k:'flashRed', label:'REDUCED FLASHING', sec:'ACCESSIBILITY',
   hint:'Tones down the bright flashes: blasts, muzzle flashes, lightning and forge sparks.',
   opts:[
     {n:'OFF', cfg:{flashRed:0}},
     {n:'ON',  cfg:{flashRed:1}}
   ], def:0},
'@ @'
  // v28.xx (cw-cx-flashdefault), his 2.61: reduced flashing starts on for new pillagers.
  {k:'flashRed', label:'REDUCED FLASHING', sec:'ACCESSIBILITY',
   hint:'Tones down the bright flashes: blasts, muzzle flashes, lightning and forge sparks.',
   opts:[
     {n:'OFF', cfg:{flashRed:0}},
     {n:'ON',  cfg:{flashRed:1}}
   ], def:1},
'@

SubRx @'
function flash(x,y,r,col,life){
  if(G.sim) return;
'@ @'
// v28.xx (cw-cx-flashdefault), his 2.61: at most about three bright flashes a second. Blasts and bolts share one visual budget per raid.
function brightFlashOk(){
  if(CFG.flashRed!==1||G.sim) return true;
  var t=performance.now();
  if(typeof G._brightFlashAt==='number'&&t-G._brightFlashAt<334) return false;
  G._brightFlashAt=t;
  return true;
}
// v28.xx (cw-cx-flashdefault): keep the real lightning timer for bot sight, damage and sound; limit only the sheet and fog lift.
function lightningFlash(){ G.lightning=0.34; G._flashBolt=brightFlashOk(); }
function lightningVisual(){ return CFG.flashRed===1&&!G._flashBolt?0:(G.lightning||0); }
function flash(x,y,r,col,life){
  if(G.sim||!brightFlashOk()) return;
'@

SubRx @'
    if(S.rm){ G.lightning=0.34; if(!G.sim) sfxHere('alarm',S.x,S.y); continue; }   // v16.06: a host bolt on a linked window: the flash and the crack only; the host lands the hit (netAreaHitPeers)
'@ @'
    if(S.rm){ lightningFlash(); if(!G.sim) sfxHere('alarm',S.x,S.y); continue; }   // v16.06: a host bolt on a linked window: the flash and the crack only; the host lands the hit (netAreaHitPeers) // v28.xx (cw-cx-flashdefault): the peer bolt uses the same visual limiter.
'@

SubRx @'
    G.lightning=0.34;                       // the flash the renderer has always had
'@ @'
    lightningFlash(); // v28.xx (cw-cx-flashdefault): the local bolt uses the same visual limiter.
'@

SubRx @'
  var _flash=clamp((G.lightning||0)/0.34,0,1)*flashK();   // v26.xx (settings9): REDUCED FLASHING lifts the fog less in a bolt
'@ @'
  var _flash=clamp(lightningVisual()/0.34,0,1)*flashK(); // v28.xx (cw-cx-flashdefault): a suppressed bolt cannot brighten the fog.
'@

SubRx @'
    if(G.lightning>0){
      // a hard flash
'@ @'
    // v28.xx (cw-cx-flashdefault): suppressed bolts keep their gameplay timer but draw no sheet.
    if(lightningVisual()>0){
      // a hard flash
'@

SubRx @'
      G.flashes.push({x:bx,y:by,r:rnd(180,340)*(CFG.flashRed===1?0.6:1),t:0,life:0.5*(CFG.flashRed===1?0.7:1),c:'#ffd6a0'});   // v27.67 (cloud-menus-nuke-reduced-flash), CLOUD HUNT 2026-10-15: these blooms skip flash(), so REDUCED FLASHING never shrank them; same factors as flash(), same rnd draw
'@ @'
      // v28.xx (cw-cx-flashdefault): barrage blooms share the flash budget; always take the radius draw so the raid seed stays unchanged.
      var _nr=rnd(180,340);
      if(brightFlashOk()) G.flashes.push({x:bx,y:by,r:_nr*(CFG.flashRed===1?0.6:1),t:0,life:0.5*(CFG.flashRed===1?0.7:1),c:'#ffd6a0'});
'@

SubRx @'
  for(k in ARCADE_SBX) if(Object.prototype.hasOwnProperty.call(ARCADE_SBX,k)) sb[k]=JSON.parse(JSON.stringify(ARCADE_SBX[k]));
'@ @'
  for(k in ARCADE_SBX) if(Object.prototype.hasOwnProperty.call(ARCADE_SBX,k)) sb[k]=JSON.parse(JSON.stringify(ARCADE_SBX[k]));
  // v28.xx (cw-cx-flashdefault), his 3.15: the demo starts on its own reduced flashing choice, even when the career save chose off.
  sb.gameOpts=sb.gameOpts||{}; sb.gameOpts.flashRed=1;
  if(sb.tuned) delete sb.tuned.flashRed;
'@

SubRx @'
  netUpPutP(JSON.stringify(sb));
'@ @'
  netUpPutP(JSON.stringify(sb));
  CFG.flashRed=1; // v28.xx (cw-cx-flashdefault): the demo setting takes effect in either window at entry.
'@

SubRx @'
var VER='32.90';
'@ @'
var VER='32.91';
'@

$pat = "(?m)^  now:'v32\.90:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.91: New saves and the demo start with reduced flashing. Existing choices stay. Blast lights and lightning share a three-per-second visual limit when on. Check 32.91 fails on v32.90',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
