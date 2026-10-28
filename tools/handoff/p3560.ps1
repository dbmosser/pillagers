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

# BLOCKED PAD READS KEEP THE GAME RUNNING (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function pollPad(){
  if(!navigator.getGamepads) return;
  if(typeof SNIP==='object'&&SNIP&&SNIP.on) return;   // v30.xx (cw-snip): the pad is not read while a snip is up, so a press cannot reach a menu under it
  var gps=navigator.getGamepads(),gp=null;
'@ @'
function pollPad(){
  if(typeof SNIP==='object'&&SNIP&&SNIP.on) return;   // v30.xx (cw-snip): the pad is not read while a snip is up, so a press cannot reach a menu under it
  var gps=[],gp=null;
  // v28.xx (cw-cx-padpollguard): a frame policy can block pad reads; use the ordinary no-pad cleanup and keep drawing.
  try{ if(navigator.getGamepads) gps=navigator.getGamepads()||[]; }catch(_pg){}
'@

SubRx @'
  pollPad();
'@ @'
  // v28.xx (cw-cx-padpollguard): even an unexpected pad-handler failure must leave keyboard, mouse and the rest of this frame running.
  try{ pollPad(); }catch(_pp){ padRelease(); PAD.on=false; PAD.mx=0; PAD.my=0; PAD.aiming=false; RUMBLE.gp=null; RUMBLE.other=null; padBodyCls(); }
'@

SubRx @'
var VER='35.59';
'@ @'
var VER='35.60';
'@

$pat = "(?m)^  now:'v35\.59:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.60: Blocked pad access keeps the game drawing and keyboard and mouse working. Check 35.60 fails on v35.59',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
