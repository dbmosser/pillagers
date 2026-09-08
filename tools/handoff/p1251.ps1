$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# FROM THE 2026-09-07 READ-ONLY AUDIT (P2), specced from the source.
#
# ONE REPORT BECAME A BARRAGE. A Howler that hears a noise writes the bearing
# down, keeps it for eight seconds and mails a shell to it. The shell lands two
# seconds later and its own impact is a noise of 480, which every listening
# machine on the map hears, including the Howler that fired it: the bearing is
# overwritten with the crater and the eight seconds are wound back to full. Its
# cooldown then runs out with the clock still going, so it shells its own crater,
# and that impact winds it up again. The man made ONE sound and went quiet,
# which is the whole counterplay, and was shelled two to four more times at the
# spot he was heard.
#
# The shell now carries the machine that fired it, and that machine does not
# take its own crater for a fresh report. Everything else on the map still hears
# the impact exactly as before, which is what pulls the room to a burst, and the
# firing Howler still walks to it as it always did.
SubRx @'
          G.shells.push({mortar:1,x0:e.x,y0:e.y,
            tx:e.heardX+rnd(-_hs2,_hs2),ty:e.heardY+rnd(-_hs2,_hs2),
'@ @'
          G.shells.push({mortar:1,x0:e.x,y0:e.y,by:e,   // v12.51: whose shell this is
            tx:e.heardX+rnd(-_hs2,_hs2),ty:e.heardY+rnd(-_hs2,_hs2),
'@

SubRx @'
          G.shells.push({mortar:1,x0:e.x,y0:e.y,tx:_htx+rnd(-_hsc,_hsc),ty:_hty+rnd(-_hsc,_hsc),
'@ @'
          G.shells.push({mortar:1,x0:e.x,y0:e.y,by:e,tx:_htx+rnd(-_hsc,_hsc),ty:_hty+rnd(-_hsc,_hsc),   // v12.51: whose shell this is
'@

SubRx @'
  ping(SH.tx,SH.ty,480,false,false,'robot','fire');
'@ @'
  // v12.51, 2026-09-07 audit: A HOWLER IS DEAF TO ITS OWN GUN. Everything it
  // does is a noise every listening machine hears, which is right and is what
  // pulls a room to a burst; but the machine that made the noise heard it too.
  // The round leaving the tube wrote its own position down as the bearing, and
  // the hole the round made overwrote that with the crater and wound its eight
  // second clock back to full, so when the cooldown ran out it shelled its own
  // last position or its own crater, and that shot did it again. One report
  // became a barrage, every shell after the first landing on a man who had gone
  // quiet, which is the counterplay this machine is built around. Only the three
  // fields the hearing sweep writes are put back, and only for the machine that
  // made the noise: everything else on the map hears all of it exactly as
  // before, and the firing Howler is still turned toward the crater by the same
  // noise, which is what used to end the barrage on its own.
  howlerDeaf(SH.by,function(){ ping(SH.tx,SH.ty,480,false,false,'robot','fire'); });
'@

# AND THE SECOND CAUSE, FOUND BY RUNNING THE CHECK: the mortar cooldown lives in
# the SAME field the idle wander uses as its retarget timer, and the wander zeroes
# that field every frame a machine is standing on its own patrol point. So a
# Howler at rest with a live bearing fired EVERY FRAME, not once every five or
# six seconds. This is exactly the collision v12.30 found on the crawler and
# split there; the Howler was the other machine with the same wound.
SubRx @'
        if(_hd<e.rng&&_hd>140&&!mortarRoofed(e,e.heardX,e.heardY)){   // v12.00: not through a roof
'@ @'
        if(_hd<e.rng&&_hd>140&&!mortarRoofed(e,e.heardX,e.heardY)&&!(e.mortT>0)){   // v12.00: not through a roof. v12.51: and its own cooldown, not the wander clock
'@

SubRx @'
          e.cd=5.4+rnd(0,1.8);
'@ @'
          e.mortT=5.4+rnd(0,1.8);   // v12.51: the gun cooling, in a field the wander cannot wipe
'@

SubRx @'
        if(e.cd<=0&&d<e.rng&&d>140&&!p.downed&&(_hSee||e.alert>1.2)&&!mortarRoofed(e,_htx,_hty)){   // v12.00: not through a roof
'@ @'
        if(!(e.mortT>0)&&d<e.rng&&d>140&&!p.downed&&(_hSee||e.alert>1.2)&&!mortarRoofed(e,_htx,_hty)){   // v12.00: not through a roof. v12.51: its own cooldown, not the wander clock
'@

SubRx @'
          e.cd=4.2+rnd(0,1.6);
'@ @'
          e.mortT=4.2+rnd(0,1.6);   // v12.51: the gun cooling, in a field the wander cannot wipe
'@

SubRx @'
    if(e.wanderT>0) e.wanderT-=dt;   // v12.30: the wander clock, its own field on a crawler
'@ @'
    if(e.wanderT>0) e.wanderT-=dt;   // v12.30: the wander clock, its own field on a crawler
    if(e.mortT>0) e.mortT-=dt;       // v12.51: the mortar cooling, its own field on a Howler
'@

SubRx @'
function howlerImpact(SH){
'@ @'
// v12.51, 2026-09-07 audit: DEAF TO ITS OWN GUN. A Howler writes down the
// bearing of any noise it hears and keeps it for eight seconds. Both the noises
// it makes itself reached it through that same door: the round leaving the tube,
// and the hole the round makes. So it wrote down its own position, walked, and
// then shelled where it had been standing; or wrote down its own crater and
// shelled that. Either way one report from the man became a barrage after he had
// gone quiet. Everything else on the map still hears all of it, which is the
// point of those noises; the machine that made one simply does not take it as a
// fresh report about somebody else.
function howlerDeaf(e,fn){
  if(!e||e.kind!=='howler'){ fn(); return; }
  var _t=e.hearT, _x=e.heardX, _y=e.heardY;
  fn();
  e.hearT=_t; e.heardX=_x; e.heardY=_y;
}
function howlerImpact(SH){
'@

SubRx @'
          e.alert=3;
          ping(e.x,e.y,620,false,false,'robot','fire',e);
'@ @'
          e.alert=3;
          howlerDeaf(e,function(){ ping(e.x,e.y,620,false,false,'robot','fire',e); });   // v12.51: it does not hear its own gun
'@

SubRx @'
          e.alert=2.0;
          ping(e.x,e.y,620,false,false,'robot','fire',e);
'@ @'
          e.alert=2.0;
          howlerDeaf(e,function(){ ping(e.x,e.y,620,false,false,'robot','fire',e); });   // v12.51: it does not hear its own gun
'@

# NEW IN.
SubRx @'
  'BREAKING A CRIER LINE OF SIGHT NOW ACTUALLY CANCELS ITS ALARM. The cancel cleared the windup and then fired the alarm on the very same frame, so hiding never once called one off. The three seconds have to be unbroken now, which they always claimed to be.',
'@ @'
  'BREAKING A CRIER LINE OF SIGHT NOW ACTUALLY CANCELS ITS ALARM. The cancel cleared the windup and then fired the alarm on the very same frame, so hiding never once called one off. The three seconds have to be unbroken now, which they always claimed to be.',
  'A HOWLER IS DEAF TO ITS OWN GUN. It heard the round leave its own tube and the hole that round made, took both for fresh reports about you, and shelled where it had been standing or the crater it had just dug. One noise from you became a barrage after you had gone quiet.',
'@

# STAMPS.
SubRx @'
var VER='12.50';
'@ @'
var VER='12.51';
'@
SubRx @'
var WHATSNEW_VER='12.50';
'@ @'
var WHATSNEW_VER='12.51';
'@
$cnt=([regex]::Matches($s,"now:'v12\.50:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.50 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.50:[^']*'",{ param($m) "now:'v12.51: 2026-09-07 audit (P2). One report became a barrage. A Howler that hears a noise writes the bearing down, keeps it for eight seconds and mails a shell to it. The shell lands two seconds later and its own impact is a noise of 480 that every listening machine on the map hears, including the Howler that fired it: the bearing was overwritten with the crater and the eight seconds wound back to full, so when its cooldown ran out it shelled its own crater, and that impact wound it up again. The man made ONE sound and went quiet, which is the whole counterplay the Listener and the Howler are built around, and was shelled two to four more times at the spot he was heard. Both noises it makes itself reached it through the same door, the round leaving the tube and the hole the round makes, so it wrote down its own position, walked, and shelled where it had been standing, or wrote down its own crater and shelled that. Each shell now carries the machine that fired it and a Howler is deaf to its own gun: only the three fields the hearing sweep writes are put back, and only for the machine that made the noise, so everything else on the map still hears all of it exactly as before and the firing Howler is still turned toward the crater by the same noise. Check 12.51 puts one Howler alone on an empty map four hundred units from a single staged noise, points it away so it cannot see him, and steps twenty seconds of raid with the man silent: after the first impact the eight second clock must have DECAYED rather than been wound back, the bearing must still be the noise and not the crater, and the shell count must be at most the two that the eight second bearing and the five to seven second cooldown honestly allow; fails on v12.50.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
