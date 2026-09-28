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

# THE KEYBOARD ALWAYS DRIVES PLAYER 1 ON ONE PC (from his playtest report: player 1 could not extract while downed).

SubRx @'
function netSameOnMsg(m){
'@ @'
// v16.89, from his playtest report (player 1 could not extract while downed after player 2 had extracted): IN A SAME MACHINE
// PAIR THE KEYBOARD ALWAYS DRIVES PLAYER 1. Player 1 plays the keyboard and mouse, player 2 a controller (his rule of v16.35).
// The browser gives the keyboard to the window last clicked, so after a click on the player 2 window every key went there:
// E, WASD and the rest moved player 2 and did nothing for player 1. The player 2 window now hands every key it receives to
// the player 1 window over the pair channel and does not act on it; the player 1 window plays it as its own key. A text box
// in the player 2 window still types. The mouse is not handed over: it acts where it points.
function netKeyFwd(ev){
  if(!(typeof NET==='object'&&NET&&NET.same==='p2'&&NET.pair)) return;
  var tn=(ev.target&&ev.target.tagName)||'';
  if(tn==='INPUT'||tn==='TEXTAREA'||tn==='SELECT') return;
  netSamePost({t:'key',pair:NET.pair,ty:(ev.type==='keyup')?'keyup':'keydown',code:String(ev.code||''),key:String(ev.key||''),rep:!!ev.repeat,sh:!!ev.shiftKey,ct:!!ev.ctrlKey});
  ev.preventDefault(); ev.stopImmediatePropagation();
}
try{ window.addEventListener('keydown',netKeyFwd,true); window.addEventListener('keyup',netKeyFwd,true); }catch(_kf){}
function netSameOnMsg(m){
'@

SubRx @'
  if(m.t==='pad') return netPadRecv(m);
'@ @'
  if(m.t==='key'){   // v16.89: a key the player 2 window was given, played here as this window own key
    if(NET.same!=='host') return 'ignored';
    try{ window.dispatchEvent(new KeyboardEvent((m.ty==='keyup')?'keyup':'keydown',{code:String(m.code||''),key:String(m.key||''),repeat:!!m.rep,shiftKey:!!m.sh,ctrlKey:!!m.ct,bubbles:true,cancelable:true})); }catch(_ke){}
    return 'key';
  }
  if(m.t==='pad') return netPadRecv(m);
'@

SubRx @'
var VER='16.88';
'@ @'
var VER='16.89';
'@

$pat = "(?m)^  now:'v16\.88:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.89: THE KEYBOARD ALWAYS DRIVES PLAYER 1 ON ONE PC. From his playtest report: player 1 could not extract while downed after player 2 had extracted. The browser gives the keyboard to the window last clicked, so after a click on the player 2 window the keys of player 1 went there. In a same machine pair the player 2 window now hands every key to the player 1 window, which plays it as its own; player 2 keeps his controller, and a text box in his window still types. Check 16.89 fails on v16.88',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
