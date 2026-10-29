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

# IN-GAME KEYS ARE KEYCARDS NOW (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
name:'Turbine Room Key',
'@ @'
name:'Turbine Room Keycard',
'@

SubRx @'
name:'Substation Vault Key',
'@ @'
name:'Substation Vault Keycard',
'@

SubRx @'
name:'Sealed Cellar Key',
'@ @'
name:'Sealed Cellar Keycard',
'@

SubRx @'
name:'Garage Depot Key',
'@ @'
name:'Garage Depot Keycard',
'@

SubRx @'
name:'Blast Freezer Key',
'@ @'
name:'Blast Freezer Keycard',
'@

SubRx @'
name:'Foreman Office Key',
'@ @'
name:'Foreman Office Keycard',
'@

SubRx @'
name:'Magazine Key',
'@ @'
name:'Magazine Keycard',
'@

SubRx @'
name:'Assay Office Key',
'@ @'
name:'Assay Office Keycard',
'@

SubRx @'
name:'Bond Room Key',
'@ @'
name:'Bond Room Keycard',
'@

SubRx @'
name:'Deep Freeze Key',
'@ @'
name:'Deep Freeze Keycard',
'@

SubRx @'
name:'Blast Vault Key',
'@ @'
name:'Blast Vault Keycard',
'@

SubRx @'
name:'Cryo Lockup Key',
'@ @'
name:'Cryo Lockup Keycard',
'@

SubRx @'
name:'Pump Control Vault Key',
'@ @'
name:'Pump Control Vault Keycard',
'@

SubRx @'
name:'Melt Locker Key',
'@ @'
name:'Melt Locker Keycard',
'@

SubRx @'
name:'Manifest Cage Key',
'@ @'
name:'Manifest Cage Keycard',
'@

SubRx @'
name:'Winch Room Key',
'@ @'
name:'Winch Room Keycard',
'@

SubRx @'
  if(g.kind==='key') return 'A key to a sealed room';
'@ @'
  if(g.kind==='key') return 'A keycard to a sealed room';   // v28.xx (cw-keycards), HIS ORDER 2026-10-28: in-game keys are keycards, keys are what you press
'@

SubRx @'
    return ITEMS[k]?ITEMS[k].name:'a key';
'@ @'
    return ITEMS[k]?ITEMS[k].name:'a keycard';
'@

SubRx @'
      mapLabel('KEY',ikx,iky-9*_MZ,UIC.tx_1);
'@ @'
      mapLabel('KEYCARD',ikx,iky-9*_MZ,UIC.tx_1);   // v28.xx (cw-keycards)
'@

SubRx @'
['salvage','SALVAGE'],['key','KEYS'],
'@ @'
['salvage','SALVAGE'],['key','KEYCARDS'],
'@

SubRx @'
    ?'Next raid: every locked-room key and every elite shown live on your map. One core per raid.'
'@ @'
    ?'Next raid: every locked-room keycard and every elite shown live on your map. One core per raid.'
'@

SubRx @'
deploys knowing things: every locked-room key location and every elite, live on the M map. One is in the stash.')
'@ @'
deploys knowing things: every locked-room keycard location and every elite, live on the M map. One is in the stash.')
'@

SubRx @'
Spend a Data Core for better map info. Every locked-room key location and every elite will be live on the M map.
'@ @'
Spend a Data Core for better map info. Every locked-room keycard location and every elite will be live on the M map.
'@

SubRx @'
var VER='36.17';
'@ @'
var VER='36.18';
'@

$pat = "(?m)^  now:'v36\.17:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.18: the items that open sealed rooms are keycards, so keys only means keys you press Check 36.18 fails on v36.17',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
