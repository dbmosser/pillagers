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

# CLOSING THE UNDERCROFT BACKPACK OVERWROTE LOADOUT EDITS MADE AT THE TERMINAL.
# Opening the backpack (I) snapshots P.kit and P.hotAssign into hubBagG, and
# closing commits that copy back over the profile, by design, so a half-finished
# drag never writes a broken bag. But hubModalOpen ignores hubBagOpen, so the
# floor keeps running with the bag open, E at THE STASH opens the terminal, the
# terminal edits P.kit and P.hotAssign directly, and ESC then closes the bag and
# writes the STALE snapshot over everything the terminal just did. The terminal
# now commits and closes the open backpack before it draws, so the snapshot can
# never be older than what the terminal changes.
SubRx @'
     acts:{KeyE:['terminal',function(){ renderHub(); document.getElementById('hub').classList.add('on'); }]}},
'@ @'
     acts:{KeyE:['terminal',function(){ if(hubBagOpen) hubBagOpenSet(false); /* v11.50: commit the open backpack first, or its stale snapshot overwrites what the terminal does */ renderHub(); document.getElementById('hub').classList.add('on'); }]}},
'@

# STAMPS.
SubRx @'
var VER='11.49';
'@ @'
var VER='11.50';
'@
SubRx @'
var WHATSNEW_VER='11.49';
'@ @'
var WHATSNEW_VER='11.50';
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'PACKING AT THE STASH WITH YOUR BACKPACK OPEN NO LONGER GETS UNDONE. If you opened your backpack on the Undercroft floor, then walked to THE STASH and packed your loadout there, closing the backpack afterwards put back the old loadout over the new one. The backpack now closes itself when the stash opens.',
'@
$cnt=([regex]::Matches($s,"now:'v11\.49:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v11.49 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v11\.49:[^']*'",{ param($m) "now:'v11.50: closing the Undercroft backpack overwrote loadout edits made at the terminal. Opening it snapshots P.kit and P.hotAssign and closing commits the copy back, by design; but hubModalOpen ignores hubBagOpen, so with the bag open the floor still runs, E at THE STASH opens the terminal, which edits P.kit and P.hotAssign directly, and ESC then wrote the stale snapshot over the lot. The terminal act now commits and closes the open backpack before it draws. From the v11.46 audit, P0.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
