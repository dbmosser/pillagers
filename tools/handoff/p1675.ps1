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

# SUPERHOT FOLLOWS THE HOST FOR THE WHOLE PARTY (stability pass, 2026-09-27; drafted by a review agent, reviewed by a second).

SubRx @'
      cycleGameOpt('superhot');
'@ @'
      if(cycleGameOpt('superhot')===false) return;   // v16.74, his order: on a linked window the host word rules; cycleGameOpt said so, and there is no dial of its own to report
'@

SubRx @'
  if(CFG.superhot&&G.player&&!G.over&&!G.paused){   // v16.27, his note: in co-op time runs while ANY player up top is acting (v16.04 had it off)
'@ @'
  if(CFG.superhot&&G.player&&!G.over&&(!G.paused||netPauseLive())){   // v16.27, his note: in co-op time runs while ANY player up top is acting (v16.04 had it off); v16.74, his order: a window paused in a shared raid, where the world runs on, still stops time unless a teammate is acting
'@

SubRx @'
    G.shAct=_shAct;
    if(!_shAct&&!netAnyActing()) dt=0;
'@ @'
    if(G.paused) _shAct=false;   // v16.74, his order: paused in a shared raid this player is not acting, whatever is still held under the box
    G.shAct=_shAct;
    if(!_shAct&&!netAnyActing()) dt=0;
'@

SubRx @'
  NET.up=[]; NET.upAcc=0; NET.upN=0; NET.upSeed=0; NET.upFp=null;   // v15.79: and nobody up top
'@ @'
  NET.up=[]; NET.upAcc=0; NET.upN=0; NET.upSeed=0; NET.upFp=null;   // v15.79: and nobody up top
  netShDrop();   // v16.74, his order: the Superhot dial goes back to this window own word when the party ends
'@

SubRx @'
function netKidMul(){ var h=(typeof NET.kidHost==='number'&&NET.kidHost>=0.1&&NET.kidHost<=1)?NET.kidHost:1; return Math.min(kidMulOwn(),h); }
'@ @'
function netKidMul(){ var h=(typeof NET.kidHost==='number'&&NET.kidHost>=0.1&&NET.kidHost<=1)?NET.kidHost:1; return Math.min(kidMulOwn(),h); }
// v16.74, his order: SUPERHOT IS THE HOST SETTING FOR THE WHOLE PARTY. Each window had its own dial (the Settings row, the
// backquote key), and the state word says a window with the dial off is always acting (sa), so with player 1 on and player 2
// off time never stopped for either. The host now sends its dial in the world word (netWorldSend, twice a second), and a linked
// window puts it on its live dial, CFG.superhot: the gate that stops time, the state word, the Settings row and the backquote
// line all read that one dial, so they use and show the host value. Its own saved word (P.gameOpts) is never written: the first
// host word keeps the live value it replaced (NET.shOwn) and netReset puts it back when the party ends. applyGameOpts puts the
// host value back on top after any other Settings row is clicked, and cycleGameOpt refuses the row and the key while a host
// word rules, with a line that says so. The host window and solo play never reach any of it.
function netShHost(){ return (typeof NET==='object'&&NET&&NET.on&&NET.role==='join'&&(NET.shHost===0||NET.shHost===1))?NET.shHost:null; }
function netShTake(v){
  v=v?1:0;
  if(NET.shHost!==0&&NET.shHost!==1) NET.shOwn=CFG.superhot?1:0;
  NET.shHost=v;
  if((CFG.superhot?1:0)!==v){
    CFG.superhot=v;
    try{ var _sm=document.getElementById('settingsmodal'); if(_sm&&_sm.classList.contains('on')) renderSettings(); }catch(_rs){}
  }
  return v;
}
function netShDrop(){
  if((NET.shHost===0||NET.shHost===1)&&(NET.shOwn===0||NET.shOwn===1)) CFG.superhot=NET.shOwn;
  NET.shHost=null; NET.shOwn=null;
}
'@

SubRx @'
  m.kd=kidMulOwn();   // v16.44: kid mode as the host has it, live
'@ @'
  m.kd=kidMulOwn();   // v16.44: kid mode as the host has it, live
  m.sh=CFG.superhot?1:0;   // v16.74, his order: Superhot as the host has it, for the whole party (netShTake on a linked window)
'@

SubRx @'
  if(typeof m.kd==='number'&&isFinite(m.kd)) NET.kidHost=clamp(m.kd,0.1,1);   // v16.44: kid mode as the host has it
'@ @'
  if(typeof m.kd==='number'&&isFinite(m.kd)) NET.kidHost=clamp(m.kd,0.1,1);   // v16.44: kid mode as the host has it
  if(m.sh===0||m.sh===1) netShTake(m.sh);   // v16.74, his order: Superhot as the host has it, put on this window live dial
'@

SubRx @'
  G=S; NET.specTick=true;
  try{
'@ @'
  G=S; NET.specTick=true;
  try{
    if(CFG.superhot&&!netAnyActing()) wdt=0;   // v16.74, his order: in Superhot the kept raid clock and world stand still unless a teammate up top is acting (the v16.27 rule, which the run card frame keeps and this stepper did not)
'@

SubRx @'
  if(gameOptIx('raiders')===3&&!tk.raiderWaves) CFG.raiderWaves=0;
'@ @'
  if(gameOptIx('raiders')===3&&!tk.raiderWaves) CFG.raiderWaves=0;
  if(netShHost()!==null) CFG.superhot=netShHost();   // v16.74, his order: on a linked window the host Superhot word stays on top of every other row click and of a profile load
'@

SubRx @'
  P.gameOpts=P.gameOpts||{};
'@ @'
  if(k==='superhot'&&netShHost()!==null){   // v16.74, his order: player 1 sets Superhot for the party; the row and the key on a linked window say so and stay
    var _shL='Superhot follows the host while you are in a party.';
    if(G&&!G.over&&!G.sim) say(_shL); else if(typeof say2==='function') say2(_shL);
    return false;
  }
  P.gameOpts=P.gameOpts||{};
'@

SubRx @'
var VER='16.74';
'@ @'
var VER='16.75';
'@

$pat = "(?m)^  now:'v16\.74:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.75: SUPERHOT FOLLOWS THE HOST FOR THE WHOLE PARTY. His order during his co-op session: when player 1 turns Superhot on or off it applies to everyone in the party for the rest of the session. Before, each window had its own switch, and with only one of them on time never stopped for anyone. And whenever time stands still in Superhot, so do the extraction clock, the wave clock and the raid the host keeps running for the party. Check 16.75 fails on v16.74',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
