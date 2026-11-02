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

# three heirs with small traits and rough names for the next pillager (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var WORN_PW_MAX=100;

'@ @'
var WORN_PW_MAX=100;
// v37.xx (cw-p2heirs), HIS RULINGS OF 11-01 (season zero m2): "choose 1 of 3 heirs, each with small traits, auto-named like Rogue Legacy"; answer 3:
// no $ bonus for a worse draw. A TRAIT is a small signed stat in the gear vocabulary (WORN_STATS), a third to a half of one gear trait, so it is felt
// but gear matters more; a bad one is negative. raidWornMods adds the living pillager's traits onto the gear sum, so wornM stays the one reader.
// Mostly good (a good trait is rolled three times as often): an heir is a reason to play, not a punishment. Two traits never share a stat, so a
// trait never comes with its opposite.
var PIL_TRAITS=[
  {id:'lightstep',  n:'light step',   m:[{s:'quiet', v:0.02}]},
  {id:'loudboots',  n:'loud boots',   m:[{s:'quiet', v:-0.02}]},
  {id:'steadyhands',n:'steady hands', m:[{s:'steady',v:0.02}]},
  {id:'shaky',      n:'shaky',        m:[{s:'steady',v:-0.02}]},
  {id:'quickhands', n:'quick hands',  m:[{s:'reload',v:0.02}]},
  {id:'slowhands',  n:'slow hands',   m:[{s:'reload',v:-0.02}]},
  {id:'toughhide',  n:'tough hide',   m:[{s:'tough', v:0.012}]},
  {id:'glassbones', n:'glass bones',  m:[{s:'tough', v:-0.012}]},
  {id:'longlegs',   n:'long legs',    m:[{s:'spd',   v:0.015}]},
  {id:'heavyfeet',  n:'heavy feet',   m:[{s:'spd',   v:-0.015}]},
  {id:'deeplungs',  n:'deep lungs',   m:[{s:'stam',  v:0.025}]},
  {id:'shortwind',  n:'short wind',   m:[{s:'stam',  v:-0.025}]},
  {id:'shadow',     n:'shadow',       m:[{s:'hide',  v:0.015}]},
  {id:'bigtarget',  n:'big target',   m:[{s:'hide',  v:-0.015}]},
  {id:'fieldmedic', n:'field medic',  m:[{s:'heal',  v:0.025},{s:'revive',v:0.03}]},
  {id:'keeneye',    n:'keen eye',     m:[{s:'search',v:0.02}]},
  {id:'stubborn',   n:'stubborn',     m:[{s:'grit',  v:0.03}]}
];
var PIL_TRAIT_BY={}; (function(){ for(var i=0;i<PIL_TRAITS.length;i++) PIL_TRAIT_BY[PIL_TRAITS[i].id]=PIL_TRAITS[i]; })();
// Short rough names; the numeral after one counts that name in the lineage (pilName).
var PIL_NAMES=['brakka','vosk','tamsin','gurt','morl','hask','edda','crane','rook','skarn','dagny','orrin','maeve','thorn','bram','kesk','ulla','fenn',
  'grue','harl','juno','kett','lusk','marrow','nell','odo','pike','quill','rask','sable','tusk','varg','wren','yarrow','zell','bodge','cinder','drabb','flint','gorse'];

'@

SubRx @'
function pilMake(name,gen){ return {name:String(name||'PILLAGER').slice(0,24),gen:Math.max(1,gen|0),traits:[],lvl:1,lsp:0,picks:[],raids:0,ext:0,kills:0,best:0,born:Date.now()}; }

'@ @'
function pilMake(name,gen,traits,num){ return {name:String(name||'PILLAGER').slice(0,24),gen:Math.max(1,gen|0),num:Math.max(1,num|0),traits:Array.isArray(traits)?traits.slice(0,2):[],lvl:1,lsp:0,picks:[],raids:0,ext:0,kills:0,best:0,born:Date.now()}; }   // v37.xx (cw-p2heirs): num, traits

