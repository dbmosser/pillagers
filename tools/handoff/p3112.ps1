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

# the frost fog of a dry ice barrel is a thick cloud (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    wc.globalAlpha=0.20*fade; wc.fillStyle='#d6f1ff'; wc.beginPath(); wc.ellipse(x,y,R*0.9,R*0.54,0,0,6.2832); wc.fill();
    wc.globalAlpha=0.45*fade; wc.strokeStyle='#ffffff'; wc.lineWidth=1.2; wc.beginPath(); wc.ellipse(x,y,R*0.88,R*0.53,0,0,6.2832); wc.stroke();
    for(j=0;j<5;j++){   // five soft clouds that drift round the middle
      a=j*1.2566+t*0.22; s=R*(0.62+0.1*Math.sin(t*0.9+j*1.7));
      wc.globalAlpha=0.34*fade; wc.drawImage(sp,x+Math.cos(a)*R*0.34-s,y+Math.sin(a)*R*0.2-s*0.62-16,s*2,s*1.24);
'@ @'
    wc.globalAlpha=0.32*fade; wc.fillStyle='#cfeeff'; wc.beginPath(); wc.ellipse(x,y,R*0.92,R*0.56,0,0,6.2832); wc.fill();   // v28.xx (cw-barrels3b): a thicker fog, it was a faint outline in the pictures
    wc.globalAlpha=0.6*fade; wc.strokeStyle='#ffffff'; wc.lineWidth=1.4; wc.beginPath(); wc.ellipse(x,y,R*0.9,R*0.55,0,0,6.2832); wc.stroke();
    for(j=0;j<6;j++){   // six thick clouds that drift round the middle
      a=j*1.0472+t*0.22; s=R*(0.70+0.1*Math.sin(t*0.9+j*1.7));
      wc.globalAlpha=0.46*fade; wc.drawImage(sp,x+Math.cos(a)*R*0.38-s,y+Math.sin(a)*R*0.22-s*0.62-16,s*2,s*1.24);
'@

SubRx @'
var VER='31.11';
'@ @'
var VER='31.12';
'@

$pat = "(?m)^  now:'v31\.11:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.12: The frost fog a dry ice barrel leaves is now a thick cloud you can read at a glance. Check 31.12 fails on v31.11',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
