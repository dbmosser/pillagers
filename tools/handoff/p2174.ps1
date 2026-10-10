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

# A CONTROLLER CUTS THE SEAL AND HELPS THE SURVIVOR (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
      if(_xDown&&PAD.xMode==null&&(PAD.xNearN==null||PAD.xNearN!==(G.nearN||0)||(G.player&&G.player.downed))){ var _xm=false; try{ _xm=!!(NET.on&&typeof netMateDown==='function'&&netMateDown(G.player)>=0); }catch(_xe){} PAD.xMode=(G.nearContainer||G.nearPad||G.nearDown||G.nearDoor||G.nearPed||_xm)?'KeyE':'KeyR'; if(PAD.xNearN!=null){ PAD.xDownAt=G.t; PAD.xNearN=null; _xSearch=!!(G.nearPad&&G.nearContainer); } }
'@ @'
      // v21.74, from the whole-game bug hunt of 2026-10-08 (K14): X HOLDS E AT THE SEAL AND AT A SURVIVOR. Neither was on this list,
      // so at THE SEAL (which stands clear of every wall, so usually nothing else is in reach) X held R and reloaded and the seal never
      // cut, and at a found survivor the [X] GIVE prompt was a reload too. A seal already open is left out (its reach is not looked
      // up again once it opens), and so is a survivor the prompt does not offer (not yet found, or turned hostile), so X still
      // reloads in a fight with him.
      if(_xDown&&PAD.xMode==null&&(PAD.xNearN==null||PAD.xNearN!==(G.nearN||0)||(G.player&&G.player.downed))){ var _xm=false; try{ _xm=!!(NET.on&&typeof netMateDown==='function'&&netMateDown(G.player)>=0); }catch(_xe){} PAD.xMode=(G.nearContainer||G.nearPad||G.nearDown||G.nearDoor||G.nearPed||(G.nearSeal&&!G.nearSeal.done)||(G.nearStray&&G.nearStray.found&&!G.nearStray.hostile)||_xm)?'KeyE':'KeyR'; if(PAD.xNearN!=null){ PAD.xDownAt=G.t; PAD.xNearN=null; _xSearch=!!(G.nearPad&&G.nearContainer); } }
'@

SubRx @'
    ctx.fillStyle='#ffc04a'; ctx.fillText('HOLD E TO CUT THE SEAL',_slp.x,_slp.y);
'@ @'
    ctx.fillStyle='#ffc04a'; ctx.fillText('HOLD '+keyLabel('KeyE','E')+' TO CUT THE SEAL',_slp.x,_slp.y);   // v21.74 (K14): the button in hand, as every other prompt; on the keyboard with E unmoved it reads as before
'@

SubRx @'
var VER='21.73';
'@ @'
var VER='21.74';
'@

$pat = "(?m)^  now:'v21\.73:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.74: On a controller, holding X now cuts THE SEAL and hands the survivor his item. Check 21.74 fails on v21.73',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
