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

# THE RIOT SCATTERGUN KICKS THE SCREEN (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function fireWeapon(sh,wep,tx,ty,fromPlayer){
'@ @'
// v28.xx (cw-kickshotgun), his Q5 (2026-10-18, gun and enemy feel this week). THE CAMERA KICK OF A SHOT IS PER GUN. Every light gun kicked the camera the same 2.2 and every heavy one 4.5,
// and the camera shake only grows when the number RISES (gfxTrauma: trauma += rise/14, size = 18 px x trauma squared), so a lone 2.2 is 0.16 trauma, under half a pixel: the Riot
// Scattergun, six pellets and 96 damage on one pull, kicked the screen like a pea shooter. GUN_SHAKE names a gun base and the shake one round of it sets; a gun with no entry keeps the old
// number (4.5 over 40 damage, else 2.2). Riot Scattergun 2.2 to 6.5: trauma 0.16 to 0.46, a kick of 0.4 px to 3.9 px at 1080p, settling in about a third of a second. Live feel only, no draw.
var GUN_SHAKE={shotgun:6.5};
function gunShake(wep){
  var b=(wep&&wep.id)?gunBase(wep.id):'', s=GUN_SHAKE[b];
  return (s===undefined)?((wep&&wep.dmg>40)?4.5:2.2):s;
}
function fireWeapon(sh,wep,tx,ty,fromPlayer){
'@

SubRx @'
G.shake=Math.max(G.shake,wep.dmg>40?4.5:2.2);
'@ @'
G.shake=Math.max(G.shake,gunShake(wep));   // v28.xx (cw-kickshotgun): the kick is per gun (GUN_SHAKE), the Riot Scattergun 6.5
'@

SubRx @'
var VER='30.33';
'@ @'
var VER='30.34';
'@

$pat = "(?m)^  now:'v30\.33:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v30.34: The Riot Scattergun now kicks the screen when it fires. Check 30.34 fails on v30.33',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