'@

SubRx @'
  if(!Array.isArray(q.traits)) q.traits=[];

'@ @'
  if(!Array.isArray(q.traits)) q.traits=[];
  q.traits=q.traits.filter(function(id,i,a){ return typeof id==='string'&&!!PIL_TRAIT_BY[id]&&a.indexOf(id)===i; }).slice(0,2);   // v37.xx (cw-p2heirs)
  q.num=Math.max(1,(+q.num|0));

'@

SubRx @'
  if(typeof p.pilGen!=='number'||!isFinite(p.pilGen)||p.pilGen<p.pil.gen) p.pilGen=p.pil.gen;

'@ @'
  if(typeof p.pilGen!=='number'||!isFinite(p.pilGen)||p.pilGen<p.pil.gen) p.pilGen=p.pil.gen;
  if(p.heirs!==undefined){ if(pilHeirsOk(p,pilNext(p))) p.heirs.forEach(function(q){ pilClean(q); }); else delete p.heirs; }   // v37.xx (cw-p2heirs)

'@

SubRx @'
function pilBirth(p,name){
  var g;
  if(!p||typeof p!=='object') return null;
  if(!Array.isArray(p.hall)) p.hall=[];
  g=Math.max(p.pilGen|0,p.hall.length)+1;
  p.pil=pilMake(name||p.pname,g); p.pilGen=g;
  return p.pil;
}

