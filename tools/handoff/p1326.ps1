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

# HIS REWRITE OF THE SECTOR LINE REACHED ONLY HIM, and one of the two maps.
#
# He baked two edits of the map screen fact line: keep the run count, size, zones
# and keyed rooms, say the test robot extract rate is for THAT map, and drop first
# contact, containers a raid and median haul. Baked edits match the WHOLE rendered
# sentence, and this sentence carries the player run count and the live robot
# figures. His keys held his own counts at the time: "you: 2 runs here" on COLD
# STORAGE and "YOU HAVE NEVER RAIDED HERE" on THE COLD MILE.
#
# MEASURED ON A FRESH PROFILE, after the text engine had run: THE COLD MILE shows
# his wording only because a new player also has never raided it, and COLD
# STORAGE shows the long line he cut. The moment a friend raids THE COLD MILE once,
# or the robot figures are re-measured, that map reverts too. v11.51 made these two
# lines exact-only on purpose, because matching by digit shape printed the wrong
# map name, so the text engine cannot be the fix.
#
# SO THE GAME NOW BUILDS HIS SENTENCE. Every player sees it with their own count.
# The measured figures stay in SECTOR_MEAS for the checks that read them; they are
# only no longer printed.
#
# ONE WORD CHOSEN FOR HIM, AND IT IS FLAGGED: his COLD STORAGE edit reads "extracts
# in 39.2% of its raids in Cold Storage" and his COLD MILE edit reads "extracts
# 38.3% of its raids in The Cold Mile". One generated sentence cannot be both, and
# the second reads as intended, so that is the form used.
SubRx @'
function renderSector(){
'@ @'
// v13.26: the map name the way he wrote it in the sector line, Cold Storage and The
// Cold Mile, from the upper-case name the heading uses.
function sectorTitle(n){ return String(n||'').toLowerCase().replace(/\b[a-z]/g,function(c){ return c.toUpperCase(); }); }
function renderSector(){
'@

SubRx @'
    if(MS.ext!==undefined) facts.push('the test robot extracts '+MS.ext+'% of its raids here');
    if(MS.fc!==undefined)  facts.push('first contact ~'+MS.fc+'s');
    if(MS.cont!==undefined)facts.push(MS.cont+' containers a raid');
    if(MS.haul!==undefined)facts.push('median haul '+'$'+MS.haul.toLocaleString()+'');
'@ @'
    // v13.26, HIS WORDING FOR EVERY PLAYER: his baked edits of this line matched
    // only his own run counts, so a new player saw the long version he cut on one
    // map and his on the other. The figures he dropped stay in SECTOR_MEAS.
    if(MS.ext!==undefined) facts.push('the test robot extracts '+MS.ext+'% of its raids in '+sectorTitle(M.name)+'.');
'@

SubRx @'
var VER='13.25';
'@ @'
var VER='13.26';
'@

$pat = "(?m)^  now:'v13\.25:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.26: HIS REWRITE OF THE SECTOR LINE REACHED ONLY HIM, AND ONLY ONE MAP. He baked two edits of the map screen fact line: keep the run count, size, zones and keyed rooms, say the test robot extract rate is for that map, and drop first contact, containers a raid and median haul. Baked edits match the whole rendered sentence, and this one carries the player run count and the live robot figures, and his keys held his own counts at the time, two runs on Cold Storage and never raided on The Cold Mile. Measured on a fresh profile after the text engine had run: The Cold Mile showed his wording only because a new player has never raided it either, and Cold Storage showed the long line he cut; the moment a friend raids The Cold Mile once, or the robot figures are re-measured, that map reverts too. v11.51 made these lines exact-only on purpose, because matching by digit shape printed the wrong map name, so the text engine could not be the fix. The game now builds his sentence itself, so every player sees it with their own count; the dropped figures stay in SECTOR_MEAS for the checks that read them. One word was chosen for him and is flagged: his Cold Storage edit reads extracts in 39.2 percent of its raids in Cold Storage, his Cold Mile edit reads extracts 38.3 percent of its raids in The Cold Mile, one generated sentence cannot be both, and the second reads as intended. Check 11.29 required first contact on the screen for both maps, the display his wording retired, and is repaired in the same build. Check 13.26 draws the map screen for a player who has never raided and for one with a run on each map, requires his wording on both maps and none of the three cut figures, and fails on v13.25',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
