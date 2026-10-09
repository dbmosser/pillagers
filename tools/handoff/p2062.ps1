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

# A NEW GUN DOES NOT FINISH THE OLD RELOAD (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
        p.wep=found; p.ammo=(ct&&ct.dropped)?takeRounds(found.id,found.mag):Math.ceil(p.wep.mag/2); p.wepIssued=false; p.wepFromArmory=false;   // v13.81
'@ @'
        // v20.62, from the whole-game bug hunt of 2026-10-08 (H6): AND THE OLD GUN'S RELOAD STOPS. This swap left p.reloading running,
        // and tickReload tops up whatever gun is in hand when it ends, so a better gun that came up half loaded while the Scav Pistol
        // was reloading was filled to a full magazine 1.4 seconds later and said Reloaded, skipping its own longer reload. Every other
        // change of the gun in hand (bagHeldGun, swapGuns, equipFromBag) already clears it.
        p.wep=found; p.ammo=(ct&&ct.dropped)?takeRounds(found.id,found.mag):Math.ceil(p.wep.mag/2); p.wepIssued=false; p.wepFromArmory=false; p.reloading=0;   // v13.81
'@

SubRx @'
var VER='20.61';
'@ @'
var VER='20.62';
'@

$pat = "(?m)^  now:'v20\.61:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.62: A better gun picked up during a reload no longer gets a free full magazine from the old reload. Check 20.62 fails on v20.61',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
