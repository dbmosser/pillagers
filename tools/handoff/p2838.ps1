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

# CONTROLLER HIGHLIGHT NEVER HIDES UNDER THE SETTINGS JUMP BAR (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  PAD.focus=el;
  try{ el.scrollIntoView({block:'nearest',inline:'nearest'}); }catch(_e){}
  // v22.01, from the whole-game bug hunt of 2026-10-08 (K11): A HIGHLIGHTED STASH ITEM IS NAMED. The line above the stash grid
'@ @'
  PAD.focus=el;
  try{ el.scrollIntoView({block:'nearest',inline:'nearest'}); }catch(_e){}
  try{ var _sl=el.closest&&el.closest('#setlist'), _sj=_sl&&_sl.querySelector('.setjump'); if(_sj&&!_sj.contains(el)){ var _c=_sj.getBoundingClientRect().bottom-el.getBoundingClientRect().top, _z=(_sl.offsetHeight>0)?_sl.getBoundingClientRect().height/_sl.offsetHeight:1; if(_c>0) _sl.scrollTop-=(_c+4)/(_z>0?_z:1); } }catch(_sj2){}   // v28.38 (cloud-coop-pad-settings-under-bar), CLOUD HUNT 2026-10-15: in Settings the sticky jump bar covers the top of the list, so a control the pad highlights scrolls clear below it; the overlap is converted from screen pixels to list pixels under the menu zoom, as setSecJump notes
  // v22.01, from the whole-game bug hunt of 2026-10-08 (K11): A HIGHLIGHTED STASH ITEM IS NAMED. The line above the stash grid
'@

SubRx @'
var VER='28.37';
'@ @'
var VER='28.38';
'@

$pat = "(?m)^  now:'v28\.37:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.38: On a controller, walking up the Settings list always keeps the highlighted setting in sight below the jump bar. Check 28.38 fails on v28.37',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
