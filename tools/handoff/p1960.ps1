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

# THE DOOR PROMPT DODGES AT ITS DRAWN SIZE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
      var _dy=hudDodge(dsc.x,dsc.y,ctx.measureText(_dlab).width/2+6,LH(15),(!haveKey&&kName)?LH(12):0);
'@ @'
      // v19.60, from the review (2026-10-08): with the prompt grown about its place (v19.55), the corner readout dodge was tested at
      // the 1080p size and its lift applied inside the scale. It is tested at the size drawn, in screen pixels, and brought back in.
      var _dr=_hsD?Math.max(1,hudRes()):1;
      var _dy=hudDodge(dsc.x,dsc.y,(ctx.measureText(_dlab).width/2+6)*_dr,LH(15)*_dr,((!haveKey&&kName)?LH(12):0)*_dr);
      _dy=dsc.y+(_dy-dsc.y)/_dr;
'@

SubRx @'
var VER='19.59';
'@ @'
var VER='19.60';
'@

$pat = "(?m)^  now:'v19\.59:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.60: At 4K a door prompt near the corner readout steps clear of it. Check 19.60 fails on v19.59',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
