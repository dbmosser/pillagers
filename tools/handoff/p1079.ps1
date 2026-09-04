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

# ============ THREE GUARDS ONLY ASKED WHETHER A THING WAS DRAWN AT ALL.
# ============
# ============ This closes the STILL OPEN line "v8.99, v9.07, v9.08 and v9.15 are
# ============ still numbers nobody measured". No game change: the game file moves
# ============ only its version and the BUILDING line. The whole build is in the
# ============ harness, which is the instrument every other build is judged on.
# ============
# ============ MEASURED TODAY at 1920x1080, DPR 1, seed 4242, map 0:
# ============   the container search bar appearing      1,319 pixels, floor was 0
# ============   the same bar filling from empty to half 1,319 pixels, floor was 0
# ============   a noise ring at the frame it is born      120 pixels, floor was 20
# ============   the standing extract prompt pulsing        25.7 percent, floor 3
# ============
# ============ So a bar reduced to ONE pixel passed, a ring reduced to a fifth
# ============ passed, and a pulse reduced to a ninth passed. Three of the four
# ============ guards were really "is it non-zero", which is the v9.86 fault:
# ============ green for the wrong reason.
SubRx @'
var VER='10.78';
'@ @'
var VER='10.79';
'@
SubRx @'
  now:'v10.78: the Discount Fashion Depot and the ascent check stop cutting their own contents off. SURPRISE ME, all three LOOKS slots and half the appearance rows sat past the bottom of a window that could not be scrolled, so nobody could reach them at all.',
'@ @'
  now:'v10.79: the harness stops accepting a trace of a thing as proof the thing is there. Measured: the container search bar moves 1,319 pixels, a noise ring 120, the standing extract prompt pulses 25.7 percent; their floors were 0, 20 and 3, so a bar of one pixel passed. Every floor now sits at half the measured reading and a quarter-strength signal is refused.',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
