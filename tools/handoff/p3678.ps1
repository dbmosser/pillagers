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

# A DANGER STANDS OVER THE DOWNED CARD (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var DOWNGAP=64, DOWNLIFT=0;
'@ @'
var DOWNGAP=64, DOWNLIFT=0, DOWNTOP=0;   // v36.77 (cw-dangerdown): DOWNTOP is the top of the downed card on the screen, in px, as last drawn
'@

SubRx @'
DOWNLIFT=_dLift; }catch(_dlf){}
'@ @'
DOWNLIFT=_dLift; DOWNTOP=Math.round(H/2+_dwz*((_dpR.y-_dLift)-H/2)); }catch(_dlf){}
'@

SubRx @'
function alertSlotY(){ return Math.max(ALERTY||LH(96),Math.round(H*ALERTYF/((HUDZ.msg||1)*hudRes()*hudUserZ('msg')))); }   // the top of the danger plate, before the message scale
'@ @'
function alertSlotY(hh){   // the top of the danger plate, before the message scale
  var z=(HUDZ.msg||1)*hudRes()*hudUserZ('msg'), y=Math.max(ALERTY||LH(96),Math.round(H*ALERTYF/z)), p=G&&G.player;
  // v36.77 (cw-dangerdown): while you are down the downed card stands at the same height (it was lifted off the player, v35.xx cw-clockcard), so the danger plate stands on top of it
  if(p&&p.downed&&!G.over&&DOWNTOP>0) y=Math.max(ALERTY||LH(96),Math.min(y,Math.floor(DOWNTOP/z-hh-LH(8))));
  return y;
}
'@

SubRx @'
slot:1,y:alertSlotY(),
'@ @'
slot:1,y:alertSlotY(y+Math.round((sl.length?lp:hp)*0.3)+LH(5)),
'@

SubRx @'
var VER='36.77';
'@ @'
var VER='36.78';
'@

$pat = "(?m)^  now:'v36\.77:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.78: A danger said while you are down stands over the downed card, never on it. Check 36.78 fails on v36.77',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
