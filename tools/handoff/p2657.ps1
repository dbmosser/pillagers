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

# CAMERA LOOK AHEAD (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function render2D(dt){
'@ @'
// v26.xx (feel12), HIS ORDER (2026-10-14): "Yes this is a good idea" to a camera look-ahead toward the cursor, longer for sniper-class guns.
// WHAT WAS THERE: the camera already leaned toward the cursor by 0.13 of its distance from the screen centre (0.30 and 0.46 held to aim). WHAT
// IT IS NOW: with a gun in hand the lean is LOOK_BASE (0.20) of that distance, and LOOK_LONG (0.30) for a gun with a scope of 2.5 or more
// (the Marksman Rifle, the Longshot and the Meridian Lance), so you see farther along the line you shoot. It eases in and out through the same camera ease as
// before (the lean target is read every frame and the camera chases it), the world clamp still holds, bare hands and a thrown item keep the
// old 0.13, and the held-to-aim lean is unchanged. Render only: no gameplay number, no seeded draw.
var LOOK_BASE=0.20, LOOK_LONG=0.30, LOOK_HANDS=0.13;
function lookLean(p){
  var w=p&&p.wep;
  if(!w||!(w.mag>0)||p.hand) return LOOK_HANDS;
  return (w.optic>=2.5)?LOOK_LONG:LOOK_BASE;
}
function render2D(dt){
'@

SubRx @'
var lean=p.ads?(opticMag()>1?.46:.30):.13;
'@ @'
var lean=p.ads?(opticMag()>1?.46:.30):lookLean(p);   // v26.xx (feel12): the look-ahead, longer for the long guns
'@

SubRx @'
var VER='26.56';
'@ @'
var VER='26.57';
'@

$pat = "(?m)^  now:'v26\.56:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.57: The camera looks farther ahead toward your cursor, farthest with the long scoped guns. Check 26.57 fails on v26.56',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