'@ @'
// v37.xx (cw-p2heirs): the traits of a record (ids this build knows), their sum as stat to fraction (null with none), and whether a trait helps.
function pilTraitList(r){ var L=[], i, t; if(!r||!Array.isArray(r.traits)) return L; for(i=0;i<r.traits.length;i++){ t=PIL_TRAIT_BY[r.traits[i]]; if(t) L.push(t); } return L; }
function pilTraitMods(r){ var L=pilTraitList(r), m=null, i, j, s; for(i=0;i<L.length;i++) for(j=0;j<L[i].m.length;j++){ s=L[i].m[j]; if(!m) m={}; m[s.s]=(m[s.s]||0)+s.v; } return m; }
function pilTraitGood(t){ var v=0, j; for(j=0;t&&j<t.m.length;j++) v+=t.m[j].v; return v>0; }
// THE SHOWN NAME, always lower case: the name and, from the second of that name in the lineage on, its numeral ("brakka", then "brakka ii").
function pilRoman(n){ var v=[1000,900,500,400,100,90,50,40,10,9,5,4,1], c=['m','cm','d','cd','c','xc','l','xl','x','ix','v','iv','i'], s='', i; n=Math.max(0,Math.min(3999,n|0)); for(i=0;i<v.length;i++) while(n>=v[i]){ s+=c[i]; n-=v[i]; } return s; }
function pilName(r){ var n; if(!r) return ''; n=String(r.name||'').toLowerCase(); return (r.num|0)>=2?n+' '+pilRoman(r.num):n; }
function pilOrd(n){ var s=['th','st','nd','rd'], v; n=n|0; v=n%100; return n+(s[(v-20)%10]||s[v]||s[0]); }
// How many pillagers of that name the lineage has had, in the hall and living, plus one.
function pilNum(p,name){ var n=1, i, k=String(name||'').toLowerCase(), H=(p&&Array.isArray(p.hall))?p.hall:[]; for(i=0;i<H.length;i++) if(H[i]&&String(H[i].name||'').toLowerCase()===k) n++; if(p&&p.pil&&String(p.pil.name||'').toLowerCase()===k) n++; return n; }
function pilNext(p){ return Math.max(p.pilGen|0,Array.isArray(p.hall)?p.hall.length:0)+1; }
// The heirs' dice: the account name, its first pillager's birth time and the generation, on wornRand, never RNGS or FXS, so seed 4242 never moves
// and a reload rolls the same three.
function pilSeed(p,g){ var b=(Array.isArray(p.hall)&&p.hall[0]&&p.hall[0].born)||(p.pil&&p.pil.born)||0, s=String(p.acctName||'')+'|'+b+'|'+g, h=2166136261, i; for(i=0;i<s.length;i++){ h^=s.charCodeAt(i); h=Math.imul(h,16777619); } return h>>>0; }
function pilHeirsOk(p,g){ var L=p.heirs, i; if(!Array.isArray(L)||L.length!==3) return false; for(i=0;i<3;i++) if(!L[i]||typeof L[i]!=='object'||L[i].gen!==g) return false; return true; }
// THREE HEIRS for the next pillager, kept in P.heirs until one is chosen: three different names, one or two traits each.
function pilHeirs(p){
  var g, R, names, out=[], i, j, k, n, nm, tr, used, pool, tot, x, t, ok;
  if(!p||typeof p!=='object') return [];
  if(!Array.isArray(p.hall)) p.hall=[];
  g=pilNext(p);
  if(pilHeirsOk(p,g)) return p.heirs;
  R=wornRand(pilSeed(p,g)); names=PIL_NAMES.slice();
  for(i=0;i<3;i++){
    nm=names.splice(Math.floor(R()*names.length),1)[0];
    n=R()<0.55?1:2; tr=[]; used={};
    for(j=0;j<n;j++){
      pool=[]; tot=0;
      for(k=0;k<PIL_TRAITS.length;k++){ t=PIL_TRAITS[k]; ok=1; for(x=0;x<t.m.length;x++) if(used[t.m[x].s]) ok=0; if(ok){ pool.push(t); tot+=pilTraitGood(t)?3:1; } }
      if(!pool.length) break;
      x=R()*tot; for(k=0;k<pool.length-1;k++){ t=pilTraitGood(pool[k])?3:1; if(x<t) break; x-=t; }
      t=pool[k]; tr.push(t.id); for(x=0;x<t.m.length;x++) used[t.m[x].s]=1;
    }
    t=pilMake(nm,g,tr,pilNum(p,nm)); t.born=0; out.push(t);
  }
  p.heirs=out;
  return out;
}
// Heir i becomes the living pillager (the next generation) and the roll is cleared. With no heir the first is taken, so a birth with no
// screen still works; a name given instead of an heir renames the first.
function pilBirth(p,a){
  var g, L, r;
  if(!p||typeof p!=='object') return null;
  if(!Array.isArray(p.hall)) p.hall=[];
  g=pilNext(p); L=pilHeirs(p);
  r=JSON.parse(JSON.stringify(L[(typeof a==='number'&&a>=0&&a<L.length)?Math.floor(a):0]));
  if(typeof a==='string'&&a){ r.name=a.slice(0,24); r.num=pilNum(p,r.name); }
  r.gen=g; r.born=Date.now();
  p.pil=pilClean(r); p.pilGen=g; delete p.heirs;
  return p.pil;
}

'@

SubRx @'
function wornMods(worn){
  var m={}, ring={}, i, j, s, pc, v;
  for(s in WORN_STATS) if(Object.prototype.hasOwnProperty.call(WORN_STATS,s)) m[s]=0;
  if(!worn||typeof worn!=='object') return m;
  for(i=0;i<WORN_SLOTS.length;i++){ pc=worn[WORN_SLOTS[i]]; if(!pc||!Array.isArray(pc.tr)) continue;
    for(j=0;j<pc.tr.length;j++){ s=pc.tr[j].s; if(!WORN_STATS[s]) continue; v=wornTraitV(pc,pc.tr[j]);
      if(pc.k==='ring'){ ring[s]=Math.max(ring[s]||0,v); continue; }
      m[s]+=v; } }
  for(s in ring) m[s]+=ring[s];
  for(s in m) m[s]=Math.round(Math.min(WORN_STATS[s].cap,m[s])*10000)/10000;
  return m;
}

