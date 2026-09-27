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

# THE HP BAR IS ALWAYS THERE AND THE BELT NEVER COVERS IT. His notes of 2026-09-27.

SubRx @'
    var _bR=390*(HUDZ.body||1)*_hz;        // vitals block, inner edge
    var _gL=W-252*(HUDZ.gear||1)*_hz;      // gear stack, inner edge
'@ @'
    // v16.28, his note: the HP bar ran under the belt. These edges ignored the size and place he gave each block, so a vitals block
    // made bigger or moved right went under the slots. They now read both (hudUserZ, hudOff), and the slots shrink to fit.
    var _bR=390*(HUDZ.body||1)*_hz*hudUserZ('body')+Math.max(0,hudOff('body').dx);        // vitals block, inner edge
    var _gL=W-252*(HUDZ.gear||1)*_hz*hudUserZ('gear')+Math.min(0,hudOff('gear').dx);      // gear stack, inner edge
'@

SubRx @'
    bw=clamp(bw,LH(52),LH(112));
'@ @'
    bw=Math.max(20,Math.min(bw,LH(112)));   // v16.28: the slots fit the room between the blocks, smaller if they must be, never over the vitals or the gear
'@

SubRx @'
  return {dx:o.dx||0,dy:o.dy||0,c:!!o.c};
'@ @'
  return {dx:o.dx||0,dy:o.dy||0,c:!!o.c&&id!=='body'};   // v16.28, his note: the vitals block (health) never folds away
'@

SubRx @'
var VER='16.27';
'@ @'
var VER='16.28';
'@

$pat = "(?m)^  now:'v16\.27:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.28: THE HP BAR IS ALWAYS THERE AND THE BELT NEVER COVERS IT. His notes. The health block can no longer be folded away, and the tactical belt now fits between the health block and the gear readout as you have sized and moved them, with smaller slots if it has to, instead of drawing over your health. No number moved. Check 16.28 fails on v16.27',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
