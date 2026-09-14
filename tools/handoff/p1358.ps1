$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new, [int]$want = 1) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne $want) { throw "regex matched $c times, wanted ${want}: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# UNDERCROFT AUDIT OF 2026-09-14, finding 3: EQUIP AS YOUR GUN ON A SPARE COPY OF THE GUN-2
# GUN PUT THE SAME GUN IN BOTH HANDS. Both copies of the verb (the stash item menu and the
# right-click menu) set P.equipped and never looked at P.equippedSec, while the gun menu's
# own Put in gun 1 already clears it. Raid start then drops gun 2 because it matches gun 1,
# so the raid began with no second gun and the gun menu showed both slots as already there.
# Every one of the four equip sites now empties gun 2 when it names the gun going to gun 1.
SubRx @'
P.equipped=it.gk; saveProfile(); refreshInv();
'@ @'
if(P.equippedSec===it.gk) P.equippedSec='none'; P.equipped=it.gk; saveProfile(); refreshInv();   // v13.58: one gun, one hand
'@ 2
SubRx @'
P.equipped=it.gk; saveProfile(); renderHub();
'@ @'
if(P.equippedSec===it.gk) P.equippedSec='none'; P.equipped=it.gk; saveProfile(); renderHub();   // v13.58: one gun, one hand
'@ 2
SubRx @'
var VER='13.57';
'@ @'
var VER='13.58';
'@

$pat = "(?m)^  now:'v13\.57:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.58: ONE GUN CANNOT BE IN BOTH HANDS. Undercroft audit of 2026-09-14, finding 3: Equip as your gun on a spare copy of the gun already in gun 2 set gun 1 and left gun 2 naming the same gun, so raid start dropped gun 2 and the raid began with one gun, while the gun menu greyed both slots out. All four equip sites, in the stash item menu and the right-click menu, now empty gun 2 when it names the gun going to gun 1, as Put in gun 1 already does. Check 13.58 equips a spare of the gun-2 gun from the stash menu and requires it in gun 1 only, with a spare of a third gun leaving gun 2 alone as the control; it fails on v13.57',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
