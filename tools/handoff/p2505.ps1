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

# CAREER RAIDS: THE 10 MINUTE CLOCK (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(ARCADE&&ARCADE.on&&G&&!G.sim) arcadePostBuild(G);
'@ @'
  if(ARCADE&&ARCADE.on&&G&&!G.sim) arcadePostBuild(G);
  else if(G&&!G.sim&&CAREER_ON) careerPostBuild(G);   // v24.xx (feat0h1): every other raid from the Undercroft is a CAREER raid
'@

SubRx @'
// Run from startRaid right after the build, in every window that builds the arcade raid
'@ @'
// v24.xx (feat0h1), HIS MODE DESIGN (2026-10-12): "CAREER - Arcade mode but with the Undercroft ... 10 minute raids ... has all the
// other career/undercroft features we've already created", and his rule "GAMEPLAY ELEMENTS ... SHOULD BE EXACTLY THE SAME IN DEMO AND
// CAREER". A CAREER RAID. Every raid he takes up from the Undercroft (not the DEMO, not the bot) now runs on the DEMO clock: 10
// minutes (it was 9), and the rings never close early, so the clock and the burn at 0 are the pressure, as in the DEMO. The raid
// carries G.career and its own score store G.cs, which the kill score, the waves and the payout build on. His own kit from the stash,
// full enemy damage and coming back empty after a death are the career rules and stay. Nothing is drawn from the seeded stream, so
// a seed builds the same raid, and a co-op partner builds the same one in startRaid. CAREER_ON 0 gives the old raid (the test fixture
// pins it, as it pins GO_SEC).
var CAREER_ON=1, CAREER_RAID_SEC=600;
function careerPostBuild(g){
  if(!g||g.sim||g.arcade) return false;
  var i;
  g.career=1; g.raidLen=g.timeLeft=CAREER_RAID_SEC;
  for(i=0;i<(g.zones||[]).length;i++) g.zones[i].closeAt=undefined;
  g.cs={s:0,k:0,streak:null,waveT:0,waveN:0};
  return true;
}
// Run from startRaid right after the build, in every window that builds the arcade raid
'@

SubRx @'
var VER='25.04';
'@ @'
var VER='25.05';
'@

$pat = "(?m)^  now:'v25\.04:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v25.05: Raids from the Undercroft are CAREER raids: 10 minutes, and the rings stay open until the clock runs out. Check 25.05 fails on v25.04',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
