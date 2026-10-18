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

# HEAVY AND RAIDER ARMOUR IS CHIPPED AND STRIPED (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    wc.fillStyle='#9aa6b2'; wc.fillRect(cx-HP+0.9,py0+1.0,0.9,0.9); wc.fillRect(cx+HP-1.8,py0+1.0,0.9,0.9);
'@ @'
    wc.fillStyle='#9aa6b2'; wc.fillRect(cx-HP+0.9,py0+1.0,0.9,0.9); wc.fillRect(cx+HP-1.8,py0+1.0,0.9,0.9);
    // v28.xx (cw-setplates), art build step b (char-art-build-brief): "chunkier armour plates ... chipped paint edges and colour-panel stripes on armour",
    // most of all on the Heavy and Raider sets. Two scheme colour panel stripes down the plate sides and six bare steel chips on the edges. Inside the old outline.
    wc.fillStyle=A; wc.fillRect(cx-HP+1.6,py0+2.8,1.0,3.1); wc.fillRect(cx+HP-2.6,py0+2.8,1.0,3.1);
    wc.fillStyle='#dfe6ec';
    wc.fillRect(cx-HP+0.3,py0+3.4,1.0,0.9); wc.fillRect(cx-HP+3.4,py0+0.2,1.0,0.9); wc.fillRect(cx-HP+1.6,py0+7.5,1.0,0.9);
    wc.fillRect(cx+HP-1.4,py0+3.2,1.0,0.9); wc.fillRect(cx+2.8,py0+0.3,1.0,0.9); wc.fillRect(cx+HP-4.0,py0+7.4,1.0,0.9);
'@

SubRx @'
    wc.fillStyle=A; wc.fillRect(px-5.6,y0+3.4,11.2,1.3);
'@ @'
    wc.fillStyle=A; wc.fillRect(px-5.6,y0+3.4,11.2,1.3);
    // v28.xx (cw-setplates): the Heavy pauldron is a layered plate: a lower lip, a panel seam, three rivets under the colour stripe and four bare steel paint chips.
    wc.strokeStyle='#363f48'; wc.lineWidth=1.1; wc.beginPath(); wc.ellipse(px,y0+2.6,6.2,4.7,0,0.15,2.99); wc.stroke();
    wc.fillStyle='#2f363d'; wc.fillRect(px+1.6,y0-2.0,0.8,2.8);
    wc.fillStyle='#1d2227'; wc.fillRect(px-3.7,y0+3.3+1.4,1.1,1.1); wc.fillRect(px-0.5,y0+3.3+1.4,1.1,1.1); wc.fillRect(px+2.7,y0+3.3+1.4,1.1,1.1);
    wc.fillStyle='#b8c3cd'; wc.fillRect(px-3.7,y0+4.7,0.5,0.5); wc.fillRect(px-0.5,y0+4.7,0.5,0.5); wc.fillRect(px+2.7,y0+4.7,0.5,0.5);
    wc.fillStyle='#dfe6ec';
    wc.fillRect(px-5.6,y0+1.0,1.2,0.9); wc.fillRect(px-3.4,y0-1.0,1.2,0.9); wc.fillRect(px+4.6,y0+3.6-1.0,1.2,0.9); wc.fillRect(px+1.4,y0+6.6,1.2,0.9);
'@

SubRx @'
      wc.strokeStyle=A; wc.lineWidth=0.9; wc.beginPath(); wc.ellipse(px,y0+2.4,4.2,3.3,0,0.3,2.9); wc.stroke();
'@ @'
      wc.strokeStyle=A; wc.lineWidth=0.9; wc.beginPath(); wc.ellipse(px,y0+2.4,4.2,3.3,0,0.3,2.9); wc.stroke();
      // v28.xx (cw-setplates): the Raider pad is chipped: two bare steel flecks on the lit edge (the spiked pad keeps its clean paint).
      if(id==='padsround'){ wc.fillStyle='#dfe6ec'; wc.fillRect(px-3.4,y0+0.5,1.1,0.8); wc.fillRect(px+3.0,y0+1.2,1.1,0.8); }
'@

SubRx @'
var VER='29.42';
'@ @'
var VER='29.43';
'@

$pat = "(?m)^  now:'v29\.42:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.43: Heavy and Raider armour now shows chipped paint and colour stripes. Check 29.43 fails on v29.42',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
