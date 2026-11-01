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

if ($s.Contains("  {v:'37.25',what:")) { throw "check 37.25 is in the fixture already" }

SubRx @'
  {v:'37.24',what:
'@ @'
  {v:'37.25',what:'cw-m1nocash, his rulings of 11-01 (no cash in riads, keep it like a credit card; contracts pay in gear and items to sell; racks pay materials instead of $; his pick 36, an extraction bonus of about 10% of the haul): an extraction pays exactly round(haul x 0.10) onto the account and into lifetime earnings and the card says extraction bonus; a death pays no bonus and no $; racks pay rack parts worth what they paid and no $; a stall sale is banked at the sale and a death keeps it; the survivor pays salvage into the backpack and no $; a claimed contract pays salvage and a spare gun to the stash and no $; an old save loads twice with nothing moved',
   run:function(){
     if(!(window.__runPrep&&window.__resetCfg&&window.__pinDefaults&&window.__cleanProfile&&window.__deploy&&window.__endRaid&&window.__state)) return 'SKIP: this fixture cannot stage';
     if(typeof applyLoadedProfile!=='function'||typeof lifeEarnNow!=='function'||typeof pedSellAll!=='function'||typeof strayGive!=='function'||typeof claimContractAt!=='function') return 'SKIP: no loader, lifetime earnings, stall, survivor or contracts here';
     var saved=P, cfg={}, k, oldStore=storeSet, oldSave=saveProfile, d0=DMUL_ON, bad=[], g, c0, l0, s0, exp, el, t, i, v, n, haul, snap, W, c, r, MATS={scrap:1,wire:1,cell:1,board:1};
     function need(ok,msg){ if(!ok) bad.push(msg); }
     function worth(L){ var s=0; for(var q=0;q<L.length;q++) s+=ival(L[q]); return s; }
     function mats(L){ var o=[]; for(var q=0;q<L.length;q++) if(MATS[L[q]]) o.push(L[q]); return o; }
     function cardText(){ var e=document.getElementById('oc_manifest'); return String((e&&e.textContent)||''); }
     function up(bag){
       __deploy({kit:[],safe:null,mapIx:0,seed:4242}); var q=__state();
       if(!q||!q.player||q.over) throw new Error('no live raid');
       q.bag=bag.slice(); q.carriedIn=0; q.carriedKit=[]; q.issuedBandages=0; q.pedCarry=0; q.pedSold=0; q.strayPaid=0; q.goalRewards=null;
       q.player.downed=false; q.player.hp=100; q.ents.length=0; q.player.iv=99;
       return q;
     }
     function done(){ if(typeof pendingRun!=='undefined'&&pendingRun&&!pendingRun._committed&&typeof commitRun==='function') commitRun(pendingRun); }
     for(k in CFG) cfg[k]=CFG[k];
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       storeSet=function(){}; saveProfile=function(){};
       DMUL_ON=0; P.cond='day'; P.terms=[]; P.merc=''; P.racks=2; P.arrays=0;
       haul=ival('core')+ival('titan'); exp=Math.round(haul*0.10);
       if(!(exp>0)) return 'control: core and titan are worth nothing here';
       // ONE: an extraction pays the bonus and nothing else in $; the racks pay parts
       g=up(['core','titan']); c0=P.credits||0; l0=lifeEarnNow(); s0=P.stash.slice();
       __endRaid('extract'); done();
       need((P.credits||0)-c0===exp,'ONE: an extraction moved credits by '+((P.credits||0)-c0)+', not the bonus '+exp+' (10% of '+haul+')');
       need(lifeEarnNow()-l0===exp,'ONE: lifetime earnings moved by '+(lifeEarnNow()-l0)+', not '+exp);
       t=cardText().toLowerCase();
       need(t.length>20,'ONE: control: no raid end card');
       need(t.indexOf('extraction bonus +$'+exp.toLocaleString())>=0,'ONE: the card has no "extraction bonus +$'+exp+'" line');
       v=worth(mats(P.stash))-worth(mats(s0));
       need(v>400-ival('scrap')&&v<=400,'ONE: two racks paid parts worth $'+v+', not about $400');
       // TWO: a death on the same staging pays no bonus, no $ and no parts
       g=up(['core','titan']); c0=P.credits||0; l0=lifeEarnNow(); s0=P.stash.slice();
       __endRaid('dead'); done();
       need((P.credits||0)===c0&&lifeEarnNow()===l0,'TWO: a death moved credits by '+((P.credits||0)-c0)+' and lifetime by '+(lifeEarnNow()-l0));
       need(cardText().toLowerCase().indexOf('extraction bonus')<0,'TWO: the death card shows an extraction bonus');
       need(worth(mats(P.stash))===worth(mats(s0)),'TWO: a death paid rack parts');
       // THREE: a stall sale is banked at the sale and a death keeps it
       g=up(['core']); g.trade={x:g.player.x,y:g.player.y,stock:[],traded:0};
       c0=P.credits||0; l0=lifeEarnNow(); n=Math.round(((typeof sellPriceOf==='function')?sellPriceOf('core'):ival('core'))*pedBuyRate());
       pedSellAll();
       need((P.credits||0)-c0===n&&lifeEarnNow()-l0===n,'THREE: a stall sale banked '+((P.credits||0)-c0)+' and lifetime '+(lifeEarnNow()-l0)+', not '+n+' at the sale');
       need(!g.pedCarry,'THREE: the raid still holds stall money ('+g.pedCarry+')');
       g.trade=null; __endRaid('dead'); done();
       need((P.credits||0)-c0===n,'THREE: the death took the stall money (credits moved '+((P.credits||0)-c0)+')');
       need(cardText().toLowerCase().indexOf('stall sales')>=0,'THREE: the death card has no stall sales line');
       // FOUR: the survivor pays salvage into the backpack, no $
       g=up(['medkit']); c0=P.credits||0;
       strayGive({want:'medkit',x:g.player.x+20,y:g.player.y,helped:0});
       need((P.credits||0)===c0,'FOUR: the survivor paid $'+((P.credits||0)-c0));
       v=worth(g.bag)-ival(g.strayGave||'');
       need(!!g.strayGave&&v>900-ival('scrap')&&v<=1500,'FOUR: the survivor put salvage worth $'+v+' in the backpack ('+JSON.stringify(g.bag)+'), not $900 to $1500');
       g.player.downed=false; __endRaid('abandon'); done();
       // FIVE: a claimed contract pays salvage and a spare gun, no $
       W=null; for(k in WEAPONS) if(ITEMS['gun_'+k]&&k!=='fists'){ W=k; break; }
       c=P.contracts&&P.contracts[0];
       if(!W||!c) bad.push('FIVE: control: no gun or no contract to stage');
       else {
         if(P.weapons.indexOf(W)<0) P.weapons.push(W);
         c.reward=1000; c.prog=c.n; c.gear={kind:'wep',k:W};
         c0=P.credits||0; s0=P.stash.length;
         r=claimContractAt(0);
         t=P.stash.slice(s0);
         need(!!r,'FIVE: the claim refused');
         need((P.credits||0)===c0,'FIVE: the contract paid $'+((P.credits||0)-c0));
         need(t.indexOf('gun_'+W)>=0,'FIVE: the spare gun did not go to the stash ('+JSON.stringify(t)+')');
         v=worth(t)-ival('gun_'+W);
         need(v>1000-ival('scrap')&&v<=1000,'FIVE: the contract paid salvage worth $'+v+', not about $1000');
       }
       // SIX: an old save (nothing new is saved) loads twice with nothing moved
       snap=JSON.parse(JSON.stringify(P)); snap.cfg=JSON.parse(JSON.stringify(CFG)); snap.cfgv=18;
       for(i=0;i<2;i++){
         applyLoadedProfile({value:JSON.stringify(snap)});
         need(P.credits===snap.credits&&JSON.stringify(P.stash)===JSON.stringify(snap.stash)&&JSON.stringify(P.contracts)===JSON.stringify(snap.contracts)&&P.lifeEarn===snap.lifeEarn&&JSON.stringify(P.weapons)===JSON.stringify(snap.weapons)&&P.racks===snap.racks,'SIX: load '+(i+1)+' moved the save (credits '+P.credits+' vs '+snap.credits+', stash '+P.stash.length+' vs '+snap.stash.length+', lifetime '+P.lifeEarn+' vs '+snap.lifeEarn+')');
         snap=JSON.parse(JSON.stringify(P));
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ g=__state(); if(g&&!g.over){ g.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       DMUL_ON=d0;
       P=saved; storeSet=oldStore; saveProfile=oldSave;
       for(k in CFG) if(!(k in cfg)) delete CFG[k]; for(k in cfg) CFG[k]=cfg[k];
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'37.24',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
