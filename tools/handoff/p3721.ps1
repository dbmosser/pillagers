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

# SEASON ZERO M1: LIFETIME EARNINGS AND THE 30 RANKS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var P={credits:900,stash:[],
'@ @'
// v37.xx (cw-m1ranks), his answer 40 of 11-01: "a brand-new account starts with $1,000" (was 900); born at scrounger i, its ranks stamp set (rankMig)
var P={credits:1000,rankPaid:[0],mig1r:1,stash:[],
'@

SubRx @'
function lifeEarnAdd(n){ n=Math.round(+n||0); if(n<=0||!P) return 0; acctEnsure(P); P.lifeEarn+=n; return n; }
'@ @'
function lifeEarnAdd(n){ n=Math.round(+n||0); if(n<=0||!P) return 0; acctEnsure(P); P.lifeEarn+=n; try{ rankCheck(); }catch(_rk){} return n; }   // v37.xx (cw-m1ranks): a rank reached pays, once
'@

SubRx @'
  P.credits+=got*p;
  return got*p;
'@ @'
  P.credits+=got*p;
  try{ rankCheck(); }catch(_rk){}   // v37.xx (cw-m1ranks): a sale that reaches a rank pays it, once
  return got*p;
'@

SubRx @'
function netWorth(){ return ((P&&P.credits)||0)+stashWorth(); }
'@ @'
function netWorth(){ return ((P&&P.credits)||0)+stashWorth(); }
// v37.xx (cw-m1ranks), HIS RULINGS OF 11-01 (season zero m1): "ok call that 'lifetime earnings'"; answers 47 to 53: every dollar earned counts; 30 named
// ranks, scrounger, cutpurse, sacker, reaver, marauder, warlord, five steps each (i to v, warlord v the top); a reward at every rank; shown at the Mainframe
// and on the account card, never over the head in a raid (there it is the pillager name and level only); ranks never open or gate anything.
// THE TABLE (n name, need lifetime earnings, rw reward). The first rank up at $20,000 is about two good early raids; each step is about 6 percent more than
// the one before, so warlord v at $1,500,000 is about 120 raids, six weeks at about 20 raids a week. From his flight recorder of 11-01: his extracted hauls
// average about $41,000 and about 1 run in 3 gets out, so about $12,500 a raid; early hauls on a starter kit run $5,000 to $15,000.
// rw.k is the kind: cash (v $), kit (v item ids, l its name), start (the $1,000 a new account starts with, paid by the profile literal). m3, m6 and m7 add
// kinds (gear crates, dyes, relics, body options); a kind this build does not know is marked paid and pays nothing. A rank reward is a prize, not
// earnings: it never counts in lifetime earnings, or the ladder would feed itself.
var RANKS=[
  {n:'scrounger i',   need:0,       rw:{k:'start',v:1000}},
  {n:'scrounger ii',  need:20000,   rw:{k:'kit',l:'bandages and ammo',v:['bandage','bandage','bandage','bandage','bandage','ammobox']}},
  {n:'scrounger iii', need:41000,   rw:{k:'cash',v:2500}},
  {n:'scrounger iv',  need:64000,   rw:{k:'kit',l:'frags and ammo',v:['frag','frag','ammobox','ammobox']}},
  {n:'scrounger v',   need:88000,   rw:{k:'cash',v:3000}},
  {n:'cutpurse i',    need:113000,  rw:{k:'kit',l:'medkits and bandages',v:['medkit','medkit','bandage','bandage','bandage']}},
  {n:'cutpurse ii',   need:140000,  rw:{k:'cash',v:3500}},
  {n:'cutpurse iii',  need:168000,  rw:{k:'kit',l:'armor plates',v:['plate','plate','bandage','bandage']}},
  {n:'cutpurse iv',   need:199000,  rw:{k:'cash',v:4000}},
  {n:'cutpurse v',    need:231000,  rw:{k:'kit',l:'stims and a medkit',v:['stim','stim','medkit']}},
  {n:'sacker i',      need:265000,  rw:{k:'cash',v:4500}},
  {n:'sacker ii',     need:301000,  rw:{k:'kit',l:'crate of frags',v:['frag','frag','frag','frag','smoke','smoke']}},
  {n:'sacker iii',    need:339000,  rw:{k:'cash',v:5000}},
  {n:'sacker iv',     need:380000,  rw:{k:'kit',l:'data core',v:['core','cell','cell']}},
  {n:'sacker v',      need:423000,  rw:{k:'cash',v:6000}},
  {n:'reaver i',      need:469000,  rw:{k:'kit',l:'ammo restock',v:['ammobox','ammobox','ammobox','ammobox','plate','plate']}},
  {n:'reaver ii',     need:518000,  rw:{k:'cash',v:6500}},
  {n:'reaver iii',    need:569000,  rw:{k:'kit',l:'smokes and decoys',v:['smoke','smoke','smoke','decoy','decoy','decoy']}},
  {n:'reaver iv',     need:624000,  rw:{k:'cash',v:7000}},
  {n:'reaver v',      need:682000,  rw:{k:'kit',l:'four plates',v:['plate','plate','plate','plate','medkit','medkit']}},
  {n:'marauder i',    need:744000,  rw:{k:'cash',v:8000}},
  {n:'marauder ii',   need:809000,  rw:{k:'kit',l:'medkits and a stim',v:['medkit','medkit','medkit','stim']}},
  {n:'marauder iii',  need:878000,  rw:{k:'cash',v:9000}},
  {n:'marauder iv',   need:952000,  rw:{k:'kit',l:'two data cores',v:['core','core','cell','cell']}},
  {n:'marauder v',    need:1030000, rw:{k:'cash',v:10000}},
  {n:'warlord i',     need:1113000, rw:{k:'kit',l:'war chest',v:['plate','plate','plate','plate','stim','stim','medkit','medkit']}},
  {n:'warlord ii',    need:1201000, rw:{k:'cash',v:12000}},
  {n:'warlord iii',   need:1294000, rw:{k:'kit',l:'arsenal',v:['frag','frag','frag','frag','ammobox','ammobox','ammobox','ammobox','medkit','medkit']}},
  {n:'warlord iv',    need:1393000, rw:{k:'cash',v:15000}},
  {n:'warlord v',     need:1500000, rw:{k:'cash',v:25000}}
];
function rankIxOf(le){ var i; le=+le||0; for(i=RANKS.length-1;i>0;i--) if(le>=RANKS[i].need) return i; return 0; }
// Lifetime earnings of any profile with today's sales in (lifeEarnNow for one that is not P yet, while it loads).
function rankLe(p){ var s=p&&p.sellDay, e=(s&&isFinite(+s.e)&&+s.e>0)?Math.round(+s.e):0; return Math.round((p&&+p.lifeEarn)||0)+e; }
function rankPaidList(p){
  var L=[], i, q;
  if(Array.isArray(p.rankPaid)) for(i=0;i<p.rankPaid.length;i++){ q=p.rankPaid[i]|0; if(q>=0&&q<RANKS.length&&L.indexOf(q)<0) L.push(q); }
  if(L.indexOf(0)<0) L.unshift(0);
  p.rankPaid=L; return L;
}
// The rank: the highest lifetime earnings reach, or the highest already paid, so a buy back (which undoes a sale) never takes a rank away. Spending never
// touches lifetime earnings, so it never lowers the rank either.
function rankNow(){
  var r, L, i, q;
  if(!P) return 0;
  r=rankIxOf(lifeEarnNow()); L=Array.isArray(P.rankPaid)?P.rankPaid:[];
  for(i=0;i<L.length;i++){ q=L[i]|0; if(q>r&&q<RANKS.length) r=q; }
  return r;
}
function rankRwTxt(w){ if(!w) return ''; if(w.k==='cash'||w.k==='start') return '$'+Math.round(+w.v||0).toLocaleString(); return String(w.l||w.k||''); }
function rankPay(w){
  var i;
  if(!w||!P) return;
  if(w.k==='cash') P.credits=(+P.credits||0)+Math.max(0,Math.round(+w.v||0));
  else if(w.k==='kit'&&Array.isArray(w.v)){ if(!Array.isArray(P.stash)) P.stash=[]; for(i=0;i<w.v.length;i++) if(ITEMS[w.v[i]]) P.stash.push(w.v[i]); }
}
// Pays every rank reached and not yet paid, once each (P.rankPaid), and says the highest on the floor. Never in the demo (it plays on a copy), and never
// before rankMig has stamped the save, so an old save on its first load is never paid for ranks the ladder already paid.
function rankCheck(){
  var L, r, i, top=-1, got=[];
  if(!P||P.mig1r!==1) return 0;
  if(typeof ARCADE==='object'&&ARCADE&&ARCADE.on) return 0;
  L=rankPaidList(P); r=rankIxOf(lifeEarnNow());
  for(i=1;i<=r;i++) if(L.indexOf(i)<0){ L.push(i); rankPay(RANKS[i].rw); top=i; got.push(RANKS[i].rw); }
  if(top<0) return 0;
  P.rankNote={t:'rank up: '+RANKS[top].n+(got.length===1?('  '+rankRwTxt(got[0])):''),shown:0};
  try{ rankNoteShow(); }catch(_rn){}
  try{ renderRank(); }catch(_rr){}
  return got.length;
}
// The one short line on the floor. A rank reached away from the floor waits for the next arrival there.
function rankNoteShow(){
  var n=P&&P.rankNote;
  if(!n||n.shown||typeof n.t!=='string'||!n.t) return false;
  if(state!=='hub') return false;
  if(typeof ARCADE==='object'&&ARCADE&&ARCADE.on) return false;
  n.shown=1;
  hubToast(n.t,6);
  return true;
}
// THE OLD SAVE RULE (once per save, P.mig1r, born set on a new profile): every rank its lifetime earnings already reach is marked paid WITHOUT paying (the
// ladder payout paid it), so the starting rank comes from lifetime earnings and nothing pays twice. A restore code goes through it too.
function rankMig(p){
  var r, i, L=[];
  if(!p||typeof p!=='object'||p.mig1r===1) return null;
  r=rankIxOf(rankLe(p));
  for(i=0;i<=r;i++) L.push(i);
  p.rankPaid=L; p.mig1r=1;
  return r;
}
// THE MAINFRAME STRIP: rank, lifetime earnings, the next rank with its need and reward, and the bar to it.
function renderRank(){
  var el=document.getElementById('rankstrip'), i, R, N, le, f, lab;
  if(!el||!P) return '';
  i=rankNow(); R=RANKS[i]; N=RANKS[i+1]||null; le=lifeEarnNow();
  f=N?Math.max(0,Math.min(1,(le-R.need)/(N.need-R.need))):1;
  lab='font-size:13px;letter-spacing:.14em;color:var(--ash);line-height:18px';
  el.innerHTML=
    '<div style="flex:none;min-width:190px"><div style="'+lab+'">rank</div><div id="rankname" style="font-size:26px;line-height:32px;font-weight:700;letter-spacing:.04em;color:var(--amber)">'+R.n+'</div></div>'+
    '<div style="flex:none;min-width:190px"><div style="'+lab+'">lifetime earnings</div><div id="rankearn" style="font-size:26px;line-height:32px;font-weight:700;color:var(--bone)">$'+le.toLocaleString()+'</div></div>'+
    '<div style="flex:1;min-width:0">'+
      '<div style="display:flex;justify-content:space-between;gap:12px;'+lab+'"><span id="ranknext">'+(N?('next  '+N.n+'  $'+N.need.toLocaleString()):'top rank')+'</span>'+
      (N?('<span>reward  <b id="rankrw" style="color:var(--amber);font-weight:600">'+rankRwTxt(N.rw)+'</b></span>'):'')+'</div>'+
      '<div style="height:10px;margin-top:8px;border:1px solid var(--steel-hi);border-radius:2px;background:rgba(0,0,0,.35)"><div id="rankfill" style="height:100%;width:'+(f*100).toFixed(1)+'%;background:var(--amber)"></div></div>'+
    '</div>';
  return R.n;
}
'@

SubRx @'
          try{ xpOffMig(P); }catch(_xom){}
'@ @'
          try{ xpOffMig(P); }catch(_xom){} try{ rankMig(P); }catch(_rkm){}
'@

SubRx @'
  P.lifeEarn=(typeof o.le==='number'&&o.le>=0)?Math.round(o.le):Math.max(0,P.netEarn);   // v37.xx (cw-p0acct): an older code starts from its net figure
'@ @'
  P.lifeEarn=(typeof o.le==='number'&&o.le>=0)?Math.round(o.le):Math.max(0,P.netEarn);   // v37.xx (cw-p0acct): an older code starts from its net figure
  P.mig1r=0; try{ rankMig(P); }catch(_rkr){}   // v37.xx (cw-m1ranks): the restored character starts at the rank its lifetime earnings reach, nothing paid
'@

SubRx @'
    try{ szNoteShow(); }catch(_szs){}   // v37.xx (cw-p0acct): "$N paid for unclaimed rewards", once
'@ @'
    try{ if(!szNoteShow()) rankNoteShow(); }catch(_szs){}   // v37.xx (cw-p0acct): "$N paid for unclaimed rewards", once; v37.xx (cw-m1ranks): else a rank up reached away from the floor
'@

SubRx @'
  <h3>THE MAINFRAME</h3>
  <div class="invtabs" id="optabs" style="padding:0 0 10px 0"></div>
'@ @'
  <h3>THE MAINFRAME</h3>
  <!-- v37.xx (cw-m1ranks): rank, lifetime earnings, the next rank and its reward (renderRank) -->
  <div id="rankstrip" style="display:flex;align-items:center;gap:28px;flex:none;padding:12px 16px;margin:0 0 12px;border:1px solid var(--steel-hi);border-radius:4px;background:rgba(0,0,0,.25)"></div>
  <div class="invtabs" id="optabs" style="padding:0 0 10px 0"></div>
'@

SubRx @'
  try{ renderSeason(); }catch(e){}
  var tb=document.getElementById('optabs');
'@ @'
  try{ renderSeason(); }catch(e){}
  try{ renderRank(); }catch(e){}   // v37.xx (cw-m1ranks)
  var tb=document.getElementById('optabs');
'@

SubRx @'
  // v37.xx (cw-m1xpoff), his 11-01 order: no Experience card (no XP and no player level); m1e puts lifetime earnings and the rank here
'@ @'
  // v37.xx (cw-m1xpoff), his 11-01 order: no Experience card (no XP and no player level)
  // v37.xx (cw-m1ranks), his 11-01 rulings: lifetime earnings and the rank on the account card
  h+=card('lifetime earnings', '$'+lifeEarnNow().toLocaleString(), 'rank '+RANKS[rankNow()].n);
'@

SubRx @'
var VER='37.20';
'@ @'
var VER='37.21';
'@

$pat = "(?m)^  now:'v37\.20:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v37.21: RANKS: scrounger i at 0, scrounger ii at 20,000 (about two good early raids), each step about 6 percent more than the last (20,000 then 21,000, 23,000 ... 99,000, 107,000), warlord v at 1,500,000 (about 120 raids, six weeks at about 20 raids a week). Rewards alternate cash (2,500 rising to 25,000 at warlord v, 121,000 in all) and kits of existing items (bandages, frags, medkits, plates, stims, smokes, decoys, data cores); a reward is not earnings. A rank is paid once when reached (P.rankPaid) with one floor line (rank up: sacker ii and its reward); a buy back or spending never lowers the rank. An old save is stamped once (P.mig1r): every rank its lifetime earnings reach is marked paid without paying. The Mainframe has a strip on every tab (rank, lifetime earnings, next rank, its reward, a bar); the stats page has a lifetime earnings card with the rank. A new profile starts with 1,000 dollars (was 900) Check 37.21 fails on v37.20',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
