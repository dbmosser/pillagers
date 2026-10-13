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

# CAREER RAIDS: THE WAVES (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
if(G.arcade&&!G.over) try{ arcadeWaveTick(dt); }catch(_awt){}
'@ @'
if((G.arcade||G.career)&&!G.over) try{ arcadeWaveTick(dt); }catch(_awt){}
'@

SubRx @'
function arcadeWaveTick(dt){
  if(!G||!G.arcade||G.over||G.sim||!G.map||!Array.isArray(G.ents)) return 0;
  if((ARCADE.role==='p2'&&!G.netWasJoin)||netEntsPeer()) return 0;   // v23.52 (arcade28): a player 2 that took the raid over runs the waves
  var tier=Math.max(0,Math.min(8,Math.floor(arcadeTeam()/4000))), iv=Math.max(10,22-2*tier), cap=Math.min(24,6+2*tier),
      pack=Math.min(6,2+Math.floor(tier/2)), men, live, q, c, n, i, e, s, kd, kinds, made=0;
  ARCADE.waveT=(+ARCADE.waveT||0)+((dt>0)?dt:0);
  if(ARCADE.waveT<iv) return 0;
'@ @'
// v24.xx (feat0h3), HIS ANSWER (2026-10-12): "CAREER waves are the same as DEMO", and his rule that the gameplay is EXACTLY THE SAME in
// DEMO and CAREER. WAVES IN A CAREER RAID. The same tick runs in a CAREER raid with the same interval, cap, pack and kinds, keeping its
// clock and count in the raid score store (G.cs) and taking its tier from the CAREER score; the host (or the one who took the raid
// over) runs it, never a co-op partner sharing the host world. Two career-only guards keep his save clean: a wave body is made on the
// cosmetic stream (fxBorrow), so the seeded stream of the raid never moves, and a wave pillager carries a wave identity (an id ending
// _cwN) that idRec never files, so a wave kill writes no grudge, no WANTS REVENGE and no rival into his save, in either window.
function waveIdent(id){ return String(id||'').indexOf('_cw')>=0; }
function arcadeWaveTick(dt){
  if(!G||!(G.arcade||G.career)||G.over||G.sim||!G.map||!Array.isArray(G.ents)) return 0;
  if((G.arcade&&ARCADE.role==='p2'&&!G.netWasJoin)||netEntsPeer()) return 0;   // v23.52 (arcade28): a player 2 that took the raid over runs the waves
  var WS=G.arcade?ARCADE:G.cs; if(!WS) return 0;
  var tier=Math.max(0,Math.min(8,Math.floor((G.arcade?arcadeTeam():Math.max(0,WS.s|0))/4000))), iv=Math.max(10,22-2*tier), cap=Math.min(24,6+2*tier),
      pack=Math.min(6,2+Math.floor(tier/2)), men, live, q, c, n, i, e, s, kd, kinds, made=0;
  WS.waveT=(+WS.waveT||0)+((dt>0)?dt:0);
  if(WS.waveT<iv) return 0;
'@

SubRx @'
  if(live>=cap){ ARCADE.waveT=iv-1; return 0; }   // full: look again in a second
  q=men[Math.floor(Math.random()*men.length)];
  c=arcadeWaveSpot(men,q);
  if(!c){ ARCADE.waveT=iv-0.5; return 0; }   // no floor this time: try again shortly
'@ @'
  if(live>=cap){ WS.waveT=iv-1; return 0; }   // full: look again in a second
  q=men[Math.floor(Math.random()*men.length)];
  c=arcadeWaveSpot(men,q);
  if(!c){ WS.waveT=iv-0.5; return 0; }   // no floor this time: try again shortly
'@

SubRx @'
    e=(kd==='sentry')?mkSentry(s.x,s.y):(kd==='raider')?arcadeWaveRaider(s.x,s.y):mkCrawler(s.x,s.y);
'@ @'
    e=null;
    if(G.career) fxBorrow(function(){ e=(kd==='sentry')?mkSentry(s.x,s.y):(kd==='raider')?arcadeWaveRaider(s.x,s.y):mkCrawler(s.x,s.y); });   // v24.xx (feat0h3)
    else e=(kd==='sentry')?mkSentry(s.x,s.y):(kd==='raider')?arcadeWaveRaider(s.x,s.y):mkCrawler(s.x,s.y);
'@

SubRx @'
  ARCADE.waveT=0;
  if(made){ ARCADE.waveN=(ARCADE.waveN|0)+1; say('WAVE '+ARCADE.waveN,'warn');
'@ @'
  WS.waveT=0;
  if(made){ WS.waveN=(WS.waveN|0)+1; say('WAVE '+WS.waveN,'warn');
'@

SubRx @'
function arcadeWaveRaider(x,y){
  var idn=null, i, j, c, t, R, w=ARCADE.waveN|0;
'@ @'
function arcadeWaveRaider(x,y){
  var idn=null, i, j, c, t, R, w=(G.career&&G.cs)?(G.cs.waveN|0):(ARCADE.waveN|0);
'@

SubRx @'
  R=mkRaider(x,y,idn,false);
'@ @'
  if(G.career) idn={id:idn.id+'_cw'+w,tag:idn.tag,coat:idn.coat};   // v24.xx (feat0h3): a wave identity, never filed in his save
  R=mkRaider(x,y,idn,!!G.career);
'@

SubRx @'
function idRec(id){
  P.rivals=P.rivals||{};
'@ @'
function idRec(id){
  if(typeof waveIdent==='function'&&waveIdent(id)) return {kills:0,deaths:0,met:0,standing:-1};   // v24.xx (feat0h3): a CAREER wave pillager is never filed
  P.rivals=P.rivals||{};
'@

SubRx @'
if(e.kind==='raider'&&e.ident&&!G.sim){
'@ @'
if(e.kind==='raider'&&e.ident&&!G.sim&&!waveIdent(e.ident)){   /* v24.xx (feat0h3): no grudge for a CAREER wave pillager */
'@

SubRx @'
if(k==='raider'&&e&&e.ident){
'@ @'
if(k==='raider'&&e&&e.ident&&!waveIdent(e.ident)){   /* v24.xx (feat0h3) */
'@

SubRx @'
var VER='25.36';
'@ @'
var VER='25.37';
'@

$pat = "(?m)^  now:'v25\.36:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v25.37: CAREER raids send waves at you, as the DEMO does. Check 25.37 fails on v25.36',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
