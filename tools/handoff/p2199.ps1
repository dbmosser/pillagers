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

# ESC ON THE KEYS WINDOW KEEPS THE RAID PAUSED (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  ev.preventDefault(); ev.stopPropagation();
  if(KEYS.waiting){ if(ev.code!=='Escape') keysBind(KEYS.waiting,ev.code);
'@ @'
  ev.preventDefault(); ev.stopPropagation();
  // v21.99, from the whole-game bug hunt of 2026-10-08 (K9): THE KEYS WINDOW USES UP ITS KEY. stopPropagation does not stop the
  // later capture listeners on this same window, so the pause box closer below saw the same ESC. With a press waiting it shut the
  // whole Keys window; with none, the Keys window was already shut (and Settings with it, when it opened), so it shut the pause
  // box and the raid ran on. In a player 2 window netKeyFwd also handed every key pressed here to player 1. The key stops here
  // now, as the pause box does with its own (v16.93): ESC cancels a waiting press, or shuts this window only, and the pause box
  // stays up with the raid paused. F11 still reaches fullscreen while no press is waiting, and a held ESC does nothing after
  // the first press.
  if(ev.stopImmediatePropagation&&(KEYS.waiting||ev.code!=='F11')) ev.stopImmediatePropagation();
  if(ev.repeat&&ev.code==='Escape') return;
  if(KEYS.waiting){ if(ev.code!=='Escape') keysBind(KEYS.waiting,ev.code);
'@

SubRx @'
var VER='21.98';
'@ @'
var VER='21.99';
'@

$pat = "(?m)^  now:'v21\.98:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.99: ESC on the CHANGE KEYS window now cancels a press or closes only that window, and the raid stays paused. Check 21.99 fails on v21.98',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
