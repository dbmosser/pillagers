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

# Easy mode question in the 2 player demo (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function arcadeIniHud(){

'@ @'
// v28.xx (cw-easymode), HIS ANSWER (2026-10-18, Q66): "At some point the game asks the players if they want easy mode." In the 2 player demo, the
// moment a player drops back in after his second death of the run with no extraction yet, a card asks once (per page, per window): keyboard Y or N,
// pad A or B, no answer in 12 s is a no. Yes takes a third off the damage he takes (EASY_MUL, the Forgiving setting). The card never stops play: only
// its own keys and buttons are taken. Nothing changes until he says yes, so a normal raid and the seed 4242 fingerprint are untouched.
var EASY_MUL=0.7, EASY_MS=12000;
function easyDmgMul(){ return (typeof ARCADE==='object'&&ARCADE&&ARCADE.easy&&G&&G.arcade)?EASY_MUL:1; }
function easyLive(){ return !!(typeof ARCADE==='object'&&ARCADE&&ARCADE.on&&ARCADE.easyAsk&&G&&G.arcade&&!G.over&&!G.sim); }
function easyAskMaybe(why){
  if(typeof ARCADE!=='object'||!ARCADE||!ARCADE.on||ARCADE.solo||ARCADE.easyAsked||ARCADE.easy||why==='bench') return false;
  if((ARCADE.deaths|0)<2||(ARCADE.ext|0)>0) return false;
  ARCADE.easyAsked=1; ARCADE.easyAsk={at:Date.now()};
  return true;
}
function easyAnswer(yes){
  if(!ARCADE||!ARCADE.easyAsk) return false;
  ARCADE.easyAsk=null;
  if(yes){ ARCADE.easy=1; try{ say('Easy mode on','info'); }catch(_es){} }
  return true;
}
function easyKey(e){
  if(!easyLive()||!e||String(e.type||'')!=='keydown'||e.repeat||e.ctrlKey||e.altKey||e.metaKey) return false;
  var cd=String(e.code||'');
  if(cd!=='KeyY'&&cd!=='KeyN') return false;
  try{ e.preventDefault(); e.stopImmediatePropagation(); }catch(_x){}
  easyAnswer(cd==='KeyY');
  return true;
}
function easyPad(nw){
  if(!easyLive()||!nw) return false;
  var i, b, yes=null;
  for(i=0;i<nw.length&&yes===null;i++){ b=nw[i]; if(b===0) yes=true; else if(b===1) yes=false; }
  if(yes===null) return false;
  try{ PAD.prev[nw[i-1]]=true; if(!PAD.mSpent) PAD.mSpent=[]; PAD.mSpent[nw[i-1]]=1; }catch(_pp){}
  easyAnswer(yes);
  return true;
}
function easyHud(){
  var n=ARCADE.easyAsk, cx, y, bw, bh, left;
  if(!easyLive()||!ctx) return;
  left=EASY_MS-(Date.now()-(+n.at||0));
  if(left<=0){ easyAnswer(false); return; }
  cx=Math.round(W/2); y=Math.round(H*0.30); bw=LH(440); bh=LH(96);
  ctx.save(); ctx.textAlign='center'; ctx.textBaseline='alphabetic';
  ctx.fillStyle='rgba(6,9,13,.86)'; ctx.fillRect(cx-bw/2,y-LH(40),bw,bh);
  ctx.strokeStyle='rgba(127,227,212,.75)'; ctx.lineWidth=2; ctx.strokeRect(cx-bw/2+1,y-LH(40)+1,bw-2,bh-2);
  ctx.font=FS(TYPE.head); ctx.fillStyle='#7fe3d4'; hudText('Want easy mode?',cx,y-LH(12));
  ctx.font=FS(TYPE.micro); ctx.fillStyle='rgba(242,230,200,.88)';
  hudText(padB('Y or A  yes  \u00b7  N or B  no')+'  \u00b7  '+Math.ceil(left/1000),cx,y+LH(18));
  ctx.restore();
}
function arcadeIniHud(){

'@

SubRx @'
  try{ arcadeIniHud(); }catch(_aih){}   // v23.45 (arcade22): the initials card at a top 10 extraction

'@ @'
  try{ arcadeIniHud(); }catch(_aih){}   // v23.45 (arcade22): the initials card at a top 10 extraction
  try{ easyHud(); }catch(_eh){}   // v28.xx (cw-easymode): the easy mode question

'@

SubRx @'
  ARCADE.holdT=3;
  return true;

'@ @'
  try{ easyAskMaybe(why); }catch(_ea){}   // v28.xx (cw-easymode): his answer Q66, the easy mode question after the second death
  ARCADE.holdT=3;
  return true;

'@

SubRx @'
  if(ARCOP) return arcadeOpKey(e);   // v26.xx (party5): the operator menu takes the keys and clicks

'@ @'
  if(ARCOP) return arcadeOpKey(e);   // v26.xx (party5): the operator menu takes the keys and clicks
  if(easyKey(e)) return true;   // v28.xx (cw-easymode): Y or N answers the easy mode question

'@

SubRx @'
  if(padMenu(pressed)){ PAD.mSpent=[];
'@ @'
  // v28.xx (cw-easymode): the easy mode question takes A (yes) or B (no) on this window pad; the press is spent, the rest of the pad plays on
  if(typeof ARCADE==='object'&&ARCADE&&ARCADE.on&&easyLive()){
    var _enw=[], _ei;
    for(_ei=0;_ei<bt.length;_ei++) if(pressed(_ei)&&!PAD.prev[_ei]) _enw.push(_ei);
    try{ easyPad(_enw); }catch(_epd){}
  }
  if(padMenu(pressed)){ PAD.mSpent=[];
'@

SubRx @'
  amt*=CFG.eDmg;

'@ @'
  amt*=CFG.eDmg*easyDmgMul();   // v28.xx (cw-easymode): a third off once he said yes to easy mode

'@

SubRx @'
var VER='30.31';
'@ @'
var VER='30.32';
'@

$pat = "(?m)^  now:'v30\.31:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v30.32: The 2 player demo now asks once if you want easy mode after your second death. Check 30.32 fails on v30.31',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
