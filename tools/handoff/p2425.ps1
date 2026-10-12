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

# THE TITLE FITS A 4K SCREEN, NO FALSE ERROR (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    nat=col.scrollHeight; room=(window.innerHeight||1080)*0.985;
'@ @'
    nat=col.scrollHeight; room=(window.innerHeight||1080)*0.985;
    // v24.25 (ui5b, the 4K title shot): the screen padding round the column is zoomed with it, so it is part of what must fit
    try{ var _tcs=getComputedStyle(ti); nat+=(parseFloat(_tcs.paddingTop)||0)+(parseFloat(_tcs.paddingBottom)||0); }catch(_tp){}
'@

SubRx @'
  try{ if(col&&typeof ResizeObserver==='function') new ResizeObserver(function(){ if(ti.classList.contains('on')) titleFit(); }).observe(col); }catch(_ro){}
'@ @'
  // v24.25 (ui5b): the refit waits for the next frame; changing the zoom inside the callback made the browser post a loop notice
  try{ if(col&&typeof ResizeObserver==='function') new ResizeObserver(function(){ if(titleFit.raf) return; titleFit.raf=requestAnimationFrame(function(){ titleFit.raf=0; if(ti.classList.contains('on')) titleFit(); }); }).observe(col); }catch(_ro){}
'@

SubRx @'
  if(!(ev&&ev.message)&&!er) return;
'@ @'
  if(!(ev&&ev.message)&&!er) return;
  // v24.25 (ui5b): the browser notice that a ResizeObserver could not deliver every change in one frame is not a crash (the spec says
  // so); it put ERROR SAVED TO YOUR RUN REPORT on every 4K title.
  if(!er&&(/^ResizeObserver loop/).test(String(ev.message||''))) return;
'@

SubRx @'
var VER='24.24';
'@ @'
var VER='24.25';
'@

$pat = "(?m)^  now:'v24\.24:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v24.25: The title fits a 4K screen with nothing cut off, and it no longer says ERROR SAVED TO YOUR RUN REPORT when it opens. Check 24.25 fails on v24.24',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
