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

if ($s.Contains("  {v:'37.40',what:")) { throw "check 37.40 is in the fixture already" }

SubRx @'
  {v:'37.39',what:
'@ @'
  {v:'37.40',what:'cw-nospcash, his ruling of 11-01 (most the money should come from selling gear): a career extraction banks the extraction bonus and not the raid score, the score itself still reads x2, the money total is the haul, a death banks nothing, and neither card has a credits row',
   run:function(){
     if(!(window.__runPrep&&window.__topClear&&window.__resetCfg&&window.__pinDefaults&&window.__cleanProfile&&window.__deploy&&window.__state&&window.__endRaid&&window.__P)) return 'SKIP: this fixture cannot stage';
     if(typeof extractBonusFor!=='function') return 'SKIP: no extraction bonus in this build';
     var d0=DMUL_ON, c0=CAREER_ON, saved=P, snap0=JSON.stringify(P), oldStore=storeSet, oldSave=saveProfile, g=null, q=null, bad=[], cash, lg, sec, strip, totEl;
     function need(ok,msg){ if(!ok) bad.push(msg); }
     function done(){ if(typeof pendingRun!=='undefined'&&pendingRun&&!pendingRun._committed&&typeof commitRun==='function') commitRun(pendingRun); }
     function raid(s){
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       DMUL_ON=0; CAREER_ON=1; q=__P(); q.cond='day'; q.wxPick='clear'; q.terms=[]; q.merc=''; q.racks=0; q.arrays=0;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242}); g=__state();
       if(!g||!g.player||g.over) throw new Error('no live raid');
       g.career=1; g.terms=[]; g.wx=WEATHER.filter(function(w){return w.id==='clear';})[0];
       g.cs={s:s,k:0,b:{kill:s}}; g.bag=['core']; g.carriedIn=0; g.carriedKit=[]; g.issuedBandages=0; g.pedCarry=0; g.pedSold=0; g.strayPaid=0; g.goalRewards=null;
       g.player.downed=false; g.player.hp=100; g.player.iv=99; g.ents.length=0; q.credits=10000;
     }
     try{
       storeSet=function(){}; saveProfile=function(){};
       raid(1000);
       __endRaid('extract'); done();
       cash=q.credits-10000;
       lg=document.querySelector('#oc_manifest .lg');
       if(!lg) return 'the career extraction card has no ledger';
       strip=document.querySelector('#oc_manifest .haulstrip'); sec=strip?(+strip.getAttribute('data-sec')||0):0;
       if(!(sec>0)) return 'control: the haul strip carries no value';
       need(cash===extractBonusFor(sec),'an extraction moved the account by $'+cash+', not the bonus $'+extractBonusFor(sec)+' on a haul of $'+sec);
       need(g.careerLb&&g.careerLb.score===2000,'the raid score is '+(g.careerLb&&g.careerLb.score)+', not 2000 (1000 x2)');
       need(!lg.querySelector('.lgr.cr'),'the money panel still has a credits banked row');
       need(!/credits (not )?banked/i.test(lg.textContent||''),'the extraction card still talks about credits banked');
       totEl=lg.querySelector('.lgpm .lgr.tot [data-to]');
       need(totEl&&(+totEl.getAttribute('data-to'))===sec,'the money total is '+(totEl&&totEl.getAttribute('data-to'))+', not the haul '+sec);
       __endRaid('abandon'); done();
       raid(400);
       __endRaid('dead'); done();
       cash=q.credits-10000;
       need(cash===0,'a death moved the account by $'+cash);
       lg=document.querySelector('#oc_manifest .lg');
       if(!lg) bad.push('the career death card has no ledger');
       else {
         need(!/credits (not )?banked/i.test(lg.textContent||''),'the death card still talks about credits not banked');
         need((lg.textContent||'').indexOf('LOST')>=0,'the death card no longer says LOST');
       }
     }catch(e2){ bad.push('threw: '+(e2&&e2.message||e2)); }
     finally{
       try{ if(g&&!g.over){ g.player.downed=false; __endRaid('abandon'); done(); } }catch(_e){}
       DMUL_ON=d0; CAREER_ON=c0; P=saved;
       (function(){ var n, s=JSON.parse(snap0); for(n in P) if(Object.prototype.hasOwnProperty.call(P,n)) delete P[n]; for(n in s) P[n]=s[n]; })();
       storeSet=oldStore; saveProfile=oldSave;
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'37.39',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
