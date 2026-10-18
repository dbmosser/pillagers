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

# A MIMIC POPS OUT AWAY FROM YOU AND ITS BOX SPINS INTO THE VOID (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  a=p?Math.atan2(p.y-ct.y,p.x-ct.x):0; x=ct.x+Math.cos(a)*26; y=ct.y+Math.sin(a)*26;
  if(!spotFree(G.map,x,y,12)){ x=ct.x; y=ct.y; }
  fxBorrow(function(){ c=mkCrawler(x,y); });
  c.mimic=1; c.state='chase'; c.alert=3; c.tx=p?p.x:x; c.ty=p?p.y:y;

'@ @'
  // v28.xx (cw-mimicaway), HIS ORDER (2026-10-15): "MIMIC crawler from a looting box: pops out AWAY from the player, so he can kill it without
  // taking damage; has a different name, so he knows where it came from". It came out on the player's side of the box (26 toward him) and bit
  // at once. It now comes out 34 on the far side of the box (then the nearest free side), is named MIMIC, and holds its first bite for a second.
  a=p?Math.atan2(p.y-ct.y,p.x-ct.x):0; var _mo=[3.1416,2.3416,3.9416,1.5416,4.7416], _mf=false, _mi;
  for(_mi=0;_mi<_mo.length&&!_mf;_mi++){ x=ct.x+Math.cos(a+_mo[_mi])*34; y=ct.y+Math.sin(a+_mo[_mi])*34; if(spotFree(G.map,x,y,12)) _mf=true; }
  if(!_mf){ x=ct.x; y=ct.y; }
  fxBorrow(function(){ c=mkCrawler(x,y); c.name=mkName('MIMIC',['M','X','V']); });
  c.mimic=1; c.state='chase'; c.alert=3; c.tx=p?p.x:x; c.ty=p?p.y:y; c.cd=1.0;

'@

SubRx @'
  ct.mimicDone=1; ct.mimicWake=0;

'@ @'
  ct.mimicDone=1; ct.mimicWake=0;
  // v28.xx (cw-mimicaway), HIS ORDER (2026-10-15): "the box gets a unique disappear-into-the-void swirl animation". The box was only a box the crawler
  // came out of. It is spent now (no loot, not searchable) and spins away into a violet swirl for 1.5 s, then is gone.
  ct.opened=true; ct.loot=[]; ct.prog=0; ct.pulled=0; if(!G.sim) ct.mimicVoid=1.5;

'@

SubRx @'
    if(ct.mimicDone||ct.opened) continue;

'@ @'
    if(ct.mimicVoid>0) ct.mimicVoid-=dt;   // v28.xx (cw-mimicaway): the void swirl timer
    if(ct.mimicDone||ct.opened) continue;

'@

SubRx @'
function drawContS(ct){
  var w,lift,d2,cF,cT;

'@ @'
// v28.xx (cw-mimicaway), HIS ORDER (2026-10-15): "the box gets a unique disappear-into-the-void swirl animation". The spent mimic box shrinks and
// spins into a dark hole ringed by four violet spiral arms, over 1.5 s, and is gone. Pure function of the timer: no random draw.
function drawMimicVoid(ct){
  var t=1-Math.max(0,ct.mimicVoid)/1.5, s=Math.max(0.03,1-t*t*0.97), k, j, a, r, o=ct.opened, fade=Math.min(1,t*5)*(1-Math.max(0,t-0.8)*5);
  wc.save();
  wc.globalAlpha=0.9*fade; wc.fillStyle='#08001a'; wc.beginPath(); wc.ellipse(ct.x,ct.y+2,26*(0.4+0.6*fade),13*(0.4+0.6*fade),0,0,6.2832); wc.fill();
  wc.restore();
  wc.save(); wc.translate(ct.x,ct.y); wc.rotate(t*7); wc.scale(s,s); wc.translate(-ct.x,-ct.y);
  ct.opened=false; ct.mimicVoidIn=1;
  try{ drawContS(ct); } finally { ct.opened=o; ct.mimicVoidIn=0; }
  wc.restore();
  wc.save();
  for(k=0;k<4;k++) for(j=0;j<9;j++){
    r=(8+j*3.4)*(1-t*0.5); a=k*1.5708+j*0.55+t*10;
    wc.globalAlpha=Math.max(0,fade)*(1-j*0.07); wc.fillStyle=(j%2)?'#c58cff':'#5a1aa0';
    wc.beginPath(); wc.arc(ct.x+Math.cos(a)*r,ct.y+2+Math.sin(a)*r*0.55,Math.max(0.6,2.8-j*0.2),0,6.2832); wc.fill();
  }
  wc.restore();
}
function drawContS(ct){
  var w,lift,d2,cF,cT;
  if(ct.mimicVoid!==undefined&&!ct.mimicVoidIn){ if(ct.mimicVoid>0) drawMimicVoid(ct); return; }   // v28.xx (cw-mimicaway): a spent mimic box is only its swirl, then nothing

'@

SubRx @'
var VER='28.99';
'@ @'
var VER='29.00';
'@

$pat = "(?m)^  now:'v28\.99:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.00: A mimic crawler comes out away from you, named MIMIC, and its box spins into the void. Check 29.00 fails on v28.99',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
