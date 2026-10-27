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

# RAID GO FULLSCREEN BUTTON OFF THE CLOCK (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  var r=cv.getBoundingClientRect(), sx=(W>0)?r.width/W:1, sy=(H>0)?r.height/H:1, left, tf, top=Math.round(r.top+8*sy);
  if(SCOREBOX.g===G&&SCOREBOX.w>0){ left=Math.round(r.left+(SCOREBOX.x-12)*sx); tf='translateX(-100%)'; }
  else { left=Math.round(r.left+(W/2)*sx); tf='translateX(-50%)'; }
  var lp=left+'px', tp=top+'px';
  if(b.style.left!==lp) b.style.left=lp;
  if(b.style.top!==tp) b.style.top=tp;
  if(b.style.transform!==tf) b.style.transform=tf;
'@ @'
  // v35.03 (cw-fsbtnspot): the top left corner, clear of the score plate, the raid clock and the extract pill in every mode (the first
  // spot sat on the raid clock whenever no score plate was drawn), and sized with the HUD scale so it reads the same at 4K.
  var r=cv.getBoundingClientRect(), z=Math.max(0.75,Math.min(2.2,(r.height>0?r.height:1080)/1080));
  var lp=Math.round(r.left+16*z)+'px', tp=Math.round(r.top+14*z)+'px', fz=Math.round(15*z)+'px', pd=Math.round(7*z)+'px '+Math.round(14*z)+'px';
  if(b.style.left!==lp) b.style.left=lp;
  if(b.style.top!==tp) b.style.top=tp;
  if(b.style.fontSize!==fz) b.style.fontSize=fz;
  if(b.style.padding!==pd) b.style.padding=pd;
'@

SubRx @'
var VER='35.02';
'@ @'
var VER='35.03';
'@

$pat = "(?m)^  now:'v35\.02:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.03: The raid go fullscreen button sits top left, clear of the clock. Check 35.03 fails on v35.02',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
