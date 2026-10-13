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

# SIEGE INCOMING NAMES NO COUNT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
callouts: SIEGE INCOMING with About N machines inbound, a closing ring
'@ @'
callouts: SIEGE INCOMING (no count since v25.62), a closing ring
'@

SubRx @'
      // v9.34, HIS 6: THE SIEGE, NAMED, AND HOW BIG IT WILL BE.
      // The count is the same expression tickExtractPoints uses, so what he is
      // promised here and what actually walks in cannot drift apart. Rounded to
      // "about", because arrivals stop when the ship lands and a precise figure
      // he does not always see would read as a lie.
      // The ceiling, which is what the tick will refuse to go past...
      var _scap=Math.round(siegeBase(_g)*(CFG.siegeVol===undefined?1:CFG.siegeVol));   // v18.35: the one siege size
      // ...and how many the wait actually has room for, one every siegeIv
      // seconds. This is the smaller of the two in every configuration the game
      // ships with, and it is the one he will count. A long hold at the ring can
      // bring more, up to the ceiling, which is why the line says "about".
      // v9.85: THE RATE MOVES WITH THE DIAL TOO. siegeVol only raised the
      // ceiling, and the ceiling is not what limits a siege; this interval is. On
      // v9.84 Heavy delivered 6 and 15 machines against Standard 6 and 14, so the
      // loudest option on the row was worth one machine or none. Divided here and
      // at the tick by the same dial, so the promise and the arrivals stay in
      // step, and Standard divides by 1 and does not move.
      var _siv=(8-4.6*_g)/(CFG.siegeVol===undefined?1:CFG.siegeVol);
      var _sc=Math.max(1,Math.min(_scap,Math.floor(CFG.extractWait/Math.max(0.1,_siv))));
'@ @'
      // v25.62, HIS ORDER (2026-10-12): "Siege Incoming -- don't tell how many machines are inbound!" SIEGE INCOMING NAMES NO COUNT.
      // v9.34 (his 6) named the siege and promised its size, About N machines inbound, with N worked out here from the same ceiling
      // (siegeBase by greed and the siegeVol dial) and the same rate (one every siegeIv seconds over the wait) as tickExtractPoints.
      // The line was the only reader of that figure, so it is gone with the detail. The siege itself is unchanged: the tick still
      // sizes it by greed and the dial, and brings them in at the same rate. Nothing here drew from the seeded stream.
'@

SubRx @'
then THE SIEGE with how many are coming, then
'@ @'
then SIEGE INCOMING (no count since v25.62), then
'@

SubRx @'
so only the one inbound figure is in a detail. The count is the same _sc as before.
'@ @'
so only the one inbound figure is in a detail.
'@

SubRx @'
say('SIEGE INCOMING','warn',{key:'siege',sub:'About '+_sc+(_sc===1?' machine':' machines')+' inbound'});
'@ @'
say('SIEGE INCOMING','warn',{key:'siege'});   // v25.62, his order (2026-10-12): no count
'@

SubRx @'
var VER='25.61';
'@ @'
var VER='25.62';
'@

$pat = "(?m)^  now:'v25\.61:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v25.62: SIEGE INCOMING no longer says how many machines are coming. Check 25.62 fails on v25.61',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
