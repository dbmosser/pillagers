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

# A FORGE UPGRADE RAISES NO WEAPON CARD (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  G.gunCard={gk:nw.id,w:nw,vs:w,route:'cost '+forgeMoney(o.cost),t0:G.t||0};   // v28.xx (cw-cx-forgeread): name the debit as the upgrade cost.

'@ @'
  // v28.xx (cw-no-gun-card), HIS WORDS (2026-10-31): "after i upgrade a weapon, i don't need to see a weapon card. The only time a weapon card should show up is when mousing over the weapon in the hotbar". The upgrade used to set G.gunCard (the new gun against the old, "cost $N"); it sets nothing now. The sparks, the upgrade sound, the ping and the "gun upgraded" line stay; the card shows on the hotbar hover (beltHoverHud).

'@

SubRx @'
var VER='36.96';
'@ @'
var VER='36.97';
'@

$pat = "(?m)^  now:'v36\.96:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.97: No weapon card after an upgrade; hover the hotbar to see it. Check 36.97 fails on v36.96',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
