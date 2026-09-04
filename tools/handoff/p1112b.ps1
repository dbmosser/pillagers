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

# THE FOURTH PLACE, AND THE ONE THAT MATTERED. The grid route came out of the
# door correctly; the string-pull then threw the corner away because it could
# SEE from the start straight to the goal, through the window. Measured with the
# other three fixed: the path was two points long and the first one was the
# target, so the crawler walked into the glass exactly as before.
SubRx @'
      var a=pt(cells[i2]),b2=pt(cells[j]);
      if(losClear(a.x,a.y,b2.x,b2.y,G.map.segs)) break;
'@ @'
      var a=pt(cells[i2]),b2=pt(cells[j]);
      // v11.12: walkClear. A corner that only looks skippable because there is
      // a window in the way is the corner that takes the body out of the door.
      if(walkClear(a.x,a.y,b2.x,b2.y)) break;
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
