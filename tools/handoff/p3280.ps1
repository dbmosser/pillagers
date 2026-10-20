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

# THE RAID BACKPACK LOSES ITS DEAD STRIP AND FLOATING VALUES (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var hh=LH(262)*BZ+rows
'@ @'
var hh=LH(244)*BZ+rows
'@

SubRx @'
x+11+LH(100)*BZ,_ry);
'@ @'
x+11+LH(64)*BZ,_ry);   // v28.xx (cw-bagpolish2), the critic: the value of a detail row floated far from its label, so the value column is closer, and the footer was 90 px of dead panel below the hints, so it is shorter
'@

SubRx @'
ctx.font=bFS(TYPE.title); ctx.fillStyle='#efe9dc';
'@ @'
ctx.font=bFS(TYPE.head); ctx.fillStyle='#efe9dc';   // v28.xx (cw-bagpolish2), the critic: the title outshone the selected item, so it is the item-name size
'@

SubRx @'
(p.ammo===0?'#ff5a4a':'#ffc04a')
'@ @'
(p.ammo===0?'#ff5a4a':'#efe9dc')
'@

SubRx @'
var VER='32.79';
'@ @'
var VER='32.80';
'@

$pat = "(?m)^  now:'v32\.79:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.80: The raid backpack has no dead strip at the bottom and its detail rows read as one line. Check 32.80 fails on v32.79',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
