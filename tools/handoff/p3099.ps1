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

# Settings from the pause menu opens at the top every time; the dead screen-height padding rule is gone (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
#root #settingsmodal, #root #keysmodal{ --py:max(var(--sp-5), calc((100vh - var(--sp-5) * 15) / 2)); padding-top:var(--py); padding-bottom:var(--py); }
'@ @'
/* v30.xx (cw-pausesets), HIS NOTE (2026-10-18): "accessing settings from pauise menu doesn't work right (maybe due to usperhot?)". The air above and below the Settings
   and Keys cards was a share of 100vh, and 100vh inside a zoomed window is NOT divided by the zoom, so on a screen taller than 1080p (he plays at 4K) it grew past the
   screen and squeezed the list to a sliver. The later cw-cardwide rule overrode it with a plain margin, so the share is dead; it is gone here so nothing can bring it back. */
#root #settingsmodal, #root #keysmodal{ --py:var(--sp-5); padding-top:var(--py); padding-bottom:var(--py); }
'@

SubRx @'
function openSettings(tab){
  var want=tab||'display';
'@ @'
function openSettings(tab){
  var want=tab||'display';
  var _smOn=false; try{ _smOn=document.getElementById('settingsmodal').classList.contains('on'); }catch(_so){}   // v30.xx (cw-pausesets): a fresh open starts at the top; a tab or a jump inside the open window keeps its place
'@

SubRx @'
  openModal('settingsmodal');
'@ @'
  openModal('settingsmodal');
  // v30.xx (cw-pausesets), HIS NOTE (2026-10-18): "accessing settings from pauise menu doesn't work right (maybe due to usperhot?)". Not Superhot: a pause stands the world
  // still under Settings with Superhot on and a key held (checked). The window is kept in the page and only hidden, so it kept its scroll between visits: a second visit from
  // the pause box opened half way down the list, with the section he wanted off the top. A fresh open now starts at the top, as the first one does.
  if(!_smOn){ try{ var _sl0=document.getElementById('setlist'); if(_sl0&&_sl0.scrollTop) _sl0.scrollTop=0; }catch(_sr0){} }
'@

SubRx @'
var VER='30.98';
'@ @'
var VER='30.99';
'@

$pat = "(?m)^  now:'v30\.98:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v30.99: Settings from the pause menu opens at the top every time. Check 30.99 fails on v30.98',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
