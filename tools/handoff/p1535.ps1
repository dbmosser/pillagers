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
  if(e.button===2){ if(G&&!G.over) G.player.ads=true; return; }
  // v8.96: on the Undercroft floor the same two handlers below run against the
'@ @'
  // v15.35, peddler audit finding 7: A MOUSE CLICK ON THE OPEN STALL NEVER FIRES THE GUN BEHIND IT. The stall panel is only
  // drawn; its rows answer the number keys and pad A. Nothing here claimed a left click on it the way the map, the backpack
  // and the HUD panels claim theirs (the v3.64 rule), so the click fell through to the trigger, and the fire and cook code in
  // updatePlayer runs before the stall's own early return. The gun fired toward the cursor through the panel: a round spent,
  // noise made, a selected Frag Charge cooked, and a round on his side hit the Peddler, who bolts and shuts the stall (held on
  // an automatic, it killed him for a point of Notoriety). The F strike and pad A were already blocked here. The map above
  // still comes first, a right click still only aims, a click on a belt cell no longer changes the selection behind the panel
  // (as on the pad), and the canvas click listener still wakes the audio.
  if(e.button===0&&G&&!G.over&&G.trade) return;
  if(e.button===2){ if(G&&!G.over) G.player.ads=true; return; }
  // v8.96: on the Undercroft floor the same two handlers below run against the
'@
SubRx @'
    // v8.28: the stall never closes now, so this refusal cannot fire. Left as
    // the one place that would speak if pedOpen ever means something again.
    if(!pedOpen()) say('He has heard what you did to the last one. No deal.');
    else { G.trade=ped; blip('pick'); }
'@ @'
    // v8.28: the stall never closes now, so this refusal cannot fire. Left as
    // the one place that would speak if pedOpen ever means something again.
    // v15.35, peddler audit finding 7: AND A TRIGGER HELD INTO THE STALL LETS GO. A mouse button held while E opened the stall
    // left mouse.down set, and the fire and cook code above runs every frame before the stall's return below, so an automatic
    // kept firing through its magazine behind the panel. The stall lets go of it the way padRelease lets go of pad A (v14.20):
    // the next frame ends the hold, and a grenade being cooked is thrown rather than left to cook off in his hand.
    if(!pedOpen()) say('He has heard what you did to the last one. No deal.');
    else { G.trade=ped; mouse.down=false; blip('pick'); }
'@
SubRx @'
var VER='15.34';
'@ @'
var VER='15.35';
'@

$pat = "(?m)^  now:'v15\.34:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.35: A MOUSE CLICK ON THE OPEN STALL NEVER FIRES THE GUN BEHIND IT. The Peddler stall panel never claimed a left click the way the map, the backpack and the HUD panels do, so a click on it fired the gun toward the cursor, spent a round and could hit the Peddler, and a trigger held while the stall opened kept an automatic firing behind it. A left click on the open stall now does nothing, and opening the stall lets go of the trigger. Check 15.35 clicks the open stall with the Scav Pistol and holds a Compact SMG trigger into it; it fails on v15.34',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
