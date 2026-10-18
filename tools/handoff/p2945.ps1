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

# THE RAIDER HELMET AND BANDOLIER ARE CHIPPED (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
      wc.fillStyle=_SCH?_SCH.a:'#e8d890'; wc.fillRect(hx2+fl*3.8-1.5,ty-46.1,3.0,2.4);
'@ @'
      wc.fillStyle=_SCH?_SCH.a:'#e8d890'; wc.fillRect(hx2+fl*3.8-1.5,ty-46.1,3.0,2.4);
      // v28.xx (cw-raiderchip), art build step b (char-art-build-brief): "chipped paint edges and colour-panel stripes on armour ... heavy headgear". The Raider helmet gets a scheme colour panel stripe across the dome and four bare steel paint chips, all inside the old outline.
      wc.fillStyle=_SCH?_SCH.a:'#e8d890'; wc.fillRect(hx2-7.2,ty-40.4,14.4,1.1);
      wc.fillStyle='#dfe6ec'; wc.fillRect(hx2-7.4,ty-41.6,1.4,1.0); wc.fillRect(hx2+5.4,ty-42.6,1.4,1.0); wc.fillRect(hx2+6.4,ty-38.2,1.4,1.0); wc.fillRect(hx2-4.6,ty-38.0,1.4,1.0);
'@

SubRx @'
    wc.fillStyle=INK; wc.fillRect(x1-0.9,y1-1.1,3.0,3.0); wc.fillStyle=A; wc.fillRect(x1-0.4,y1-0.6,2.0,2.0);
'@ @'
    wc.fillStyle=INK; wc.fillRect(x1-0.9,y1-1.1,3.0,3.0); wc.fillStyle=A; wc.fillRect(x1-0.4,y1-0.6,2.0,2.0);
    // v28.xx (cw-raiderchip): the Raider bandolier strap is worn: four bare steel flecks on its lit edge, between the cartridges.
    wc.fillStyle='#dfe6ec'; for(i=0;i<4;i++){ t=0.23+i*0.18; px=x1+(x2-x1)*t; py=y1+(y2-y1)*t; wc.fillRect(px-0.7,py-1.0,1.4,1.0); }
'@

SubRx @'
var VER='29.44';
'@ @'
var VER='29.45';
'@

$pat = "(?m)^  now:'v29\.44:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.45: The Raider helmet and bandolier now show chipped paint and a colour stripe. Check 29.45 fails on v29.44',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
