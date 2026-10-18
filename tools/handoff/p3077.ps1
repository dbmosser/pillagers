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

# the player 2 window follows the last input device too (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
// tracker. The player 2 window of a same machine pair has no keyboard or mouse of its own (it hands every key to player 1, netKeyFwd),
'@ @'
// tracker. The player 2 window is one too: since v30.68 (cw-p2keys, the window in front plays the keys) it has a keyboard and a mouse like any other, and
'@

SubRx @'
// so it ignores both and keeps the pad prompts while its pad is there. Mouse events count only when real (the pad's own synthetic
'@ @'
// the pad state a window in the back is handed counts as that window's pad. Mouse events count only when real (the pad's own synthetic
'@

SubRx @'
// presses must not flip it back); key events always count (the keys player 2 hands over arrive as synthetic keydowns and are player 1
'@ @'
// presses must not flip it back), and a mouse MOVE only in the window that has the keyboard (indevMoveOk): a pointer that only crosses a window
'@

SubRx @'
// on the keyboard). INDEV.legacy is for the test fixture only: it keeps the older checks, which set PAD.on by hand, meaning what they meant.
'@ @'
// in the back is not a hand on its mouse. Key events always count. INDEV.legacy is for the test fixture only: it keeps the older checks, which set PAD.on by hand, meaning what they meant.
'@

SubRx @'
function indevP2(){ try{ return !!((typeof NET==='object'&&NET&&NET.same==='p2')||(typeof ARCADE==='object'&&ARCADE&&ARCADE.on&&ARCADE.role==='p2')); }catch(_ip){ return false; } }
'@ @'
function indevMoveOk(e){ try{ return !!(e&&e.isTrusted&&(typeof document.hasFocus!=='function'||document.hasFocus())); }catch(_mo){ return false; } }   // v30.xx (cw-glyphs3), v30.68 (cw-p2keys), his order: "if I bring the 2nd player screen to the front, it should take my key input, e.g. keys control whatever screen is to the top". Every window is judged the same now, the player 2 window too. A mouse move counts when it is real and this window has the keyboard: the host pointer crossing a window that is not in front is no hand on that window's mouse (a click still counts, it focuses the window)
'@

SubRx @'
function indevKey(){ if(!indevP2()) indevSet('kb'); }
'@ @'
function indevKey(){ indevSet('kb'); }   // v30.xx (cw-glyphs3): a key press in any window, the player 2 window too, puts the key prompts up there
'@

SubRx @'
if(indevP2()) return;
'@ @'
/* v30.xx (cw-glyphs3): the player 2 window is judged like any other */
'@

SubRx @'
window.addEventListener('mousemove',function(e){ if(e.isTrusted) indevMouse(e.clientX,e.clientY,e.movementX,e.movementY); },true);
'@ @'
window.addEventListener('mousemove',function(e){ if(indevMoveOk(e)) indevMouse(e.clientX,e.clientY,e.movementX,e.movementY); },true);
'@

SubRx @'
// connected no longer counts: it must also be the last device used (INDEV, above). The player 2 window has no other device, so it keeps the pad prompts.
'@ @'
// connected no longer counts: it must also be the last device used (INDEV, above). The player 2 window is judged like any other (v30.xx, cw-glyphs3).
'@

SubRx @'
INDEV.dev==='pad'||INDEV.legacy||indevP2()));
'@ @'
INDEV.dev==='pad'||INDEV.legacy));
'@

SubRx @'
var VER='30.76';
'@ @'
var VER='30.77';
'@

$pat = "(?m)^  now:'v30\.76:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v30.77: The second player window now follows what it used last too: a key shows keys, its controller shows its buttons. Check 30.77 fails on v30.76',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
