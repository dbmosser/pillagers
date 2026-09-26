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

# THE EMOTE BAR CLOSES WHEN HE GOES DOWN AND ITS KEYS SAY WHY WHILE HE IS DOWN. The going-down block in damagePlayer shut
# the map and the backpack and never touched G.emoteBar, the V toggle in raidKey had no downed test, and doEmote returned
# on the floor or in a roll with nothing said.
SubRx @'
    G.mapOpen=false; G.bagOpen=false; G.drag=null;   // v14.07, HUD audit: nothing covers the downed screen
'@ @'
    G.mapOpen=false; G.bagOpen=false; G.drag=null;   // v14.07, HUD audit: nothing covers the downed screen
    // v15.85, trade audit finding: THE EMOTE BAR CLOSES WHEN HE GOES DOWN AND ITS KEYS SAY WHY WHILE HE IS DOWN. The line
    // above shuts the map and the backpack so that nothing covers the downed screen, and the emote bar was missed: V opens it
    // (say, to hail a pillager at range), a shot puts him on the floor, and drawHUD draws the bar after the red downed wash
    // with no downed test of its own, so HAIL, STAND DOWN, POINT and THANKS sat over the bleed-out under the caption weapon
    // down, they will listen, while 1 to 4 went to doEmote, which returns on the floor. Shut here with the other panels; the
    // first standing V after a revive opens it again. No number, no player text and no seeded draw moved.
    G.emoteBar=false;
'@
SubRx @'
  if(code==='KeyV'&&G&&!G.over&&!G.paused&&!G.trade&&!repeat){
    if(ev) ev.preventDefault();
    G.emoteBar=!G.emoteBar;
    return;
  }
'@ @'
  // v15.85, trade audit finding: THE EMOTE BAR CLOSES WHEN HE GOES DOWN AND ITS KEYS SAY WHY WHILE HE IS DOWN. This toggle
  // had no downed test, unlike the backpack rule below (v14.57), so V on the floor opened the bar over the downed screen, and
  // 1 to 4 then went to doEmote, which returned on the floor with nothing said. Down or in the death fade V opens nothing;
  // down, it says so, in the words the belt already uses from the floor (useHot). Closing is untouched: the emote bar block
  // above still shuts an open bar on V, ESC or TAB before this line runs. No number and no seeded draw moved.
  if(code==='KeyV'&&G&&!G.over&&!G.paused&&!G.trade&&!repeat&&!(G.player&&(G.player.downed||G.player.dying))){
    if(ev) ev.preventDefault();
    G.emoteBar=!G.emoteBar;
    return;
  }
  if(code==='KeyV'&&G&&!G.over&&!G.paused&&!G.trade&&!repeat&&G.player&&G.player.downed&&!G.player.dying){ if(ev) ev.preventDefault(); say('Not while you are down.'); return; }
'@
SubRx @'
  var p=G.player;
  if(p.downed||p.roll>0) return;
  if((G.emoteCd||0)>0) return;
'@ @'
  var p=G.player;
  // v15.85, trade audit finding: THE EMOTE BAR CLOSES WHEN HE GOES DOWN AND ITS KEYS SAY WHY WHILE HE IS DOWN. A digit that
  // reached here on the floor or in a roll returned with nothing said, so a working key read as a broken one (his v13.19
  // report on the silent roll). Down, it says the line the belt uses from the floor; in a roll, the same shape. The bar
  // stays up for the press after the roll. The cooldown below stays silent: it is under a second after an emote he just
  // watched. No number and no seeded draw moved.
  if(p.downed){ say('Not while you are down.'); return; }
  if(p.roll>0){ say('Not while you are rolling.'); return; }
  if((G.emoteCd||0)>0) return;
'@
SubRx @'
var VER='15.84';
'@ @'
var VER='15.85';
'@

$pat = "(?m)^  now:'v15\.84:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.85: THE EMOTE BAR CLOSES WHEN HE GOES DOWN AND ITS KEYS SAY WHY WHILE HE IS DOWN. Shot down with the emote bar up, the bar stayed drawn over the downed screen with its caption and its four boxes, V opened it again while he was down, and 1 to 4 did nothing and said nothing. Going down now shuts the bar with the map and the backpack, V while he is down opens nothing and says Not while you are down, and a digit pressed on the bar in a roll says so too. Check 15.85 opens the bar, shoots him down and presses V on the floor, then presses a digit on the bar in a roll; it fails on v15.84',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
