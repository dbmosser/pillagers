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

if ($s.Contains("  {v:'37.19',what:")) { throw "check 37.19 is in the fixture already" }

SubRx @'
  {v:'37.18',what:
'@ @'
  {v:'37.19',what:'cw-m1xpoff, his order of 11-01 (lets get rid of the concept of xp altogether, everything you can get, you have to buy with cash; plan m1): an old save is paid once in $ for every ladder reward it earned since m0 and never claimed, marked claimed, added to lifetime earnings, the hub line added to an unshown note and said once; a second load pays nothing; a new save pays nothing; a full extraction leaves the saved XP as it was and banks SP on the career board as before; the raid end card, the Mainframe tabs and the corner readout print no xp and no lvl; level and board gated looks are open',
   run:function(){
     if(!(window.__runPrep&&window.__resetCfg&&window.__pinDefaults&&window.__cleanProfile&&window.__deploy&&window.__endRaid&&window.__state)) return 'SKIP: this fixture cannot stage';
     if(typeof applyLoadedProfile!=='function'||typeof SEASON_TIERS==='undefined'||typeof hubToast!=='function'||typeof ladderRewardCash!=='function'||typeof openOps!=='function'||typeof syncTopRight!=='function') return 'SKIP: no loader, ladder, Mainframe or corner here';
     var saved=P, cfg={}, k, oldStore=storeSet, oldSave=saveProfile, oldToast=hubToast, d0=DMUL_ON, c0=CAREER_ON, toasts=[], bad=[], base, snap, exp, o, g, t, i, cl, cut, el;
     function need(ok,msg){ if(!ok) bad.push(msg); }
     function oldSave3717(over){
       // a save as v37.17 writes it: m0 has run (mig0p), the XP ladder payout stamp of this build is not there yet
       var s=JSON.parse(JSON.stringify(base)), q;
       delete s.mig1x; delete s.szNote; s.mig0p=1;
       for(q in over) if(Object.prototype.hasOwnProperty.call(over,q)) s[q]=over[q];
       return s;
     }
     function load(s){ applyLoadedProfile({value:JSON.stringify(s)}); }
     function noXp(where,txt){ var m=/\b(xp|lvl)\b/i.exec(String(txt||'')); if(m) bad.push(where+' still prints "'+m[0]+'": ...'+String(txt).slice(Math.max(0,m.index-50),m.index+30).replace(/\s+/g,' ')+'...'); }
     for(k in CFG) cfg[k]=CFG[k];
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       storeSet=function(){}; saveProfile=function(){}; hubToast=function(t){ toasts.push(String(t)); };
       base=JSON.parse(JSON.stringify(P)); base.cfg=JSON.parse(JSON.stringify(CFG)); base.cfgv=18;
       exp=ladderRewardCash(SEASON_TIERS[3])+ladderRewardCash(SEASON_TIERS[4]);
       if(!(exp>0)||!(SEASON_TIERS[4].sp<=65000)||!(SEASON_TIERS[5].sp>65000)) return 'control: rewards 4 and 5 are not the two rewards a save at 65000 xp reaches past 3 ('+exp+')';
       // ONE: rewards 1 to 3 claimed, 4 and 5 earned since m0 and never claimed
       snap=oldSave3717({pname:'ozzrik',credits:1000,xp:65000,spClaimed:[0,1,2],lifeEarn:5000,netEarn:2500,stash:['scrap','core'],weapons:['pistol','smg'],equipped:'smg'});
       load(snap);
       need(P.credits===1000+exp,'ONE: credits '+P.credits+', not 1000 + '+exp+' paid for the two unclaimed rewards');
       cl=(P.spClaimed||[]).slice().sort(); need(JSON.stringify(cl)===JSON.stringify([0,1,2,3,4]),'ONE: claimed rewards read '+JSON.stringify(P.spClaimed)+', not 0 to 4');
       need(P.lifeEarn===5000+exp,'ONE: lifetime earnings '+P.lifeEarn+', not 5000 + '+exp);
       need(P.szNote&&P.szNote.c===exp&&P.szNote.n===2&&!P.szNote.shown,'ONE: the hub line was not queued: '+JSON.stringify(P.szNote));
       need(P.mig1x===1,'ONE: the save is not stamped (mig1x '+P.mig1x+')');
       need(P.xp===65000&&P.netEarn===2500&&JSON.stringify(P.stash)===JSON.stringify(['scrap','core'])&&P.weapons.indexOf('smg')>=0&&P.equipped==='smg','ONE: something else moved (xp '+P.xp+', net '+P.netEarn+', stash '+JSON.stringify(P.stash)+', guns '+JSON.stringify(P.weapons)+')');
       need(P.pil&&P.pil.gen===1&&P.mig0p===1,'ONE: the m0 records moved: '+JSON.stringify(P.pil));
       toasts=[];
       try{ showScreen('hub'); }catch(_sh){}
       try{ showScreen('hub'); }catch(_sh2){}
       o=toasts.filter(function(t){ return /unclaimed/.test(t); });
       need(o.length===1&&o[0]==='$'+exp.toLocaleString()+' paid for unclaimed rewards','ONE: the hub said '+JSON.stringify(o)+', not $'+exp+' paid for unclaimed rewards once');
       // TWO: the same save loaded again pays nothing more
       snap=JSON.parse(JSON.stringify(P)); load(snap);
       need(P.credits===1000+exp&&P.lifeEarn===5000+exp&&(P.spClaimed||[]).length===5,'TWO: a second load moved it (credits '+P.credits+', lifetime '+P.lifeEarn+', claimed '+JSON.stringify(P.spClaimed)+')');
       // THREE: an m0 line not yet shown is added to, not replaced
       snap=oldSave3717({credits:0,xp:65000,spClaimed:[0,1,2],lifeEarn:100}); snap.szNote={c:300,n:1,shown:0};
       load(snap);
       need(P.szNote&&P.szNote.c===300+exp&&P.szNote.n===3&&!P.szNote.shown&&P.lifeEarn===100+exp,'THREE: the unshown note reads '+JSON.stringify(P.szNote)+' and lifetime '+P.lifeEarn);
       // FOUR: a save from this build (born set) pays nothing
       snap=oldSave3717({credits:900,xp:65000,spClaimed:[],lifeEarn:0}); snap.mig1x=1;
       load(snap);
       need(P.credits===900&&(P.spClaimed||[]).length===0&&P.lifeEarn===0&&!P.szNote,'FOUR: a new save was paid (credits '+P.credits+', claimed '+JSON.stringify(P.spClaimed)+', lifetime '+P.lifeEarn+')');
       // FIVE: a full extraction keeps the saved XP and banks SP as before; the card prints no xp and no lvl
       DMUL_ON=0; CAREER_ON=1; P.cond='day'; P.terms=[]; P.merc=''; P.xp=4321;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242}); g=__state();
       if(!g||!g.player||g.over) throw new Error('no live raid');
       g.career=1; g.cs={s:1000,k:0,b:{kill:1000}}; g.bag=['core']; g.carriedIn=0; g.pedCarry=0; g.player.downed=false; g.player.hp=100;
       __endRaid('extract');
       if(typeof pendingRun!=='undefined'&&pendingRun&&!pendingRun._committed&&typeof commitRun==='function') commitRun(pendingRun);
       need(P.xp===4321,'FIVE: an extraction moved the saved XP to '+P.xp);
       need(g.careerLb&&g.careerLb.score===2000,'FIVE: the career board banked '+(g.careerLb&&g.careerLb.score)+' SP, not 2000');
       el=document.getElementById('oc_manifest');
       need(el&&(el.textContent||'').length>20,'FIVE: control: no raid end card was drawn');
       noXp('the extracted card',el&&el.textContent);
       // SIX: the Mainframe, through openOps, every tab; the never opened rewards pane is left out
       for(i=0;i<3;i++){
         openOps(['con','mf','rec'][i]);
         cut=document.getElementById('opmodal').cloneNode(true); o=cut.querySelector('#opane_rew'); if(o) o.parentNode.removeChild(o);
         t=cut.textContent||'';
         need(t.length>20,'SIX: control: the Mainframe drew nothing');
         noXp('the Mainframe ('+['contracts','racks','your stats'][i]+')',t);
       }
       need(document.querySelector('#optabs [data-optab="rew"]')===null,'SIX: the rewards tab is still on the Mainframe');
       try{ document.getElementById('opmodal').classList.remove('on'); }catch(_om){}
       // SEVEN: the corner readout
       _trLast=''; syncTopRight();
       noXp('the corner readout',(document.getElementById('topright')||{}).textContent);
       // EIGHT: a look gated on the level or the reward board is open at level 1 with nothing claimed
       P.xpLevel=1; P.spClaimed=[]; P.cosAll=false;
       o=COSMETICS.filter(function(c){ var h=String(c.how); return h.indexOf('level:')===0||h.indexOf('board:')===0; });
       need(o.length>0,'EIGHT: control: no level gated looks');
       for(i=0;i<o.length;i++) if(!cosOwned(o[i])) bad.push('EIGHT: '+o[i].name+' ('+o[i].how+') is still locked');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ g=__state(); if(g&&!g.over){ g.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       DMUL_ON=d0; CAREER_ON=c0;
       P=saved; storeSet=oldStore; saveProfile=oldSave; hubToast=oldToast;
       for(k in CFG) if(!(k in cfg)) delete CFG[k]; for(k in cfg) CFG[k]=cfg[k];
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'37.18',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
