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

# CONTROLLER RUMBLE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function netPadTick(gps){
'@ @'
// v17.37, HIS PICK 2 (2026-09-30): CONTROLLER RUMBLE. Each player pad buzzes when that player is hit (harder for a bigger
// hit), goes down, or is near a blast, with a light tick when he fires. A pad this window reads itself (RUMBLE.gp) buzzes
// directly; on one PC the window whose pad is handed over asks the other window, which buzzes the pad it reads for him
// (RUMBLE.other). A pad nobody has touched for a minute never buzzes, so a keyboard player with a pad lying there feels
// nothing. Settings: Controller rumble, On by default.
var RUMBLE={gp:null,other:null,usedAt:-1e9,at:0,s:0};
function padRumbleOn(gp,s,ms){
  try{
    var va=gp&&gp.vibrationActuator;
    if(!va||typeof va.playEffect!=='function'||!(s>0)||!(ms>0)) return false;
    var pr=va.playEffect('dual-rumble',{startDelay:0,duration:Math.round(Math.min(1000,ms)),strongMagnitude:Math.min(1,s),weakMagnitude:Math.min(1,s*0.6)});
    if(pr&&typeof pr.catch==='function') pr.catch(function(){});
    return true;
  }catch(e){ return false; }
}
function padRumble(s,ms){
  if(CFG.rumble===0||!(s>0)||!(ms>0)) return 'off';
  if(typeof G!=='undefined'&&G&&G.sim) return 'sim';
  var now=(typeof performance!=='undefined')?performance.now():Date.now();
  if(!(now-RUMBLE.usedAt<60000)) return 'idle';
  if(now-RUMBLE.at<50&&s<=RUMBLE.s) return 'soon';
  RUMBLE.at=now; RUMBLE.s=s;
  if(RUMBLE.gp) return padRumbleOn(RUMBLE.gp,s,ms)?'own':'none';
  if(typeof NET!=='undefined'&&NET&&NET.same&&NET.pair&&typeof netSamePost==='function') return netSamePost({t:'rumble',pair:NET.pair,s:+s.toFixed(2),ms:Math.round(ms)})?'sent':'none';
  return 'none';
}function netPadTick(gps){
'@

SubRx @'
  else for(var i=0;i<gps.length;i++){ if(gps[i]&&gps[i].connected){ gp=gps[i]; break; } }
'@ @'
  else for(var i=0;i<gps.length;i++){ if(gps[i]&&gps[i].connected){ gp=gps[i]; break; } }
  RUMBLE.gp=(gp&&gp.vibrationActuator&&typeof gp.vibrationActuator.playEffect==='function')?gp:null;   // v17.37: the pad this window plays, for padRumble
  if(gp&&(((gp.buttons||[]).some(function(b){ return b&&(b.pressed||b.value>0.3); }))||((gp.axes||[]).some(function(a){ return Math.abs(a)>0.3; })))) RUMBLE.usedAt=(typeof performance!=='undefined')?performance.now():Date.now();
'@

SubRx @'
    other=netPadFor((NET.same==='host')?'p2':'host',NET.padOther,NET.padIx,gps,was);
'@ @'
    other=netPadFor((NET.same==='host')?'p2':'host',NET.padOther,NET.padIx,gps,was);
    RUMBLE.other=(other>=0&&gps[other])?gps[other]:null;   // v17.37: the pad this window reads for the other player, which buzzes when he asks
'@

SubRx @'
  if(m.t==='key'){   // v16.89: a key the player 2 window was given, played here as this window own key
'@ @'
  if(m.t==='rumble'){ if(!RUMBLE.other) return 'nopad'; return padRumbleOn(RUMBLE.other,+m.s||0,+m.ms||0)?'rumble':'nopad'; }   // v17.37: a buzz the other window asked for, on the pad this window reads for him
  if(m.t==='key'){   // v16.89: a key the player 2 window was given, played here as this window own key
'@

SubRx @'
  if(p.iv>0) return;
  p.combatT=0;
'@ @'
  if(p.iv>0) return;
  padRumble(Math.min(1,0.3+amt/40),Math.round(110+Math.min(200,amt*6)));   // v17.37: his pick 2, the pad buzzes with the hit
  p.combatT=0;
'@

SubRx @'
p.hp=0; p.downed=true; p.downT=CFG.downTime; p.pendKiller=src; p.prep=null; p.prepA=null; G.crouchTog=false; G.pCrouch=false;
'@ @'
p.hp=0; p.downed=true; p.downT=CFG.downTime; p.pendKiller=src; p.prep=null; p.prepA=null; G.crouchTog=false; G.pCrouch=false;
  padRumble(1,450);   // v17.37: going down is the longest buzz
'@

SubRx @'
    G.player.recoil=1; G.player.combatT=0; G.tel.shots+=shots;
'@ @'
    G.player.recoil=1; G.player.combatT=0; G.tel.shots+=shots;
    padRumble(0.12,35);   // v17.37: a light tick per shot
'@

SubRx @'
  var p=G.player,R=(CFG.fragR===undefined?190:CFG.fragR),i;
'@ @'
  var p=G.player,R=(CFG.fragR===undefined?190:CFG.fragR),i;
  try{ var _rd=Math.hypot(f.x-p.x,f.y-p.y); if(_rd<R*1.6) padRumble(Math.max(0.3,1-_rd/(R*1.6)),230); }catch(_rb){}   // v17.37: a blast near you thumps the pad
'@

SubRx @'
  {k:'raiders', label:'Other pillagers',
'@ @'
  {k:'rumble', label:'Controller rumble',
   hint:'Each player controller buzzes when that player is hit, goes down or is near a blast, with a light tick when firing. A controller nobody is using stays still.',
   opts:[
     {n:'Off', cfg:{rumble:0}},
     {n:'On',  cfg:{rumble:1}}
   ], def:1},
  {k:'raiders', label:'Other pillagers',
'@

SubRx @'
var VER='17.36';
'@ @'
var VER='17.37';
'@

$pat = "(?m)^  now:'v17\.36:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.37: CONTROLLER RUMBLE, his pick from the feature list. Each player controller buzzes when that player is hit (harder for a bigger hit), goes down or is near a blast, with a light tick when firing; on one PC the player 2 buzz goes to the window that reads his controller. Settings has a Controller rumble row, On by default, and a controller nobody has touched for a minute stays still. Check 17.37 fails on v17.36',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
