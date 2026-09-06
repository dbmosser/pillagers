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

# FIRST TEN MINUTES AUDIT, 2026-09-06 (two readers): everything in the
# profile loader runs only when a save exists. A first launch has none, so
# the Settings rows were never applied, the wording watcher never armed
# (every reworded sentence since v11.42 was missing for the whole first
# session), and the menus drew at zoom 1.0 and grew a third larger on the
# second launch. Both are set on every load now, save or none.
SubRx @'
          else P.cfg=null;
        } }
}
function loadProfile(){
'@ @'
          else P.cfg=null;
        } }
  // v11.95: THE FIRST SESSION IS SET UP LIKE EVERY LATER ONE. Everything above
  // runs only when a save exists. A friend on his first launch had none, so
  // the Settings rows were never applied (the wording watcher of v9.74 stayed
  // unarmed and every reworded sentence shipped since v11.42 was missing until
  // his second launch), and the menus drew at zoom 1.0 and grew a third larger
  // the next day. Both are set here, on every load, save or none.
  if(!P.menuZoom) P.menuZoom=1.3;
  try{ applyGameOpts(); }catch(_ag){}
}
function loadProfile(){
'@

# STAMPS.
SubRx @'
var VER='11.94';
'@ @'
var VER='11.95';
'@
$cnt=([regex]::Matches($s,"now:'v11\.94:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v11.94 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v11\.94:[^']*'",{ param($m) "now:'v11.95: from the 2026-09-06 first-ten-minutes audit, a first launch with no save skipped the whole profile loader, so the Settings rows and the wording watcher (every reworded sentence since v11.42) were dead for the first session and the menus drew at zoom 1.0 and grew a third larger the next day. The menu zoom default and the Settings pass now run on every load, save or none. Check 11.95 loads a null record and requires the zoom at 1.3 and the watcher armed; fails on v11.94.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
