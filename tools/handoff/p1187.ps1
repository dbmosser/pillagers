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

# HIS NOTE, 2026-09-06 (his 06:39 export, run 5, @118s): "survivor should
# move towards closest extract, not follow player". His earlier note had him
# follow you to extraction and help; the later order stands. A helped
# survivor walks to the nearest open extraction on his own, still shooting
# at machines on the way, and when he reaches the ring he is gone: parked
# off the map with a flag rather than removed, so no index shifts under the
# loop and no count changes.
SubRx @'
if(e.kind==='stray'){
      var sdd=dist(e,p);
'@ @'
if(e.kind==='stray'){
      if(e.gone) continue;   // v11.87: he reached an extraction and left
      var sdd=dist(e,p);
'@
SubRx @'
      if(!G.sim&&e.helped&&!e.downed){
        // HIS NOTE: "Survivor should follow you to extract and help you."
        if(sdd>150){ navSeek(e,p.x,p.y,120,dt); e.moving=true; }
        else e.moving=false;
'@ @'
      if(!G.sim&&e.helped&&!e.downed){
        // HIS NOTE of 2026-08: "Survivor should follow you to extract and help
        // you." HIS NOTE of 2026-09-06: "survivor should move towards closest
        // extract, not follow player". The later order stands: he walks to the
        // nearest open ring on his own, shooting at machines on the way (below),
        // and leaves when he reaches it.
        var _sz=null,_szd=1e9;
        for(var _zq=0;_zq<G.zones.length;_zq++){ var _zz=G.zones[_zq]; if(!_zz.open) continue; var _zd=dist(e,_zz); if(_zd<_szd){ _szd=_zd; _sz=_zz; } }
        if(_sz&&_szd>_sz.r*0.9){ navSeek(e,_sz.x,_sz.y,120,dt); e.moving=true; }
        else if(_sz){
          e.moving=false; e.gone=1; e.x=-9000; e.y=-9000;
          say('The survivor made it to Extraction '+extLetter(_sz)+'.');
          if(G.tel) G.tel.strayOut=(G.tel.strayOut||0)+1;
          continue;
        }
        else e.moving=false;
'@

# STAMPS.
SubRx @'
var VER='11.86';
'@ @'
var VER='11.87';
'@
SubRx @'
var WHATSNEW_VER='11.86';
'@ @'
var WHATSNEW_VER='11.87';
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'A HELPED SURVIVOR WALKS TO THE NEAREST OPEN EXTRACTION on his own and leaves when he reaches it, instead of following you.',
'@
$cnt=([regex]::Matches($s,"now:'v11\.86:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v11.86 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v11\.86:[^']*'",{ param($m) "now:'v11.87: HIS NOTE of 2026-09-06, the survivor should move towards the closest extraction, not follow the player; reverses his earlier follow-me note. A helped survivor walks to the nearest open ring at his old speed, still shooting at machines on the way, and when he reaches it he leaves (parked off the map with a gone flag, not spliced). Check 11.87 stages a helped survivor near a ring with the player far away, steps the real entity update, and requires him to reach the ring and leave while his distance to the player never falls; fails on v11.86 where he walks to the player.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
