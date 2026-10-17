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

# THE HELD GUN CASTS A SHADOW (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  wc.drawImage(B.c,B.x0+ext,B.y0,B.w,B.h);

'@ @'
  // v28.xx (cw-gunshadow), art build step 5 (char-art-build-brief): "a soft cast shadow and a gun shadow". Lit from the top left, the gun throws a
  // soft dark strip down onto the body and the far arm under it. Drawn before the gun sprite, so only the lower fringe shows.
  wc.fillStyle='rgba(0,0,0,.26)'; wc.fillRect(D.rv[0]+ext+1,D.by+1.2,D.tip-D.rv[0]-3,D.rv[1]+D.rv[3]-D.by+0.4);
  wc.drawImage(B.c,B.x0+ext,B.y0,B.w,B.h);

'@

SubRx @'
var VER='28.81';
'@ @'
var VER='28.82';
'@

$pat = "(?m)^  now:'v28\.81:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.82: Guns in hand now cast a soft shadow on the body under them. Check 28.82 fails on v28.81',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
