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

# THE MAP KEEPS THE CLOSING TIME DURING AN EXTRACT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
      ctx.fillText(_zSub,ox+Z.x*sc,oy+Z.y*sc-Math.max(4,Z.r*sc)-LH(6)*_MZ);
'@ @'
      ctx.fillText(_zSub,ox+Z.x*sc,oy+Z.y*sc-Math.max(4,Z.r*sc)-LH(6)*_MZ);
      // v21.15, HIS NOTE (2026-10-08): "on the map when an extract is in progress you still need to show the aggregate amt of time
      // that extract stays open in terms of match length so player can plan his route". A called ring and a ring in progress showed
      // only the call or the hold, and the closing countdown every other ring shows was gone just when the route is planned. It
      // stays now, on its own row under the ring, in the same words the other rings use.
      if(Z.open&&(_zAct||_zHold)) ctx.fillText((Z.closeAt===undefined)?'STAYS OPEN':('closes in '+fmtMS(Math.max(0,Math.ceil(G.timeLeft-Z.closeAt)))),ox+Z.x*sc,oy+Z.y*sc+Math.max(4,Z.r*sc)+LH(16)*_MZ);
'@

SubRx @'
var VER='21.14';
'@ @'
var VER='21.15';
'@

$pat = "(?m)^  now:'v21\.14:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.15: On the map, a called extraction and one in progress still show when they close. Check 21.15 fails on v21.14',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
