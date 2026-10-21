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

# ONLY THE HEAD IS SCALED UP, NOT THE SHOULDERS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  // v10.54, his notes: THE SUIT'S OWN PAINT. Last, over everything the racks
'@ @'
  wc.restore();   // v33.xx (cw-headbody), job 68, his a01 D: the scaled head ends with the hair, face and hats; the suit body paint, caps and pads below draw at body scale (pads at their own FIG_VEST, his a05 B)
  // v10.54, his notes: THE SUIT'S OWN PAINT. Last, over everything the racks
'@

SubRx @'
      wc.fillRect(x-4.6+swing2*.5,ty-10.4,1.4,6.4-liftB*.5); wc.fillRect(x+3.4+swing*.5,ty-10.4,1.4,6.4-liftA*.5);
'@ @'
      wc.fillRect(x-4.6+swing2*.5,ty-10.4,1.4,6.4-liftB*.5); wc.fillRect(x+3.4+swing*.5,ty-10.4,1.4,6.4-liftA*.5);
      wc.save(); wc.translate(hx2,ty-22); wc.scale(FIG_HEAD,FIG_HEAD); wc.translate(-hx2,-(ty-22));   // v33.xx (cw-headbody): scaled head for the skull
'@

SubRx @'
      wc.fillRect(hx2-2.6,ty-25.4,0.8,1.8); wc.fillRect(hx2-0.4,ty-25.4,0.8,1.8); wc.fillRect(hx2+1.8,ty-25.4,0.8,1.8);
'@ @'
      wc.fillRect(hx2-2.6,ty-25.4,0.8,1.8); wc.fillRect(hx2-0.4,ty-25.4,0.8,1.8); wc.fillRect(hx2+1.8,ty-25.4,0.8,1.8);
      wc.restore();   // v33.xx (cw-headbody)
'@

SubRx @'
      wc.fillStyle=INK;       rrF(hx2-7.8,ty-32.4,15.6,5.4,1.4);
'@ @'
      wc.save(); wc.translate(hx2,ty-22); wc.scale(FIG_HEAD,FIG_HEAD); wc.translate(-hx2,-(ty-22));   // v33.xx (cw-headbody): scaled head for the robot eye bar and antenna
      wc.fillStyle=INK;       rrF(hx2-7.8,ty-32.4,15.6,5.4,1.4);
'@

SubRx @'
      wc.fillStyle='#ff3a3a'; wc.fillRect(hx2-1.1,ty-43.6,2.2,1.6);
'@ @'
      wc.fillStyle='#ff3a3a'; wc.fillRect(hx2-1.1,ty-43.6,2.2,1.6);
      wc.restore();   // v33.xx (cw-headbody)
'@

SubRx @'
      wc.fillStyle=INK;       rrF(hx2-7.8,ty-32.0,15.6,4.6,1.4);
'@ @'
      wc.save(); wc.translate(hx2,ty-22); wc.scale(FIG_HEAD,FIG_HEAD); wc.translate(-hx2,-(ty-22));   // v33.xx (cw-headbody): scaled head for the android eye band
      wc.fillStyle=INK;       rrF(hx2-7.8,ty-32.0,15.6,4.6,1.4);
'@

SubRx @'
      wc.fillStyle='#1a1c22'; rrF(hx2-7.2,ty-31.5,14.4,3.6,1.1);
'@ @'
      wc.fillStyle='#1a1c22'; rrF(hx2-7.2,ty-31.5,14.4,3.6,1.1);
      wc.restore();   // v33.xx (cw-headbody)
'@

SubRx @'
      wc.fillStyle=INK;       rrF(hx2-12.6,ty-38.8,25.2,3.8,1.9);
'@ @'
      wc.save(); wc.translate(hx2,ty-22); wc.scale(FIG_HEAD,FIG_HEAD); wc.translate(-hx2,-(ty-22));   // v33.xx (cw-headbody): scaled head for the peddler hat
      wc.fillStyle=INK;       rrF(hx2-12.6,ty-38.8,25.2,3.8,1.9);
'@

SubRx @'
      wc.fillStyle='#7c5c40'; wc.fillRect(hx2-6.0,ty-42.6,6.4,1.0); wc.fillRect(hx2-11.2,ty-38.2,8,0.8);
'@ @'
      wc.fillStyle='#7c5c40'; wc.fillRect(hx2-6.0,ty-42.6,6.4,1.0); wc.fillRect(hx2-11.2,ty-38.2,8,0.8);
      wc.restore();   // v33.xx (cw-headbody)
'@

SubRx @'
      wc.fillStyle=INK; wc.fillRect(hx2-8.1,ty-36.8,16.2,3.0);
'@ @'
      wc.save(); wc.translate(hx2,ty-22); wc.scale(FIG_HEAD,FIG_HEAD); wc.translate(-hx2,-(ty-22));   // v33.xx (cw-headbody): scaled head for the survivor head bandage
      wc.fillStyle=INK; wc.fillRect(hx2-8.1,ty-36.8,16.2,3.0);
'@

SubRx @'
      wc.fillStyle='#9a2a20'; wc.fillRect(hx2+3.0,ty-36.2,1.6,1.3);
'@ @'
      wc.fillStyle='#9a2a20'; wc.fillRect(hx2+3.0,ty-36.2,1.6,1.3);
      wc.restore();   // v33.xx (cw-headbody)
'@

SubRx @'
  // a small mouth, hurt pulls it into a grimace
'@ @'
  wc.save(); wc.translate(hx2,ty-22); wc.scale(FIG_HEAD,FIG_HEAD); wc.translate(-hx2,-(ty-22));   // v33.xx (cw-headbody): the head scale again for the mouth (closed by the restore after it)
  // a small mouth, hurt pulls it into a grimace
'@

SubRx @'
var VER='33.16';
'@ @'
var VER='33.17';
'@

$pat = "(?m)^  now:'v33\.16:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v33.17: The head, hair, hats, face and suit head marks stay 1.2; shoulder caps and suit body paint are back at body scale and the pauldrons at 1.12. Check 33.17 fails on v33.16',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
