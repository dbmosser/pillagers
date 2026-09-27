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

# PLAYER 2 SEES ONLY ITS OWN SAVE (stability pass, 2026-09-27; drafted by a review agent, reviewed by a second).

SubRx @'
<div style="margin-top:6px;font-size:10.5px;color:var(--ash);letter-spacing:.06em">Changing save reloads the game, which is why it leaves fullscreen.</div>
'@ @'
<div id="slotnote" style="margin-top:6px;font-size:10.5px;color:var(--ash);letter-spacing:.06em">Changing save reloads the game, which is why it leaves fullscreen.</div>
'@

SubRx @'
      var _ngl=document.getElementById('newgame'); if(_ngl) _ngl.textContent='CREATE A NEW SAVE';
'@ @'
      var _ngl=document.getElementById('newgame'); if(_ngl) _ngl.textContent='CREATE A NEW SAVE';
      // v16.77, HIS REPORT (player 2 loading saves is all messed up): THE PLAYER 2 WINDOW LISTS NO SAVES. This list is the
      // player 1 saves (slotKey) with the player 1 pointer (SLOT) highlighted, and the player 2 window plays
      // salvagerun:profile:p2 whatever the pointer says: so here it listed and highlighted player 1 saves, its DELETE erased
      // them, and a row or CREATE A NEW SAVE wrote nothing (netSaveLocked) and reloaded the same player 2 save. In the
      // player 2 window the panel says so in one line and draws no rows, no ERASE and no create; the name box above still
      // names the player 2 pillager. A save list of its own for player 2 is a later build.
      var _p2w=!!(typeof NETP2!=='undefined'&&NETP2), _sln=document.getElementById('slotnote');
      if(_ngl) _ngl.style.display=_p2w?'none':'';
      if(_sln) _sln.style.display=_p2w?'none':'';
      if(_p2w){
        host.innerHTML='';
        var _p2l=document.createElement('div');
        _p2l.style.cssText='font-size:11px;color:var(--ash);letter-spacing:.06em';
        _p2l.textContent='Player 2 plays its own save on this machine.';
        host.appendChild(_p2l);
        return;
      }
'@

SubRx @'
var VER='16.81';
'@ @'
var VER='16.82';
'@

$pat = "(?m)^  now:'v16\.81:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.82: PLAYER 2 SEES ONLY ITS OWN SAVE. His report during his co-op session: the second player loading saves is all messed up. The player 2 window showed the saves of player 1, could erase them, and its rows only reloaded the player 2 save. Its title screen now shows player 2 its own save only, and nothing there can touch a player 1 save. Check 16.82 fails on v16.81',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
