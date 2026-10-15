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

# ACTIVE RELOAD ON A CONTROLLER NEXT TO A BOX (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
      if(_xDown&&PAD.xMode==null&&(PAD.xNearN==null||PAD.xNearN!==(G.nearN||0)||(G.player&&G.player.downed))){ var _xm=false; try{ _xm=!!(NET.on&&typeof netMateDown==='function'&&netMateDown(G.player)>=0); }catch(_xe){} PAD.xMode=(G.nearContainer||G.nearPad||G.nearDown||G.nearDoor||G.nearPed||G.nearForge||(G.nearSeal&&!G.nearSeal.done)||(G.nearStray&&G.nearStray.found&&!G.nearStray.hostile)||_xm)?'KeyE':'KeyR'; if(PAD.xNearN!=null){ PAD.xDownAt=G.t; PAD.xNearN=null; _xSearch=!!(G.nearPad&&G.nearContainer); } }
'@ @'
      if(_xDown&&PAD.xMode==null&&(PAD.xNearN==null||PAD.xNearN!==(G.nearN||0)||(G.player&&G.player.downed))){ var _xm=false; try{ _xm=!!(NET.on&&typeof netMateDown==='function'&&netMateDown(G.player)>=0); }catch(_xe){} PAD.xMode=(G.nearContainer||G.nearPad||G.nearDown||G.nearDoor||G.nearPed||G.nearForge||(G.nearSeal&&!G.nearSeal.done)||(G.nearStray&&G.nearStray.found&&!G.nearStray.hostile)||_xm)?'KeyE':'KeyR'; var _rp=G.player; if(PAD.xMode==='KeyE'&&_rp&&!_rp.downed&&_rp.reloading>0&&_rp.rlTot>0&&!G.nearDown&&!_xm){ var _arf=1-_rp.reloading/_rp.rlTot; if(_arf>=AR_A&&_arf<=AR_B) PAD.xMode='KeyR'; } if(PAD.xNearN!=null){ PAD.xDownAt=G.t; PAD.xNearN=null; _xSearch=!!(G.nearPad&&G.nearContainer); } }   // v28.37 (cloud-coop-pad-active-reload), CLOUD HUNT 2026-10-15: X is the only reload button on a controller, so in the sweet spot of a reload it lands the active reload even with a box, body, door or forge in reach (it searched instead, so player 2 could never get the bonus there); a downed teammate still takes the revive
'@

SubRx @'
var VER='28.36';
'@ @'
var VER='28.37';
'@

$pat = "(?m)^  now:'v28\.36:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.37: On a controller, pressing X in the sweet spot of a reload now lands the active reload even standing next to a box. Check 28.37 fails on v28.36',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
