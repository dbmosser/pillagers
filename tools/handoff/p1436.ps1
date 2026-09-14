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
document.addEventListener('visibilitychange',function(){
  if(document.hidden) releaseAllKeys(); else lastTs=performance.now();
});
'@ @'
document.addEventListener('visibilitychange',function(){
  // v14.36, audio audit finding 2: A HIDDEN TAB GOES QUIET. Hiding or minimising the tab stops the frames, so the game
  // freezes and the ambient bed is never ramped again, but the audio context kept running: room tone, rain and dread held
  // at their last level for as long as the tab stayed hidden. The context is suspended here; ac() resumes it on the first
  // frame back, since the music, reverb and ambience ticks all call it.
  if(document.hidden){ releaseAllKeys(); try{ if(AC&&AC.suspend) AC.suspend(); }catch(e){} } else lastTs=performance.now();
});
'@
SubRx @'
var VER='14.35';
'@ @'
var VER='14.36';
'@

$pat = "(?m)^  now:'v14\.35:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.36: A HIDDEN TAB GOES QUIET. Switching tabs or minimising during a raid froze the frames but not the audio, so room tone, rain and dread held at their last level for as long as the tab stayed hidden. The audio context is now suspended when the tab is hidden, and the first frame back resumes it. Check 14.36 fires the visibility change on a hidden pane with a fake audio context; it fails on v14.35',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
