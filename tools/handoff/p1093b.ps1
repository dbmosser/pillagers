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

# ---- MY OWN ANNOUNCEMENT PUT THE NAME BACK. The new-in card line and the
# ---- what-is-new-now line both spelled out the old three word name in order to
# ---- say it had gone, which is the name still occurring, which is the thing he
# ---- asked to stop. Caught by the v10.93 check on my own build. Reworded so the
# ---- change is still announced without reprinting what it replaced.
SubRx @'
  'THE UNDERCROFT READS PROPERLY NOW. The station names were painted into the room before the room went dark, so the darkness went over them as well; they are drawn on top of it now and are no longer see-through. The controls line and the line under each station prompt came up with them. THE DISCOUNT FASHION DEPOT IS NOW CALLED FASHION.',
'@ @'
  'THE UNDERCROFT READS PROPERLY NOW. The station names were painted into the room before the room went dark, so the darkness went over them as well; they are drawn on top of it now and are no longer see-through. The controls line and the line under each station prompt came up with them. THE STATION WITH THE RACKS IS NOW CALLED FASHION, everywhere.',
'@
SubRx @'
  now:'v10.93: the text in the Undercroft, your note. The station names were painted into the world BEFORE the room darkness went over it, so they kept 60 percent of an already see-through 75 percent. They are drawn on top of the darkness now, opaque, on a firm plate. And the Discount Fashion Depot is called FASHION everywhere.',
'@ @'
  now:'v10.93: the text in the Undercroft, your note. The station names were painted into the world BEFORE the room darkness went over it, so they kept 60 percent of an already see-through 75 percent. They are drawn on top of the darkness now, opaque, on a firm plate. And the station with the racks is called FASHION everywhere.',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
