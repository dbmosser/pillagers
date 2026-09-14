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

# DEPLOY AND LOADOUT AUDIT OF 2026-09-15, finding 4: THE FREEBIE KIT'S SCAV PISTOL CARRIED THE RESERVE OF THE GUN
# LEFT AT HOME. The player is built with a reserve of two magazines of the gun he equipped, and the freebie
# branch then swaps in the Scav Pistol and refills its magazine without touching the reserve. With a Support MG
# equipped at home the free pistol came up with 120 rounds behind it; with a Scav Pistol, 24; with nothing
# equipped, anywhere from 12 to 56 by the starter roll. The same free kit varied five-fold with what stayed in
# the armoury. The free pistol now gets two of its own magazines.
SubRx @'
        g.player.wep=WEAPONS[FREEKIT_GUN];
        g.player.ammo=g.player.wep.mag;
'@ @'
        g.player.wep=WEAPONS[FREEKIT_GUN];
        g.player.ammo=g.player.wep.mag;
        g.player.reserve=g.player.wep.mag*2;   // v14.01, loadout audit: its own two magazines, not the home gun's
'@
SubRx @'
var VER='14.00';
'@ @'
var VER='14.01';
'@

$pat = "(?m)^  now:'v14\.00:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.01: THE FREEBIE PISTOL CARRIES ITS OWN RESERVE. Deploy and loadout audit of 2026-09-15, finding 4: the player is built with two magazines of the equipped gun in reserve, and the freebie branch swapped in the Scav Pistol and refilled its magazine without touching the reserve, so with a Support MG at home the free pistol came up with 120 rounds behind it and with a Scav Pistol 24. The free pistol now gets two of its own magazines. Check 14.01 takes the freebie with a Support MG equipped and requires a reserve of two pistol magazines, with a Scav Pistol equipped as the control; it fails on v14.00',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
