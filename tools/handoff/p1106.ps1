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

# ============ HIS NOTE 20: THE BALLER'S JERSEY IS BEHIND A BLACK BLOCK.
# ============
# ============ "micheal jordan character, can't see his jersey bc its blocked by
# ============ a black block (maybe supposed to be backpack straps?)", 2026-09-04.
# ============
# ============ NOT THE BACKPACK. The pack is drawn BEFORE the torso and the torso
# ============ covers it. Two other things are on that chest, and I put both there.
# ============
# ============ MEASURED, one baller drawn at nine times raid size, every painted
# ============ pixel in a 125 by 130 box around the chest counted by colour:
# ============   3,222  the red of the jersey
# ============   2,384  #14161b, the jersey's own black side panels
# ============   1,602  the red in shadow
# ============   1,582  the white of the 23
# ============   1,506  the ink outline
# ============     882  the chest rig band, over the dark
# ============ The black side panels alone are 74 percent of the red. They are
# ============ 2.4 wide each on a chest 13 wide, so 4.8 of 13, thirty-seven
# ============ percent of the shirt, in near-black. At sprite size two black bars
# ============ down a chest read as straps, which is exactly what he said.
# ============
# ============ AND A SECOND ONE UNDER IT: the chest rig is a near-black band the
# ============ FULL width of the chest, drawn immediately after the jersey, right
# ============ across the lower half of the numeral.
# ============
# ============ THE FIX, both of them, without losing the design. The side panels
# ============ go from 2.4 to 1.4, which is trim rather than a block and leaves
# ============ the red reading as a shirt. And the jersey is drawn AFTER the chest
# ============ rig instead of before it, so the 23 sits on top of the band rather
# ============ than under it. The rig still reads: it shows between the number and
# ============ the panels.
SubRx @'
  if(iv<=0&&(OUTF?!!OUTF.jersey:(st.hero&&cosWorn('fit')==='jersey'))){   // v10.54: the baller wears it
    // v10.46: the number 23 jersey. Black side panels, and a pale 2 and 3 in
    // one-pixel strokes across the chest, five tall.
    var _jx=x-6.5+leanX;
    wc.fillStyle='#14161b'; wc.fillRect(_jx,ty-21.4,2.4,10); wc.fillRect(_jx+10.6,ty-21.4,2.4,10);
    wc.fillStyle='#f4f2ec';
    var _jy=ty-20;
    wc.fillRect(_jx+2.6,_jy,3.4,1.5); wc.fillRect(_jx+4.5,_jy,1.5,2.6); wc.fillRect(_jx+2.6,_jy+1.9,3.4,1.5); wc.fillRect(_jx+2.6,_jy+1.9,1.5,2.6); wc.fillRect(_jx+2.6,_jy+3.8,3.4,1.5);
    wc.fillRect(_jx+7.2,_jy,3.4,1.5); wc.fillRect(_jx+9.1,_jy,1.5,5.3); wc.fillRect(_jx+7.2,_jy+1.9,3.4,1.5); wc.fillRect(_jx+7.2,_jy+3.8,3.4,1.5);
  }
  // chest rig, and a hit shimmer when recently hurt
  wc.fillStyle='rgba(16,21,27,.85)';
  wc.fillRect(x-6.5+leanX,ty-18,13,2.4);
'@ @'
  // v11.06, HIS NOTE 20: the jersey used to be painted HERE, before the chest
  // rig, so the rig's near-black band was laid across the lower half of the
  // numeral. It goes on after the rig now, a dozen lines down.
  // chest rig, and a hit shimmer when recently hurt
  wc.fillStyle='rgba(16,21,27,.85)';
  wc.fillRect(x-6.5+leanX,ty-18,13,2.4);
  if(iv<=0&&(OUTF?!!OUTF.jersey:(st.hero&&cosWorn('fit')==='jersey'))){   // v10.54: the baller wears it
    // v10.46: the number 23 jersey. Black side panels, and a pale 2 and 3 in
    // one-pixel strokes across the chest, five tall.
    // v11.06, HIS NOTE 20: the panels were 2.4 wide each on a chest 13 wide,
    // which is thirty-seven percent of the shirt in near-black and measured 2,384
    // pixels against the red's 3,222. At this size two black bars down a chest
    // read as backpack straps. They are trim now.
    var _jx=x-6.5+leanX;
    wc.fillStyle='#14161b'; wc.fillRect(_jx,ty-21.4,1.4,10); wc.fillRect(_jx+11.6,ty-21.4,1.4,10);
    wc.fillStyle='#f4f2ec';
    var _jy=ty-20;
    wc.fillRect(_jx+2.6,_jy,3.4,1.5); wc.fillRect(_jx+4.5,_jy,1.5,2.6); wc.fillRect(_jx+2.6,_jy+1.9,3.4,1.5); wc.fillRect(_jx+2.6,_jy+1.9,1.5,2.6); wc.fillRect(_jx+2.6,_jy+3.8,3.4,1.5);
    wc.fillRect(_jx+7.2,_jy,3.4,1.5); wc.fillRect(_jx+9.1,_jy,1.5,5.3); wc.fillRect(_jx+7.2,_jy+1.9,3.4,1.5); wc.fillRect(_jx+7.2,_jy+3.8,3.4,1.5);
  }
'@

SubRx @'
var VER='11.05';
'@ @'
var VER='11.06';
'@
SubRx @'
  now:'v11.05: your question about a daytime blackout, and the answer is no. Lamp brightness is the weather times the time of day, and the time of day is ZERO at 8am and noon, so a blackout there kills lamps that were already off. That makes my v11.00 wrong: it paid your 1.1x for killing the lamps whatever the hour. Killing the lamps only counts now when a real amount of light actually goes. Cutting sight, which is rain, fog and storm, is unchanged.',
'@ @'
  now:'v11.06: the black block over the jersey, your note. Not the backpack, which is drawn behind the body. It was the jersey own black side panels, 2.4 wide each on a chest 13 wide, measured at 2,384 pixels against 3,222 of red, plus the chest rig band laid straight across the lower half of the 23. The panels are trim now and the jersey is drawn after the rig instead of before it.',
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'THE 23 JERSEY READS AS A JERSEY AGAIN. Its black side panels were more than a third of the shirt and read as backpack straps, and the chest rig band was drawn straight across the number. The panels are trim now and the number sits on top of the rig.',
'@
SubRx @'
var WHATSNEW_VER='11.05';
'@ @'
var WHATSNEW_VER='11.06';
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
