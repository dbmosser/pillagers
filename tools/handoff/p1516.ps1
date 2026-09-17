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
  // back into the bag and stays worth taking off his body.
  if((e.kitT=(e.kitT||0)-dt)<=0){
'@ @'
  // back into the bag and stays worth taking off his body.
  // v15.16, mainframe audit finding 1: AN IMPORTED FRIEND KEEPS THEIR FAVOURITE GUN FOR THE RAID. applyGhost hands the
  // friend the gun their run report used most, but the body they walk in still carries its own rolled gun in e.bag (mkRaider
  // pushes 'gun_'+wk), and this test never asked whether the pillager was the ghost. kitT starts unset, so on the first frame
  // the swap ran at once and took any gun of a higher WTIER: a Scav Pistol favourite was traded for the SMG, Auto Rifle,
  // carbine or scattergun the body rolled six times in nine, and fought all raid with it, breaking the promise the Mainframe
  // makes. The ghost skips only this swap: the heal below still runs, and the body gun stays in the bag as loot.
  if(!e.ghost&&(e.kitT=(e.kitT||0)-dt)<=0){
'@
SubRx @'
var VER='15.15';
'@ @'
var VER='15.16';
'@

$pat = "(?m)^  now:'v15\.15:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.16: AN IMPORTED FRIEND KEEPS THEIR FAVOURITE GUN FOR THE RAID. A friend imported at the Mainframe was handed the gun their report used most, and on the first frame they swapped it for any better gun the pillager body they walk in was carrying, so a Scav Pistol favourite fought all raid with a rifle or a scattergun. The friend now keeps their favourite gun and still heals, and the body gun stays on them as loot. Check 15.16 stages a pistol favourite carrying an Auto Rifle beside a plain pillager holding the same pair and runs one frame; it fails on v15.15',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
