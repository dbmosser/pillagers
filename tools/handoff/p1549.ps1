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

SubRx @'
  if((code==='Escape'||code==='KeyP'||(code==='Tab'&&!repeat))&&G&&!G.over)
    togglePauseBox(!document.getElementById('pausebox').classList.contains('on'));
'@ @'
  // v15.49, pause audit finding 9: HOLDING ESC OR P DOES NOT FLICKER THE PAUSE BOX. Only TAB ignored a key repeat here, so a
  // held P flipped the box open and shut on every repeat, wiping the keys and the mouse each time it opened, and it came to
  // rest open or shut by chance when he let go. A held ESC did the same, and so did the ESC held after it closed the map,
  // because the map line above takes only a fresh press. A key repeat of ESC, P or TAB now does nothing here, so a held key
  // toggles the box once, the way v13.44 made a held TAB and the floor branch already did. The pad sends only fresh presses
  // and is unchanged. No player text, no number and no seeded draw moved.
  if((code==='Escape'||code==='KeyP'||code==='Tab')&&!repeat&&G&&!G.over)
    togglePauseBox(!document.getElementById('pausebox').classList.contains('on'));
'@
SubRx @'
    if(ev.code==='Tab'&&ev.repeat) return;   // v13.44: a held TAB closes the box once, not on every repeat
'@ @'
    // v15.49, pause audit finding 9: HOLDING ESC OR P DOES NOT FLICKER THE PAUSE BOX. Only a held TAB was ignored here, so a
    // repeated ESC shut the open box, and the next repeat reached the raid keys with the box shut and opened it again, over
    // and over for as long as ESC was held. On the floor a held ESC opened the box and its first repeat shut it. Every key
    // repeat is swallowed here now, after the stop above, so neither the raid keys nor the floor branch can reopen it.
    if(ev.repeat) return;   // v13.44: a held TAB closes the box once, not on every repeat; v15.49: a held ESC too
'@
SubRx @'
var VER='15.48';
'@ @'
var VER='15.49';
'@

$pat = "(?m)^  now:'v15\.48:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.49: HOLDING ESC OR P DOES NOT FLICKER THE PAUSE BOX. Held down in a raid, P flipped the pause box open and shut on every key repeat and left it open or shut by chance, and a held ESC did the same, even the ESC held after it closed the map; only a held TAB was ignored. Key repeats of ESC, P and TAB are now ignored for that toggle, so a held key opens or closes the box once. Check 15.49 holds P over five repeats, holds the ESC that closed the map, sends held ESC repeats to the open box through the page, and still opens and closes the box with fresh presses of P, ESC and TAB; it fails on v15.48',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