'@ @'
function wornMods(worn,add){
  var m={}, ring={}, i, j, s, pc, v;
  for(s in WORN_STATS) if(Object.prototype.hasOwnProperty.call(WORN_STATS,s)) m[s]=0;
  if(worn&&typeof worn==='object') for(i=0;i<WORN_SLOTS.length;i++){ pc=worn[WORN_SLOTS[i]]; if(!pc||!Array.isArray(pc.tr)) continue;
    for(j=0;j<pc.tr.length;j++){ s=pc.tr[j].s; if(!WORN_STATS[s]) continue; v=wornTraitV(pc,pc.tr[j]);
      if(pc.k==='ring'){ ring[s]=Math.max(ring[s]||0,v); continue; }
      m[s]+=v; } }
  for(s in ring) m[s]+=ring[s];
  // v37.xx (cw-p2heirs): the pillager's traits (add, stat to signed fraction) join the sum; a stat never goes below minus its base, so every
  // (1-x) and (1+x) a site multiplies by stays sane
  if(add&&typeof add==='object') for(s in add) if(Object.prototype.hasOwnProperty.call(m,s)) m[s]+=(+add[s]||0);
  for(s in m) m[s]=Math.round(Math.max(-WORN_STATS[s].base,Math.min(WORN_STATS[s].cap,m[s]))*10000)/10000;
  return m;
}

'@

SubRx @'
function raidWornMods(){
  var m, s, any=0;
  if(typeof ARCADE==='object'&&ARCADE&&ARCADE.on) return null;
  if(!P||!P.worn||typeof P.worn!=='object'||typeof wornMods!=='function') return null;
  m=wornMods(P.worn); for(s in m) if(m[s]) any=1;
  return any?m:null;
}

'@ @'
function raidWornMods(){
  var m, s, any=0;
  if(typeof ARCADE==='object'&&ARCADE&&ARCADE.on) return null;
  if(!P||typeof wornMods!=='function') return null;
  m=wornMods((P.worn&&typeof P.worn==='object')?P.worn:null,pilTraitMods(P.pil));   // v37.xx (cw-p2heirs): and the living pillager's traits
  for(s in m) if(m[s]) any=1;
  return any?m:null;
}

'@

SubRx @'
  g.innerHTML=h;
  try{ achStatsDraw(g); }
'@ @'
  // v37.xx (cw-p2heirs), his 11-01 rulings: the living pillager on the account card, "your 14th pillager", "brakka iv", its traits good in green, bad in
  // red. Last in the list so the cards the stylesheet places by position keep their places; order -3 shows it first.
  (function(){
    var r=pilNow(), T=pilTraitList(r), i, sub=[], v;
    if(!r) return;
    for(i=0;i<T.length&&i<2;i++) sub.push('<span style="color:var('+(pilTraitGood(T[i])?'--ok':'--danger')+')">'+T[i].n+'</span>');
    v=escHtml(pilName(r));
    h+='<div class="scard" id="pilcard" style="order:-3"><div class="sk">your '+pilOrd(r.gen)+' pillager</div><div class="sv'+(v.replace(/[^A-Za-z]/g,'').length>7?' word':'')+'">'+v+'</div>'+
       (sub.length?'<div class="ss">'+sub.join('<br>')+'</div>':'')+'</div>';
  })();
  g.innerHTML=h;
  try{ achStatsDraw(g); }
'@

SubRx @'
var VER='37.29';
'@ @'
var VER='37.30';
'@

$pat = "(?m)^  now:'v37\.29:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v37.30: Your stats has a card for the living pillager: your Nth pillager, its name, and its traits in green and red. The next pillager after a death comes with one or two small traits and a rough name. Watch for: nothing changes in play until a pillager dies, generation one has no traits. Check 37.30 fails on v37.29',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
