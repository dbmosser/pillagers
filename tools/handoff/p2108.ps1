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

# THE PAUSE BOX KEYS IN ONE STYLE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  return 'MOUSE aim &nbsp; LMB fire &nbsp; RMB aim down sights &nbsp; '+s('KeyW')+s('KeyA')+s('KeyS')+s('KeyD')+' move &nbsp; '+s('Space')+' dodge roll &nbsp; '+s('ShiftLeft')+' hold to sprint &nbsp; '+
    s('ControlLeft')+' / '+s('KeyC')+' crouch toggle &nbsp; '+s('KeyE')+' interact &nbsp; '+s('KeyR')+' reload &nbsp; '+s('KeyF')+' melee strike &nbsp; 1-9 tactical belt &nbsp; '+s('KeyB')+' / '+s('KeyI')+' backpack &nbsp; '+
    s('Enter')+' equip from backpack &nbsp; '+s('KeyM')+' map &nbsp; '+s('KeyZ')+' drop an item for a teammate &nbsp; '+s('KeyN')+' ping &nbsp; '+s('KeyH')+' controls &nbsp; TAB back out &nbsp; '+s('KeyP')+' / TAB pause';   // v18.25: the trade key, from the audit
'@ @'
  // v21.08, from the whole-game bug hunt of 2026-10-08 (V-D6), seen on the 4K pause screenshot: EVERY KEY IN THE PAUSE BOX IN THE SAME
  // BOLD, AND TAB NAMED ONCE. MOUSE, LMB, RMB, 1-9 and TAB were plain grey while every other key was bold, so the line read as two
  // styles, and TAB was listed twice with two jobs (back out, then pause). The fixed keys take the same bold as the rest, P is the
  // pause key, and TAB is one entry in the words of the controls card: pause, or back out.
  var k=function(t){ return '<b style="color:var(--bone)">'+t+'</b>'; };
  return k('MOUSE')+' aim &nbsp; '+k('LMB')+' fire &nbsp; '+k('RMB')+' aim down sights &nbsp; '+s('KeyW')+s('KeyA')+s('KeyS')+s('KeyD')+' move &nbsp; '+s('Space')+' dodge roll &nbsp; '+s('ShiftLeft')+' hold to sprint &nbsp; '+
    s('ControlLeft')+' / '+s('KeyC')+' crouch toggle &nbsp; '+s('KeyE')+' interact &nbsp; '+s('KeyR')+' reload &nbsp; '+s('KeyF')+' melee strike &nbsp; '+k('1-9')+' tactical belt &nbsp; '+s('KeyB')+' / '+s('KeyI')+' backpack &nbsp; '+
    s('Enter')+' equip from backpack &nbsp; '+s('KeyM')+' map &nbsp; '+s('KeyZ')+' drop an item for a teammate &nbsp; '+s('KeyN')+' ping &nbsp; '+s('KeyH')+' controls &nbsp; '+s('KeyP')+' pause &nbsp; '+k('TAB')+' pause, or back out';   // v18.25: the trade key, from the audit
'@

SubRx @'
var VER='21.07';
'@ @'
var VER='21.08';
'@

$pat = "(?m)^  now:'v21\.07:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.08: The pause box lists every key in the same bold, and TAB once. Check 21.08 fails on v21.07',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
