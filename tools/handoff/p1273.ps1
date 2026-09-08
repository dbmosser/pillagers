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

# FROM THE 2026-09-08 FIRST-HOUR AUDIT, confirmed by a skeptic and then by me
# reading grantLoot and say end to end.
#
# say() holds exactly one line: it writes G.msg and a 3.2 second clock, and the
# last call in a frame is the only one anybody sees. grantLoot writes two lines
# inside its per-item loop, and both of them are about the thing that matters
# most in a pull, which gun is now in which hand:
#
#   "<gun> to your empty slot. <held> stays in hand, X swaps."
#   "<gun> equipped, +N% damage."
#
# Then, after the loop, it unconditionally writes "Found: <names>" over the top.
# That branch is guarded on keys.length, which is true whenever the loop ran at
# all, so the overwrite is not a rare collision: it happens every single time.
# Neither line has ever been readable.
#
# The cost is not decoration. On a brand new profile the second gun slot holds
# Bare Hands, so the first better gun a first-time player pulls out of a crate
# arms slot 2 and puts a live number key under his finger, and the only thing he
# is told is the name of what he found. He learns the slot exists by pressing 2
# by accident, if he ever does.
#
# THE FIX. The per-item line is kept rather than spoken, and the one line that
# does get spoken carries both facts. A single pull of one gun says the gun line
# by itself, because the summary would only repeat the name it already contains.
SubRx @'
        if(!G.sim){
          say(found.name+' to your empty slot. '+p.wep.name+' stays in hand, X swaps.');
          if(found.qRank>=2) blip('pickGun');
        }
'@ @'
        if(!G.sim){
          // v12.73: KEPT, not spoken. The summary below used to overwrite this
          // in the same frame, so it has never been readable.
          _gunLine=found.name+' to your empty slot. '+p.wep.name+' stays in hand, X swaps.';
          if(found.qRank>=2) blip('pickGun');
        }
'@

SubRx @'
        if(!G.sim){
          var cmp=oldDmg>0?Math.round((found.dmg*(found.pellets||1)/Math.max(1,oldDmg*(1))-1)*100):0;
          say(found.name+' equipped'+(cmp>0?', +'+cmp+'% damage':'')+'.');
'@ @'
        if(!G.sim){
          var cmp=oldDmg>0?Math.round((found.dmg*(found.pellets||1)/Math.max(1,oldDmg*(1))-1)*100):0;
          // v12.73: KEPT, not spoken, for the same reason as the empty slot line.
          _gunLine=found.name+' equipped'+(cmp>0?', +'+cmp+'% damage':'')+'.';
'@

SubRx @'
function grantLoot(ct,keys,delay0){
'@ @'
function grantLoot(ct,keys,delay0){
  // v12.73, 2026-09-08 first-hour audit: WHAT HAPPENED TO HIS GUNS SURVIVES THE
  // SUMMARY. say() holds one line and the last call in a frame wins, so the two
  // lines written inside the loop below, both of them about which gun is now in
  // which hand, were overwritten by the Found line every time the loop ran. On
  // a new profile the second slot holds Bare Hands, so the first good gun of a
  // first raid arms a number key and he was told only the name of the item.
  var _gunLine='';
'@

SubRx @'
    if(keys.length){
      say('Found: '+keys.map(function(k){return ITEMS[k].name;}).join(', '));
'@ @'
    if(keys.length){
      // v12.73: one line, both facts. A single gun says the gun line alone,
      // because the summary would only repeat the name it already carries.
      var _sum='Found: '+keys.map(function(k){return ITEMS[k].name;}).join(', ');
      say(_gunLine?((keys.length>1)?(_gunLine+' '+_sum):_gunLine):_sum);
'@

# NEW IN.
SubRx @'
  'YOUR RUN REPORT IS NAMED AFTER THIS GAME. The file the game saves to your Downloads still carried the old project name, which is the one place the rename was missed and the only one that leaves the browser. Reports you already have still load: they are read by their contents, not their name.',
'@ @'
  'YOUR RUN REPORT IS NAMED AFTER THIS GAME. The file the game saves to your Downloads still carried the old project name, which is the one place the rename was missed and the only one that leaves the browser. Reports you already have still load: they are read by their contents, not their name.',
  'THE GAME TELLS YOU WHEN A FOUND GUN CHANGES YOUR HANDS. A gun going into your empty second slot, or replacing the one you were holding, wrote you a line saying so and then wrote Found over the top of it in the same frame, every time. Both facts now arrive in the one line you can actually read.',
'@

# STAMPS.
SubRx @'
var VER='12.72';
'@ @'
var VER='12.73';
'@
SubRx @'
var WHATSNEW_VER='12.72';
'@ @'
var WHATSNEW_VER='12.73';
'@
$cnt=([regex]::Matches($s,"now:'v12\.72:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.72 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.72:[^']*'",{ param($m) "now:'v12.73: from the 2026-09-08 first-hour audit, confirmed by a skeptic and then by me reading grantLoot and say end to end. say holds exactly one line, writing a message and a 3.2 second clock, so the last call in a frame is the only one anybody sees. grantLoot writes two lines inside its per-item loop and both are about the thing that matters most in a pull, which gun is now in which hand: one for a gun going into an empty slot, naming the key that swaps, and one for a gun that replaced what he was holding, with the damage difference. Then, after the loop, it writes Found over the top of them. That branch is guarded on the key list being non-empty, which is true whenever the loop ran at all, so this is not a rare collision, it happens every single time and neither line has ever been readable. The cost is not decoration: on a brand new profile the second gun slot holds Bare Hands, so the first better gun a first-time player pulls out of a crate arms slot 2 and puts a live number key under his finger, and the only thing he is told is the name of the item he found. He learns the slot exists by pressing 2 by accident. The per-item line is kept rather than spoken now, and the one line that is spoken carries both facts; a single pull of one gun says the gun line by itself, because the summary would only repeat the name it already contains. Check 12.73 pulls a gun that arms the empty slot and requires the line he is left with to name the swap key, pulls a gun alongside other items and requires the line to carry both the gun and the list, and controls that a pull with no gun in it still says exactly what it always said; fails on v12.72.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
