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

# A SIEGE MACHINE FOR A RING PLAYER 2 CALLED NO LONGER DROPS RIGHT BESIDE PLAYER 2 (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    do{ ss2=freeSpot(G.map,30); st2++; }while(dist(ss2,p)<700&&st2<40);
    if(dist(ss2,p)>=700){
'@ @'
    // v17.32, co-op hunt 2026-09-28: in co-op the arrival keeps 700 clear of every player up top, as the pillager waves do (v15.80),
    // not of the host player alone, so a ring player 2 called never drops a machine on top of him. Solo measures as it always did.
    var _sd=function(q){ return NET.on?netNearDist(q):dist(q,p); };
    do{ ss2=freeSpot(G.map,30); st2++; }while(_sd(ss2)<700&&st2<40);
    if(_sd(ss2)>=700){
'@

SubRx @'
var VER='17.31';
'@ @'
var VER='17.32';
'@

$pat = "(?m)^  now:'v17\.31:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.32: Siege placement, co-op hunt 2026-09-28: tickExtractPoints runs on the host and placed each siege arrival with dist(spot,G.player)>=700, which is the host player only. The raider wave spawn has measured from every player since v15.80 (netNearDist), but the siege loop did not, so on a ring player 2 called with player 1 far away the first freeSpot draw was taken even when it sat a few dozen units from player 2, and the arrival (alert 3, investigate toward the ring, and netTargetFor picks the nearest standing player) went straight at him. The placement loop and its accept test now measure with netNearDist when a party is on, which counts the host player unless he is spectating and every teammate shown up top. With the party off the test is the old dist to the player, so solo play and its seeded stream are unchanged. No number moved. Check 17.32 fails on v17.31',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
