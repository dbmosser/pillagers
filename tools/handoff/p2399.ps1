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

# RETRY IS A ROW (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
// The mode rows a keyboard or a pad can land on: shown and not greyed.
function netTitleRows(){
  var m=document.getElementById('modemenu'), out=[], q, i, el, w;
  if(!m) return out;
  q=m.querySelectorAll('button[data-mode]');
'@ @'
// The mode rows a keyboard or a pad can land on: shown and not greyed.
// v23.99, HIS ORDER 2026-10-12 (his #39, full controller navigation, keyboard and mouse first): RETRY IS A ROW. When the browser
// blocks the player 2 window the title shows RETRY under the rows, and the arrows walked only the data-mode rows, so the keyboard
// could never reach it and ENTER pressed the 1 PLAYER start instead: a blocked same machine pick had to be finished with the mouse.
// RETRY, while it shows, is now the last row the arrows land on, and ENTER on it presses it. The pad already reached it.
function netTitleRows(){
  var m=document.getElementById('modemenu'), out=[], q, i, el, w;
  if(!m) return out;
  q=m.querySelectorAll('button[data-mode],#moderetry');
'@

SubRx @'
  if(cur&&m&&m.contains(cur)&&cur.getAttribute&&cur.getAttribute('data-mode')&&!cur.disabled&&cur.id!=='titlestart'){ cur.click(); return 'row'; }
'@ @'
  if(cur&&m&&m.contains(cur)&&cur.getAttribute&&(cur.getAttribute('data-mode')||cur.id==='moderetry')&&!cur.disabled&&cur.id!=='titlestart'){ cur.click(); return 'row'; }   // v23.99 (his #39): RETRY too
'@

SubRx @'
var VER='23.98';
'@ @'
var VER='23.99';
'@

$pat = "(?m)^  now:'v23\.98:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.99: The arrow keys reach RETRY on the title, and ENTER presses it. Check 23.99 fails on v23.98',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
