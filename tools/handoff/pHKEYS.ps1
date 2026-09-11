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

# HIS NOTE, after a live round: "if I press H to look at the full keys, it is a
# mess. Do not need all the tips, just give the keys only."
#
# The panel is two columns. The left one is the key list, which is what he
# pressed H for. The right one is a column of gear rules and a colour key for the
# sound visualiser, neither of which is a key binding, and together they are
# taller than the keys are: the panel was sized on whichever column was bigger,
# so the tips were setting the size of the thing he opened to read the keys.
#
# Both tip blocks go. The key list stays exactly as it is, the panel is sized on
# the keys alone, and it gets narrower with the right column gone.
#
# NOTHING IS DELETED FROM THE GAME, only from this panel: GEARRULES and SOUNDKEY
# are still declared and still read by the hub legend, so the rules and the sound
# colours have not been lost, they are simply not in the way of his key list.
SubRx @'
  var _hR=GEARRULES.length*LH(11)+SOUNDKEY.length*LH(10)+LH(30);
'@ @'
  // v12.79, HIS NOTE: THE KEY PANEL IS KEYS. The right column held gear rules
  // and a sound colour key, neither of them a key binding, and it was taller
  // than the key list, so the tips decided how big the panel he opened to read
  // the keys would be. The column is gone and the panel is sized on the keys.
  var _hR=0;
'@

SubRx @'
cy=_cy2;
  for(i=0;i<GEARRULES.length;i++){
    var gr=GEARRULES[i];
    if(gr[0]){
      ctx.font=FS(TYPE.micro); ctx.fillStyle='#7fc4a0';
      ctx.fillText(typeof gr[0]==='function'?gr[0]():gr[0],_cx2,cy);
    }
    ctx.font=FS(TYPE.micro); ctx.fillStyle='#8a96a1';
    // a rule may be a function when its wording depends on the input device
    ctx.fillText(typeof gr[1]==='function'?gr[1]():gr[1],_cx2+(gr[0]?LH(68):LH(6)),cy);
    cy+=LH(11);
  }
  // sound key: the visualizer's colour language, stated so it can be learned
  cy+=LH(4);
  ctx.font=FS(TYPE.micro); ctx.fillStyle='#7fc4a0';
  ctx.fillText('SOUND',_cx2,cy); cy+=LH(11);
  for(i=0;i<SOUNDKEY.length;i++){
    ctx.fillStyle=SOUNDKEY[i][0];
    ctx.fillRect(_cx2+LH(4),cy-LH(6),LH(8),LH(6));
    ctx.font=FS(TYPE.micro); ctx.fillStyle='#8a96a1';
    ctx.fillText(SOUNDKEY[i][1],_cx2+LH(18),cy);
    cy+=LH(10);
  }
'@ @'
  // v12.79, HIS NOTE: the gear rules and the sound colour key used to be drawn
  // here, in a second column beside the keys. He opened this to read the keys
  // and got a wall of prose instead. Both are still declared and still read
  // elsewhere; they are simply no longer in front of him when he presses H.
'@

SubRx @'
      var _fBox=Math.max(_fRows*LH(12),GEARRULES.length*LH(11)+SOUNDKEY.length*LH(10)+LH(30))+LH(26);
'@ @'
      var _fBox=_fRows*LH(12)+LH(26);   // v12.79: sized on the keys, nothing else
'@

# NEW IN.
SubRx @'
  'A GUN YOU CHOSE IS NOT SWAPPED OUT BEHIND YOUR BACK. A pickup used to replace the weapon in your hands whenever the game judged it a step up. Only an empty slot, Bare Hands or the Scav Pistol yields now; with two real guns on you, the find goes to the backpack and equipping it is your call.',
'@ @'
  'A GUN YOU CHOSE IS NOT SWAPPED OUT BEHIND YOUR BACK. A pickup used to replace the weapon in your hands whenever the game judged it a step up. Only an empty slot, Bare Hands or the Scav Pistol yields now; with two real guns on you, the find goes to the backpack and equipping it is your call.',
  'H IS THE KEY LIST AND NOTHING ELSE. It used to open with a second column of gear rules and a sound colour key beside the keys, taller than the keys themselves, so the tips were setting the size of the panel you opened to read the bindings.',
'@

# STAMPS.
SubRx @'
var VER='12.78';
'@ @'
var VER='12.79';
'@
SubRx @'
var WHATSNEW_VER='12.78';
'@ @'
var WHATSNEW_VER='12.79';
'@
$cnt=([regex]::Matches($s,"now:'v12\.78:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.78 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.78:[^']*'",{ param($m) "now:'v12.79: HIS NOTE after a live round, that pressing H to look at the full keys is a mess and he does not need all the tips, just the keys. The panel is two columns: the left one is the key list, which is what he pressed H for, and the right one is a column of gear rules plus a colour key for the sound visualiser, neither of them a key binding. Together they were TALLER than the key list, and the panel was sized on whichever column was bigger, so the tips were deciding how large the thing he opened to read his keys would be. Both tip blocks are gone from this panel. The key list is untouched, the panel is sized on the keys alone, and it is narrower with the right column removed. Nothing is deleted from the game: GEARRULES and SOUNDKEY are still declared and still read by the hub legend, so the rules and the sound colours are not lost, they are simply no longer in the way. Check 12.79 opens the full panel in a real raid and reads the text the frame actually writes: every key row must still be drawn, and no gear rule and no sound colour label may be, with a control that the compact corner legend is unchanged; fails on v12.78.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
