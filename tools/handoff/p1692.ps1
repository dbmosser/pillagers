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

# A KEY HELD IN THE PLAYER 2 WINDOW IS LET GO WHEN THAT WINDOW LOSES FOCUS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  var tn=(ev.target&&ev.target.tagName)||'';
  if(tn==='INPUT'||tn==='TEXTAREA'||tn==='SELECT') return;
  netSamePost({t:'key',pair:NET.pair,ty:(ev.type==='keyup')?'keyup':'keydown',code:String(ev.code||''),key:String(ev.key||''),rep:!!ev.repeat,sh:!!ev.shiftKey,ct:!!ev.ctrlKey});
  ev.preventDefault(); ev.stopImmediatePropagation();
}
try{ window.addEventListener('keydown',netKeyFwd,true); window.addEventListener('keyup',netKeyFwd,true); }catch(_kf){}
'@ @'
  var tn=(ev.target&&ev.target.tagName)||'', up=(ev.type==='keyup'), cd=String(ev.code||'');
  // v16.92, co-op hunt 2026-09-28: A KEY HELD HERE IS LET GO IN THE PLAYER 1 WINDOW. A key let go over a text box was dropped
  // here, and a key still down when this window lost focus sent its keyup to another program, so player 1 kept walking,
  // sprinting or holding E with no key down. This window now remembers what it handed down, a keyup for it is handed on even
  // over a text box (the box still sees it), and netKeyLetGo below hands up whatever is left when the keyboard goes.
  var box=(tn==='INPUT'||tn==='TEXTAREA'||tn==='SELECT');
  if(box&&!(up&&netKeyHeld[cd])) return;
  if(up) delete netKeyHeld[cd]; else if(cd) netKeyHeld[cd]=1;
  netSamePost({t:'key',pair:NET.pair,ty:up?'keyup':'keydown',code:cd,key:String(ev.key||''),rep:!!ev.repeat,sh:!!ev.shiftKey,ct:!!ev.ctrlKey});
  if(box) return;
  ev.preventDefault(); ev.stopImmediatePropagation();
}
var netKeyHeld={};   // v16.92: the codes this player 2 window handed down to player 1 and has not yet handed up
// v16.92: hands up every key still held for player 1 and forgets them; run when this window loses the keyboard, is hidden or closes.
// Plain keyups, not a releaseAllKeys on the host, so player 1s open backpack and his mouse drag are left alone.
function netKeyLetGo(){
  var c, n=0, ok=(typeof NET==='object'&&NET&&NET.same==='p2'&&NET.pair);
  for(c in netKeyHeld){ if(ok){ netSamePost({t:'key',pair:NET.pair,ty:'keyup',code:c,key:'',rep:false,sh:false,ct:false}); n++; } }
  netKeyHeld={};
  return n;
}
try{ window.addEventListener('keydown',netKeyFwd,true); window.addEventListener('keyup',netKeyFwd,true); }catch(_kf){}
try{ window.addEventListener('blur',netKeyLetGo); window.addEventListener('pagehide',netKeyLetGo); document.addEventListener('visibilitychange',function(){ if(document.hidden) netKeyLetGo(); }); }catch(_kl){}
'@

SubRx @'
var VER='16.91';
'@ @'
var VER='16.92';
'@

$pat = "(?m)^  now:'v16\.91:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.92: Co-op hunt 2026-09-28, findings 10 and 11: netKeyFwd in the player 2 window posts every keydown and keyup to the player 1 window, whose keyup listener is the only thing that clears keys for a handed key. When the player 2 window lost focus mid press (alt-tab, taskbar, another program) the keyup went elsewhere, releaseAllKeys cleared only the empty keys table of the player 2 window, and the unfocused player 1 window got no blur of its own, so keys stayed true there and player 1 kept walking, sprinting or holding E. A keyup aimed at a text box in the player 2 window was also dropped before it was handed on. The player 2 window now keeps netKeyHeld, the codes it handed down and not yet up; netKeyLetGo posts a keyup for each and empties it, and runs on window blur, on pagehide and on visibilitychange to hidden; outside a pair it only forgets them. A keyup for a held code is handed on even over a text box, without stopping the box from seeing it. The host is sent plain keyups, not a releaseAllKeys, so its open backpack and a mouse drag are left alone. No number and no player text moved. Check 16.92 fails on v16.91',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
