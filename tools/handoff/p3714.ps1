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

# SEASON ZERO FOUNDATION: THE ACCOUNT AND THE PILLAGER (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  mig739:1,mig945:1,beltV:5,hotbarV:10,
'@ @'
  mig739:1,mig945:1,beltV:5,hotbarV:10,mig0p:1,lifeEarn:0,   // v37.xx (cw-p0acct): season zero records born set (seasonZeroMig)
'@

SubRx @'
var RIG_PAYOUT={rig_light:360,rig_medium:1280,rig_heavy:3120};
'@ @'
// v37.xx (cw-p0acct), HIS PLAN OF 11-01, season zero, m0 (foundation). His go: "once you push the plan, get started on the real thing".
// THE ACCOUNT AND THE PILLAGER ARE TWO RECORDS. His rulings of 11-01: a pillager keeps its level "until they die. and then they get a new
// pillager but it stays on the same account"; "upon death player keeps cash in stash, lifetime earns, account"; "character and account
// names should be separate"; lifetime earnings counts "every dollar earned". This build lays the records down and nothing in play reads them yet:
//   P.acctName  the account name (menus and the two-player lobby come in m2), first taken from the name the save already has
//   P.pil       the living pillager: name, gen, traits, lvl, lsp (its survival level SP), picks, raids, ext, kills, best, born
//   P.hall      every pillager that has ended, kept forever (his answer 10), oldest first
//   P.pilGen    how many pillagers the account has had
//   P.lifeEarn  lifetime earnings: every $ earned; spending never lowers it (m1 adds sales and the extraction bonus through lifeEarnAdd)
// AN OLD SAVE LOSES NOTHING (his "old saves paid out: ok sure"). Once per save (P.mig0p, born set on a new profile): every XP ladder reward it
// earned and never claimed is paid as $ (cash as cash, a kit at its items' base value, a gun at its stash value) and marked claimed; lifetime
// earnings start at the larger of what its run log shows extracted and its net lifetime earnings, plus every $ the ladder ever paid it, so its
// first rank (m1) comes from what it really earned; and the character it plays becomes generation one, keeping its raids, extracts, kills and
// best haul. The hub says it once: "$N paid for unclaimed rewards". The storage key is unchanged.
function pilMake(name,gen){ return {name:String(name||'PILLAGER').slice(0,24),gen:Math.max(1,gen|0),traits:[],lvl:1,lsp:0,picks:[],raids:0,ext:0,kills:0,best:0,born:Date.now()}; }
function pilClean(q){
  var k, n=['lvl','lsp','raids','ext','kills','best','born'];
  if(typeof q.name!=='string'||!q.name) q.name='PILLAGER';
  q.gen=Math.max(1,(+q.gen|0));
  if(!Array.isArray(q.traits)) q.traits=[];
  if(!Array.isArray(q.picks)) q.picks=[];
  for(k=0;k<n.length;k++) if(typeof q[n[k]]!=='number'||!isFinite(q[n[k]])||q[n[k]]<0) q[n[k]]=0;
  q.lvl=Math.max(1,Math.min(20,Math.round(q.lvl)));
  return q;
}
function acctEnsure(p){
  var g;
  if(!p||typeof p!=='object') return null;
  if(typeof p.acctName!=='string'||!p.acctName) p.acctName=(typeof p.pname==='string'&&p.pname)?p.pname:'PILLAGER';
  if(!Array.isArray(p.hall)) p.hall=[];
  if(typeof p.lifeEarn!=='number'||!isFinite(p.lifeEarn)||p.lifeEarn<0) p.lifeEarn=0;
  if(!p.pil||typeof p.pil!=='object'||Array.isArray(p.pil)){ g=Math.max(p.pilGen|0,p.hall.length)+1; p.pil=pilMake(p.pname,g); }
  pilClean(p.pil);
  if(typeof p.pilGen!=='number'||!isFinite(p.pilGen)||p.pilGen<p.pil.gen) p.pilGen=p.pil.gen;
  return p.pil;
}
// What one ladder reward is worth in $. Cash is cash; a kit is its items at base value (the difficulty's loot dial never moves it); a gun is
// what its stash item is worth, or the duplicate price claimTier pays for a gun with no stash item.
function ladderRewardCash(T){
  var s=0, i, it, w;
  if(!T||typeof T!=='object') return 0;
  if(T.kind==='credits'||T.kind==='last') return Math.max(0,Math.round(+T.v||0));
  if(T.kind==='kit'&&Array.isArray(T.v)){ for(i=0;i<T.v.length;i++){ it=ITEMS[T.v[i]]; if(it&&it.val>0) s+=it.val; } return s; }
  if(T.kind==='wep'){ it=ITEMS['gun_'+T.v]; if(it&&it.val>0) return it.val; w=WEAPONS[T.v]; return Math.max(300,Math.round(((w&&w.dmg)||20)*22)); }
  return 0;
}
// Every reward the save earned and never claimed, paid as $ and marked claimed. Safe to run again: a claimed reward is never paid twice.
function ladderPayout(p){
  var cl, i, T, c=0, n=0, xp;
  if(!p||typeof p!=='object'||typeof SEASON_TIERS==='undefined') return {n:0,c:0};
  if(!Array.isArray(p.spClaimed)) p.spClaimed=[];
  cl=p.spClaimed; xp=+p.xp||0;
  for(i=0;i<SEASON_TIERS.length;i++){ T=SEASON_TIERS[i]; if(xp>=T.sp&&cl.indexOf(i)<0){ c+=ladderRewardCash(T); cl.push(i); n++; } }
  if(c) p.credits=(+p.credits||0)+c;
  return {n:n,c:c};
}
// The $ the ladder already paid as cash rewards, which were earned like any other dollar.
function ladderCashClaimed(p){
  var s=0, i, T, cl=(p&&Array.isArray(p.spClaimed))?p.spClaimed:[];
  if(typeof SEASON_TIERS==='undefined') return 0;
  for(i=0;i<cl.length;i++){ T=SEASON_TIERS[cl[i]]; if(T&&(T.kind==='credits'||T.kind==='last')) s+=Math.max(0,+T.v||0); }
  return s;
}
// What the run log shows extracted (the haul and the stall money carried out), or the net lifetime earnings when that is larger.
function lifeEarnSeed(p){
  var g=0, L=(p&&Array.isArray(p.log))?p.log:[], i, r;
  for(i=0;i<L.length;i++){ r=L[i]||{}; if(r.outcome==='extract') g+=Math.max(0,(+r.haul||0)+(+r.pedSold||0)); }
  return Math.max(0,g,+((p&&p.netEarn)||0)||0);
}
function seasonZeroMig(p){
  var before, pay, k, q;
  if(!p||typeof p!=='object'||p.mig0p===1) return null;
  before=ladderCashClaimed(p); pay=ladderPayout(p);
  if(!p.pil||typeof p.pil!=='object'||Array.isArray(p.pil)){
    q=pilMake(p.pname,1);
    q.raids=Math.max(0,p.runs|0); q.ext=Math.max(0,p.ext|0); q.best=Math.max(0,+p.best||0); q.born=0;
    k=(p.achN&&typeof p.achN==='object')?((+p.achN.raider||0)+(+p.achN.mach||0)):0;
    q.kills=Math.max(0,Math.round(k)||0);
    p.pil=q;
  }
  p.pilGen=Math.max(p.pilGen|0,1);
  p.lifeEarn=Math.round(Math.max(+p.lifeEarn||0,lifeEarnSeed(p)+before+pay.c));
  if(pay.c>0) p.szNote={c:pay.c,n:pay.n,shown:0};
  p.mig0p=1;
  acctEnsure(p);
  return pay;
}
// Lifetime earnings only ever go up. The one writer m1 calls for every $ earned.
function lifeEarnAdd(n){ n=Math.round(+n||0); if(n<=0||!P) return 0; acctEnsure(P); P.lifeEarn+=n; return n; }
function pilNow(){ return acctEnsure(P); }
// A pillager ends (m2 calls this from a death or a retire): its record goes to the hall with how it ended, and the account has no living one
// until pilBirth. Stash cash, lifetime earnings and the account are not touched.
function pilEnd(p,how){
  var r, k;
  if(!acctEnsure(p)) return null;
  r=JSON.parse(JSON.stringify(p.pil)); r.end={at:Date.now()};
  if(how&&typeof how==='object') for(k in how) if(Object.prototype.hasOwnProperty.call(how,k)) r.end[k]=how[k];
  p.hall.push(r); p.pil=null;
  return r;
}
function pilBirth(p,name){
  var g;
  if(!p||typeof p!=='object') return null;
  if(!Array.isArray(p.hall)) p.hall=[];
  g=Math.max(p.pilGen|0,p.hall.length)+1;
  p.pil=pilMake(name||p.pname,g); p.pilGen=g;
  return p.pil;
}
// The one-time hub line for an old save's payout. Never in the demo, which plays on a copy.
function szNoteShow(){
  var n=P&&P.szNote;
  if(!n||n.shown||!(n.c>0)) return false;
  if(typeof ARCADE==='object'&&ARCADE&&ARCADE.on) return false;
  n.shown=1;
  hubToast('$'+Math.round(n.c).toLocaleString()+' paid for unclaimed rewards',8);
  try{ saveProfile(); }catch(_sz){}
  return true;
}
var RIG_PAYOUT={rig_light:360,rig_medium:1280,rig_heavy:3120};
'@

