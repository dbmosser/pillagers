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

SubRx @'
    var _bleed=!!(G&&G.player&&(G.player.downed||G.player.hp<=0||(G.deathBeat||0)>0));
    var _h3=document.querySelector('#pausebox h3');
    if(_h3) _h3.textContent=_inRaid?(_bleed?'BLEEDING OUT':'RAID PAUSED'):'PAUSED';
    var _ab=document.getElementById('abandonbtn'), _ca=document.getElementById('confirmabandon');
    if(_ab) _ab.style.display=(_inRaid&&!_bleed)?'':'none';
    if(_ca&&(!_inRaid||_bleed)) _ca.style.display='none';
    var _bl=document.getElementById('pausebleed');
    if(_bl) _bl.style.display=(_inRaid&&_bleed)?'':'none';
'@ @'
    // v15.48, pause audit finding 8: WHILE THE SITE BURNS OR A DEATH PLAYS OUT, THE PAUSE BOX OFFERS NO ABANDON AND NO EXTRACT.
    // Once the clock runs out with no call made, G.nuking burns the site and the raid can only end in death, but tickNuke puts
    // him down only after 1.15 seconds of it. Paused in that first second this test read false, so the box offered Abandon run
    // and a certain timer death became an abandon that kept the armoury guns and counted no death, the very swap v9.37 closed for
    // the bleed-out. And over the death beat (hp 0, not downed) and later in the burn the box read BLEEDING OUT and said he can
    // extract while downed, when he is dead or burning and cannot. The burn now counts here, so Abandon run stays hidden for all
    // of it, and only a real downed player outside the burn is told he is bleeding out. No player text, no number and no seeded
    // draw moved.
    var _bleed=!!(G&&(G.nuking||(G.player&&(G.player.downed||G.player.hp<=0||(G.deathBeat||0)>0))));
    var _downNow=!!(_bleed&&!G.nuking&&G.player.downed);
    var _h3=document.querySelector('#pausebox h3');
    if(_h3) _h3.textContent=_inRaid?(_downNow?'BLEEDING OUT':'RAID PAUSED'):'PAUSED';
    var _ab=document.getElementById('abandonbtn'), _ca=document.getElementById('confirmabandon');
    if(_ab) _ab.style.display=(_inRaid&&!_bleed)?'':'none';
    if(_ca&&(!_inRaid||_bleed)) _ca.style.display='none';
    var _bl=document.getElementById('pausebleed');
    if(_bl) _bl.style.display=(_inRaid&&_downNow)?'':'none';
'@
SubRx @'
  if(G&&G.player&&(G.player.downed||G.player.hp<=0||(G.deathBeat||0)>0)){
    var _blq=document.getElementById('pausebleed');
    if(_blq) _blq.style.display='';
'@ @'
  // v15.48, pause audit finding 8: WHILE THE SITE BURNS OR A DEATH PLAYS OUT, THE PAUSE BOX OFFERS NO ABANDON AND NO EXTRACT.
  // This refused only a player already down, so a press in the first second of the burn armed the confirm. The burn refuses
  // here too, and the downed line comes up only for a real downed player outside the burn: over the death beat or the burn it
  // told a dead or burning man he can extract while downed.
  if(G&&(G.nuking||(G.player&&(G.player.downed||G.player.hp<=0||(G.deathBeat||0)>0)))){
    var _blq=document.getElementById('pausebleed');
    if(_blq&&!G.nuking&&G.player&&G.player.downed) _blq.style.display='';
'@
SubRx @'
var VER='15.47';
'@ @'
var VER='15.48';
'@

$pat = "(?m)^  now:'v15\.47:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.48: WHILE THE SITE BURNS OR A DEATH PLAYS OUT, THE PAUSE BOX OFFERS NO ABANDON AND NO EXTRACT. Paused in the first second of the burn after the clock ran out, the box offered Abandon run, which turned a certain timer death into an abandon that kept the armoury guns, and over the death beat or later in the burn it read BLEEDING OUT and said he can extract while downed. The burn now hides and refuses Abandon run, and only a real downed player outside the burn is told he is bleeding out. Check 15.48 pauses with P on his feet, downed, in the first frame of the burn, down in the burn and over the death beat, pressing Abandon run each time; it fails on v15.47',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
