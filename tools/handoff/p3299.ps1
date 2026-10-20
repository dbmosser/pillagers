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

# SETTINGS: AN EXPERIMENTAL MENU WITH THE FIRST FOUR SWITCHES (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
applyCfg(DEF,null); CFG.preset='B';

'@ @'
// v32.xx (cw-expmenu1), HIS ORDER (2026-10-14: "create an experimental settings menu inside settings where I can turn new features on and off"; round 3, 2.R4 b:
// "make it a separate menu accessible from settings"). Settings has one row, experimental, that opens its own page with an on/off row per newer feature. Every
// switch is ON by default, so a profile that never opens it plays exactly as before. Each key is a DEF key, so the host's off switches ride in the raid word
// (netUpCfgDiff) and a linked window builds and plays the raid under them. A WORLD switch ('w') is read from XF, a snapshot startRaid takes before the raid is
// built, never from CFG during a raid: a change made mid raid starts with the next raid. A LOCAL switch ('l') is read live from CFG. A row is listed only when
// its guard is in the build: add the row above XF_ROWS_END and the guard where the feature starts.
var XF_ROWS=[
  // [key, label, hint, scope]
  ['xfGoals','run goals','three goals a raid','w'],
  ['xfGold','golden enemy','one golden enemy a raid','w'],
  ['xfHold','strongholds','fenced compounds','w'],
  ['xfPwr','power-ups','kills drop power-ups','w'],
  // XF_ROWS_END
];
var XF_KEYS=[], XF_WORLD=[], XF={}, SETSUB='';
(function(){ var i; for(i=0;i<XF_ROWS.length;i++){ XF_KEYS.push(XF_ROWS[i][0]); DEF[XF_ROWS[i][0]]=1; if(XF_ROWS[i][3]==='w') XF_WORLD.push(XF_ROWS[i][0]); } })();
function xfSnap(){ var i, k; XF={}; for(i=0;i<XF_WORLD.length;i++){ k=XF_WORLD[i]; XF[k]=(CFG&&CFG[k]===0)?0:1; } return XF; }
function xf(k){ return XF[k]!==0; }                      // a WORLD switch, as this raid was started with it (all on before any raid)
function xfL(k){ return !(CFG&&CFG[k]===0); }            // a LOCAL switch, this window, now
function expRowHtml(){
  return '<div class="row"><div style="flex:1"><b>experimental</b><div class="hint">newer features on or off</div></div><button id="exp_open" style="padding:6px 12px;min-width:92px">open</button></div>';
}
function expPage(host,S){
  var i, eb;
  host.innerHTML='<div class="row"><div style="flex:1"><b>experimental</b><div class="hint">starts next raid</div></div><button id="exp_back" style="padding:6px 12px;min-width:92px">back</button></div>'+(S.EXPERIMENTAL||'');
  eb=document.getElementById('exp_back'); if(eb) eb.onclick=function(){ SETSUB=''; renderSettings(); };
  for(i=0;i<GAMEOPTS.length;i++) if(GAMEOPTS[i].sec==='EXPERIMENTAL') (function(k){ var b=document.getElementById('go_'+k); if(b) b.onclick=function(){ cycleGameOpt(k); renderSettings(); }; })(GAMEOPTS[i].k);
}
applyCfg(DEF,null); CFG.preset='B';

'@

SubRx @'
// v10.28: which option the LIVE dials match, or -1 when a slider has put them

'@ @'
// v32.xx (cw-expmenu1): the experimental rows, one per XF_ROWS line, on first. They are not in SETSEC, so the main page never draws them; expPage does.
(function(){
  var i, r, on, off;
  for(i=0;i<XF_ROWS.length;i++){
    r=XF_ROWS[i]; on={}; off={}; on[r[0]]=1; off[r[0]]=0;
    GAMEOPTS.push({k:r[0],label:r[1],sec:'EXPERIMENTAL',hint:r[2],opts:[{n:'on',cfg:on},{n:'off',cfg:off}],def:0});
  }
})();// v10.28: which option the LIVE dials match, or -1 when a slider has put them

'@

SubRx @'
  // v16.50, stability: Settings opens in a raid since v16.45, and three of its buttons do not belong there. PICK FILE opens a

