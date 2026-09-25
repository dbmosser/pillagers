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
    ctx.fillText((PAD&&PAD.on)?'DPAD select   DPAD L drop'
      :('ARROWS move   Z drop one   drag to tactical belt'
        +(isGun?'   ENTER equip   SHIFT+ENTER to back':'')
        ),x+11,_ry+LH(3));
'@ @'
    // v15.59, first run audit finding: THE UNDERCROFT BACKPACK NAMES ONLY KEYS THAT WORK ON THE FLOOR. drawHubBag draws this
    // same panel on the floor with G swapped to the Undercroft backpack, and this line printed the raid hint there too: the
    // arrows to move, Z to drop one, and on a gun ENTER to equip and SHIFT+ENTER to put it on the back. The floor branch of the
    // keydown listener returns before raidKey, where all of those live, and nothing else on the floor reads them for the
    // backpack, so down here the arrows moved nothing, Z dropped nothing and ENTER equipped nothing, right after the stash told
    // a new player to equip his gun. With a controller the line named the D-pad, and the floor branch of the pad poll reads no
    // D-pad. Only the mouse drag onto the tactical belt works on the floor, so on the floor the line names only that, and with a
    // controller it names nothing. state is 'raid' in a raid, so the raid hint is untouched. No number and no seeded draw moved.
    ctx.fillText((state==='hub')?((PAD&&PAD.on)?'':'drag to tactical belt')
      :(PAD&&PAD.on)?'DPAD select   DPAD L drop'
      :('ARROWS move   Z drop one   drag to tactical belt'
        +(isGun?'   ENTER equip   SHIFT+ENTER to back':'')
        ),x+11,_ry+LH(3));
'@
SubRx @'
var VER='15.58';
'@ @'
var VER='15.59';
'@

$pat = "(?m)^  now:'v15\.58:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.59: THE UNDERCROFT BACKPACK NAMES ONLY KEYS THAT WORK ON THE FLOOR. Opened on the Undercroft floor, the backpack told you to move with the arrows, drop with Z and equip a gun with ENTER, and none of those keys does anything down here, so only the mouse drag onto the tactical belt worked. On the floor it now names only the drag, and with a controller it names no D-pad button, while the raid backpack keeps its full hint. Check 15.59 draws the backpack with a gun selected in a raid and on the floor, and presses the arrows, Z and ENTER on the floor; it fails on v15.58',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
