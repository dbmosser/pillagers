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

# GUNS TAKE A MOMENT TO DRAW (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function swapGuns(){
'@ @'
// v26.xx (wheel1), HIS ORDER 2026-10-14: "different guns should have different 'pull out' / 'ready to fire' times". A gun that comes into his hands
// (a swap, a draw from the backpack, a pickup, and in the next builds the gun coming back after an item) cannot fire until it is ready: a
// pistol in a quarter of a second, an SMG 0.4, a rifle 0.55, a shotgun 0.6, a marksman rifle 0.7, a sniper 0.85, the machine gun and the lance a
// full second. The time is the gun's CLASS, so a Forge upgrade (MK II, MK III, an element) does not change it. drawTick, run every frame from
// updatePlayer, starts the clock when the gun in his hands is not the one it saw last frame; the first frame of a raid starts nothing (the gun
// is drawn already), and the bot sim never waits (the clock is held at 0 under G.sim). p.drawT is the seconds left; p.drawLen the full time,
// for the reticle. No seeded draw, nothing a bot reads.
var DRAWT={tacker:0.25,pistol:0.25,magnum:0.35,sputter:0.4,smg:0.4,whisper:0.45,chatter:0.5,carbine:0.5,rifle:0.55,scuttle:0.6,shotgun:0.6,dmr:0.7,sniper:0.85,lmg:1.0,lance:1.0};
function drawTime(w){
  if(!w||!w.id||w.mag===0) return 0;
  return Object.prototype.hasOwnProperty.call(DRAWT,w.id)?DRAWT[w.id]:0.5;
}
function drawTick(p,dt){
  var w=p.wep;
  if((G&&G.sim)||!w){ p.drawT=0; p.drawRef=w; return; }
  if(p.drawRef===undefined){ p.drawRef=w; p.drawT=0; p.drawLen=0; }   // the first frame: already drawn
  else if(p.drawRef!==w){ p.drawRef=w; p.drawLen=drawTime(w); p.drawT=p.drawLen; }
  else if(p.drawT>0) p.drawT=Math.max(0,p.drawT-dt);
}
function swapGuns(){
'@

SubRx @'
  var HSL=hotbarSlots(), HSC=HSL[hotSel()];
'@ @'
  drawTick(p,dt);   // v26.xx (wheel1): the gun that just came into his hands is not ready yet
  var HSL=hotbarSlots(), HSC=HSL[hotSel()];
'@

SubRx @'
else if(mouse.down&&!p.trigYield&&!p.cooking&&p.reloading<=0&&p.jam<=0&&now-p.lastShot>p.wep.rof){
'@ @'
else if(mouse.down&&!p.trigYield&&!p.cooking&&!(p.drawT>0)&&p.reloading<=0&&p.jam<=0&&now-p.lastShot>p.wep.rof){
'@

SubRx @'
var VER='26.15';
'@ @'
var VER='26.16';
'@

$pat = "(?m)^  now:'v26\.15:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.16: Guns now take a moment to draw: a pistol is ready fast, a sniper rifle or the machine gun takes nearly a second. Check 26.16 fails on v26.15',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
