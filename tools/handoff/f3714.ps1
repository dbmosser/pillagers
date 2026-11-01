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

if ($s.Contains("  {v:'37.14',what:")) { throw "check 37.14 is in the fixture already" }

SubRx @'
  {v:'37.13',what:
'@ @'
  {v:'37.14',what:'cw-p0acct, his progression plan of 11-01 (m0 foundation; old saves paid out, his ok sure): an old save loads with nothing lost, every XP ladder reward it earned and never claimed paid once as $ (cash, kits at item value, a gun at its stash value) and marked claimed, lifetime earnings seeded from what it extracted plus every $ the ladder paid, the character it plays is generation one with its raids, extracts, kills and best haul, the hub says $N paid for unclaimed rewards once and never in the demo; a second load pays nothing; a new profile pays nothing; a pillager can end into the hall and the next is generation two with cash and lifetime earnings untouched',
   run:function(){
     if(!(window.__runPrep&&window.__resetCfg&&window.__pinDefaults&&window.__cleanProfile)) return 'SKIP: this fixture cannot stage';
     if(typeof applyLoadedProfile!=='function'||typeof SEASON_TIERS==='undefined'||typeof hubToast!=='function') return 'SKIP: no loader, ladder or hub toast here';
     if(typeof seasonZeroMig!=='function'||typeof acctEnsure!=='function'||typeof pilEnd!=='function'||typeof pilBirth!=='function'||typeof lifeEarnAdd!=='function'||typeof szNoteShow!=='function') return 'no season zero account records in this build (seasonZeroMig, acctEnsure, pilEnd, pilBirth, lifeEarnAdd, szNoteShow)';
     var saved=P, cfg={}, k, oldStore=storeSet, oldSave=saveProfile, oldToast=hubToast, toasts=[], bad=[], base, snap, o, r, hallN;
     function need(ok,msg){ if(!ok) bad.push(msg); }
     function oldSave3713(over){
       // a save as v37.13 writes it: no season zero fields at all
       var s=JSON.parse(JSON.stringify(base)), q;
       ['mig0p','lifeEarn','pil','hall','pilGen','acctName','szNote'].forEach(function(f){ delete s[f]; });
       for(q in over) if(Object.prototype.hasOwnProperty.call(over,q)) s[q]=over[q];
       return s;
     }
     function load(s){ applyLoadedProfile({value:JSON.stringify(s)}); }
     for(k in CFG) cfg[k]=CFG[k];
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       storeSet=function(){}; saveProfile=function(){}; hubToast=function(t){ toasts.push(String(t)); };
       base=JSON.parse(JSON.stringify(P)); base.cfg=JSON.parse(JSON.stringify(CFG)); base.cfgv=18;
       // ONE: an old save with reward 2 ($800) claimed and rewards 1 and 3 earned but unclaimed (5 bandages and an ammo box 390, 2 frags and 2 ammo boxes 540)
       snap=oldSave3713({pname:'ozzrik',credits:1234,xp:30000,spClaimed:[1],runs:17,ext:9,died:8,best:4321,achN:{raider:5,mach:22},netEarn:2500,
         log:[{outcome:'extract',haul:3000,pedSold:200},{outcome:'dead',haul:999},{outcome:'extract',haul:1100}],
         stash:['scrap','core','frag'],weapons:['pistol','smg'],equipped:'smg'});
       load(snap);
       need(P.credits===1234+930,'ONE: credits '+P.credits+', not 1234 + 930 paid for the two unclaimed rewards');
       need(JSON.stringify((P.spClaimed||[]).slice().sort())===JSON.stringify([0,1,2]),'ONE: claimed rewards read '+JSON.stringify(P.spClaimed)+', not 0, 1 and 2');
       need(P.lifeEarn===4300+800+930,'ONE: lifetime earnings '+P.lifeEarn+', not 4300 extracted + 800 the ladder paid + 930 paid now');
       need(JSON.stringify(P.stash)===JSON.stringify(['scrap','core','frag']),'ONE: the stash changed: '+JSON.stringify(P.stash));
       need(P.weapons.indexOf('smg')>=0&&P.weapons.indexOf('pistol')>=0&&P.equipped==='smg','ONE: the guns changed: '+JSON.stringify(P.weapons)+' in hand '+P.equipped);
       need(P.xp===30000&&P.runs===17&&P.ext===9&&P.best===4321&&P.netEarn===2500,'ONE: a career counter moved (xp '+P.xp+', runs '+P.runs+', ext '+P.ext+', best '+P.best+', net '+P.netEarn+')');
       r=P.pil||{};
       need(r.name==='ozzrik'&&r.gen===1&&r.raids===17&&r.ext===9&&r.kills===27&&r.best===4321&&r.lvl===1&&Array.isArray(r.traits)&&Array.isArray(r.picks),'ONE: the character is not generation one with its record: '+JSON.stringify(r));
       need(P.acctName==='ozzrik'&&Array.isArray(P.hall)&&P.hall.length===0&&P.pilGen===1&&P.mig0p===1,'ONE: account name '+P.acctName+', hall '+JSON.stringify(P.hall)+', pilGen '+P.pilGen+', mig0p '+P.mig0p);
       need(P.szNote&&P.szNote.c===930&&P.szNote.n===2&&!P.szNote.shown,'ONE: the hub line was not queued: '+JSON.stringify(P.szNote));
       // TWO: the hub says it once, through the hub arrival
       toasts=[];
       try{ showScreen('hub'); }catch(_sh){}
       try{ showScreen('hub'); }catch(_sh2){}
       o=toasts.filter(function(t){ return /unclaimed/.test(t); });
       need(o.length===1&&o[0]==='$930 paid for unclaimed rewards','TWO: the hub said '+JSON.stringify(o)+', not $930 paid for unclaimed rewards once');
       need(P.szNote&&P.szNote.shown===1,'TWO: the line is not marked shown');
       // THREE: the same save loaded again pays nothing more
       snap=JSON.parse(JSON.stringify(P)); load(snap);
       need(P.credits===2164&&P.lifeEarn===6030&&P.pil&&P.pil.gen===1&&P.pil.raids===17,'THREE: a second load moved it (credits '+P.credits+', lifetime '+P.lifeEarn+', pil '+JSON.stringify(P.pil)+')');
       // FOUR: a later reward and a gun: xp 65000 with nothing claimed pays 390 + 800 + 540 + 600 (2 medkits, 3 bandages) + 300 (the backup pistol at its stash value)
       snap=oldSave3713({pname:'vell',credits:0,xp:65000,spClaimed:[],netEarn:9000,log:[],achN:{}});
       load(snap);
       need(P.credits===2630&&P.lifeEarn===9000+2630,'FOUR: credits '+P.credits+' and lifetime '+P.lifeEarn+', not 2630 and 11630');
       need(P.szNote&&P.szNote.c===2630,'FOUR: queued '+JSON.stringify(P.szNote));
       toasts=[]; P.szNote.shown=0;
       ARCADE.on=true; try{ szNoteShow(); } finally{ ARCADE.on=false; }
       need(!toasts.length&&!P.szNote.shown,'FOUR: the demo said it: '+JSON.stringify(toasts));
       szNoteShow();
       need(toasts.length===1&&toasts[0]==='$2,630 paid for unclaimed rewards','FOUR: the hub said '+JSON.stringify(toasts));
       // FIVE: a profile from this build (born set) has nothing to pay, and still has its generation one
       snap=oldSave3713({pname:'newb',credits:900,xp:65000,spClaimed:[]}); snap.mig0p=1; snap.lifeEarn=0;
       load(snap);
       need(P.credits===900&&(P.spClaimed||[]).length===0&&P.lifeEarn===0&&!P.szNote,'FIVE: a new profile was paid (credits '+P.credits+', claimed '+JSON.stringify(P.spClaimed)+', lifetime '+P.lifeEarn+')');
       need(P.pil&&P.pil.gen===1&&P.pil.name==='newb'&&P.pilGen===1&&P.acctName==='newb','FIVE: no generation one: '+JSON.stringify(P.pil));
       // SIX: a pillager ends into the hall and the next is generation two; cash and lifetime earnings stay
       P.credits=777; P.lifeEarn=5000; P.pil.kills=4;
       r=pilEnd(P,{outcome:'dead',by:'crawler'});
       hallN=P.hall.length;
       need(r&&hallN===1&&P.hall[0].name==='newb'&&P.hall[0].gen===1&&P.hall[0].kills===4&&P.hall[0].end&&P.hall[0].end.by==='crawler'&&P.hall[0].end.outcome==='dead'&&P.pil===null,'SIX: the hall reads '+JSON.stringify(P.hall)+' and the living pillager '+JSON.stringify(P.pil));
       r=pilBirth(P,'brakka');
       need(r&&P.pil.name==='brakka'&&P.pil.gen===2&&P.pilGen===2&&P.pil.kills===0&&P.credits===777&&P.lifeEarn===5000&&P.acctName==='newb','SIX: the heir reads '+JSON.stringify(P.pil)+' (credits '+P.credits+', lifetime '+P.lifeEarn+', account '+P.acctName+')');
       snap=JSON.parse(JSON.stringify(P)); load(snap);
       need(P.pil&&P.pil.gen===2&&P.hall.length===1&&P.pilGen===2,'SIX: the lineage did not survive a reload: '+JSON.stringify(P.pil)+' hall '+P.hall.length);
       // SEVEN: lifetime earnings only go up
       lifeEarnAdd(250); lifeEarnAdd(-90); lifeEarnAdd(0);
       need(P.lifeEarn===5250,'SEVEN: lifetime earnings '+P.lifeEarn+', not 5250 after +250 and a refused -90');
       // EIGHT: a restore code carries lifetime earnings
       if(typeof restoreMake==='function'){ o=restoreMake(); o=(typeof o==='string')?null:o; if(o&&typeof o==='object') need(o.le===5250,'EIGHT: the restore code carries '+o.le+' lifetime earnings'); }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ ARCADE.on=false; }catch(_a){}
       P=saved; storeSet=oldStore; saveProfile=oldSave; hubToast=oldToast;
       for(k in CFG) if(!(k in cfg)) delete CFG[k]; for(k in cfg) CFG[k]=cfg[k];
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'37.13',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
