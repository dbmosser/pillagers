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

# ============ HIS NOTE: "game needs to be playable at 1080p, 1440p or 4k".
# ============ MY OWN v10.73 ONLY FIXED THE FIRST OF THE THREE.
# ============
# ============ I listed 1440p and 4K as not verified for four builds running,
# ============ because the test pane would not go bigger. It will: resizing the
# ============ tab really does give a 2560x1440 and a 3840x2160 viewport, and I
# ============ should have tried it instead of writing the caveat again.
# ============
# ============ MEASURED at 3840x2160 on v10.76: the title screen paints 45
# ============ percent of the monitor with 1,062 pixels empty down each side.
# ============ That is barely better than the 56 percent v10.73 set out to fix,
# ============ on the machine he actually tests on: "I am testing in 4k".
# ============
# ============ WHY THE CSS COULD NOT DO IT. Everything on this screen paints
# ============ inside a zoom, and the zoom is not the same at every resolution,
# ============ so a fixed vw fraction over-paints at one size and under-paints at
# ============ another. Raising the 1320 cap fixes 4K and overflows 1440p:
# ============ measured, 1587 css pixels at 1440p paint 2,745 on a 2,560 screen.
# ============ The one number that knows the answer is the zoom the game has
# ============ just worked out for itself, so the cap is set from it.
# ============
# ============ AFTER, all three measured with the real viewport: 1920x1080 80
# ============ percent, 2560x1440 80 percent, 3840x2160 80 percent, each fitting
# ============ sideways and downwards. The 820 floor still protects a small
# ============ laptop and the CSS rule stays as the value before the first
# ============ layout pass runs.
SubRx @'
    _ti.style.zoom=_want;
  }
}
'@ @'
    // v10.77, his note that it has to be playable at 1080p, 1440p and 4K. The
    // css cap cannot know the zoom, and the zoom is what decides how much of the
    // monitor a css width paints, so the cap is computed from the zoom this
    // function has just settled on: 80 percent of the screen, whatever the
    // screen is. The 820 floor is the same one the stylesheet carries.
    if(_col) _col.style.maxWidth=Math.max(820,Math.round((window.innerWidth||1920)*0.80/_want))+'px';
    _ti.style.zoom=_want;
  }
}
'@

SubRx @'
var VER='10.76';
'@ @'
var VER='10.77';
'@
SubRx @'
  now:'v10.76: your ten stash layouts have their picker back, in Settings beside the text size. The button that chose them was removed with the row it lived in, so for the last while nine of the ten were unreachable and the stash showed three items at a time.',
'@ @'
  now:'v10.77: the title screen fills a 4K monitor too. v10.73 fixed 1080p and left 4K painting 45 percent of the screen, because the css cap cannot know the zoom that multiplies it. It is worked out from that zoom now: 80 percent at 1080p, 1440p and 4K alike.',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
