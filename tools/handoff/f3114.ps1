$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
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

if ($s.Contains("  {v:'31.14',what:")) { throw "check 31.14 is in the fixture already" }

SubRx @'
  {v:'31.13',what:
'@ @'
  {v:'31.14',what:'cw-meleeone, his order (2026-10-18): one crowbar swing kills a crawler at every enemy health setting; an elite crawler takes 2, a pillager 3 (an elite one 4), a sentry 5; the Overseer and the golden enemy are not scaled; a swing out of reach or out of the arc does nothing, the bot never swings; a kill reads (kill marker, number, harder kick), a blow that leaves him standing holds him; player 2 sends the host the same number',
   run:function(){
     if(!window.__deploy||!window.__endRaid||!window.__state||typeof meleeStrike!=='function'||typeof mkCrawler!=='function'||typeof mkRaider!=='function'||typeof mkSentry!=='function'||typeof mkWarden!=='function'||typeof netShotTake!=='function') return 'SKIP: this fixture cannot stage a swing';
     if(typeof NET==='object'&&NET&&NET.on) return 'SKIP: a party is live';
     var bad=[], g=null, p=null, E0=null, ang=0, ux=1, uy=0, i, a, ok=false, c, r, s, w, h0, n, eh, lost, k, q, NK={}, oS=netSend, oSF=netSendFast, mx=mouse.x, my=mouse.y, sent=[], pa={state:'in',seat:1}, res;
     for(k in NET) NK[k]=NET[k];
     function clr(){ for(var z in keys) keys[z]=false; }
     function put(e,d,face){ e.x=p.x+ux*d; e.y=p.y+uy*d; e.face=(face===undefined)?ang+Math.PI:face; e.downed=false; e.finished=0; e.roll=0; e.merc=0; e.friendlyPC=0; g.ents=[e]; return e; }
     function swing(){ p.meleeAt=undefined; p.lastShot=undefined; p.cooking=0; p.downed=false; p.dying=false; p.roll=0; p.face=ang; g.searching=null; g.trade=null; g.paused=false; g.t+=0.5; clr(); return meleeStrike(); }
     function swingsToKill(e,max){ var cnt=0; while(cnt<max&&e.hp>0){ if(!swing()) return -1; cnt++; } return cnt; }
     function crawler(rate){ CFG.eliteRate=rate; return mkCrawler(p.x,p.y); }
     function raider(rate){ var x; CFG.eliteRate=rate; x=mkRaider(p.x,p.y,IDENTITIES[0],false); x.hp=x.maxhp; x.armor=0; x.hostile=true; x.downed=false; return x; }
     function offAxis(rad){
       var sg, e;
       for(sg=-1;sg<=1;sg+=2){
         e=crawler(0); e.x=p.x+Math.cos(ang+sg*rad)*40; e.y=p.y+Math.sin(ang+sg*rad)*40; e.face=ang+sg*rad+Math.PI; e.downed=false; e.finished=0; e.roll=0; e.merc=0; e.friendlyPC=0;
         if(losClear(p.x,p.y,e.x,e.y,g.map.segs)){ g.ents=[e]; return e; }
       }
       return null;
     }
     function p2swing(e){
       var m;
       g.ents=[e]; NET.role='host'; NET.seat=0; NET.peers=[pa]; netEntsInit(g);
       NET.role='join'; NET.seat=1; NET.peers=[{seat:0,state:'in'}]; sent.length=0;
       swing();
       m=sent.filter(function(x){ return x.t==='shot'; })[0]||null;
       NET.role='host'; NET.seat=0; NET.peers=[pa];
       return m;
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g&&g.player; if(!g||g.over||!p) return 'SKIP: no live raid';
       if(g.sim) return 'SKIP: the fixture raid is a sim raid';
       E0=g.ents; p.iv=99; clr();
       for(a=0;a<8;a++){ ang=a*0.785; ux=Math.cos(ang); uy=Math.sin(ang); if(losClear(p.x,p.y,p.x+ux*150,p.y+uy*150,g.map.segs)){ ok=true; break; } }
       if(!ok) return 'SKIP: staging: no clear line beside the player';
       p.face=ang;
       // ONE: a standard crawler at full health dies to ONE real swing at every enemy health setting, and from behind too
       for(i=0;i<4;i++){
         eh=[1,0.5,1.5,2][i]; CFG.eHp=eh;
         c=put(crawler(0),40,(i===3)?ang:undefined); h0=c.hp;
         if(!swing()){ bad.push('ONE: the swing was refused (enemy health x'+eh+')'); break; }
         if(c.hp>0) bad.push('ONE: a standard crawler of '+h0+' health (enemy health x'+eh+') survived one crowbar swing with '+Math.round(c.hp));
       }
       CFG.eHp=1;
       // TWO: an elite crawler takes two
       c=put(crawler(1),40);
       if(!c.elite) return 'SKIP: staging: no elite crawler could be made';
       h0=c.hp; n=swingsToKill(c,8);
       if(n!==2) bad.push('TWO: an elite crawler of '+h0+' health took '+n+' swings, not 2');
       // THREE: a pillager takes three from full health, an elite one four
       r=put(raider(0),40); h0=r.hp; n=swingsToKill(r,10);
       if(n!==3) bad.push('THREE: a pillager of '+h0+' health took '+n+' swings, not 3');
       r=put(raider(1),40);
       if(!r.elite) return 'SKIP: staging: no elite pillager could be made';
       h0=r.hp; n=swingsToKill(r,12);
       if(n!==4) bad.push('THREE: an elite pillager of '+h0+' health took '+n+' swings, not 4');
       // FOUR: a sentry takes five
       CFG.eliteRate=0; s=put(mkSentry(p.x,p.y),40); h0=s.hp; n=swingsToKill(s,12);
       if(n!==5) bad.push('FOUR: a sentry of '+h0+' health took '+n+' swings, not 5');
       // FIVE: the Overseer is not scaled to its health, and the golden enemy lives through one swing
       w=put(mkWarden(p.x,p.y),40); w.boss=1; w.maxhp=w.hp=4000; h0=w.hp; swing(); lost=h0-w.hp;
       if(!(lost>0&&lost<=30)) bad.push('FIVE: the Overseer lost '+lost+' to one swing, not a flat blow of 30 or less');
       c=put(crawler(0),40); c.golden=1; c.maxhp=c.hp=Math.round(c.maxhp*3); swing();
       if(!(c.hp>0)) bad.push('FIVE: the golden crawler died to one swing');
       // SIX: out of reach does nothing, out of the arc does nothing, inside the drawn swing it lands
       c=put(crawler(0),130); h0=c.hp; swing();
       if(c.hp!==h0) bad.push('SIX: a crawler 130 away took '+(h0-c.hp)+' from a swing');
       c=offAxis(1.45);
       if(c){ h0=c.hp; swing(); if(c.hp!==h0) bad.push('SIX: a crawler 83 degrees off the swing took '+(h0-c.hp)+' from it'); }
       c=offAxis(1.1);
       if(c){ h0=c.hp; swing(); if(!(c.hp<=0)) bad.push('SIX: a crawler 63 degrees off the swing, inside the arc the crowbar is drawn over, was not hit'); }
       // SEVEN: the bot never swings
       c=put(crawler(0),40); g.sim=true; res=meleeStrike(); g.sim=false;
       if(res||c.hp<c.maxhp) bad.push('SEVEN: a swing in a sim raid was not refused');
       // EIGHT: a kill reads, a blow that leaves him standing holds him
       g.hitMark=null; g.dmgN=[]; g.shake=0; c=put(crawler(0),40); swing();
       if(!(g.hitMark&&g.hitMark.kill)) bad.push('EIGHT: the killing swing set no kill marker');
       if(!(g.dmgN||[]).some(function(d){ return d.kill; })) bad.push('EIGHT: the killing swing showed no kill number');
       if(!((g.shake||0)>=3)) bad.push('EIGHT: the killing swing kicked the screen only '+(g.shake||0));
       g.hitMark=null; g.dmgN=[]; g.shake=0; c=put(crawler(1),40); c.stopT=0; swing();
       if(!(c.hp>0&&c.stopT>0)) bad.push('EIGHT: a blow that left an elite standing did not hold him (hp '+c.hp+', stop '+c.stopT+')');
       if(g.hitMark&&g.hitMark.kill) bad.push('EIGHT: a blow that did not kill set the kill marker');
       if((g.shake||0)>4) bad.push('EIGHT: a blow that did not kill kicked the screen '+g.shake);
       // NINE: player 2 swing sends the host the very number, and the host takes it
       NET.on=true; NET.upSeed=g.seed>>>0; NET.up=[]; NET.roster=[{seat:0,name:'A'},{seat:1,name:'B'}];
       netSend=function(q2,m){ sent.push(JSON.parse(JSON.stringify(m))); return true; }; netSendFast=netSend;
       c=put(crawler(0),40); h0=c.hp; w=p2swing(c);
       if(!w) bad.push('NINE: player 2 swing sent the host no word');
       else {
         if(!(w.dmg>=h0)) bad.push('NINE: player 2 swing at a standard crawler of '+h0+' health sent '+w.dmg);
         if(w.hs!==1) bad.push('NINE: player 2 swing did not ask the host to hold a body it leaves standing');
         res=netShotTake(pa,w);
         if(res!=='shot'||!(c.hp<=0)) bad.push('NINE: the host did not kill the crawler player 2 swung at ('+res+', health '+c.hp+')');
       }
       c=put(crawler(1),40); h0=c.hp; w=p2swing(c);
       if(w){
         if(!(w.dmg>=h0/2-0.5&&w.dmg<h0)) bad.push('NINE: player 2 swing at an elite crawler of '+h0+' health sent '+w.dmg+', not half of it');
         res=netShotTake(pa,w);
         if(!(c.hp>0)) bad.push('NINE: the host killed an elite crawler with one swing of player 2');
         else if(!(c.stopT>0)) bad.push('NINE: the host did not hold the elite crawler player 2 left standing');
       } else bad.push('NINE: player 2 swing at an elite sent the host no word');
       return bad.length?bad.join('; '):null;
     } finally {
       try{ netSend=oS; netSendFast=oSF; for(k in NET) if(!(k in NK)) delete NET[k]; for(k in NK) NET[k]=NK[k]; }catch(_n){}
       try{ if(g){ g.sim=false; g.barT=0; g.punchT=0; g.shake=0; g.hitMark=null; if(E0) g.ents=E0; } }catch(_g){}
       try{ mouse.x=mx; mouse.y=my; clr(); }catch(_m){}
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.iv=0; __endRaid('abandon'); } }catch(_e){}
       try{ __resetCfg(); }catch(_c){}
       __topClear(); __cleanProfile();
     } }},
  {v:'31.13',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
