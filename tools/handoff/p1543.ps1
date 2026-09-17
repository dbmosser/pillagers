$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

SubRx @'
  var _tSrc=_noClk?(G.t||0):G.timeLeft;
  var mm=Math.floor(_tSrc/60),ss=Math.floor(_tSrc%60);
  ctx.fillStyle=(!_noClk&&G.timeLeft<45)?'#ff5a4a':'#cdd6dd';
'@ @'
  // v15.43, hud audit finding: THE RAID CLOCK READS 0:10 WHEN TEN SECONDS IS SAID, AND 0:00 ONLY WHEN IT IS OUT. The countdown
  // rounded its seconds down, and tickClockWarn fires on the frame the clock crosses a mark. So TEN SECONDS was said and the
  // first tick played with 0:09 on screen, THIRTY SECONDS with 0:29 and 1 minute left with 0:59; the last tick played as the
  // figure turned 0:00, and a whole second then passed at 0:00 before the site began to burn. Once it burns the loop runs the
  // clock on below zero, and the floor of a negative figure drew -1:0-1, then -1:0-2 and -1:0-3. Every other countdown rounds
  // up (EXTRACT NOW, INBOUND, the closes in line on the map), so an extraction window clamped to the clock read 3S LEFT beside
  // 0:02. The countdown now rounds up and stops at zero: each figure turns on the same frame as its warning, 0:00 means the
  // clock is out, and red tests the figure shown, so it still starts at 0:44. The count up with the clock off, tickClockWarn
  // and every number are unchanged.
  var _tSrc=_noClk?(G.t||0):Math.ceil(Math.max(0,G.timeLeft));
  var mm=Math.floor(_tSrc/60),ss=Math.floor(_tSrc%60);
  ctx.fillStyle=(!_noClk&&_tSrc<45)?'#ff5a4a':'#cdd6dd';
'@
SubRx @'
var VER='15.42';
'@ @'
var VER='15.43';
'@

$pat = "(?m)^  now:'v15\.42:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.43: THE RAID CLOCK READS 0:10 WHEN TEN SECONDS IS SAID, AND 0:00 ONLY WHEN IT IS OUT. The clock rounded its seconds down, so TEN SECONDS was said with 0:09 on screen, the last tick played as it turned 0:00, a whole second then passed at 0:00 before the site began to burn, and through the burn it read -1:0-1. It now rounds up like every other countdown and stops at zero, so each warning lands on the figure it names and red still starts at 0:44. Check 15.43 crosses one minute, thirty, ten and one second through the clock warning and reads the drawn clock on the frames either side, with whole seconds and the count up as controls; it fails on v15.42',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
