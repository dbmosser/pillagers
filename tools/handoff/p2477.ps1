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

# RUN OVER: BEST MOMENTS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function arcadeKill(k,el,boss,x,y){

'@ @'
// v23.xx, HIS ANSWERS (2026-10-12), answer 20: "RUN OVER: score count-up plus best moments". BEST MOMENTS. Once the score has counted
// up, the RUN OVER card shows the three moments of the run: BEST STREAK (the longest chain of kills, 2 or more), BIGGEST HAUL (the
// most loot credits picked up in one life, between drops) and LONGEST SHOT (the farthest kill, in metres from him to the body). Each
// window keeps its own (ARCADE.bm), reset at every drop into a new run; player 2 sends its own with the score word (arcsc bm), so in
// the 2 player demo the card shows the best of the two with P1 or P2 beside it. A moment that did not happen is left off. Display
// only: nothing is scored, saved or drawn from a seeded stream.
function arcadeBmNew(){ return {st:0,hl:0,ls:0,cur:0,lid:''}; }
function arcadeBmKill(n,x,y){
  var b=ARCADE.bm||(ARCADE.bm=arcadeBmNew()), d;
  if((n|0)>b.st) b.st=n|0;
  if(G&&G.player&&isFinite(x)&&isFinite(y)){ d=metres(Math.hypot(x-G.player.x,y-G.player.y)); if(d>b.ls) b.ls=d; }
  return b;
}
function arcadeBmLoot(n){
  var b=ARCADE.bm||(ARCADE.bm=arcadeBmNew()), lid=(ARCADE.deaths|0)+'|'+(ARCADE.ext|0);
  if(b.lid!==lid){ b.lid=lid; b.cur=0; }
  b.cur+=Math.max(0,n|0); if(b.cur>b.hl) b.hl=b.cur;
  return b;
}
function arcadeBmWire(){ var b=ARCADE.bm||arcadeBmNew(); return [b.st|0,b.hl|0,b.ls|0]; }
function arcadeBmTake(w){ if(!Array.isArray(w)) return null; return {st:Math.max(0,w[0]|0),hl:Math.max(0,w[1]|0),ls:Math.max(0,w[2]|0)}; }
// the moments of the run for the card: the best of this window and the other, with who
function arcadeBmFinal(){
  var me=ARCADE.bm||arcadeBmNew(), mt=ARCADE.mateBm||null, host=(ARCADE.role==='host'), two=!ARCADE.solo&&!!mt, out={}, k, a, b;
  ['st','hl','ls'].forEach(function(k2){
    a=me[k2]|0; b=mt?(mt[k2]|0):0;
    out[k2]=(b>a)?{v:b,who:two?(host?'P2':'P1'):''}:{v:a,who:two?(host?'P1':'P2'):''};
  });
  return out;
}
function arcadeBmDraw(c,o,counting){
  var m=o&&o.bm, el, rows=[], i, t, s1, s2;
  if(!c||!m) return false;
  el=c.querySelector('.aobm');
  if(!el){
    if(m.st&&m.st.v>=2) rows.push(['BEST STREAK',m.st.v+' KILLS',m.st.who]);
    if(m.hl&&m.hl.v>0) rows.push(['BIGGEST HAUL',arcadeCr(m.hl.v),m.hl.who]);
    if(m.ls&&m.ls.v>0) rows.push(['LONGEST SHOT',m.ls.v+' M',m.ls.who]);
    if(!rows.length) return false;
    el=document.createElement('div'); el.className='aobm';
    el.style.cssText='display:none;justify-content:center;gap:2.4em;margin:.55em 0 .1em;';
    for(i=0;i<rows.length;i++){
      t=document.createElement('div'); t.className='aobmt'; t.style.cssText='text-align:center;line-height:1.05';
      s1=document.createElement('div'); s1.style.cssText='font-size:.62em;letter-spacing:.14em;color:#f2e6c8;opacity:.78'; s1.textContent=rows[i][0]+(rows[i][2]?'  \u00b7  '+rows[i][2]:'');
      s2=document.createElement('div'); s2.style.cssText='font-size:1.25em;color:#ffc04a'; s2.textContent=rows[i][1];
      t.appendChild(s1); t.appendChild(s2); el.appendChild(t);
    }
    c.appendChild(el);
  }
  el.style.display=counting?'none':'flex';
  return true;
}
function arcadeKill(k,el,boss,x,y){

'@

SubRx @'
  s.n++; s.t=t; mx=arcadeStreakX(s.n); n*=mx;
'@ @'
  s.n++; s.t=t; mx=arcadeStreakX(s.n); n*=mx;
  try{ arcadeBmKill(s.n,x,y); }catch(_bmk){}   // v23.xx (his answer 20): the best streak and the longest shot
'@

SubRx @'
  ARCADE.mine=(ARCADE.mine|0)+n; ARCADE.pot=(ARCADE.pot|0)+n;
'@ @'
  ARCADE.mine=(ARCADE.mine|0)+n; ARCADE.pot=(ARCADE.pot|0)+n;
  try{ arcadeBmLoot(n); }catch(_bml){}   // v23.xx (his answer 20): the biggest haul
'@

SubRx @'
  ARCADE.streak=null;   // v23.38 (arcade15): the kill streak starts again
'@ @'
  ARCADE.streak=null;   // v23.38 (arcade15): the kill streak starts again
  ARCADE.bm=arcadeBmNew(); ARCADE.mateBm=null;   // v23.xx (his answer 20): the best moments start again
'@

SubRx @'
  if(ARCADE.scEv){ m.ev=ARCADE.scEv; m.n=Math.max(0,ARCADE.scN|0); }
'@ @'
  try{ m.bm=arcadeBmWire(); }catch(_bmw){}   // v23.xx (his answer 20): the best moments go with the score
  if(ARCADE.scEv){ m.ev=ARCADE.scEv; m.n=Math.max(0,ARCADE.scN|0); }
'@

SubRx @'
  ARCADE.scSeen=Date.now(); ARCADE.mate=Math.max(0,Math.round(+m.s||0));
'@ @'
  try{ if(m.bm) ARCADE.mateBm=arcadeBmTake(m.bm); }catch(_bmt){}   // v23.xx (his answer 20)
  ARCADE.scSeen=Date.now(); ARCADE.mate=Math.max(0,Math.round(+m.s||0));
'@

SubRx @'
  ARCADE.over={at:Date.now(),why:String(why||''),team:arcadeTeam(),p1:host?me:mt,p2:host?mt:me};
'@ @'
  ARCADE.over={at:Date.now(),why:String(why||''),team:arcadeTeam(),p1:host?me:mt,p2:host?mt:me};
  try{ ARCADE.over.bm=arcadeBmFinal(); }catch(_bmf){}   // v23.xx (his answer 20): the best moments of the run
'@

SubRx @'
  c.setAttribute('data-cu',k<1?'1':'0');
'@ @'
  c.setAttribute('data-cu',k<1?'1':'0');
  try{ arcadeBmDraw(c,o,k<1); }catch(_bmd){}   // v23.xx (his answer 20): then the best moments
'@

SubRx @'
var VER='24.76';
'@ @'
var VER='24.77';
'@

$pat = "(?m)^  now:'v24\.76:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v24.77: After the score counts up, RUN OVER shows BEST STREAK, BIGGEST HAUL and LONGEST SHOT. Check 24.77 fails on v24.76',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
