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
function cycleThrow(){
  for(var i=1;i<=3;i++){
    var n=(G.tsel+i)%3;
    if(G.pouch[THROWKEYS[n]]>0){
      G.tsel=n;
'@ @'
function cycleThrow(){
  // v15.06, throwables audit finding 4: the hand is no longer moved here, before a key is found. See the cell search below.
  var _unkeyed=0;
  for(var i=1;i<=3;i++){
    var n=(G.tsel+i)%3;
    if(G.pouch[THROWKEYS[n]]>0){
'@
SubRx @'
      if(_cf>=0) G.hot=_cf;
      say(ITEMS[THROWKEYS[n]].name+' ready');
      return;
    }
  }
  say('No throwables');
}
'@ @'
      // v15.06, throwables audit finding 4: Q NEVER PICKS A GRENADE THAT HAS NO KEY ON THE TACTICAL BELT. Something of his own on
      // the Smoke key covers the Smoke cell, so the Smoke had no cell anywhere; Q still put the Smoke in hand, left the highlight
      // on the Frag and said the Smoke was ready, and the trigger cooked a Smoke under the Frag count. A grenade no key can use
      // is passed over, and the hand and the highlight now move together or not at all.
      if(_cf<0){ _unkeyed++; continue; }
      G.tsel=n; G.hot=_cf;
      say(ITEMS[THROWKEYS[n]].name+' ready');
      return;
    }
  }
  say(_unkeyed?'No throwable you carry is on your tactical belt.':'No throwables');
}
'@
SubRx @'
  if(s2.kind==='throw') doThrow();
'@ @'
  // v15.06, throwables audit finding 4: AND G THROWS THE GRENADE IN THE HIGHLIGHTED CELL. doThrow reads the hidden selector,
  // which a drag moves past without touching, so G (and the pad, which comes through here) could throw another grenade.
  if(s2.kind==='throw'){ var _dtx=THROWKEYS.indexOf(String(s2.k).split(':')[1]); if(_dtx>=0) G.tsel=_dtx; doThrow(); }
'@
SubRx @'
      else if(!p.cooking){ if(!p.fired){ p.fired=true; startCook(); } }
'@ @'
      // v15.06, throwables audit finding 4: AND THE TRIGGER COOKS THE GRENADE IN THE HIGHLIGHTED CELL. startCook reads the hidden
      // selector, so a hand left on another grenade cooked that one under this cell's count.
      else if(!p.cooking){ if(!p.fired){ p.fired=true; var _htx=THROWKEYS.indexOf(String(HSC.k).split(':')[1]); if(_htx>=0) G.tsel=_htx; startCook(); } }
'@
SubRx @'
var VER='15.05';
'@ @'
var VER='15.06';
'@

$pat = "(?m)^  now:'v15\.05:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.06: Q NEVER PICKS A GRENADE THAT HAS NO KEY ON THE TACTICAL BELT. With something of his own on key 3, where the Smoke sits, Q from the Frag chose the Smoke anyway, left the highlight on the Frag and said the Smoke was ready, and the trigger then cooked a Smoke under the Frag count. Q now passes over a grenade no key can use, and the trigger and G use the grenade in the highlighted cell. Check 15.06 puts a Medkit over the Smoke, presses Q from the Frag and pulls the trigger and G; it fails on v15.05',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
