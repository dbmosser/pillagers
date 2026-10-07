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

# THE UNDERCROFT HUD READS ON ANY WALL (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var HUBBELT={cells:[]};
'@ @'
var HUBBELT={cells:[]};
// v18.62, seen on the Undercroft screenshot (2026-10-07): the footer (WASD WALK, E USE STATION) sat at the bottom edge, behind the
// belt the floor draws there since v18.0x, so only scraps of it showed between the cells. It now sits just above the belt when
// the belt is shown, and at the bottom edge as before when it is not.
function hubFootY(){
  var c=(HUBBELT&&HUBBELT.cells)||[], t=H, i;
  for(i=0;i<c.length;i++) if(c[i]&&typeof c[i].y==='number'&&isFinite(c[i].y)) t=Math.min(t,c[i].y);
  return (t<H-LH(20))?Math.round(t-LH(8)):H-16;
}
'@

SubRx @'
  ctx.font=FS(TYPE.head); ctx.fillStyle='#ffc04a';
  ctx.fillText('THE UNDERCROFT',16,28);
'@ @'
  // v18.62, SEEN ON THE UNDERCROFT SCREENSHOT (2026-10-07): THE FLOOR HUD READS ON ANY WALL. The title and the stats line under it
  // run across the light side wall of the room, where the grey stats line vanished (0 items in stash read 0 items ... sh). Both
  // are drawn with a dark halo now, and the stats line a shade lighter; nothing moves.
  ctx.shadowColor='rgba(4,6,9,.95)'; ctx.shadowBlur=4;
  ctx.font=FS(TYPE.head); ctx.fillStyle='#ffc04a';
  ctx.fillText('THE UNDERCROFT',16,28);
  ctx.shadowColor='transparent'; ctx.shadowBlur=0;
'@

SubRx @'
  try{ hubDrawDropPrompt(); }catch(_hdp){}   // v18.28: E TAKE beside a dropped crate
  ctx.font=FS(TYPE.micro); ctx.fillStyle='#8a96a1';
'@ @'
  try{ hubDrawDropPrompt(); }catch(_hdp){}   // v18.28: E TAKE beside a dropped crate
  ctx.shadowColor='rgba(4,6,9,.95)'; ctx.shadowBlur=4;   // v18.62: the halo, for the stats line too
  ctx.font=FS(TYPE.micro); ctx.fillStyle='#aeb8c2';
'@

SubRx @'
  // v8.13: the line itself moved to #hubtoast
'@ @'
  ctx.shadowColor='transparent'; ctx.shadowBlur=0;   // v18.62: the halo ends with the stats line
  // v8.13: the line itself moved to #hubtoast
'@

SubRx @'
  #topright small{ font-size:14px; color:var(--ash); letter-spacing:.24em; font-weight:400; margin-left:7px; margin-right:20px; }
'@ @'
  #topright{ text-shadow:0 0 3px rgba(4,6,9,.95),0 0 8px rgba(4,6,9,.8); }   /* v18.62: the corner readout reads over a light wall (CREDITS vanished on the Undercroft side wall) */
  #topright small{ font-size:14px; color:var(--ash); letter-spacing:.24em; font-weight:400; margin-left:7px; margin-right:20px; }
'@

SubRx @'
TAKE THE DROPPED ITEM':''),W/2,H-16); ctx.textAlign='left'; return; }
'@ @'
TAKE THE DROPPED ITEM':''),W/2,hubFootY()); ctx.textAlign='left'; return; }
'@

SubRx @'
TAKE THE DROPPED ITEM':'')),W/2,H-16);
'@ @'
TAKE THE DROPPED ITEM':'')),W/2,hubFootY());
'@

SubRx @'
var VER='18.61';
'@ @'
var VER='18.62';
'@

$pat = "(?m)^  now:'v18\.61:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.62: On the Undercroft floor the top line, the credits and the key footer are all readable. Check 18.62 fails on v18.61',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
