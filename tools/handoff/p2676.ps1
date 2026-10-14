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

# SEARCHERS SWEEP IN WIDENING RINGS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function feudFoe(a,b){
'@ @'
// v26.xx (ai26), HIS YES (2026-10-14, suggestion 26): SEARCH PATTERNS. A pillager or machine that lost you used to walk to ONE point
// near where it last saw you (its own slot of the fan, searchSector) and, on arriving with nothing there, drop the whole hunt on the
// spot. Now it searches in THREE widening rings: on reaching its point it picks a new one farther out along the same slot (the
// radius grows by 80 percent a ring, 130 then 234 then 338) and keeps hunting, and only gives up on arriving at the third. And you can
// SEE the search: a faint amber scan cone on the ground in front of each searcher you can see, which widens with each ring (reach 170,
// 250, 340; half angle 0.55, 0.75, 0.95 radians), sweeps a little side to side, is cut off by walls and by smoke (it is clipped by the
// same sight segments the sight test uses), and SHORTENS to the crouch-hide distance (CFG.crouchHide, 170) while you crouch, which is
// exactly the distance past which crouching hides you from it. Linked windows are told a body is searching by the top flag bit and draw
// the middle ring. Cosmetic code draws no random number; the search itself spends none (a counter and a radius).
var SEARCH_MAXL=2, SEARCH_REACH=[170,250,340], SEARCH_HALF=[0.55,0.75,0.95];
function searching(e){
  if(!e||!(e.hp>0)||e.downed||e.finished||e.merc||e.friendlyPC) return false;
  if(e.net) return e.srch===1;
  return e.state==='chase'&&e.searchX!==undefined&&(((G&&G.t)||0)-(e.sirenSeeT===undefined?-99:e.sirenSeeT))>0.4;
}
function searchCone(e){
  var L, sight, reach, half, chid, t;
  if(!searching(e)) return null;
  if(e.kind!=='raider'&&e.kind!=='sentry'&&e.kind!=='crawler'&&e.kind!=='bulwark'&&e.kind!=='listener') return null;
  L=e.net?1:Math.max(0,Math.min(SEARCH_MAXL,e.searchLvl|0));
  sight=Math.max(e.rng||0,(CFG.eAmbient===undefined?100:CFG.eAmbient))*1.35;
  reach=Math.min(SEARCH_REACH[L],sight); half=SEARCH_HALF[L];
  chid=(CFG.crouchHide===undefined?170:CFG.crouchHide);
  if(G&&G.pCrouch&&chid>0&&reach>chid) reach=chid;
  t=(G&&G.t)||0;
  return {x:e.x,y:e.y,face:e.face+Math.sin(t*2.2+e.x*0.01)*0.3,half:half,reach:reach,lvl:L};
}
function searchAdvance(e){
  var L=e.searchLvl|0;
  if(L>=SEARCH_MAXL) return false;
  e.searchLvl=L+1; e.srchBest=undefined; e.srchT=0;
  delete e.searchX; delete e.searchY;
  e.alert=Math.max(e.alert||0,2.4);
  return true;
}
function feudFoe(a,b){
'@

SubRx @'
  var R=(CFG.crewSearchR===undefined?130:CFG.crewSearchR);
'@ @'
  var R=(CFG.crewSearchR===undefined?130:CFG.crewSearchR)*(1+0.8*(e.searchLvl|0));   // v26.xx (ai26): each ring of the search is wider
'@

SubRx @'
          if(dist(e,{x:_shx,y:_shy})>40) navSeek(e,_shx,_shy,e.spd*.9,dt);
          else e.alert=0;
'@ @'
          var _sd=dist(e,{x:_shx,y:_shy});
          if(_sd>40&&_srch){ if(_sd<(e.srchBest===undefined?1e9:e.srchBest)-6){ e.srchBest=_sd; e.srchT=0; } else e.srchT=(e.srchT||0)+dt; }   // v26.xx (ai26): a point he cannot get nearer to for 1.5 s counts as reached
          if(_sd>40&&!(_srch&&(e.srchT||0)>1.5)) navSeek(e,_shx,_shy,e.spd*.9,dt);
          else if(!(_srch&&searchAdvance(e))) e.alert=0;   // v26.xx (ai26): on arriving he searches the next, wider ring before he gives up
'@

SubRx @'
        if(e.roleT>0) e.roleT-=dt; else if(e.role){ e.role=null; }
'@ @'
        if(_srch&&!sees&&e.searchX!==undefined&&dist(e,{x:e.searchX,y:e.searchY})<44) searchAdvance(e);   // v26.xx (ai26): a machine also searches the next ring
        if(e.roleT>0) e.roleT-=dt; else if(e.role){ e.role=null; }
'@

SubRx @'
if(e.searchArc!==undefined){ delete e.searchArc; delete e.searchX; delete e.searchY; }
'@ @'
if(e.searchArc!==undefined){ delete e.searchArc; delete e.searchX; delete e.searchY; e.searchLvl=0; e.srchBest=undefined; e.srchT=0; }
'@

SubRx @'
    delete e.searchX; delete e.searchY; delete e.searchArc;
'@ @'
    delete e.searchX; delete e.searchY; delete e.searchArc; e.searchLvl=0; e.srchBest=undefined; e.srchT=0;   // v26.xx (ai26): a new sighting is a new search
'@

SubRx @'
// noise pings. v4.05: drawn AFTER the darkness now, see below; this pass
'@ @'
  // v26.xx (ai26): the scan cone of every searcher in sight, on the ground (searchCone above).
  for(i=0;i<G.ents.length;i++){
    var _sce=G.ents[i];
    if(!_sce.seen) continue;
    var _sk=searchCone(_sce); if(!_sk) continue;
    if(_sk.x+_sk.reach<ox||_sk.x-_sk.reach>ox+VW||_sk.y+_sk.reach<oy||_sk.y-_sk.reach>oy+VH) continue;
    var _spol=conePoly(_sk.x,_sk.y,_sk.face,_sk.half,_sk.reach,segsNear(_sk.x,_sk.y,_sk.reach,G.vseg),14);
    wc.fillStyle='rgba(255,196,72,'+(0.05+0.03*_sk.lvl).toFixed(3)+')';
    wc.strokeStyle='rgba(255,196,72,'+(0.14+0.05*_sk.lvl).toFixed(3)+')'; wc.lineWidth=1;
    wc.beginPath(); wc.moveTo(_spol[0].x,_spol[0].y);
    for(j=1;j<_spol.length;j++) wc.lineTo(_spol[j].x,_spol[j].y);
    wc.closePath(); wc.fill(); wc.stroke();
  }
// noise pings. v4.05: drawn AFTER the darkness now, see below; this pass
'@

SubRx @'
  if(e.downed&&e.getUp>0) f|=8388608;   // pillrevive: he is getting up
'@ @'
  if(e.downed&&e.getUp>0) f|=8388608;   // pillrevive: he is getting up
  if(searching(e)) f|=-2147483648;   // v26.xx (ai26): he is searching, so player 2 sees the scan cone
'@

SubRx @'
  e.steady=!!(f&8192);
'@ @'
  e.srch=(f&-2147483648)?1:0;   // v26.xx (ai26)
  e.steady=!!(f&8192);
'@

SubRx @'
var VER='26.75';
'@ @'
var VER='26.76';
'@

$pat = "(?m)^  now:'v26\.75:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.76: Enemies that lose you now search in three widening rings and show an amber scan cone that smoke and crouching visibly cut short. Check 26.76 fails on v26.75',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
