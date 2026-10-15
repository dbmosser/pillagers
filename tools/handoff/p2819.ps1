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

# PLAYER 2 KEEPS THE CONVOY WHEN THE HOST LEAVES (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(ev.id==='convoy'){ a=[(d.car&&d.car.nid)|0,[],d.over?1:0]; for(i=0;d.crew&&i<d.crew.length&&i<8;i++) if(d.crew[i]&&d.crew[i].nid) a[1].push(d.crew[i].nid); return a; }
'@ @'
  if(ev.id==='convoy'){ a=[(d.car&&d.car.nid)|0,[],d.over?1:0,Math.round(d.dx),Math.round(d.dy)]; for(i=0;d.crew&&i<d.crew.length&&i<8;i++) if(d.crew[i]&&d.crew[i].nid) a[1].push(d.crew[i].nid); return a; }   // v28.19 (cloud-coop-convoy-dest), CLOUD HUNT 2026-10-15: the convoy destination goes in the word too, so a player 2 window that takes over runs it to the same point
'@

SubRx @'
    d.car=evEnt(X[0]|0); d.crew=[]; for(i=0;X[1]&&i<X[1].length&&i<8;i++){ c=evEnt(X[1][i]|0); if(c) d.crew.push(c); } d.over=X[2]?1:0;
'@ @'
    d.car=evEnt(X[0]|0); d.crew=[]; for(i=0;X[1]&&i<X[1].length&&i<8;i++){ c=evEnt(X[1][i]|0); if(c) d.crew.push(c); } d.over=X[2]?1:0;
    if(isFinite(+X[3])&&isFinite(+X[4])){ d.dx=+X[3]; d.dy=+X[4]; }   // v28.19 (cloud-coop-convoy-dest), CLOUD HUNT 2026-10-15: take the host destination (an older word without it changes nothing)
'@

SubRx @'
      if(e===car){ e.tx=ev.d.dx; e.ty=ev.d.dy; }
'@ @'
      if(e===car){ if(isFinite(ev.d.dx)&&isFinite(ev.d.dy)){ e.tx=ev.d.dx; e.ty=ev.d.dy; } }   // v28.19 (cloud-coop-convoy-dest), CLOUD HUNT 2026-10-15: never steer the carrier to NaN
'@

SubRx @'
var VER='28.18';
'@ @'
var VER='28.19';
'@

$pat = "(?m)^  now:'v28\.18:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.19: If your host leaves while a machine convoy is on its way, the convoy still comes and you can still kill the carrier for its crate. Check 28.19 fails on v28.18',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
