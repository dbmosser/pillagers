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

# ==== v9.09 POKED THE BOTTOM-RIGHT CORNER BY HAND. It asks whether the pointer
# ==== over the resize grip is a resize arrow rather than the aiming reticle, and
# ==== it found that corner by doing the arithmetic itself: B.x+B.w-8, B.y+B.h-8.
# ==== On a panel that now grips on its LEFT that lands on the panel body, and
# ==== the check correctly reported both that the corner draws the reticle and,
# ==== in its own control, that the spot it picked hit-tests as body.
# ==== It asks the game where the grip is now, which is the point of there being
# ==== one function: a check that recomputes a rule is a second copy of it.
SubRx @'
     var grip =sig(Math.round(B.x+B.w-8), Math.round(B.y+B.h-8));
'@ @'
     // v10.91: ASK, do not recompute. The grip moved to the left corner on
     // panels pinned to the right edge of the screen, and a check that works out
     // the corner for itself is a second copy of the rule that can disagree.
     var _gp=(typeof hudGrip==='function')?hudGrip(B):{x:B.x+B.w,y:B.y+B.h,left:false};
     var grip =sig(Math.round(_gp.left?(_gp.x+8):(_gp.x-8)), Math.round(_gp.y-8));
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
