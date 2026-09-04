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

# ---- MY OWN ERROR, CAUGHT BEFORE IT SHIPPED. I wrote that the servo is a live
# ---- repair part again because kills wear a gun and addWear runs on every shot.
# ---- addWear does run, but WEARSTEPS carries ONE band, so wearLive() is false
# ---- and repairCost refuses every gun. The repair economy is dormant, exactly as
# ---- v9.43 left it, and telling him a servo is for gun repairs would be the game
# ---- promising a use that is switched off.
# ---- The servo is still wanted, by the contract board, which is his note and is
# ---- true today. So the repair answer is gated on the wear system actually being
# ---- alive, which is the switch v9.43 built for precisely this: put a second
# ---- band back and the servo becomes a repair part again by itself.
SubRx @'
  if(k===REPAIR_PARTS.heavy||k===REPAIR_PARTS.light) return 'gun repairs';
'@ @'
  // Only while the wear system is actually running. One band in WEARSTEPS means
  // repairCost refuses every gun, and a use the game will not honour is a lie
  // told in green text.
  if(typeof wearLive==='function'&&wearLive()&&(k===REPAIR_PARTS.heavy||k===REPAIR_PARTS.light))
    return 'gun repairs';
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
