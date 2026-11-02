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

if ($s.Contains("  {v:'37.34',what:")) { throw "check 37.34 is in the fixture already" }

SubRx @'
  {v:'37.33',what:
'@ @'
  {v:'37.34',what:'cw-m2hall, his rulings of 11-01 (season zero m2): the hall of the fallen. pilEpithet gives the documented epithet for crafted records; with three records the Mainframe hall tab draws through its real route with the living one first and marked living, every name, epithet, killer and place, and the records row picks the right pillager each; an empty hall draws the hall is empty; old records with no end field draw; generation one from an old save shows its old totals; an old save loads twice with nothing lost; the list scrolls with the wheel and the pad; a real wall stands on the hub map clear of every station, every station is still reached on foot from the lift, E at the wall opens the tab, and drawing the hub twice bakes the portraits once, each in its own look',
   run:function(){
     if(!(window.__runPrep&&window.__cleanProfile&&window.__topClear&&window.__hubEnter)) return 'SKIP: no hub fixture';
     if(typeof applyLoadedProfile!=='function'||typeof openOps!=='function'||typeof buildHub!=='function'||typeof drawHubWorld!=='function'||typeof updateHubWorld!=='function'||typeof pilNow!=='function') return 'SKIP: no loader, Mainframe or floor here';
     if(typeof pilEpithet!=='function'||typeof renderHall!=='function'||typeof hallWallDraw!=='function'||typeof HALLW==='undefined') return 'no hall in this build (pilEpithet, renderHall, hallWallDraw, HALLW)';
     var bad=[], saved=P, cp=Object.assign({},CFG), kk=keys, oldStore=storeSet, oldSave=saveProfile, oldB=drawOpBody, own0=cosOwned, i, j, k, t, row, c, rs, cards, st, H, snap, A, B, n, sk, url0, url3, pane;
     function need(ok,msg){ if(!ok) bad.push(msg); }
     function J(o){ return JSON.stringify(o); }
     function rec(name,gen,raids,ext,kills,best,lvl,end){ return {name:name,gen:gen,num:1,traits:[],lvl:lvl,lsp:0,picks:[],raids:raids,ext:ext,kills:kills,best:best,born:1000+gen,end:end}; }
     function three(){ return [
       rec('brakka',2,12,11,60,2000,4,{at:2000,how:'dead',map:FIXED_MAPS[0].id,zone:'the old pumps',by:'golden sentry',lost:300,items:[],worn:{},look:{skin:'ebony',hat:'none'}}),
       rec('ozzrik',3,3,2,3,9500,2,{at:3000,how:'dead',map:FIXED_MAPS[0].id,zone:'the kilns',by:'crawler',lost:400,items:[],worn:{},look:{skin:'tan',hat:'none'}}),
       rec('vex',4,6,6,90,700,7,{at:4000,how:'quit',map:FIXED_MAPS[0].id,zone:'',by:'',lost:0,items:[],worn:{},look:{skin:'fair',hat:'none'}})
     ]; }
     function txt(el){ return String(el?el.textContent:''); }
     function openTab(){ __topClear(); [].forEach.call(document.querySelectorAll('.modal.on'),function(x){ x.classList.remove('on'); }); hubStationById('mf').acts.KeyR[1](); }
     function tabOn(){ var m=document.getElementById('opmodal'), p=document.getElementById('opane_hall'); return !!(m&&m.classList.contains('on')&&p&&p.style.display==='flex'&&p.getBoundingClientRect().height>0); }
     try{
       P=JSON.parse(J(saved));
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       storeSet=function(){}; saveProfile=function(){};
       __hubEnter(); [].forEach.call(document.querySelectorAll('.modal.on'),function(x){ x.classList.remove('on'); });
       HB=buildHub(); HB.player.x=590; HB.player.y=400;
       // ONE: the epithets, one crafted record for each rule
       t=[[{raids:0},'the untried'],[{raids:1},'the untried'],[{raids:1,end:{how:'dead'}},'the brief'],[{raids:4,end:{how:'quit'}},'the deserter'],[{raids:6,kills:50,end:{how:'retire'}},'the old'],
          [{raids:4,kills:40,best:100,end:{how:'dead'}},'the butcher'],[{raids:4,kills:12,end:{how:'dead',lost:6000}},'the greedy'],[{raids:3,kills:12,best:9000,end:{how:'dead'}},'the lucky'],
          [{raids:6,kills:3,end:{how:'dead'}},'the ghost'],[{raids:3,kills:5,end:{how:'dead'}},'the quiet'],[{raids:12,kills:60,end:{how:'dead'}},'the stubborn'],[{raids:4,kills:12,best:100,end:{how:'dead'}},'the unsung'],[{},'the untried'],[{raids:9,kills:30},'the unsung']];
       for(i=0;i<t.length;i++) need(pilEpithet(t[i][0])===t[i][1],'ONE: '+J(t[i][0])+' is "'+pilEpithet(t[i][0])+'", not "'+t[i][1]+'"');
       // TWO: three records through the real route, the living one first
       P.hall=three(); P.pilGen=5; P.pil=pilMake('grell',5,[],2); P.pil.raids=2; P.pil.kills=4; P.pil.best=100;
       need(!!hubStationById('mf').acts.KeyR,'TWO: no R act for the hall at the Mainframe');
       openTab();
       need(tabOn(),'TWO: R at the Mainframe did not open the hall pane');
       need(!!document.querySelector('#optabs [data-optab="hall"].on'),'TWO: no hall tab beside the others');
       rs=[].slice.call(document.querySelectorAll('#halllist .hallrow'));
       need(rs.length===4,'TWO: '+rs.length+' rows, not 4');
       if(rs.length===4){
         need(/grell ii/.test(txt(rs[0]))&&/living/.test(txt(rs[0]))&&!!rs[0].querySelector('.hlive'),'TWO: the first row is not the living one marked living: '+txt(rs[0]));
         need(/vex/.test(txt(rs[1]))&&/the deserter/.test(txt(rs[1]))&&/quit/.test(txt(rs[1])),'TWO: the newest ended row is not vex the deserter: '+txt(rs[1]));
         need(/ozzrik/.test(txt(rs[2]))&&/the lucky/.test(txt(rs[2]))&&/died at the kilns/.test(txt(rs[2]))&&/killed by crawler/.test(txt(rs[2]))&&/\$9,500/.test(txt(rs[2])),'TWO: the ozzrik row: '+txt(rs[2]));
         need(/brakka/.test(txt(rs[3]))&&/the stubborn/.test(txt(rs[3]))&&/died at the old pumps/.test(txt(rs[3]))&&/killed by golden sentry/.test(txt(rs[3])),'TWO: the brakka row: '+txt(rs[3]));
         need(txt(rs[2]).indexOf(String(FIXED_MAPS[0].name).toLowerCase())>=0,'TWO: the map name is not on the row: '+txt(rs[2]));
       }
       cards={}; [].forEach.call(document.querySelectorAll('#hallrecs [data-rec]'),function(el){ cards[el.getAttribute('data-rec')]=txt(el); });
       need(/longest life/.test(cards.raids||'')&&/brakka/.test(cards.raids||'')&&/12 raids/.test(cards.raids||''),'TWO: longest life: '+cards.raids);
       need(/richest haul/.test(cards.best||'')&&/ozzrik/.test(cards.best||'')&&/\$9,500/.test(cards.best||''),'TWO: richest haul: '+cards.best);
       need(/most kills/.test(cards.kills||'')&&/vex/.test(cards.kills||'')&&/90 kills/.test(cards.kills||''),'TWO: most kills: '+cards.kills);
       need(/highest level/.test(cards.lvl||'')&&/vex/.test(cards.lvl||'')&&/level 7/.test(cards.lvl||''),'TWO: highest level: '+cards.lvl);
       need(txt(document.getElementById('opane_hall')).indexOf('the hall is empty')<0,'TWO: empty line with a full hall');
       t=txt(document.getElementById('hallrecs'))+txt(document.getElementById('halllist'));
       need(t===t.toLowerCase(),'TWO: capitals in the tab');
       // THREE: an empty hall
       P.hall=[]; P.pil=null; P.pilGen=0; pilNow(); P.runs=0; P.ext=0; P.best=0; P.achN={}; openTab();
       need(tabOn()&&txt(document.getElementById('halllist')).indexOf('the hall is empty')>=0,'THREE: an empty hall does not draw the hall is empty');
       need(document.querySelectorAll('#halllist .hallrow').length===1,'THREE: an empty hall should still show the living one');
       need(document.getElementById('hallrecs').style.display==='none','THREE: records drawn with nobody to hold them');
       // FOUR: generation one from an old save is living with its old totals; nothing is written
       P.runs=40; P.ext=22; P.best=9000; P.achN={raider:5,mach:10}; sk=J(P.pil); openTab();
       row=document.querySelector('#halllist .hallrow'); t=[].map.call(row?row.querySelectorAll('.hn'):[],txt);
       need(J(t)===J(['1','1','40','$9,000','15']),'FOUR: the old totals on the living row: '+J(t));
       need(/living/.test(txt(row)),'FOUR: not living');
       need(J(P.pil)===sk,'FOUR: drawing changed the save');
       // FIVE: old records missing any end field draw, and an old save reloads twice with nothing lost
       P.hall=[{name:'OLDTIMER'},{name:'noend',gen:2,raids:3,kills:1,best:50,lvl:1},{name:'halfend',gen:3,raids:5,kills:2,best:100,lvl:1,end:{}},{name:'bywho',gen:4,raids:2,end:{how:'dead',by:'SENTRY'}}]; P.pilGen=5; P.pil=pilMake('live',5);
       P.credits=4321; P.stash=['scrap','core']; P.lifeEarn=7000; P.acctName='ozzy';
       for(i=0;i<2;i++){
         snap=JSON.parse(J(P)); snap.cfg=JSON.parse(J(CFG)); snap.cfgv=18;
         A={c:snap.credits,s:J(snap.stash),w:J(snap.weapons),eq:snap.equipped,ct:J(snap.contracts),fg:J(snap.forged||{}),le:snap.lifeEarn,p:J(snap.pil),h:J(snap.hall),g:snap.pilGen};
         applyLoadedProfile({value:J(snap)});
         B={c:P.credits,s:J(P.stash),w:J(P.weapons),eq:P.equipped,ct:J(P.contracts),fg:J(P.forged||{}),le:P.lifeEarn,p:J(P.pil),h:J(P.hall),g:P.pilGen};
         need(J(A)===J(B),'FIVE: load '+(i+1)+' moved the save: '+J(A)+' vs '+J(B));
       }
       openTab(); t=txt(document.getElementById('halllist'));
       need(/oldtimer/.test(t)&&/noend/.test(t)&&/halfend/.test(t)&&/killed by sentry/.test(t),'FIVE: old records did not draw: '+t);
       need(!/undefined|NaN|null/.test(t),'FIVE: a missing field printed: '+t);
       // between a death and the birth card there is no living one: the hall still draws
       P.hall=three(); P.pil=null; openTab();
       rs=document.querySelectorAll('#halllist .hallrow');
       need(tabOn()&&rs.length===3&&!document.querySelector('#halllist .hlive')&&/vex/.test(txt(rs[0])),'FIVE: with nobody living the hall drew '+rs.length+' rows');
       // SIX: forty records scroll with the wheel (the wheel leaves a box that can scroll alone) and with the pad
       H=[]; for(i=0;i<40;i++) H.push(rec('row'+i,i+2,3,2,3,100,1,{at:5000+i,how:'dead',by:'crawler'})); P.hall=H; P.pilGen=42; P.pil=pilMake('live',42); openTab();
       pane=document.getElementById('opane_hall');
       need(pane.scrollHeight-pane.clientHeight>2&&(getComputedStyle(pane).overflowY==='auto'),'SIX: the pane does not scroll');
       rs=document.querySelectorAll('#halllist .hallrow'); pane.scrollTop=0;
       need(padFocusables(document.getElementById('opmodal')).indexOf(rs[rs.length-1])>=0,'SIX: the pad cannot reach the last row');
       padSetFocus(rs[rs.length-1]);
       need(pane.scrollTop>0,'SIX: the pad did not scroll to the last row');
       padSetFocus(null); document.getElementById('opmodal').classList.remove('on');
       // SEVEN: a real wall, clear of every station, and every station still reached on foot from the lift
       k=null; for(i=0;i<HB.walls.length;i++) if(HB.walls[i].x===HALLW.x&&HB.walls[i].y===HALLW.y&&HB.walls[i].w===HALLW.w&&HB.walls[i].h===HALLW.h) k=HB.dwalls[i];
       need(!!k,'SEVEN: no hall wall on the hub map');
       st=hubStationById('hall');
       need(!!st&&!!st.acts.KeyE,'SEVEN: no way to use the wall');
       if(k){
         for(i=0;i<HB.stations.length;i++){ c=HB.stations[i]; if(c.id==='hall') continue;
           n=Math.hypot(c.x-Math.max(k.x,Math.min(c.x,k.x+k.w)),c.y-Math.max(k.y,Math.min(c.y,k.y+k.h)));
           need(n>=c.r,'SEVEN: the wall stands on '+c.id+' ('+n.toFixed(1)+' from it)');
         }
         for(i=0;i<HB.dwalls.length;i++){ c=HB.dwalls[i]; if(c===k||c.y>=k.y+k.h||c.y+c.h<=k.y) continue; if(c.x<k.x+k.w&&c.x+c.w>k.x&&c.y>k.y+0) bad.push('SEVEN: the wall overlaps another wall at '+c.x+','+c.y); }
       }
       function free(x,y){ if(x<26||y<26||x>HUBW-26||y>HUBH-26) return false; for(var q=0;q<HB.dwalls.length;q++){ var D=HB.dwalls[q]; if(x>D.x-11&&x<D.x+D.w+11&&y>D.y-11&&y<D.y+D.h+11) return false; } return true; }
       var seen={}, Q=[], SS=5, lift=hubStationById('lift'), sx=Math.round(lift.x/SS), sy=Math.round((lift.y+20)/SS), vis=[], cur, nb;
       need(free(sx*SS,sy*SS),'SEVEN: the lift floor is not free');
       Q.push([sx,sy]); seen[sx+','+sy]=1;
       while(Q.length){ cur=Q.pop(); vis.push(cur); nb=[[1,0],[-1,0],[0,1],[0,-1]];
         for(j=0;j<4;j++){ var ax=cur[0]+nb[j][0], ay=cur[1]+nb[j][1], ky=ax+','+ay; if(seen[ky]||!free(ax*SS,ay*SS)) continue; seen[ky]=1; Q.push([ax,ay]); } }
       for(i=0;i<HB.stations.length;i++){ c=HB.stations[i]; n=0; for(j=0;j<vis.length&&!n;j++) if(Math.hypot(vis[j][0]*SS-c.x,vis[j][1]*SS-c.y)<c.r) n=1; need(n,'SEVEN: no way on foot from the lift to '+c.id); }
       // EIGHT: E at the wall opens the tab
       __topClear(); __hubEnter(); [].forEach.call(document.querySelectorAll('.modal.on'),function(x){ x.classList.remove('on'); });
       st=hubStationById('hall');
       HB.player.x=250; HB.player.y=70; HB.eLock=false; keys={}; updateHubWorld(0.016);
       need(HB.near===st,'EIGHT: standing at the wall is not at the hall (near '+(HB.near&&HB.near.id)+')');
       keys={KeyE:true}; updateHubWorld(0.016); keys={};
       need(tabOn(),'EIGHT: E at the wall did not open the hall tab');
       document.getElementById('opmodal').classList.remove('on'); HB.eLock=false;
       // NINE: drawing the hub twice does not redraw the portraits; a new record does; each wears its look; nothing leaks
       P.hall=[]; HALLW.k=''; HB.player.x=590; HB.player.y=400; drawHubWorld(0.016);
       url0=HALLW.c.toDataURL();
       P.hall=three(); P.cosSkin='porcelain';
       var calls=[], skinWas=P.cosSkin, wcWas=wc;
       drawOpBody=function(){ if(wc&&wc.canvas===HALLW.c) calls.push(P.cosSkin); return oldB.apply(this,arguments); };
       HALLW.k=''; A=HALLW.bakes;
       drawHubWorld(0.016);
       need(calls.length===3,'NINE: the first floor frame painted '+calls.length+' portraits, not 3');
       need(J(calls)===J(['fair','tan','ebony']),'NINE: the portraits, newest first, did not wear their looks: '+J(calls));
       need(HALLW.bakes===A+1,'NINE: '+(HALLW.bakes-A)+' bakes on the first frame');
       url3=HALLW.c.toDataURL();
       need(url3!==url0,'NINE: the board looks the same with three pillagers as with none');
       need(P.cosSkin===skinWas&&wc===wcWas&&cosOwned===own0,'NINE: the portrait left the live look or canvas changed');
       drawHubWorld(0.016); drawHubWorld(0.016);
       need(calls.length===3&&HALLW.bakes===A+1,'NINE: drawing the hub again redrew the portraits ('+calls.length+' calls, '+(HALLW.bakes-A)+' bakes)');
       P.hall.push(rec('kess',5,3,2,3,100,1,{at:6000,how:'dead',by:'crawler',look:{skin:'bronze'}}));
       drawHubWorld(0.016);
       need(calls.length===6&&HALLW.bakes===A+2,'NINE: a new record did not bake once more ('+calls.length+' calls, '+(HALLW.bakes-A)+' bakes)');
       need(calls[3]==='bronze','NINE: the newest did not take the first frame: '+J(calls));
       P.hall=[{name:'nolook',end:{how:'dead',at:7000}}]; calls.length=0; drawHubWorld(0.016);
       need(J(calls)===J([skinWas]),'NINE: a record with no look should wear today look: '+J(calls));
     }catch(e2){ bad.push('threw: '+(e2&&e2.message||e2)); }
     finally{
       drawOpBody=oldB; cosOwned=own0;
       P=saved; storeSet=oldStore; saveProfile=oldSave; keys=kk;
       for(k in CFG) if(!(k in cp)) delete CFG[k]; Object.assign(CFG,cp);
       try{ document.getElementById('opmodal').classList.remove('on'); padSetFocus(null); }catch(_m){}
       try{ HALLW.k=''; __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'37.33',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
