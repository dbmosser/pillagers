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

# HARNESS REPAIR: CHECK 13.32 THREW ON A PANE WITH NO LAYOUT.
#
# Check 13.32 steps the real frame loop, which draws. On a pane whose viewport was
# cleared (the desktop app clears emulation at some turn ends, leaving 0x0), render2D
# calls drawImage on a zero-size canvas and throws, so the check reported a failure
# that was the pane and not the build. Measured on the v13.32 gate: three throws at
# innerWidth 0, three passes after resizing to 1920x1080. Check 13.33 already asks
# __vpAlive first and skips; 13.32 now does the same. A skip is not a pass, and the
# corpus of record still runs at 1920x1080.
SubRx @'
     if(!ITEMS.gun_smg||!WEAPONS.smg||!WEAPONS.pistol) return 'SKIP: this build has no stash gun item to stage';
     var bad=[], P2=__P();
'@ @'
     if(!ITEMS.gun_smg||!WEAPONS.smg||!WEAPONS.pistol) return 'SKIP: this build has no stash gun item to stage';
     // r1334: the frame loop draws, and a pane with no layout throws in drawImage.
     if(!__vpAlive()) return 'SKIP: the pane has no layout ('+window.innerWidth+'x'+window.innerHeight+'), so the frame loop cannot draw';
     var bad=[], P2=__P();
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
