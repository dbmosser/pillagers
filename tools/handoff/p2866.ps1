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

# A FIRE NEVER PUTS A BODY THROUGH A WALL (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    for(k=0;k<5;k++){
      ta=a+((k===0)?0:((k&1)?1:-1)*Math.ceil(k/2)*0.55);
      nx=f.x+Math.cos(ta)*(R+1); ny=f.y+Math.sin(ta)*(R+1);
      if(nx>20&&ny>20&&nx<WORLD_W-20&&ny<WORLD_H-20&&spotFree(G.map,nx,ny,Math.max(6,rad*0.6))){ o.x=nx; o.y=ny; break; }
'@ @'
    for(k=0;k<7;k++){   // v27.xx (cloud-robust-fire-wall), CLOUD HUNT 2026-10-15: 7 tries (out to about 95 degrees, enough to slide along a wall), and a spot only with a clear line from where the body stood, so a fire never puts a body through a wall
      ta=a+((k===0)?0:((k&1)?1:-1)*Math.ceil(k/2)*0.55);
      nx=f.x+Math.cos(ta)*(R+1); ny=f.y+Math.sin(ta)*(R+1);
      if(nx>20&&ny>20&&nx<WORLD_W-20&&ny<WORLD_H-20&&spotFree(G.map,nx,ny,Math.max(6,rad*0.6))&&losClear(o.x,o.y,nx,ny,G.map.segs)){ o.x=nx; o.y=ny; break; }
'@

SubRx @'
var VER='28.65';
'@ @'
var VER='28.66';
'@

$pat = "(?m)^  now:'v28\.65:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.66: A fire that lights under you or a machine no longer pushes anyone through a wall. Check 28.66 fails on v28.65',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
