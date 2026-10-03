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

# A SLOW PC IS TOLD WHERE THE LEVERS ARE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var HID={w:null,lastRaf:0,fromWorker:0,ticks:0};
'@ @'
// v17.87, AAA CHECK (2026-10-02): A SLOW PC IS TOLD WHERE THE LEVERS ARE. On a weak machine the frame runs long and nothing says
// why or what to do. The loop keeps a ten second window of raid frames; when more than half of them ran over 25 ms (under 40
// frames a second) the game says, once a session, that Settings has Render resolution and Effects. Measured on the raw frame
// gap, not the clamped dt, so a capped frame rate (Frame cap) does not count as slow.
var PERF={win:[],at:0,said:0};
function perfNote(gapMs){
  var now=(typeof performance!=='undefined')?performance.now():Date.now(), i, slow=0;
  if(!(gapMs>0)||gapMs>1000) return false;
  PERF.win.push([now,gapMs]);
  while(PERF.win.length&&now-PERF.win[0][0]>10000) PERF.win.shift();
  if(PERF.said||PERF.win.length<60) return false;
  for(i=0;i<PERF.win.length;i++) if(PERF.win[i][1]>25) slow++;
  if(slow*2>PERF.win.length){ PERF.said=1; try{ sayWhenFree('Running slowly? Settings has Render resolution and Effects to lighten the load.'); }catch(_ps){} return true; }
  return false;
}
var HID={w:null,lastRaf:0,fromWorker:0,ticks:0};
'@

SubRx @'
  var dt=clamp((ts-lastTs)/1000,0,.05); lastTs=ts;
'@ @'
  var gap0=ts-lastTs; var dt=clamp(gap0/1000,0,.05); lastTs=ts;   // v17.87: gap0 is the raw frame gap, for perfNote
  if(state==='raid'&&G&&!G.over&&!G.sim&&!(CFG.fpsCap>0)) perfNote(gap0);   // v17.87: a slow PC is told where the levers are
'@

SubRx @'
var VER='17.86';
'@ @'
var VER='17.87';
'@

$pat = "(?m)^  now:'v17\.86:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.87: If the game runs slowly on a PC, it says once where the Settings levers are. Check 17.87 fails on v17.86',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
