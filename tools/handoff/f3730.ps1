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

if ($s.Contains("  {v:'37.30',what:")) { throw "check 37.30 is in the fixture already" }

SubRx @'
  {v:'37.29',what:
'@ @'
  {v:'37.30',what:'cw-p2heirs, his rulings of 11-01 (season zero m2): three heirs for the next pillager, rolled on side dice from the save (the same three on a second call and after a reload, three different rough names, one or two small traits each, never two on one stat), chosen heir i becomes the next generation and the roll clears, a trait is a small signed gear stat on the one reader (a raid with only a trait carries it, a bad trait slows him by exactly its value, caps and floors hold with big gear, nothing worn and no traits reads null, the bot sim and the demo carry nothing), the numeral counts the hall, the account card shows generation, name and traits in green and red, and an old save loads with nothing lost',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__runPrep&&window.__cleanProfile)) return 'SKIP: no raid fixture';
     if(typeof applyLoadedProfile!=='function'||typeof updatePlayer!=='function'||typeof raidWornMods!=='function'||typeof wornAdd!=='function'||typeof renderStatCards!=='function') return 'SKIP: no loader, player, gear reader or stats page here';
     if(typeof PIL_TRAITS==='undefined'||typeof PIL_NAMES==='undefined'||typeof pilHeirs!=='function'||typeof pilName!=='function'||typeof pilTraitMods!=='function') return 'no heirs, traits or rough names in this build (PIL_TRAITS, PIL_NAMES, pilHeirs, pilName, pilTraitMods)';
     var bad=[], saved=P, kk=keys, mm=Object.assign({},mouse), nk=Object.assign({},NET), pk=Object.assign({},PAD), cp=Object.assign({},CFG), oldStore=storeSet, oldSave=saveProfile,
         g, p, a, b, h, h2, i, j, t, s, m, r, x0, y0, d, dirs, snap, ids={}, nGood=0, nBad=0, st, wm0, v, pc, sg=null, tmp=null, k;
     function need(ok,msg){ if(!ok) bad.push(msg); }
     function near(x,y,tol){ return Math.abs(x-y)<=tol*Math.max(1,Math.abs(y)); }
     function calm(){
       keys={}; mouse.down=false; PAD.on=false; PAD.mx=0; PAD.my=0; NET.on=false;
       p.hand=null; p.prep=null; p.prepA=null; p.reloading=0; p.rlTot=0; p.ads=false; p.stimT=0; p.roll=0; p.rollCd=0; p.iv=0; p.downed=false; p.dying=false; p.specOut=false;
       p.hp=100; p.maxhp=100; p.armor=0; p.stam=100; p.stamLock=0; p.cooking=false; g.wheel=null; g.sprintOn=false; g.sprinting=false; g.crouchTog=false; g.pCrouch=false; g.deathBeat=null;
       g.shWas=false; p.shotSprintRelease=false; p.stamRelease=0; p.trigYield=0; try{ HHOLD.arm=0; }catch(_h){}
       p.x=x0; p.y=y0;
     }
     function arm(w){ calm(); p.wm=w; }
     function load(q){ applyLoadedProfile({value:JSON.stringify(q)}); }
     function sig(L){ return JSON.stringify((L||[]).map(function(q){ return [q.name,q.num,q.gen,q.traits]; })); }
     function byId(id){ for(var q=0;q<PIL_TRAITS.length;q++) if(PIL_TRAITS[q].id===id) return PIL_TRAITS[q]; return null; }
     for(k in CFG) cp[k]=CFG[k];
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       storeSet=function(){}; saveProfile=function(){};
       // ONE: the trait table speaks only the gear stats, small, mostly good; the names are short, lower case and different
       need(PIL_TRAITS.length>=14,'ONE: '+PIL_TRAITS.length+' traits, not at least 14');
       for(i=0;i<PIL_TRAITS.length;i++){ t=PIL_TRAITS[i];
         need(t&&typeof t.id==='string'&&!ids[t.id]&&typeof t.n==='string'&&t.n===t.n.toLowerCase()&&Array.isArray(t.m)&&t.m.length>=1&&t.m.length<=2,'ONE: trait '+JSON.stringify(t)+' is not an id, a lower case name and one or two stats');
         if(t) ids[t.id]=1;
         for(j=0;t&&Array.isArray(t.m)&&j<t.m.length;j++){ s=t.m[j];
           need(s&&WORN_STATS[s.s]&&typeof s.v==='number'&&s.v!==0&&Math.abs(s.v)<=WORN_STATS[s.s].base*0.5+1e-9&&Math.abs(s.v)>=WORN_STATS[s.s].base*0.3-1e-9,'ONE: '+(t&&t.n)+' has '+JSON.stringify(s)+', not a WORN_STATS key at a third to a half of its base');
           if(s&&s.v>0) nGood++; else nBad++; } }
       need(nBad>=4&&nGood>nBad,'ONE: '+nGood+' good and '+nBad+' bad trait stats');
       s={}; for(i=0;i<PIL_NAMES.length;i++){ t=PIL_NAMES[i]; need(typeof t==='string'&&/^[a-z]{3,8}$/.test(t)&&!s[t],'ONE: name '+JSON.stringify(t)+' is not a short lower case name of its own'); s[t]=1; }
       need(PIL_NAMES.length>=30,'ONE: '+PIL_NAMES.length+' names');
       // TWO: three heirs, three names, one or two traits on different stats, the next generation; the same on a second call, a fresh roll and a reload
       P.acctName='ozzrik'; P.hall=[]; P.pil=pilMake('ozzrik',1); P.pil.born=1700000000000; P.pilGen=1; delete P.heirs; P.worn={}; P.gear=[];
       h=JSON.parse(JSON.stringify(pilHeirs(P)));
       need(h.length===3,'TWO: '+h.length+' heirs');
       s={}; for(i=0;i<h.length;i++){ r=h[i]; need(r&&typeof r.name==='string'&&PIL_NAMES.indexOf(r.name)>=0&&!s[r.name]&&r.gen===2&&pilName(r)===r.name,'TWO: heir '+i+' '+JSON.stringify(r)+' is not a fresh pool name of generation 2'); if(r) s[r.name]=1;
         need(r&&Array.isArray(r.traits)&&r.traits.length>=1&&r.traits.length<=2,'TWO: heir '+i+' has traits '+JSON.stringify(r&&r.traits));
         st={}; for(j=0;r&&j<r.traits.length;j++){ t=byId(r.traits[j]); need(!!t,'TWO: heir '+i+' trait '+r.traits[j]+' is not in the table'); for(k=0;t&&k<t.m.length;k++){ need(!st[t.m[k].s],'TWO: heir '+i+' has two traits on '+t.m[k].s+' '+JSON.stringify(r.traits)); st[t.m[k].s]=1; } } }
       need(Array.isArray(P.heirs)&&sig(P.heirs)===sig(h),'TWO: P.heirs does not keep the roll');
       need(sig(pilHeirs(P))===sig(h),'TWO: a second call gave '+sig(pilHeirs(P))+' not '+sig(h));
       delete P.heirs; need(sig(pilHeirs(P))===sig(h),'TWO: a fresh roll for the same save gave '+sig(P.heirs)+' not '+sig(h));
       P.acctName='vell'; delete P.heirs; h2=pilHeirs(P); need(sig(h2)!==sig(h),'TWO: another account rolled the same three');
       P.acctName='ozzrik'; delete P.heirs; pilHeirs(P);
       snap=JSON.parse(JSON.stringify(P)); load(snap);
       need(sig(P.heirs)===sig(h)&&sig(pilHeirs(P))===sig(h),'TWO: a reload changed the heirs to '+sig(P.heirs));
       // THREE: heir 1 is born as the next generation and the roll clears; with no heir the first of the next roll is taken
       h=JSON.parse(JSON.stringify(pilHeirs(P)));
       pilEnd(P,{outcome:'dead'}); r=pilBirth(P,1);
       need(r&&P.pil&&P.pil.name===h[1].name&&JSON.stringify(P.pil.traits)===JSON.stringify(h[1].traits)&&P.pil.gen===2&&P.pilGen===2&&P.heirs===undefined&&P.hall.length===1&&P.pil.born>0,'THREE: pilBirth(P,1) gave '+JSON.stringify(P.pil)+' pilGen '+P.pilGen+' heirs '+JSON.stringify(P.heirs)+' for heir '+JSON.stringify(h[1]));
       h2=JSON.parse(JSON.stringify(pilHeirs(P)));
       pilEnd(P,{outcome:'dead'}); r=pilBirth(P);
       need(h2[0].gen===3&&P.pil&&P.pil.name===h2[0].name&&P.pil.gen===3&&P.pilGen===3&&P.heirs===undefined,'THREE: pilBirth(P) gave '+JSON.stringify(P.pil)+' for the first heir '+JSON.stringify(h2[0]));
       // FOUR: a raid with only a trait carries it, and a bad trait slows him by exactly its value through the real move code
       t=byId('heavyfeet'); v=t&&t.m[0].s==='spd'?t.m[0].v:0;
       need(v<0,'FOUR: staging: no bad move speed trait heavyfeet');
       P.worn={}; P.gear=[]; P.pil.traits=['heavyfeet'];
       __deploy({kit:[],seed:4242}); g=__state(); p=g.player; wm0=p.wm;
       need(wm0&&wm0.spd===v&&wm0.reload===0&&wm0.quiet===0,'FOUR: the body carries '+JSON.stringify(wm0)+' with only heavy feet');
       x0=p.x; y0=p.y; dirs=['KeyD','KeyA','KeyS','KeyW']; d=null;
       for(i=0;i<dirs.length&&!d;i++){ arm(null); keys[dirs[i]]=true; updatePlayer(0.02); a=Math.hypot(p.x-x0,p.y-y0); if(a>0.5) d=dirs[i]; }
       if(!d) bad.push('FOUR: staging: he could not walk any way from the start');
       else{ arm(null); keys[d]=true; updatePlayer(0.02); a=Math.hypot(p.x-x0,p.y-y0);
             arm(wm0); keys[d]=true; updatePlayer(0.02); b=Math.hypot(p.x-x0,p.y-y0);
             need(a>0&&b<a&&Math.abs(b/a-(1+v))<=0.002,'FOUR: with heavy feet he walked '+b.toFixed(4)+' against '+a.toFixed(4)+' (ratio '+(b/a).toFixed(4)+', not '+(1+v)+')'); }
       arm(null);
       // FIVE: caps on the plus side and the floor on the minus side hold with big gear and big traits
       pc=wornAdd(P,{k:'armor',r:3,pw:100,tr:[{s:'tough',v:0.15},{s:'spd',v:0.15}]}); wornWear(P,pc.id);
       P.pil.traits=['toughhide','longlegs'];
       m=raidWornMods();
       need(m&&m.tough===WORN_STATS.tough.cap&&m.spd===WORN_STATS.spd.cap,'FIVE: capped gear plus traits read '+JSON.stringify(m));
       m=wornMods(P.worn,{tough:0.5,spd:-0.5});
       need(m.tough===WORN_STATS.tough.cap&&m.spd===-WORN_STATS.spd.base,'FIVE: big gear and a big trait read tough '+m.tough+' and speed '+m.spd);
       m=wornMods(null,{quiet:-1,stam:-1,nosuch:1});
       need(m.quiet===-WORN_STATS.quiet.base&&m.stam===-WORN_STATS.stam.base&&m.nosuch===undefined,'FIVE: the floor reads '+JSON.stringify(m));
       // SIX: nothing worn and no traits reads null; the bot sim and the demo carry nothing even with a trait
       P.worn={}; P.gear=[]; P.pil.traits=[];
       need(raidWornMods()===null,'SIX: nothing worn and no traits reads '+JSON.stringify(raidWornMods()));
       __deploy({kit:[],seed:4242}); g=__state(); need(g&&g.player&&g.player.wm===null,'SIX: the body carries '+JSON.stringify(g&&g.player&&g.player.wm)+' with nothing');
       P.pil.traits=['lightstep'];
       if(window.__newRaid){ a=__newRaid(); need(a&&a.player&&!a.player.wm,'SIX: a bot sim raid carries the trait'); }
       ARCADE.on=true; try{ need(raidWornMods()===null,'SIX: the demo reads the career traits'); } finally{ ARCADE.on=false; }
       // SEVEN: the numeral counts the names in the hall and the living one
       P.hall=[]; for(i=0;i<PIL_NAMES.length;i++){ P.hall.push(pilMake(PIL_NAMES[i],1)); P.hall.push(pilMake(PIL_NAMES[i],1)); }
       P.pil=pilMake('zzq',1); delete P.heirs; h=pilHeirs(P);
       for(i=0;i<h.length;i++) need(h[i].num===3&&pilName(h[i])===h[i].name+' iii','SEVEN: with two of each name in the hall heir '+i+' reads '+pilName(h[i])+' (num '+h[i].num+')');
       need(pilName({name:'Brakka',num:4})==='brakka iv'&&pilName({name:'vosk',num:1})==='vosk'&&pilName({name:'gurt',num:14})==='gurt xiv','SEVEN: the shown names read '+pilName({name:'Brakka',num:4})+', '+pilName({name:'vosk',num:1})+', '+pilName({name:'gurt',num:14}));
       // EIGHT: the account card shows the generation, the name with its numeral and the traits, good in green and bad in red
       P.hall=[]; P.pil=pilMake('brakka',14,['lightstep','shaky'],4); P.pilGen=14; delete P.heirs;
       sg=document.getElementById('statgrid'); if(!sg){ tmp=document.createElement('div'); tmp.id='statgrid'; document.body.appendChild(tmp); sg=tmp; }
       renderStatCards(); s=sg.innerHTML;
       need(s.indexOf('your 14th pillager')>=0&&s.indexOf('brakka iv')>=0,'EIGHT: the card does not say your 14th pillager and brakka iv');
       need(/color:var\(--ok\)[^>]*>light step</.test(s)&&/color:var\(--danger\)[^>]*>shaky</.test(s),'EIGHT: the traits are not light step in green and shaky in red');
       // NINE: an old save (no heirs, no numerals) loads with nothing lost, twice
       snap=JSON.parse(JSON.stringify(P)); delete snap.heirs;
       snap.credits=4321; snap.stash=['scrap','core']; snap.weapons=['pistol','smg']; snap.equipped='smg'; snap.lifeEarn=7000; snap.acctName='ozzrik'; snap.pilGen=2;
       snap.pil={name:'ozzrik',gen:2,traits:[],lvl:1,lsp:0,picks:[],raids:5,ext:2,kills:3,best:900,born:1700000000000};
       snap.hall=[{name:'vosk',gen:1,traits:[],lvl:1,lsp:0,picks:[],raids:2,ext:0,kills:1,best:0,born:1690000000000,end:{at:1695000000000,outcome:'dead'}}];
       load(snap);
       need(P.credits===4321&&JSON.stringify(P.stash)==='["scrap","core"]'&&P.weapons.indexOf('smg')>=0&&P.weapons.indexOf('pistol')>=0&&P.equipped==='smg'&&P.lifeEarn===7000&&P.acctName==='ozzrik','NINE: the old save lost cash, stash, guns or earnings (credits '+P.credits+', stash '+JSON.stringify(P.stash)+', guns '+JSON.stringify(P.weapons)+', lifetime '+P.lifeEarn+')');
       need(JSON.stringify(P.contracts)===JSON.stringify(snap.contracts)&&JSON.stringify(P.forged)===JSON.stringify(snap.forged),'NINE: contracts or forged guns moved');
       need(P.pil&&P.pil.name==='ozzrik'&&P.pil.gen===2&&P.pil.raids===5&&P.pil.kills===3&&P.pil.traits.length===0&&P.pil.num===1&&pilName(P.pil)==='ozzrik'&&P.pilGen===2&&P.hall.length===1&&P.hall[0].name==='vosk'&&P.heirs===undefined,'NINE: the lineage reads '+JSON.stringify(P.pil)+' hall '+JSON.stringify(P.hall)+' heirs '+JSON.stringify(P.heirs));
       snap=JSON.parse(JSON.stringify(P)); load(snap);
       need(JSON.stringify(P.pil)===JSON.stringify(snap.pil)&&JSON.stringify(P.hall)===JSON.stringify(snap.hall)&&P.credits===4321&&P.pilGen===2&&P.lifeEarn===7000,'NINE: a second load moved it: '+JSON.stringify(P.pil));
     }catch(e2){ bad.push('threw: '+(e2&&e2.message||e2)); }
     finally{
       try{ ARCADE.on=false; }catch(_a){}
       P=saved; storeSet=oldStore; saveProfile=oldSave;
       keys=kk; Object.assign(mouse,mm); Object.assign(NET,nk); Object.assign(PAD,pk);
       for(k in CFG) if(!(k in cp)) delete CFG[k]; Object.assign(CFG,cp);
       try{ if(tmp&&tmp.parentNode) tmp.parentNode.removeChild(tmp); else if(sg) renderStatCards(); }catch(_s){}
       try{ if(G&&G.player) G.player.wm=null; }catch(_g){}
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'37.29',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
