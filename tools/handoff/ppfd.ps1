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

# First controller is player 2, second is player 1 (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function arcadePadsIn(role){
  var ix=(role==='p2')?1:0;
  if(NET.padIx!==ix){ NET.padIx=ix; NET.padWas=null; }
  netPadPost();
  return NET.padIx;
}
'@ @'
function arcadePadsIn(role){
  // v30.xx (cw-p2pads), HIS ORDER (2026-10-18): "right now if both games are fullscreened, my controller controls both screens at the same time, that is not the intent -- first controller plugged in
  // always controls p2 only, second controller plugged in always controls p1 only". The order above (controller 1 is player 1, controller 2 is player 2) is gone. Neither window is put on a fixed
  // controller now (pick -1): netPadFor gives player 2 the first controller connected and player 1 the next one, and one controller alone is player 2 (player 1 plays keyboard and mouse). With a
  // fixed pick a window whose controller was not plugged in fell to the first free controller before the other window pick had reached it, so one controller was played by both windows.
  if(NET.padIx!==-1){ NET.padIx=-1; NET.padWas=null; }
  netPadPost();
  return NET.padIx;
}
'@

SubRx @'
  if(!netSamePost({t:'pad',pair:NET.pair,ix:ix,own:NET.padIx,at:netPadIxOk(at),p:p,v:v,a:a,b:padBrandOf(g)})) return false;
'@ @'
  // v30.xx (cw-p2pads), HIS ORDER (2026-10-18): "first controller plugged in always controls p2 only, second controller plugged in always controls p1 only". The state names the side it is for
  // (to), so the window that takes it can tell a state meant for the other player and never play it (netPadRecv).
  if(!netSamePost({t:'pad',pair:NET.pair,ix:ix,own:NET.padIx,at:netPadIxOk(at),to:(NET.same==='host')?'p2':'host',p:p,v:v,a:a,b:padBrandOf(g)})) return false;
'@

SubRx @'
  if(typeof m.own==='number') NET.padOther=own;
'@ @'
  if(typeof m.own==='number') NET.padOther=own;
  if(typeof m.to==='string'&&m.to!==NET.same) return 'padnot';   // v30.xx (cw-p2pads), HIS ORDER (2026-10-18): "my controller controls both screens at the same time, that is not the intent". A state meant for the other player is never played here
'@

SubRx @'
function netPadKey(side){ return 'salvagerun:samepad:'+((side==='p2')?'p2':'host'); }
'@ @'
function netPadKey(side){ return 'salvagerun:samepad:'+((side==='p2')?'p2':'host'); }
// v30.xx (cw-p2pads), HIS ORDER (2026-10-18): "first controller plugged in always controls p2 only, second controller plugged in always controls p1 only". A pick kept by the CONTROLLER row under the old
// order (salvagerun:samepad:host or :p2) would still put a window on the pad he named then, over this rule. Once per browser, when the game loads, both kept picks are cleared and a flag is kept so a
// pick he makes later is left alone. Returns whether it cleared them.
function netPadOrderFix(){
  var flag='salvagerun:samepad:order';
  try{ if(localStorage.getItem(flag)==='1') return false; }catch(e){ return false; }
  try{ localStorage.removeItem(netPadKey('host')); localStorage.removeItem(netPadKey('p2')); localStorage.setItem(flag,'1'); }catch(e2){ return false; }
  return true;
}
try{ netPadOrderFix(); }catch(_pof){}
'@

SubRx @'
var VER='30.67';
'@ @'
var VER='30.68';
'@

$pat = "(?m)^  now:'v30\.67:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v30.68: The first controller switched on is now player 2 only, the second is player 1 only, and one controller alone goes to player 2. A window never plays the controller of the other player. Check 30.68 fails on v30.67',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
