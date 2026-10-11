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

if ($s.Contains("  {v:'23.49',what:")) { throw "check 23.49 is in the fixture already" }

SubRx @'
  {v:'23.48',what:
'@ @'
  {v:'23.49',what:'arcade25, his yes 2026-10-11: valuables ignore a full backpack, in an arcade raid with the backpack at its cap a box holding only valuables is opened by walking over it, scores into the team score, says no BACKPACK FULL and leaves the backpack as it was, with autoloot on nothing is shed for it and its ammo reaches the reserve, a box holding a Bandage is still refused, and in a normal raid the full backpack still refuses a valuables box',
   run:function(){
     var bad=[], g=null, g2=null, p, ct=null, said=[], realSay=say, ownSay=false, cap0=PACKCAP.slice(), ownCap=false, al0=P.autoloot,
         vals=[], ammo=null, k, bag0, mine0, pot0, res0, exp, i, nB='band'+'age', BF='BACKPACK'+' FULL';
     function full(gg){ var n=0; gg.bag.length=0; while(n<6){ gg.bag.push(nB); n++; } PACKCAP[P.pack|0]=bagWeight(); ownCap=true; }
     function place(gg){
       var j, c, pl=gg.player;
       for(j=0;j<gg.containers.length&&j<400;j++){ c=gg.containers[j];
         if(c.opened||c.dropped||c.mercSrc||c.strong||c.cache||c.auto||c.netBy>=0) continue;
         c.loot=[]; pl.x=c.x; pl.y=c.y; if(pl.vx!==undefined){ pl.vx=0; pl.vy=0; } keys={};
         __sim(0.02);
         if(gg.nearContainer===c) return c; }
       return null; }
     function arm(c,loot){ c.loot=loot.slice(); c.opened=false; c.prog=0; c.pulled=0; c.time=0.3; G.searching=null; G.searchT=0; said.length=0; }
     function run(gg,c,n){ var f; for(f=0;f<n&&!c.opened;f++){ gg.player.x=c.x; gg.player.y=c.y; __sim(0.05); } }
     function saidFull(){ return said.indexOf(BF)>=0; }
     try{
       __topClear(); __runPrep();
       if(typeof arcadeDeploy!=='function'||typeof ARCADE!=='object') return 'no arcadeDeploy in this build';
       if(typeof arcadeLoot!=='function') return 'no arcade walk-over loot in this build';
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(!ITEMS[nB]) return 'SKIP: no Bandage item';
       for(k in ITEMS){ if(!ITEMS[k].use&&ival(k)>0&&vals.length<2) vals.push(k); if(!ammo&&ITEMS[k].use==='ammo'&&(ITEMS[k].amt|0)>0) ammo=k; }
       if(vals.length<2||!ammo) return 'SKIP: no valuable or ammo items to stage';
       if(__state()&&!__state().over) __endRaid('abandon');
       say=function(m){ said.push(String(m)); try{ return realSay.apply(this,arguments); }catch(_s){} }; ownSay=true;
       if(!arcadeDeploy({mapIx:0,seed:4242})||!__state()||!__state().arcade) return 'SKIP: arcadeDeploy built no arcade raid';
       try{ attStop(); }catch(_as){}
       g=__state(); p=g.player; ARCADE.holdT=0; ARCADE.waveT=0; ARCADE.ownAt=Date.now();
       if(!p||p.downed||p.dying||p.specOut) return 'SKIP: the arcade player is not standing';
       ct=place(g);
       if(!ct) return 'SKIP: no box in reach after placing the player on one';
       // 1. a full backpack, autoloot off, a box of valuables only: walked over, opened, scored, no BACKPACK FULL
       P.autoloot=false; full(g); bag0=JSON.stringify(g.bag);
       if(bagWeight()<PACKCAP[P.pack|0]) return 'SKIP: the backpack is not at its cap';
       arm(ct,vals); mine0=ARCADE.mine|0; pot0=ARCADE.pot|0; exp=0;
       for(i=0;i<vals.length;i++) exp+=Math.max(1,Math.round(ival(vals[i])/ARCADE_LOOT_DIV));
       run(g,ct,40);
       if(!ct.opened) bad.push('a valuables-only box was not opened by walking over it with a full backpack');
       if(saidFull()) bad.push('a valuables-only box said '+BF+' in the arcade');
       if((ARCADE.mine|0)-mine0<exp) bad.push('the valuables scored '+((ARCADE.mine|0)-mine0)+', expected '+exp);
       if((ARCADE.pot|0)-pot0<exp) bad.push('the pot rose '+((ARCADE.pot|0)-pot0)+', expected '+exp);
       if(JSON.stringify(g.bag)!==bag0) bad.push('the backpack changed: '+JSON.stringify(g.bag));
       // 2. autoloot on, valuables plus ammo: nothing shed, the ammo reaches the reserve
       P.autoloot=true; full(g); bag0=JSON.stringify(g.bag); res0=p.reserve|0;
       arm(ct,[vals[0],ammo]);
       run(g,ct,40);
       if(!ct.opened) bad.push('a valuables and ammo box was not opened with autoloot on and a full backpack');
       if(saidFull()) bad.push('a valuables and ammo box said '+BF+' with autoloot on');
       if(JSON.stringify(g.bag)!==bag0) bad.push('autoloot shed the backpack for a box that puts nothing in it: '+JSON.stringify(g.bag));
       if((p.reserve|0)-res0<(ITEMS[ammo].amt|0)) bad.push('the ammo did not reach the reserve ('+res0+' to '+(p.reserve|0)+')');
       // 3. a box with a Bandage in it is still refused
       P.autoloot=false; full(g); bag0=JSON.stringify(g.bag);
       arm(ct,[vals[0],nB]);
       if(arcadeBagFree(ct)) bad.push('arcadeBagFree passed a box holding a Bandage');
       run(g,ct,20);
       if(ct.opened) bad.push('a box holding a Bandage was opened with a full backpack');
       if(!saidFull()) bad.push('a box holding a Bandage did not say '+BF);
       try{ arcadeLeave(); }catch(_lv){}
       // 4. a normal raid: the full backpack still refuses a valuables box searched with X
       __topClear(); __runPrep();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g2=__state();
       if(!g2) return bad.length?bad.join('; '):'SKIP: __deploy built no raid';
       if(g2.arcade) bad.push('a normal raid is flagged arcade');
       ct=place(g2);
       if(!ct) return bad.length?bad.join('; '):'SKIP: no box in reach in the normal raid';
       P.autoloot=false; full(g2);
       arm(ct,vals);
       if(arcadeBagFree(ct)) bad.push('arcadeBagFree passed a box in a normal raid');
       for(i=0;i<15&&!ct.opened;i++){ g2.player.x=ct.x; g2.player.y=ct.y; keys['KeyX']=true; __sim(0.05); }
       keys['KeyX']=false;
       if(ct.opened) bad.push('a normal raid opened a valuables box with a full backpack');
       if(!saidFull()) bad.push('a normal raid did not say '+BF+' for a valuables box');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       if(ownSay){ try{ say=realSay; }catch(_r){} }
       if(ownCap){ try{ for(i=0;i<cap0.length;i++) PACKCAP[i]=cap0[i]; }catch(_c){} }
       try{ P.autoloot=al0; }catch(_a){}
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ if(typeof ARCADE==='object'){ ARCADE.mine=0; ARCADE.pot=0; ARCADE.holdT=0; ARCADE.waveT=0; ARCADE.ownAt=0; ARCADE.idleSaid=0; } }catch(_m){}
       try{ for(var kk in keys) keys[kk]=false; }catch(_k){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'23.48',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
