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
          // THE BODY MUST NOT PAY IT AGAIN. The death path re-adds the held gun
          // to any body that is not already carrying it, so without this you
          // could revive a man for his shotgun and then shoot him for a second.
          downRdr.paidRevive=1;
'@ @'
          // THE BODY MUST NOT PAY IT AGAIN. The death path re-adds the held gun
          // to any body that is not already carrying it, so without this you
          // could revive a man for his shotgun and then shoot him for a second.
          // v15.46, bodies audit finding: REVIVING A PILLAGER NEVER LOSES THE GUN IN HIS HANDS. The loop above pays the first gun
          // in his pack on the belief that it is the gun in his hands, and this flag was set whatever it paid. An elite breaks that
          // belief every time: blessElite hands him a Marksman Rifle, Support MG, Magnum, Whisper, Longshot or Meridian Lance and
          // leaves the gun he spawned with first in his pack, and an imported friend (applyGhost) or an elite who put his blessed
          // gun away in a swap does the same. So an elite holding a Marksman Rifle paid his Scav Pistol, the flag stopped the death
          // path adding the rifle, and when he died later the gun you watched him fire was on no body and in no backpack. The flag
          // is set now only when the gun paid is the gun in his hands, from his pack or from his hands when the pack is empty: that
          // gun still pays once, and a different gun in his hands goes on his body at death as it would have with no revive. A man
          // with no gun in his hands matches nothing. No number, no player text and no seeded draw moved.
          if(_rpk==='gun_'+(downRdr.wep&&downRdr.wep.id)) downRdr.paidRevive=1;
'@
SubRx @'
var VER='15.45';
'@ @'
var VER='15.46';
'@

$pat = "(?m)^  now:'v15\.45:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.46: REVIVING A PILLAGER NEVER LOSES THE GUN IN HIS HANDS. A revive pays the first gun in his pack and marked the gun in his hands as paid whatever it paid, so an elite holding a Marksman Rifle paid the Scav Pistol he spawned with and the rifle was on no body when he died. The mark is set now only when the gun paid is the gun in his hands, so that gun still pays once and a different gun in his hands goes on his body. Check 15.46 revives three staged pillagers, kills each and reads what the revive paid and what the body holds; it fails on v15.45',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
