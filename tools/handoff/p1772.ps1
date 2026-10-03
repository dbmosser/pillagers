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

# A COVERED HOST WINDOW KEEPS THE RAID RUNNING (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function loop(ts){
  requestAnimationFrame(loop);
'@ @'
// v17.72, AAA CHECK (2026-10-02): A COVERED HOST WINDOW KEEPS THE RAID RUNNING. The host window runs every body for the party,
// and the browser stops its frames when the window is covered by another (his son's window dragged over it, or minimised):
// the raid froze for the teammate too. A worker clock, which the browser does not throttle, ticks the frame while the frames
// are not coming and this window hosts a shared raid: HID.lastRaf is stamped by the real frames; a worker tick 200 ms after
// the last one runs loop() without queuing another frame request. Solo, a covered window still stands still, which is the
// pause it always was. Drawing into a covered window is cheap and harmless.
var HID={w:null,lastRaf:0,fromWorker:0,ticks:0};
function hidWant(){ return !!(typeof NET==='object'&&NET&&NET.on&&NET.role==='host'&&typeof netEntsHost==='function'&&netEntsHost()); }
function hidTick(){
  var now=(typeof performance!=='undefined')?performance.now():Date.now();
  if(!(now-HID.lastRaf>200)||!hidWant()) return false;
  HID.fromWorker=1; HID.ticks++;
  try{ loop(now); }catch(_ht){} finally{ HID.fromWorker=0; }
  return true;
}
function hidStart(){
  if(HID.w||typeof Worker==='undefined'||typeof Blob==='undefined'||typeof URL==='undefined'||!URL.createObjectURL) return false;
  try{
    HID.w=new Worker(URL.createObjectURL(new Blob(['setInterval(function(){ postMessage(0); },33);'],{type:'text/javascript'})));
    HID.w.onmessage=function(){ hidTick(); };
    return true;
  }catch(_hw){ HID.w=null; return false; }
}
function loop(ts){
  if(!HID.fromWorker){ requestAnimationFrame(loop); HID.lastRaf=(typeof performance!=='undefined')?performance.now():Date.now(); if(!HID.w) hidStart(); }
'@

SubRx @'
var VER='17.71';
'@ @'
var VER='17.72';
'@

$pat = "(?m)^  now:'v17\.71:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.72: Two-player: if the player 1 window is covered or minimised, the raid keeps running for player 2 instead of freezing. Check 17.72 fails on v17.71',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
