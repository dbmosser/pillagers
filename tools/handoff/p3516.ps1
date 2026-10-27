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

# FPS COUNTER SCREEN RATE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    s=FPSV.fps+' FPS'; if(el.textContent!==s) el.textContent=s; if(el.className!=='on') el.className='on';
'@ @'
    // v28.xx (cw-cx-fpsscreen): his 10-27 question, "my screen is set to 144 fps, but it still says 60 fps". VSYNC.ms is positive only after enough refresh samples; show the screen rate when the cap exceeds it by more than 5.
    s=FPSV.fps+' fps'; if(VSYNC.ms>0&&CFG.fpsCap>1000/VSYNC.ms+5) s+=' | screen '+Math.round(1000/VSYNC.ms);
    if(el.textContent!==s) el.textContent=s; if(el.className!=='on') el.className='on';
'@

SubRx @'
var VER='35.15';
'@ @'
var VER='35.16';
'@

$pat = "(?m)^  now:'v35\.15:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.16: The fps counter adds screen 60 when a settled screen rate is more than 5 below the selected cap. Frame timing and quality stay the same. Check 35.16 fails on v35.15',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
