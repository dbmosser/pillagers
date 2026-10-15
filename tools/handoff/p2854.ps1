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

# HOWLER LANDING CIRCLE SHOWS THE REAL BLAST (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    wc.beginPath(); wc.ellipse(SHD.tx,SHD.ty,RR3*_sf,RR3*_sf*0.6,0,0,6.2832); wc.fill();
    wc.strokeStyle='rgba(255,90,60,.14)'; wc.lineWidth=1;
    wc.beginPath(); wc.ellipse(SHD.tx,SHD.ty,RR3,RR3*0.6,0,0,6.2832); wc.stroke();
    wc.strokeStyle='rgba(255,90,60,'+(0.25+0.45*_sf).toFixed(3)+')';
    wc.lineWidth=2;
    wc.beginPath(); wc.ellipse(SHD.tx,SHD.ty,RR3*_sf,RR3*_sf*0.6,0,0,6.2832); wc.stroke();
'@ @'
    // v28.54 (cloud-feel-howler-circle), CLOUD HUNT 2026-10-15: the circle was drawn squashed to 0.6 of its height, but the world is drawn
    // true to scale and the shell hurts everyone within its reach in every direction, so men north or south of it were hit outside it. Now round.
    wc.beginPath(); wc.ellipse(SHD.tx,SHD.ty,RR3*_sf,RR3*_sf,0,0,6.2832); wc.fill();
    wc.strokeStyle='rgba(255,90,60,.14)'; wc.lineWidth=1;
    wc.beginPath(); wc.ellipse(SHD.tx,SHD.ty,RR3,RR3,0,0,6.2832); wc.stroke();
    wc.strokeStyle='rgba(255,90,60,'+(0.25+0.45*_sf).toFixed(3)+')';
    wc.lineWidth=2;
    wc.beginPath(); wc.ellipse(SHD.tx,SHD.ty,RR3*_sf,RR3*_sf,0,0,6.2832); wc.stroke();
'@

SubRx @'
var VER='28.53';
'@ @'
var VER='28.54';
'@

$pat = "(?m)^  now:'v28\.53:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.54: The Howler landing circle is now round and shows exactly where the shell hurts; before it was squashed and men just above or below it still got hit. Check 28.54 fails on v28.53',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
