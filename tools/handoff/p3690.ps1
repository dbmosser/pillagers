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

# A DEAD PLAYER 2 WINDOW COMES BACK IN THE 2 PLAYER DEMO (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
// v23.54, HIS ORDER (2026-10-11 evening), arcade30: 1 PLAYER ARCADE DEMO. His words: "arcade mode also needs a single player option".

'@ @'
// v36.90 (cw-p2reopen), his round 2 and 3 answers 2.1 and 3.9 ("in demo mode only, 2p should restart"; "player 2 carries on alone"): A DEAD PLAYER 2 WINDOW COMES BACK.
// When the link to player 2 drops the host already plays on alone (netDrop), and a player 2 window that boots finds the pair by itself (ready, offer, arcon). Nobody
// opened the window again, so a closed or crashed TV 2 stayed dark and every later demo run was a 1 player run. Now, once player 2 has been linked in the 2 player
// demo and the link has been gone for ARC_MATE_MS, the host opens the window again at the same address (the pair code is kept, so it links at boot and the next run
// is 2 player). A window that is still open but dead gets a reload after ARC_MATE_RELOAD_MS, never while it holds a raid of its own (p2RaidNow). A browser opens a
// window only for a press, so a blocked open is tried again every ARC_MATE_TRY_MS and the next key press of player 1 goes through. The 1 player demo is untouched.
var ARC_MATE_MS=3000, ARC_MATE_RELOAD_MS=10000, ARC_MATE_TRY_MS=2500;
function arcadeMateWatch(now){
  if(typeof ARCADE!=='object'||!ARCADE) return 'off';
  if(!ARCADE.on||ARCADE.role!=='host'||ARCADE.solo){ ARCADE.p2Seen=0; ARCADE.p2LostAt=0; ARCADE.p2TryAt=0; ARCADE.p2Told=0; return 'off'; }
  if(NET.same!=='host'||!NET.pair||!NET.p2url) return 'off';
  if(netInCount()>0){ ARCADE.p2Seen=1; ARCADE.p2LostAt=0; ARCADE.p2TryAt=0; ARCADE.p2Told=0; return 'linked'; }
  if(!ARCADE.p2Seen) return 'never';
  if(!ARCADE.p2LostAt){ ARCADE.p2LostAt=now; return 'lost'; }
  if(now-ARCADE.p2LostAt<ARC_MATE_MS) return 'wait';
  if(ARCADE.p2TryAt&&now-ARCADE.p2TryAt<ARC_MATE_TRY_MS) return 'wait';
  var w=NET.p2win, gone=!w, w2=null;
  try{ if(w) gone=!!w.closed; }catch(_c){ gone=true; }
  if(!gone){
    if(now-ARCADE.p2LostAt<ARC_MATE_RELOAD_MS) return 'wait';
    try{ if(typeof p2RaidNow==='function'&&p2RaidNow()) return 'inraid'; }catch(_r){}
    ARCADE.p2TryAt=now;
    try{ w.location.reload(); }catch(_rl){ return 'reloadfail'; }
    return 'reload';
  }
  ARCADE.p2TryAt=now;
  try{ w2=window.open(NET.p2url,'pillagers_p2',netP2Features()); }catch(_o){ w2=null; }
  if(!w2) return 'blocked';
  NET.p2win=w2;
  if(!ARCADE.p2Told){ ARCADE.p2Told=1; try{ say('player 2 window reopening','info'); }catch(_sy){} }
  return 'reopen';
}
try{ if(typeof setInterval==='function') setInterval(function(){ try{ arcadeMateWatch(Date.now()); }catch(_amw){} },1000); }catch(_ami){}// v23.54, HIS ORDER (2026-10-11 evening), arcade30: 1 PLAYER ARCADE DEMO. His words: "arcade mode also needs a single player option".

'@

SubRx @'
var VER='36.89';
'@ @'
var VER='36.90';
'@

$pat = "(?m)^  now:'v36\.89:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.90: If the player 2 window closes or crashes in the 2 player demo, the host reopens it by itself within a few seconds and player 2 can press A to rejoin. Check 36.90 fails on v36.89',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
