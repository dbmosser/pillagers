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

# F11 FULLSCREENS EVERY WINDOW, PLAYER 2 INCLUDED (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function fsSync(){
'@ @'
// v17.92, HIS REPORT (2026-10-03): F11 DID NOT FULLSCREEN THE PLAYER 2 WINDOW. The second window opens as a popup, and the browser
// does not act on F11 there. The game answers F11 itself now, in every window, with the same toggle the GO FULLSCREEN button
// runs; on the key the browser still has a user gesture to grant it. Caught on the way down, before any menu eats the key.
try{ window.addEventListener('keydown',function(ev){ if(ev&&ev.code==='F11'&&!ev.repeat){ ev.preventDefault(); try{ fsToggle(); }catch(_f){} } },true); }catch(_fk){}
function fsSync(){
'@

SubRx @'
var VER='17.91';
'@ @'
var VER='17.92';
'@

$pat = "(?m)^  now:'v17\.91:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.92: F11 goes fullscreen in both windows, player 2 included. Check 17.92 fails on v17.91',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
