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

# FRAME CAPS THAT HOLD THEIR NUMBER (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function frameCapSkip(ts){ var c=+CFG.fpsCap; if(!(c>0)) return false; if(ts-CAP_LAST<1000/c-2) return true; CAP_LAST=ts; return false; }
'@ @'
function frameCapSkip(ts){ var c=+CFG.fpsCap, iv; if(!(c>0)){ CAP_LAST=0; return false; } iv=1000/c; if(CAP_LAST>0&&ts<CAP_LAST-1) return true; CAP_LAST=(CAP_LAST>0&&ts-CAP_LAST<iv)?CAP_LAST+iv:ts+iv; return false; }   /* v28.xx (cw-fpscap), HIS ORDER (2026-10-25): "I want higher frame rates to be an option, eg 75, 90, 120, 144, 240". CAP_LAST is now the time the next frame is due (0: none yet). The old test (a frame at least 1000/c-2 ms after the last) snapped to whole screen refreshes: 60 drew 48 on a 144 Hz screen, 75 and 90 drew 72, 90 drew 60 on 120 Hz. Due times step by exactly 1000/c, so the average is the cap; a frame 1 ms early is on time (stamps jitter); a frame a whole step late starts the schedule again from now, so a hitch never brings a burst. */
'@

SubRx @'
function cycleGameOpt(k){
'@ @'
var GO_SEQ={fpsCap:[0,2,1,3,4,5,6,7,8]};   /* v28.xx (cw-fpscap), his 10-25 order: the Frame cap row stepped off, 60, 30 before 75 to 240, so it read as if nothing went over 60. A click now steps off, 30, 60, 75, 90, 120, 144, 165, 240; the options keep their saved index. */ function cycleGameOpt(k){
'@

SubRx @'
P.gameOpts[k]=(_cur+1)%row.opts.length;
'@ @'
var _sq=GO_SEQ[k]; P.gameOpts[k]=(_sq&&_sq.length===row.opts.length&&_sq.indexOf(_cur)>=0)?_sq[(_sq.indexOf(_cur)+1)%_sq.length]:(_cur+1)%row.opts.length;   // v28.xx (cw-fpscap): a row with a step order follows it
'@

SubRx @'
var VER='34.81';
'@ @'
var VER='34.82';
'@

$pat = "(?m)^  now:'v34\.81:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v34.82: Settings, display, frame cap now steps off, 30, 60, 75, 90, 120, 144, 165, 240, and each cap gives its own number of frames (show fps shows it). A cap above the screen refresh gives the screen rate. Check 34.82 fails on v34.81',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
