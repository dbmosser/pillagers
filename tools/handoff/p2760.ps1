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

# F1 LIST NAMES MOVED KEYS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var LEGEND_MINI_CODES={'WASD':['KeyW','KeyA','KeyS','KeyD'],'SHIFT':['ShiftLeft'],'CTRL / C':['ControlLeft','KeyC'],'SPACE':['Space'],'R':['KeyR'],'F':['KeyF'],'B / I':['KeyB','KeyI'],'E':['KeyE'],'M':['KeyM'],'Z':['KeyZ'],'N':['KeyN'],'Q':['KeyQ'],'V':['KeyV'],'G':['KeyG'],'H':['KeyH'],'X':['KeyX'],'U':['KeyU'],'J':['KeyJ'],'U / J':['KeyU','KeyJ'],'F1':['F1'],'O':['KeyO'],'ENTER':['Enter'],'B or I':['KeyB','KeyI']};
'@ @'
var LEGEND_MINI_CODES={'WASD':['KeyW','KeyA','KeyS','KeyD'],'SHIFT':['ShiftLeft'],'CTRL / C':['ControlLeft','KeyC'],'SPACE':['Space'],'R':['KeyR'],'F':['KeyF'],'B / I':['KeyB','KeyI'],'E':['KeyE'],'M':['KeyM'],'Z':['KeyZ'],'N':['KeyN'],'Q':['KeyQ'],'V':['KeyV'],'G':['KeyG'],'H':['KeyH'],'X':['KeyX'],'U':['KeyU'],'J':['KeyJ'],'U / J':['KeyU','KeyJ'],'F1':['F1'],'O':['KeyO'],'ENTER':['Enter'],'B or I':['KeyB','KeyI'],'CAPS':['CapsLock'],'NUM + -':['NumpadAdd','NumpadSubtract'],'- =':['Minus','Equal'],'0':['Digit0']};   // v27.60 (cloud-menus-f1-list-moved-keys), CLOUD HUNT 2026-10-15: the F1 full list kept CAPS, NUM + -, - = and 0 after CHANGE KEYS moved them (v26.52 made them movable, v25.71 promised the list prints the keys as set)
'@

SubRx @'
  var c=LEGEND_MINI_CODES[s], o;
  if(!c) return s;
  try{ o=c.map(function(k){ return keyName(keysOf(k)); }); }catch(_l){ return s; }
'@ @'
  var c=LEGEND_MINI_CODES[s], o;
  if(!c&&typeof s==='string'&&s.indexOf('HOLD ')===0&&LEGEND_MINI_CODES[s.slice(5)]) return 'HOLD '+legendKeys(s.slice(5));   // v27.60 (cloud-menus-f1-list-moved-keys), CLOUD HUNT 2026-10-15: HOLD Q kept saying Q after the item wheel moved; it names the key as set
  if(!c) return s;
  try{ if(!c.some(function(k){ return keysOf(k)!==k; })) return s; o=c.map(function(k){ var q=keysOf(k); return ({NumpadAdd:'NUM +',NumpadSubtract:'NUM -'})[q]||keyName(q); }); }catch(_l){ return s; }   // v27.60 (cloud-menus-f1-list-moved-keys), CLOUD HUNT 2026-10-15: a row whose keys are all where they were reads its own text, so the defaults (CAPS, NUM + -, - =) never change, and the zoom pair reads NUM + / NUM - (keyName says NUM Add)
'@

SubRx @'
var VER='27.59';
'@ @'
var VER='27.60';
'@

$pat = "(?m)^  now:'v27\.59:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.60: The F1 full controls list names the keys you moved for the item wheel hold, walk, zoom, HUD size and zoom reset. Check 27.60 fails on v27.59',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
