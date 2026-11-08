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

if ($s.Contains("  {v:'37.65',what:")) { throw "check 37.65 is in the fixture already" }

SubRx @'
  {v:'37.64',what:
'@ @'
  {v:'37.65',what:'cw-m3coop, his rulings of 11-01 (season zero m3, answer 75, plan worn gear), through the two window net harness (one page plays the host and the partner in turn and carries every word by hand): the raid state word carries his summed gear and what he wears and the host cleans it (only gear stats, numbers held to cap and floor, a bad word or an older word without it is nothing) and passes it on; an enemy on the host sees a partner wearing hard to spot 0.1 from exactly 0.9 as far, and as before with none; the host sends a blow on the partner raw and his own window takes exactly 0.9 of it with tough 0.1; the host runs his search 1.25 times as fast with search 0.2 and his window predicts the same; a piece handed over with T in the backpack lands in the partner bag as the identical piece rebuilt from its key and leaves the giver exactly once, a line on each side, and back the other way; a lost offer or yes leaves it with the giver, a lost hand-over is sent again and taken once; out of reach, a downed partner, a downed giver and a piece not in the bag refuse; the partner row lists his worn kinds in rarity colour; an extract banks it into the holder P.gear only; an old save reloads twice with nothing lost',
   run:function(){
     if(!(window.__runPrep&&window.__deploy&&window.__endRaid&&window.__state&&window.__resetCfg&&window.__pinDefaults&&window.__cleanProfile&&window.__topClear)) return 'SKIP: this fixture cannot stage';
     if(typeof netOnState!=='function'||typeof netGiftTake!=='function'||typeof netUpTick!=='function'||typeof netTeamHud!=='function'||typeof wornItemEnsure!=='function'||typeof updateEnts!=='function'||typeof applyLoadedProfile!=='function') return 'SKIP: no net link or gear here';
     if(typeof wornMof!=='function'||typeof netWmClean!=='function'||typeof wgGive!=='function'||typeof wgGiveTick!=='function') return 'no partner gear over the net link in this build (wornMof, netWmClean, wgGive, wgGiveTick)';
     var saved=P, nk=Object.assign({},NET), cfg={}, k, oOn=WORN_DROPS_ON, oStore=storeSet, oSave=saveProfile, oNs=netSend, oNf=netSendFast, oNb=netBroadcast, oBs=buzzSlow, oCs=canSee, oSay=say, oTag=pickTag, kk=keys,
         ftOwn=Object.prototype.hasOwnProperty.call(ctx,'fillText'), oFt=ctx.fillText, bad=[], g, p, i, q, r, out=[], hits=[], fast=[], lines=[], tags=[], sees=[], drawn=[],
         K='wg_boots_2_42_8811', K2='wg_gloves_1_30_7777', pc0, pc2, W, cur=null, seed, px, py, e0, ct, d0, d1, l0, l1, base, a, st, look, hurt, srch, pred, cv, want=[], z, spy, unspy;
     function need(ok,msg){ if(!ok) bad.push(msg); }
     function same(x,y){ return JSON.stringify(x)===JSON.stringify(y); }
     function cnt(l,x){ var n=0, j; for(j=0;j<(l||[]).length;j++) if(l[j]===x) n++; return n; }
     function word(s,xx){ return {seat:s,n:1,age:0,sd:seed,x:xx,y:py,tx:xx,ty:py,f:0,tf:0,bob:0,mv:0,roll:0,dn:0,hp:100,mh:100,cr:0,sp:0,w:'',lk:null}; }
     // one window at a time: its bag, its hand-off state, who it sees up top, its role and seat
     function win(n){ if(cur){ W[cur].bag=g.bag; W[cur].wo=g.wgOut||null; W[cur].wgt=g.wgGot||null; W[cur].up=NET.up; } cur=n; g.bag=W[n].bag; g.wgOut=W[n].wo; g.wgGot=W[n].wgt; NET.up=W[n].up; NET.role=W[n].role; NET.seat=W[n].seat; }
     // every gift word queued is carried to the window it names; drop(m) loses it on the way, pre(m) runs just before it lands
     function pump(drop,pre){ var n=0, res=[], y; while(out.length&&n<30){ y=out.shift(); n++; if(drop&&drop(y.m)){ res.push('lost:'+y.m.op); continue; } win(y.to===0?'A':'B'); if(pre) pre(y.m); res.push(netGiftTake({state:'in',seat:(y.to===0)?1:0},y.m)); } return res; }
     for(k in CFG) cfg[k]=CFG[k];
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       storeSet=function(){}; saveProfile=function(){};
       P.worn={}; P.gear=[];
       __deploy({kit:['gun_rifle'],safe:null,mapIx:0,seed:4242}); g=__state(); p=g&&g.player;
       if(!g||g.over||!p) return 'could not stage a live raid';
       __topClear(); g.ents=[]; p.iv=99; p.downed=false; p.wm=null; seed=g.seed>>>0; px=p.x; py=p.y; keys={};
       pc0=JSON.stringify(wornItemEnsure(K).pc); pc2=JSON.stringify(wornItemEnsure(K2).pc);
       buzzSlow=function(){ return 1; }; netBroadcast=function(){ return 1; };
       netSend=function(q2,m){ var c=JSON.parse(JSON.stringify(m)); if(c.t==='gift') out.push({to:q2&&q2.seat,m:c}); else if(c.t==='hit') hits.push(c); return true; };
       netSendFast=function(q2,m){ fast.push(JSON.parse(JSON.stringify(m))); return true; };
       say=function(t,kd,o){ lines.push(String(t)+'|'+String((o&&o.tag)||'')); };
       pickTag=function(it,tg){ tags.push(it+'|'+tg); };
       NET.on=true; NET.upSeed=seed; NET.specG=null; NET.upOut={}; NET.upHow={}; NET.pn={}; NET.holds={}; NET.srch=null; NET.srchOwn=-1;
       NET.roster=[{seat:0,name:'hostacct'},{seat:1,name:'mateacct'}]; NET.peers=[{seat:0,state:'in'},{seat:1,state:'in'}];
       W={A:{role:'host',seat:0,bag:['bandage',K,K2],wo:null,wgt:null,up:[null,word(1,px+40)]},B:{role:'join',seat:1,bag:['bandage'],wo:null,wgt:null,up:[word(0,px+40),null]}};
       win('A');
       // ONE: T in the backpack hands the selected piece over; it leaves the giver once and lands as the identical piece
       g.bagOpen=true; g.bagBelt=false; a=bagStacks(); g.bagSel=-1;
       for(i=0;i<a.length;i++) if(g.bag[a[i].idxs[a[i].idxs.length-1]]===K) g.bagSel=i;
       need(g.bagSel>=0,'ONE: the piece is not a stack in the backpack');
       need(wgGiveHint(ITEMS[K],0).indexOf('give to mateacct')>=0,'ONE: the backpack hint does not offer give to mateacct: '+JSON.stringify(wgGiveHint(ITEMS[K],0)));
       need(netGiftKey()===true,'ONE: T in the backpack did nothing');
       g.bagOpen=false;
       need(out.length===1&&out[0].m.op==='offer'&&out[0].m.wg===1&&out[0].m.k===K&&out[0].to===1,'ONE: no gear offer went out: '+JSON.stringify(out).slice(0,300));
       need(cnt(g.bag,K)===1,'ONE: the piece left before the partner said yes');
       r=pump(null,function(m){ if(m.op==='give') delete ITEMS[K]; });
       need(same(r,['wg:yes','wg:gave','wg:took','wg:done']),'ONE: the words ran '+JSON.stringify(r));
       win('A');
       need(cnt(W.A.bag,K)===0&&cnt(W.B.bag,K)===1,'ONE: the giver has '+cnt(W.A.bag,K)+' and the partner '+cnt(W.B.bag,K)+', not 0 and 1');
       need(!!ITEMS[K]&&JSON.stringify(ITEMS[K].pc)===pc0,'ONE: the partner piece is not the identical piece');
       need(!g.wgOut,'ONE: the giver still waits after got');
       need(lines.some(function(s){ return s.indexOf('given to mateacct')>=0; }),'ONE: no given line on the giver: '+JSON.stringify(lines).slice(0,300));
       need(tags.indexOf(K+'|from hostacct')>=0,'ONE: no from line on the partner: '+JSON.stringify(tags));
       // the same hand-over word twice is taken once
       q=W.B.wgt?Object.keys(W.B.wgt)[0]:'x';
       out.push({to:1,m:{t:'gift',op:'give',id:q,k:K,wg:1,to:1,from:0}}); r=pump();
       need(r[0]==='wg:dup'&&cnt(W.B.bag,K)===1,'ONE: a second hand-over word gave it twice ('+JSON.stringify(r)+', partner has '+cnt(W.B.bag,K)+')');
       // TWO: a lost offer, a lost yes: it stays with the giver; a lost hand-over is sent again and taken once
       win('A'); lines=[];
       need(wgGive(K2)==='asked','TWO: no ask');
       r=pump(function(m){ return m.op==='offer'; });
       win('A'); g.t+=WG_GIVE_T+0.5; wgGiveTick();
       need(!g.wgOut&&cnt(W.A.bag,K2)===1&&cnt(W.B.bag,K2)===0,'TWO: a lost offer did not leave it with the giver');
       need(lines.some(function(s){ return s.indexOf('give failed')===0; }),'TWO: no give failed line: '+JSON.stringify(lines));
       need(wgGive(K2)==='asked','TWO: no second ask');
       r=pump(function(m){ return m.op==='yes'; });
       win('A'); g.t+=WG_GIVE_T+0.5; wgGiveTick();
       need(!g.wgOut&&cnt(W.A.bag,K2)===1&&cnt(W.B.bag,K2)===0,'TWO: a lost yes did not leave it with the giver ('+JSON.stringify(r)+')');
       need(wgGive(K2)==='asked','TWO: no third ask');
       r=pump(function(m){ return m.op==='give'; });
       win('A');
       need(cnt(W.A.bag,K2)===0&&cnt(W.B.bag,K2)===0&&!!g.wgOut&&g.wgOut.st==='sent','TWO: after a lost hand-over the giver does not hold it for a resend ('+JSON.stringify(r)+')');
       g.t+=1.1; need(wgGiveTick()===2,'TWO: the hand-over was not sent again');
       r=pump();
       need(cnt(W.A.bag,K2)===0&&cnt(W.B.bag,K2)===1,'TWO: the resent hand-over did not land exactly once (partner has '+cnt(W.B.bag,K2)+', '+JSON.stringify(r)+')');
       win('A'); need(!g.wgOut,'TWO: the giver still waits after the resend');
       // THREE: out of reach, a downed partner, a downed giver, a piece not in the bag (a worn one never is); the partner down when the offer lands says no
       win('B'); out=[];
       W.B.up[0].x=W.B.up[0].tx=px+200; need(wgGive(K2)==='far'&&!out.length&&cnt(g.bag,K2)===1,'THREE: out of reach was not refused');
       need(wgGiveHint(ITEMS[K2],0)==='','THREE: the hint offers a give out of reach');
       W.B.up[0].x=W.B.up[0].tx=px+40; W.B.up[0].dn=1; need(wgGive(K2)==='far'&&!out.length,'THREE: a downed partner was not refused'); W.B.up[0].dn=0;
       p.downed=true; need(wgGive(K2)==='down'&&!out.length,'THREE: a downed giver was not refused'); p.downed=false;
       need(wgGive('wg_head_3_50_1234')==='none'&&!out.length,'THREE: a piece not in the bag was offered');
       need(wgGive(K2)==='asked','THREE: no ask'); p.downed=true; r=pump(); p.downed=false; win('B');
       need(r[0]==='wg:down'&&!g.wgOut&&cnt(W.B.bag,K2)===1&&cnt(W.A.bag,K2)===0,'THREE: a partner down when the offer came took it ('+JSON.stringify(r)+')');
       // FOUR: the partner hands one back to the host the same way
       win('B'); need(wgGive(K)==='asked','FOUR: no ask from the partner'); r=pump();
       need(same(r,['wg:yes','wg:gave','wg:took','wg:done'])&&cnt(W.A.bag,K)===1&&cnt(W.B.bag,K)===0,'FOUR: the partner to host hand-over ran '+JSON.stringify(r));
       // FIVE: his sum and his list go out with his state word, and the host cleans them
       win('B'); P.worn={boots:JSON.parse(pc0)}; p.wm={hide:0.1,tough:0.1,search:0.2}; NET.wmSent=undefined; NET.upAcc=1; NET.upHold=0; fast=[];
       netUpTick(0); q=fast.filter(function(m){ return m.k==='r'; })[0];
       need(!!q&&!!q.wm&&q.wm.hide===0.1&&q.wm.search===0.2&&same(q.wg,['boots.2']),'FIVE: the state word does not carry his gear: '+JSON.stringify(q&&{wm:q.wm,wg:q.wg}));
       p.wm=null; P.worn={}; NET.upAcc=1; fast=[]; netUpTick(0); q=fast.filter(function(m){ return m.k==='r'; })[0];
       need(!!q&&same(q.wm,{})&&same(q.wg,[]),'FIVE: with nothing worn the word is not empty: '+JSON.stringify(q&&{wm:q.wm,wg:q.wg}));
       st=function(x){ var m={t:'st',k:'r',sd:seed,x:px+40,y:py,f:0,m:0,r:0,hp:100,mh:100}, z2; for(z2 in x) m[z2]=x[z2]; return netOnState({state:'in',seat:1},m); };
       win('A'); NET.up.length=0; fast=[];
       r=st({}); need(r==='state'&&!!NET.up[1]&&!NET.up[1].wm&&wornMof(netUpBody(NET.up[1]),'hide')===0,'FIVE: an older word without gear does not read as nothing ('+r+')');
       st({wm:{hide:0.1,tough:0.1,search:0.2},wg:['boots.2','ring.0']});
       need(wornMof(netUpBody(NET.up[1]),'hide')===0.1&&netSeatWm(1,'search')===0.2,'FIVE: the host does not keep his gear: '+JSON.stringify(NET.up[1].wm));
       need(same(NET.up[1].wg,[{k:'boots',r:2},{k:'ring',r:0}]),'FIVE: his list reads '+JSON.stringify(NET.up[1].wg));
       need(fast.some(function(m){ return m.s===1&&m.wm&&m.wm.hide===0.1&&same(m.wg,['boots.2','ring.0']); }),'FIVE: the host did not pass his gear on');
       st({}); need(NET.up[1].wm&&NET.up[1].wm.hide===0.1,'FIVE: a word between sends wiped his gear');
       st({wm:{hide:5,spd:-3,foo:9}}); need(!!NET.up[1].wm&&NET.up[1].wm.hide===WORN_STATS.hide.cap&&NET.up[1].wm.spd===-WORN_STATS.spd.base&&!('foo' in NET.up[1].wm),'FIVE: an oversized word was not held to cap and floor: '+JSON.stringify(NET.up[1].wm));
       st({wm:{hide:'0.1'}}); need(NET.up[1].wm===null,'FIVE: a word with a stat that is not a number was kept');
       st({wm:[0.1]}); need(NET.up[1].wm===null,'FIVE: an array word was kept');
       st({wm:new Array(5001).join('x')}); need(NET.up[1].wm===null,'FIVE: a string word was kept');
       st({wm:{},wg:['boots.9','nope.1','ring.1.2',7,new Array(41).join('x'),'boots.']}); need(NET.up[1].wm===null&&same(NET.up[1].wg,[]),'FIVE: a bad list was kept: '+JSON.stringify(NET.up[1].wg));
       p.wm={hide:0.1}; need(wornMof(p,'hide')===wornM('hide')&&wornM('hide')===0.1,'FIVE: wornMof does not read his own body through wornM'); p.wm=null;
       // SIX: how far an enemy on the host sees the partner
       e0=mkSentry(px+300,py); e0.sleep=0; e0.state='patrol'; e0.alert=0; e0.face=Math.PI;
       canSee=function(ex,ey,ef,tx,ty){ if(Math.abs(tx-(px+180))<0.01&&Math.abs(ty-py)<0.01) sees.push([arguments[6],arguments[8]]); return oCs.apply(this,arguments); };
       look=function(x){ var e=Object.assign({},e0); sees=[]; x.x=px+180; st(x); g.ents=[e]; try{ updateEnts(1/60); } finally { g.ents=[]; } return sees[0]||null; };
       l0=look({wm:{}}); l1=look({wm:{hide:0.1}});
       need(!!l0&&!!l1,'SIX: the enemy never looked at the partner ('+JSON.stringify([l0,l1])+')');
       if(l0&&l1) need(Math.abs(l1[0]/l0[0]-0.9)<1e-9&&Math.abs(l1[1]/l0[1]-0.9)<1e-9,'SIX: with hard to spot 0.1 he is seen from '+(l1[0]/l0[0])+' and '+(l1[1]/l0[1])+' as far, not 0.9');
       NET.up.length=0; q=look({}); need(!!q&&!!l0&&q[0]===l0[0]&&q[1]===l0[1],'SIX: an older word without gear is not seen as with none');
       canSee=oCs;
       // SEVEN: a blow on the partner: the host sends it raw, his own window cuts it by his tough
       st({wm:{tough:0.1}}); hits=[]; netHitPlayer(netUpBody(NET.up[1]),20,'sentry','sentry');
       need(hits.length===1&&hits[0].dmg===20,'SEVEN: the host did not send the raw blow: '+JSON.stringify(hits));
       win('B');
       hurt=function(wm){ var d; p.wm=wm; p.hp=100; p.armor=0; p.iv=0; p.roll=0; p.downed=false; netHitTake({state:'in'},{t:'hit',seat:1,dmg:20,kind:'sentry',name:'sentry'}); d=100-p.hp; p.iv=99; p.hp=100; return d; };
       d0=hurt(null); d1=hurt({tough:0.1}); p.wm=null;
       need(d0>0&&Math.abs(d1/d0-0.9)<1e-9,'SEVEN: with tough 0.1 his window took '+d1+' of '+d0);
       // EIGHT: the host runs his search at his gear's speed, and his own bar predicts the same
       win('A'); netContInit(g); ct=g.containers.filter(function(c){ return !c.opened&&typeof c.cid==='number'; })[0];
       if(!ct) throw new Error('no box with an id');
       srch=function(sv){ st({x:ct.x+30,y:ct.y,wm:sv?{search:sv}:{}}); ct.prog=0; ct.pulled=0; ct.opened=false; ct.loot=['bandage']; ct.time=100; ct.netBy=1; g.searching=null; NET.srchOwn=-1; NET.holds={1:{cid:ct.cid,slow:1}}; netSrchTick(1/60); NET.holds={}; return ct.prog; };
       d0=srch(0); d1=srch(0.2); need(d0>0&&Math.abs(d1/d0-1.25)<1e-9,'EIGHT: the host ran his search at '+(d1/d0)+' with search 0.2, not 1.25');
       win('B');
       pred=function(wm){ p.wm=wm; ct.prog=0; ct.netBy=1; g.searching=ct; NET.srch={cid:ct.cid,ok:1}; netSrchHold(ct,1/60); return ct.prog; };
       d0=pred(null); d1=pred({search:0.2}); p.wm=null; g.searching=null; NET.srch=null; ct.netBy=-1;
       need(d0>0&&Math.abs(d1/d0-1.25)<1e-9,'EIGHT: his window predicts '+(d1/d0)+', not 1.25');
       // NINE: his row lists what he wears, in rarity colour
       win('A'); st({x:px+40,y:py,wm:{hide:0.1},wg:['boots.2','ring.0']});
       cv=document.createElement('canvas').getContext('2d'); for(z=0;z<4;z++){ cv.fillStyle=WORN_RARS[z].c; want.push(String(cv.fillStyle)); }
       spy=function(){ drawn=[]; ctx.fillText=function(t){ drawn.push({t:String(t),c:String(ctx.fillStyle)}); return oFt.apply(ctx,arguments); }; };
       unspy=function(){ if(ftOwn) ctx.fillText=oFt; else delete ctx.fillText; };
       spy(); try{ netTeamHud(0); } finally { unspy(); }
       need(drawn.some(function(d){ return d.t==='boots'&&d.c===want[2]; })&&drawn.some(function(d){ return d.t==='ring'&&d.c===want[0]; }),'NINE: the row does not list boots and ring in their colours: '+JSON.stringify(drawn.slice(0,12)));
       need(drawn.some(function(d){ return d.t==='mateacct'; }),'NINE: control: the row did not draw his name');
       st({wm:{},wg:[]}); spy(); try{ netTeamHud(0); } finally { unspy(); }
       need(!drawn.some(function(d){ return d.t==='boots'; }),'NINE: an empty list still draws');
       // TEN: an extract banks only the bag of the window that holds it
       win('B'); a=W.B.bag.slice();
       need(cnt(a,K2)===1&&cnt(W.A.bag,K2)===0,'TEN: control: the partner does not hold the gloves alone');
       Object.keys(NET).forEach(function(n){ delete NET[n]; }); Object.assign(NET,nk);
       g.bag=a; g.wgOut=null; g.carriedIn=0; g.carriedKit=[]; g.ents=[]; p.iv=99; p.downed=false; g.tel.shots=3; P.gear=[]; P.worn={};
       __endRaid('extract');
       need(P.gear.length===1&&P.gear[0].k==='gloves'&&P.gear[0].pw===JSON.parse(pc2).pw&&same(P.gear[0].tr,JSON.parse(pc2).tr),'TEN: the holder banked '+JSON.stringify(P.gear));
       // ELEVEN: an old save (this job adds no save field) reloads twice with nothing lost or moved
       __topClear();
       base=JSON.parse(JSON.stringify(P)); base.cfg=JSON.parse(JSON.stringify(CFG)); base.cfgv=18;
       applyLoadedProfile({value:JSON.stringify(base)});
       need(same(P.gear,base.gear)&&P.credits===base.credits&&same(P.stash,base.stash),'ELEVEN: a reload lost gear, cash or stash');
       a=JSON.stringify({c:P.credits,s:P.stash,w:P.weapons,e:P.equipped,g:P.gear,wo:P.worn,pil:P.pil&&P.pil.name,h:(P.hall||[]).length});
       applyLoadedProfile({value:JSON.stringify(JSON.parse(JSON.stringify(P)))});
       need(a===JSON.stringify({c:P.credits,s:P.stash,w:P.weapons,e:P.equipped,g:P.gear,wo:P.worn,pil:P.pil&&P.pil.name,h:(P.hall||[]).length}),'ELEVEN: a second load moved something');
     }catch(e2){ bad.push('threw: '+(e2&&e2.message||e2)+' at '+String(e2&&e2.stack||'').split('\n').slice(1,3).join(' ')); }
     finally{
       netSend=oNs; netSendFast=oNf; netBroadcast=oNb; buzzSlow=oBs; canSee=oCs; say=oSay; pickTag=oTag; keys=kk;
       if(ftOwn) ctx.fillText=oFt; else delete ctx.fillText;
       Object.keys(NET).forEach(function(n){ delete NET[n]; }); Object.assign(NET,nk);
       try{ delete ITEMS[K]; delete ITEMS[K2]; }catch(_d){}
       P=saved; storeSet=oStore; saveProfile=oSave; WORN_DROPS_ON=oOn;
       for(k in CFG) if(!(k in cfg)) delete CFG[k]; for(k in cfg) CFG[k]=cfg[k];
       try{ var g2=__state(); if(g2&&g2.player){ g2.player.iv=0; g2.player.wm=null; } if(g2&&!g2.over){ g2.tel.shots=0; __endRaid('abandon'); } }catch(_e){}
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; ').slice(0,1800):null; }},
  {v:'37.64',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