'@ @'
  if(SETSUB==='exp'){ expPage(host,_SEC); return; }   // v32.xx (cw-expmenu1): the experimental page replaces the list until back
  // v16.50, stability: Settings opens in a raid since v16.45, and three of its buttons do not belong there. PICK FILE opens a

'@

SubRx @'
setSecsHtml(_SEC,{CONTROLS:keysRowHtml(),CONTROLLER:padRowHtml()})
'@ @'
setSecsHtml(_SEC,{CONTROLS:keysRowHtml(),CONTROLLER:padRowHtml(),ACCESSIBILITY:expRowHtml()})
'@

SubRx @'
    })(GAMEOPTS[_gh].k);
  }

'@ @'
    })(GAMEOPTS[_gh].k);
  }
  var _eo=document.getElementById('exp_open');   // v32.xx (cw-expmenu1)
  if(_eo) _eo.onclick=function(){ SETSUB='exp'; renderSettings(); try{ document.getElementById('setlist').scrollTop=0; }catch(_es){} };

'@

SubRx @'
document.getElementById('closesettings').onclick=function(){

'@ @'
document.getElementById('closesettings').onclick=function(){
  if(SETSUB){ SETSUB=''; renderSettings(); return; }   // v32.xx (cw-expmenu1): esc and B leave the experimental page first

'@

SubRx @'
  try{ renderSettings(); }catch(e){}
  try{ document.getElementById('exporttext').value=buildExport(); }catch(e){}

'@ @'
  if(!_smOn) SETSUB='';   // v32.xx (cw-expmenu1)
  try{ renderSettings(); }catch(e){}
  try{ document.getElementById('exporttext').value=buildExport(); }catch(e){}

'@

SubRx @'
function startRaid(){
  if(netGuestHeld()) return false;   // v15.91: in a party only the host takes the lift; a guest goes up on the host word (the net section)

'@ @'
function startRaid(){
  if(netGuestHeld()) return false;   // v15.91: in a party only the host takes the lift; a guest goes up on the host word (the net section)
  xfSnap();   // v32.xx (cw-expmenu1): the experimental switches this raid is built and played with (on a linked window the host's, netUpStart has them in CFG)

'@

SubRx @'
  if(flowPeer()) return;   // v27.27 (coop8): a linked player 2 window counts nothing and pays no chip, the goals are the host (goalsNetTake)

'@ @'
  if(flowPeer()) return;   // v27.27 (coop8): a linked player 2 window counts nothing and pays no chip, the goals are the host (goalsNetTake)
  if(!xf('xfGoals')) return;   // v32.xx (cw-expmenu1): switched off, the raid makes and pays no goals

'@

SubRx @'
  if(flowPeer()) return;   // v27.18 (coop5): a linked player 2 window gilds nothing, the golden enemy is the host one (goldNetTake)

'@ @'
  if(flowPeer()) return;   // v27.18 (coop5): a linked player 2 window gilds nothing, the golden enemy is the host one (goldNetTake)
  if(!xf('xfGold')) return;   // v32.xx (cw-expmenu1): switched off, no body is gilded

'@

SubRx @'
  if(flowPeer()){ shPeerTick(dt); return; }   // v27.46 (coop4): a linked player 2 window lays out and fills no stronghold, it keeps the host ones (shNetTake)

'@ @'
  if(!xf('xfHold')) return;   // v32.xx (cw-expmenu1): switched off, no stronghold is laid out
  if(flowPeer()){ shPeerTick(dt); return; }   // v27.46 (coop4): a linked player 2 window lays out and fills no stronghold, it keeps the host ones (shNetTake)

'@

SubRx @'
function pwrKill(k,el,boss,x,y,e){
  var S, t, n, ch, roll=1, wr=0, tot=0, i, kd=null, p;

'@ @'
function pwrKill(k,el,boss,x,y,e){
  var S, t, n, ch, roll=1, wr=0, tot=0, i, kd=null, p;
  if(!xf('xfPwr')) return 0;   // v32.xx (cw-expmenu1): switched off, kills drop nothing

'@

SubRx @'
var VER='32.98';
'@ @'
var VER='32.99';
'@

$pat = "(?m)^  now:'v32\.98:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.99: Settings has an experimental page with on/off rows for run goals, golden enemy, strongholds and power-ups. Check 32.99 fails on v32.98',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
