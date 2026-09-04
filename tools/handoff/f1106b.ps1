$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}
# ==== v10.46's INK FLOOR WAS CALIBRATED ON THE BLOCK HE COMPLAINED ABOUT.
# ==== It wanted 8 ink pixels of side panel at raid scale, and it got them
# ==== because the panels were 2.4 wide each on a 13 wide chest. v11.06 makes
# ==== them trim, and the honest thing is to MEASURE AGAIN rather than to widen
# ==== the art back until the old number returns.
# ==== MEASURED on v11.06 at raid scale, jersey against slate: red +58, pale +24,
# ==== ink +4. The floor goes to 2, half the live reading, which still catches
# ==== the panels being deleted and no longer demands the block.
SubRx @'
     if(cnt(jr,isInk)-cnt(sl,isInk)<8) bad.push('the jersey has no black side panels on the sprite');
'@ @'
     // v11.06: the panels are TRIM now, on his note that they read as backpack
     // straps. Live reading at raid scale is 4; the floor is half of it, which
     // still catches them being removed altogether.
     if(cnt(jr,isInk)-cnt(sl,isInk)<2) bad.push('the jersey has no black side panels on the sprite ('+(cnt(jr,isInk)-cnt(sl,isInk))+' ink px more than slate, live reading is 4)');
'@
$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
