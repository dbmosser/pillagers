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

# FROM THE 2026-09-07 READ-ONLY AUDIT (P3), specced from the source.
#
# The size of the siege a call buys is read from the bag you are carrying, ONCE,
# at the moment the call is made. The code says so in its own comment, and your
# own call clears the stored figure so it is read fresh. A pillager's call, which
# has carried the same per-zone consequences since v3.58 and which you are meant
# to be able to ride out on, does not clear it.
#
# So the first call on a ring freezes that ring's figure for the rest of the
# raid unless YOU call it again. Call a point with a heavy bag, miss the
# extraction, sell the bag, and then ride out on a pillager's call at the same
# point: the siege is sized on the bag you were carrying twenty minutes ago. The
# other order under-sizes it just as wrongly.
SubRx @'
            z.beaconT=CFG.extractWait; z.hold=null; z.siegeSpawned=0; z.siegeSpawnT=0; z.pullN=0; z.pinged=0;
'@ @'
            // v12.54, 2026-09-07 audit: HIS CALL READS THE BAG TOO. The figure the
            // siege is sized from is read once per CALL, not once per ring, which is
            // what the comment beside the reader says and what your own call has
            // always done by clearing it here. This line never did, so the first
            // call on a ring froze that ring for the rest of the raid: call with a
            // heavy bag, miss the extraction, sell it, then ride out on his call at
            // the same point and the siege is sized on a bag you no longer have.
            z.beaconT=CFG.extractWait; z.hold=null; z.siegeSpawned=0; z.siegeSpawnT=0; z.siegeGreed=null; z.pullN=0; z.pinged=0;
'@

# NEW IN.
SubRx @'
  'A MACHINE SEARCHING FOR YOU CAN NO LONGER GET STUCK FOR THE REST OF THE RAID. When one lost you it picked a point to search, never checked that anything could stand there, and had no way out except arriving. A point inside a wall held it against that wall until the raid ended.',
'@ @'
  'A MACHINE SEARCHING FOR YOU CAN NO LONGER GET STUCK FOR THE REST OF THE RAID. When one lost you it picked a point to search, never checked that anything could stand there, and had no way out except arriving. A point inside a wall held it against that wall until the raid ended.',
  'A PILLAGER CALLING EXTRACTION NOW SIZES THE SIEGE ON THE BACKPACK YOU ARE ACTUALLY CARRYING. His call kept whatever figure your own earlier call at that point had left behind, so riding out on him could bring the siege the backpack you had half an hour ago deserved.',
'@

# STAMPS.
SubRx @'
var VER='12.53';
'@ @'
var VER='12.54';
'@
SubRx @'
var WHATSNEW_VER='12.53';
'@ @'
var WHATSNEW_VER='12.54';
'@
$cnt=([regex]::Matches($s,"now:'v12\.53:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.53 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.53:[^']*'",{ param($m) "now:'v12.54: 2026-09-07 audit (P3). The size of the siege a call buys is read from the bag you are carrying, once, at the moment the call is made; the code says so in its own comment beside the reader, and your own call clears the stored figure so it is read fresh. A pillagers call, which has carried the same per-zone consequences since v3.58 and which you are explicitly meant to be able to ride out on, never cleared it. So the first call on a ring froze that rings figure for the rest of the raid unless YOU called it again: call a point with a heavy bag, miss the extraction, sell the bag, then ride out on his call at the same point, and the siege is sized on a bag you no longer have. The other order under-sizes it just as wrongly. One field added to his call, so both calls read the same way. Check 12.54 leaves a stale figure on a ring, empties the bag, has a pillager call that ring through the real state machine, and requires the figure to have been thrown away and read again from the bag he is actually holding; a control leaves the same stale figure and does not call, requiring it to survive, so the check cannot pass by something clearing it anyway; fails on v12.53.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
