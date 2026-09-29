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

# ESC OR TAB ON SETTINGS IN A RAID SHUTS SETTINGS, NOT THE PAUSE BOX BEHIND IT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    var _ta=document.getElementById('pausenote'); if(_ta) _ta.blur();
'@ @'
    // v17.19, co-op hunt 2026-09-28: A WINDOW IN FRONT OF THE BOX TAKES THE KEY. Settings opens from this box and sits over it,
    // and this listener runs before the one that shuts the front window, so ESC or TAB on Settings shut the box behind it and
    // the raid ran on under Settings. The front window (or the edit box) is shut here through its own door instead, and the box
    // stays up with the raid paused. Done here rather than passed on, so a player 2 window does not hand the key to player 1.
    var _fm=document.querySelector('.modal.on'), _tx=(typeof TXBOX!=='undefined'&&TXBOX&&document.activeElement===TXBOX);
    if(_fm||_tx){ if(_tx){ try{ txClose(); }catch(_txe){} } else escCloseTopModal(); try{ syncPause(); }catch(_sps){} return; }
    var _ta=document.getElementById('pausenote'); if(_ta) _ta.blur();
'@

SubRx @'
  if((code==='Escape'||code==='KeyP'||code==='Tab')&&!repeat&&G&&!G.over)
'@ @'
  // v17.19, co-op hunt 2026-09-28: NOT UNDER AN OPEN WINDOW. P over Settings shut the pause box behind it and unpaused the
  // raid, and the next P opened the box under Settings. The floor branch has kept this rule since v8.70.
  if((code==='Escape'||code==='KeyP'||code==='Tab')&&!repeat&&G&&!G.over&&!document.querySelector('.modal.on'))
'@

SubRx @'
var VER='17.18';
'@ @'
var VER='17.19';
'@

$pat = "(?m)^  now:'v17\.18:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.19: Co-op hunt 2026-09-28, menus finding 4: the pause box ESC and TAB listener is a window capture listener, so it runs before the document listener that shuts the front window, and it never asked whether a window was open in front of the box. With Settings opened from the box, ESC or TAB shut the box, stopped the key, and left Settings up; syncPause then unpaused the raid, so the world, the clock and his keys all ran behind the opaque Settings window. The listener now shuts the front window (or the dev edit box) through its own door when one is open over the box, keeps the box up and calls syncPause, so the raid stays paused. It does this itself rather than returning, because in a player 2 window netKeyFwd would otherwise hand the key to player 1 (the leak v16.93 closed). raidKey no longer toggles the pause box on ESC, P or TAB while a window is open, the same rule the floor branch already keeps, so P over Settings no longer shuts or opens the box under it. No number and no player text moved. Check 17.19 fails on v17.18',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
