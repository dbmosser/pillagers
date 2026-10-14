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

if ($s.Contains("  {v:'26.72',what:")) { throw "check 26.72 is in the fixture already" }

SubRx @'
  {v:'26.71',what:
'@ @'
  {v:'26.72',what:'his yes (suggestion 25): an elite machine rolls one visible affix (shielded, volatile, fast, mender), each drawn in its own colour with a badge and each doing its job: the shield soaks rounds, a volatile one explodes as it dies, a fast one is quicker, a mender heals neighbours; an affixed kill scores three times and the party is told the affix and the shield',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__sim)||typeof mkSentry!=='function'||typeof updateBullets!=='function'||typeof render2D!=='function'||typeof spotFree!=='function'||typeof mkRaider!=='function') return 'SKIP: no raid here';
     var bad=[], g=null, p=null, all=null, i, j, k, a, aa, S, S1, S2, M, T, hist={}, ks=['shield','boom','fast','mend'], e0, got, er0, hadER, sp, spB, hF, oF, hS, oS, cnt, rx, OWN=Object.prototype.hasOwnProperty, m, cp, f, hp0, cols={shield:'#4fd6ff',boom:'#ff8a3c',fast:'#f2e84a',mend:'#5cff8a'}, rgb;
     function inW(x,y){ return x>60&&y>60&&x<WORLD_W-60&&y<WORLD_H-60; }
     function spotNear(d,pad){
       var q, aa, x, y;
       for(q=0;q<24;q++){ aa=q/24*6.2832; x=p.x+Math.cos(aa)*d; y=p.y+Math.sin(aa)*d; if(inW(x,y)&&spotFree(g.map,x,y,pad||26)&&losClear(p.x,p.y,x,y,G.vseg)) return {x:x,y:y,a:aa}; }
       return null;
     }
     function spotBeside(s,d,ox,oy){
       var q, aa, x, y;
       for(q=0;q<16;q++){ aa=q/16*6.2832; x=s.x+Math.cos(aa)*d; y=s.y+Math.sin(aa)*d; if(inW(x,y)&&spotFree(g.map,x,y,22)&&losClear(s.x,s.y,x,y,G.vseg)&&(!ox||Math.hypot(x-ox,y-oy)>90)) return {x:x,y:y};
       }
       return null;
     }
     function elite(kind,x,y,ix){
       var q=mkSentry(x,y); q.elite=1; q.affix=null; q.shieldHp=0; q.hp=q.maxhp; q.state='investigate'; q.cd=9; q.face=0; if(ix>=0) affixApply(q,ix);
       return q;
     }
     try{
       if(typeof affixApply!=='function') return 'an elite machine carries no affix';
       for(k=0;k<4;k++){
         e0={kind:'sentry',elite:1,maxhp:200,hp:200,spd:70,x:0,y:0};
         got=affixApply(e0,k); if(got!==ks[k]) bad.push('affix roll '+k+' gave "'+got+'", not "'+ks[k]+'"');
         if(k===0&&e0.shieldHp!==100) bad.push('a shielded elite has a shield of '+e0.shieldHp+', not half its 200 health');
         if(k===2&&e0.spd!==95) bad.push('a fast elite runs at '+e0.spd+', not 95 (70 times 1.35)');
       }
       if(affixApply({kind:'raider',elite:1,maxhp:200,hp:200,spd:70},1)) bad.push('a pillager elite got an affix');
       if(affixApply({kind:'warden',boss:1,elite:1,maxhp:200,hp:200,spd:70},1)) bad.push('the Overseer got an affix');
       if(affixApply({kind:'sentry',elite:0,maxhp:200,hp:200,spd:70},1)) bad.push('a plain machine got an affix');
       if(arcadeKillPts('sentry',3,false)!==300||arcadeKillPts('sentry',1,false)!==200||arcadeKillPts('sentry',true,false)!==200||arcadeKillPts('sentry',0,false)!==100) bad.push('the kill score is not 100 plain, 200 elite, 300 affixed elite');
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over) return bad.length?bad.join('; '):'SKIP: no live raid';
       p=g.player; p.iv=99; p.hp=100; p.downed=false; all=g.ents.slice();
       hadER=OWN.call(CFG,'eliteRate'); er0=CFG.eliteRate; CFG.eliteRate=1;
       for(i=0;i<80;i++){ S=mkSentry(0,0); if(!S.elite||!S.affix) bad.push('with every machine an elite, one got no affix'); else hist[S.affix]=(hist[S.affix]||0)+1; if(bad.length>3) break; }
       if(!(hist.shield>=10&&hist.boom>=10&&hist.fast>=10&&hist.mend>=10)) bad.push('eighty elite Sentries do not share the four affixes evenly ('+JSON.stringify(hist)+')');
       got=mkRaider(0,0,undefined,true); if(got.affix) bad.push('an elite pillager got an affix');
       if(hadER) CFG.eliteRate=er0; else delete CFG.eliteRate;
       for(k in keys) keys[k]=false;
       sp=spotNear(100,26);
       if(!sp) return bad.length?bad.join('; '):'SKIP: no open ground beside the player';
       // the shield soaks rounds first
       spB=null; for(k=0;k<24&&!spB;k++){ aa=k/24*6.2832; var tx=p.x+Math.cos(aa)*130, ty=p.y+Math.sin(aa)*130; if(inW(tx,ty-100)&&inW(tx,ty)&&spotFree(g.map,tx,ty,26)&&spotFree(g.map,tx,ty-100,10)&&losClear(tx,ty-100,tx,ty,G.vseg)) spB={x:tx,y:ty}; }
       if(spB){
         S=elite('sentry',spB.x,spB.y,0); S.shieldHp=60; g.ents=[S];
         function fire(){ var q; g.bullets.length=0; g.bullets.push({x:spB.x,y:spB.y-100,vx:0,vy:1180,dmg:25,life:0.3,player:true,owner:p,tint:'#ffffff',el:'',thru:0}); for(q=0;q<8;q++) updateBullets(1/60); }
         fire(); fire();
         if(!(S.hp===S.maxhp)) bad.push('two rounds of 25 into a 60 shield hurt the machine ('+S.hp+' of '+S.maxhp+')');
         if(!(Math.abs(S.shieldHp-10)<0.5)) bad.push('two rounds of 25 left the shield at '+S.shieldHp+', not 10');
         fire();
         if(!(S.shieldHp===0&&S.hp<S.maxhp)) bad.push('the third round did not carry past the spent shield (shield '+S.shieldHp+', health '+S.hp+' of '+S.maxhp+')');
       }
       g.ents=[]; g.bullets.length=0;
       // a volatile machine goes off as it dies
       S1=elite('sentry',sp.x,sp.y,1); sp=spotBeside(sp,60,p.x,p.y);
       if(sp){
         S2=elite('sentry',sp.x,sp.y,-1);
         p.iv=0; p.hp=100; S1.hp=0; g.ents=[S1,S2];
         __sim(1/60);
         if(g.ents.indexOf(S1)>=0) bad.push('the dead volatile machine is still in the world');
         if(!(p.hp<100)) bad.push('a volatile Sentry dying 100 units from the player did not hurt him');
         if(!(S2.hp<S2.maxhp)) bad.push('a volatile Sentry dying beside another did not hurt it');
         S1=elite('sentry',S1.x,S1.y,-1); S1.hp=0; S2.hp=S2.maxhp; p.hp=100; g.ents=[S1,S2];
         __sim(1/60);
         if(p.hp<100||S2.hp<S2.maxhp) bad.push('a plain machine dying hurt something near it');
       }
       g.ents=[]; p.iv=99; p.hp=100;
       // a mender heals its neighbours
       spB=null; for(i=0;i<100&&!spB;i++){ sp=freeSpot(g.map,40); if(Math.hypot(sp.x-p.x,sp.y-p.y)>950){ spB=spotBeside(sp,120); if(spB) spB.base=sp; } }
       if(spB){
         M=elite('sentry',spB.base.x,spB.base.y,3); T=elite('sentry',spB.x,spB.y,-1); T.hp=Math.round(T.maxhp*0.5); hp0=T.hp; g.ents=[M,T];
         for(i=0;i<90;i++){ T.hp=Math.min(T.hp,T.maxhp); __sim(1/60); }
         if(!(T.hp>=hp0+12)) bad.push('a mender beside a damaged machine for 1.5 seconds mended it from '+hp0+' to only '+Math.round(T.hp));
       }
       g.ents=[]; g.bullets.length=0;
       // each affix draws its own colour and badge
       sp=spotNear(90,26);
       if(sp){
         p.face=sp.a;
         for(k=0;k<4;k++){
           S=elite('sentry',sp.x,sp.y,k); S.face=sp.a+3.1416; g.ents=[S];
           rgb=[parseInt(cols[ks[k]].slice(1,3),16),parseInt(cols[ks[k]].slice(3,5),16),parseInt(cols[ks[k]].slice(5,7),16)];
           rx=new RegExp(rgb[0]+',\\s*'+rgb[1]+',\\s*'+rgb[2]); cnt=0;
           hS=OWN.call(wc,'stroke'); oS=wc.stroke; hF=OWN.call(wc,'fill'); oF=wc.fill;
           wc.stroke=function(){ if(rx.test(String(this.strokeStyle))) cnt++; return oS.apply(this,arguments); };
           wc.fill=function(){ if(String(this.fillStyle).toLowerCase()===cols[ks[k]]) cnt++; return oF.apply(this,arguments); };
           try{ render2D(0.016); } finally { if(hS) wc.stroke=oS; else delete wc.stroke; if(hF) wc.fill=oF; else delete wc.fill; }
           if(cnt<2) bad.push('an elite '+ks[k]+' machine in view draws its colour only '+cnt+' times (ring and badge expected)');
         }
       }
       // the party is told
       S=elite('sentry',0,0,0); S.nid=77; S.shieldHp=40;
       m=netEntNewWord(S); if(m.af!=='shield') bad.push('the new-body word does not carry the affix ('+m.af+')');
       cp={kind:'sentry',x:0,y:0,state:'patrol',hp:50,maxhp:50}; netEntFill(cp,m); if(cp.affix!=='shield') bad.push('a linked window does not read the affix');
       f=netEntFlags(S); if(!(f&536870912)) bad.push('the party is not told the shield is up');
       netEntFlagsApply(cp,f); if(!(cp.shieldHp>0)) bad.push('a linked window does not read the shield flag');
       S.shieldHp=0; f=netEntFlags(S); if(f&536870912) bad.push('a spent shield still sends the flag');
       netEntFlagsApply(cp,f); if(cp.shieldHp>0) bad.push('a linked window keeps a spent shield');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       try{ if(typeof oS==='function'){ if(hS) wc.stroke=oS; else delete wc.stroke; } if(typeof oF==='function'){ if(hF) wc.fill=oF; else delete wc.fill; } }catch(_e0){}
       try{ if(hadER===true) CFG.eliteRate=er0; else if(hadER===false) delete CFG.eliteRate; }catch(_e1){}
       try{ if(g&&all){ g.ents=all; g.bullets.length=0; } var g2=__state(); if(g2&&!g2.over){ g2.player.iv=0; g2.player.hp=100; g2.player.downed=false; __endRaid('abandon'); } }catch(_e3){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'26.71',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