SubRx @'
          try{ gunsGoneSweep(P); }catch(_ggs){}
'@ @'
          try{ gunsGoneSweep(P); }catch(_ggs){}
          try{ seasonZeroMig(P); }catch(_szm){}   // v37.xx (cw-p0acct): unclaimed ladder rewards paid as $, lifetime earnings seeded, the character is generation one (once, P.mig0p)
'@

SubRx @'
  hotbarProfileTen(P); // v28.xx (cw-cx-hotbar9)
'@ @'
  try{ acctEnsure(P); }catch(_ae){}   // v37.xx (cw-p0acct): a first launch has its generation one pillager too
  hotbarProfileTen(P); // v28.xx (cw-cx-hotbar9)
'@

SubRx @'
    // and a new player never reads the only card that teaches the game.
    firstRunNext();
'@ @'
    // and a new player never reads the only card that teaches the game.
    firstRunNext();
    try{ szNoteShow(); }catch(_szs){}   // v37.xx (cw-p0acct): "$N paid for unclaimed rewards", once
'@

SubRx @'
         ne:P.netEarn||0,
'@ @'
         ne:P.netEarn||0,
         le:P.lifeEarn||0,   // v37.xx (cw-p0acct): lifetime earnings travel with the character
'@

SubRx @'
  P.netEarn=(typeof o.ne==='number')?o.ne:0;
'@ @'
  P.netEarn=(typeof o.ne==='number')?o.ne:0;
  P.lifeEarn=(typeof o.le==='number'&&o.le>=0)?Math.round(o.le):Math.max(0,P.netEarn);   // v37.xx (cw-p0acct): an older code starts from its net figure
'@

SubRx @'
var VER='37.13';
'@ @'
var VER='37.14';
'@

$pat = "(?m)^  now:'v37\.13:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v37.14: the save holds an account name, the living pillager (generation one is the character he plays), a hall of the fallen and lifetime earnings; an old save is paid once in cash for every ladder reward it earned and never claimed, and the hub says it once; nothing else changes in play Check 37.14 fails on v37.13',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
