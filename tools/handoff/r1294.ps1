$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# CHECK 9.71 WENT RED ON v12.94 AND ITS STAGING IS THE REASON, not the build.
#
# Its landed arm sets the GLOBAL mirrors, g.beaconT and g.shipHold, and never sets
# anything on the ring itself. The game's own comment on those mirrors says what
# they are: "THE MIRRORS ARE A VIEW, NOT A CACHE", copied off the active ring every
# frame. So the arm was staging a state the game cannot produce, a landed extraction
# that no extraction point knows about, and it passed only because the old guard
# read the same mirrors the check was writing.
#
# v12.94 made the guard read the ring he is lying in, which is where the truth is,
# so the arm now stages nothing at all and he surrenders. The staging is corrected
# to what a landed ring actually looks like; the mirrors are kept beside it, which
# is what the running game would have.
SubRx @'
         if(o.landed){ g.active=z; z.open=true; g.beaconT=0; g.shipHold=20; p.x=z.x; p.y=z.y; }
'@ @'
         // v12.94: THE RING, NOT JUST THE MIRRORS. g.beaconT and g.shipHold are a
         // view copied off the active ring every frame, so setting them alone
         // staged a landed extraction that no extraction point knew about. The
         // guard reads the ring he is lying in now, which is where the state lives.
         if(o.landed){ g.active=z; z.open=true; z.beaconT=0; z.hold=20; z.holdMax=30;
                       g.beaconT=0; g.shipHold=20; p.x=z.x; p.y=z.y; }
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
