$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

SubRx @'
  {v:'15.83',what:
'@ @'
  {v:'15.84',what:'net lifetime earnings count stall money carried out: a run row that extracted with an empty backpack, nothing carried in and 5500 sold at the stall earns 5500 and a row that carried in 3000, sold 7150 and walked out with 200 earns 4350, while the same rows dead or abandoned earn 0, a plain extraction of 4000 with 1000 carried in still earns 3000 and a row with no stall figure still earns its haul; and on the play path three Titanium Cells sold at the Peddler stall then an extraction move the lifetime figure by the backpack left minus what the lift carried in plus the stall money the extraction banked into Credits, the same figure the run row records as sold (trade audit finding)',
   run:function(){
     if(typeof runEarnings!=='function'||typeof pedSellAll!=='function'||typeof ival!=='function'||typeof mkPeddler!=='function') return 'SKIP: no run earnings, stall sale, item values or Peddler in this build';
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P&&window.__applyLoaded)) return 'SKIP: this fixture cannot deploy, end a raid and restore the profile';
     if(typeof ITEMS==='undefined'||!ITEMS||!ITEMS.titan) return 'SKIP: no Titanium Cell in this build';
     if(typeof G!=='undefined'&&G&&G.sim) return 'SKIP: a sim is running';
     var bad=[], g=null, snap=null, keepEnts=null;
     // A later control that cannot run keeps a failure already found, so the old build fails rather than skips.
     var skip=function(m){ return bad.length?(bad.join('; ')+' (then SKIP: '+m+')'):('SKIP: '+m); };
     function earn(r){ try{ return runEarnings(r); }catch(_e){ return 'threw '+(_e&&_e.message||_e); } }
     try{
       // ONE, the sum itself, on rows shaped the way endRaid writes them.
       // CONTROL: a plain extraction and a row from before the stall figure, on either build.
       if(earn({outcome:'extract',haul:4000,carriedIn:1000})!==3000) return 'SKIP: a plain extraction of 4000 with 1000 carried in earned '+earn({outcome:'extract',haul:4000,carriedIn:1000})+' rather than 3000 here, so the sum cannot be read';
       if(earn({outcome:'extract',haul:500})!==500) return 'SKIP: a row with no carried-in or stall figure earned '+earn({outcome:'extract',haul:500})+' rather than its haul of 500 here';
       // CONTROL: stall money dies where he fell and stays behind when he walks away, on either build.
       var d1=earn({outcome:'dead',haul:0,carriedIn:0,pedSold:5500});
       if(d1!==0) bad.push('a run that died with 5500 of stall money on him earned '+d1+' rather than 0');
       var a1=earn({outcome:'abandon',haul:0,carriedIn:0,pedSold:5500});
       if(a1!==0) bad.push('a run abandoned with 5500 of stall money on him earned '+a1+' rather than 0');
       var d2=earn({outcome:'dead',haul:0,carriedIn:3000,pedSold:7150});
       if(d2!==-3000) bad.push('a run that carried in 3000 and died with 7150 of stall money on him earned '+d2+' rather than -3000');
       // THE FIX: the stall money an extraction banks counts.
       var e1=earn({outcome:'extract',haul:0,carriedIn:0,pedSold:5500});
       if(e1!==5500) bad.push('a run that sold 5500 at the stall and extracted with an empty backpack earned '+e1+' rather than 5500');
       var e2=earn({outcome:'extract',haul:200,carriedIn:3000,pedSold:7150});
       if(e2!==4350) bad.push('a run that carried in 3000, sold 7150 at the stall and extracted with 200 in the backpack earned '+e2+' rather than 4350');
       // TWO, the play path: a backpack sold at the Peddler stall, then an extraction that banks the money.
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       snap=JSON.parse(JSON.stringify(__P()));
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return skip('no live raid');
       var p=g.player, P2=__P();
       p.downed=false; p.dying=false;
       g.trade=null; g.pedLock=0; g.bagOpen=false; g.mapOpen=false;
       if((g.pedCarry||0)||(g.pedSold||0)) return skip('the raid landed with stall money already on him');
       // Only the Peddler beside him; three Titanium Cells found on the surface go into the backpack beside whatever the lift issued.
       keepEnts=g.ents.slice(); g.ents.length=0;
       var pd=mkPeddler(p.x+40,p.y,g.map); g.ents.push(pd);
       g.bag.push('titan'); g.bag.push('titan'); g.bag.push('titan');
       var carriedIn=g.carriedIn||0, credits0=P2.credits||0, net0=P2.netEarn||0, runs0=(P2.log||[]).length;
       // The stall open beside him, the way E opens it, and the whole backpack sold.
       g.trade=pd;
       pedSellAll();
       g.trade=null;
       var carry=g.pedCarry||0;
       // CONTROL: the sale put money on him, the same figure the raid tallies as sold, and the cells are gone from the backpack.
       if(!(carry>0)) return skip('selling the backpack at the stall put no money on him here');
       if((g.pedSold||0)!==carry||!g.tel||(g.tel.pedSold||0)!==carry) return skip('the sale put '+carry+' on him but tallied '+(g.pedSold||0)+' sold and '+(g.tel?g.tel.pedSold:'no tally')+' in the run record, so the row cannot carry the figure here');
       if(g.bag.indexOf('titan')>=0) return skip('the stall did not take the Titanium Cells here');
       // What endRaid values: the backpack left after the sale, and what the lift carried in.
       var haul=0; for(var bi=0;bi<g.bag.length;bi++) haul+=ival(g.bag[bi]);
       __endRaid('extract');
       if(!g.over) return skip('the raid did not end here');
       var L=P2.log||[], rec=L[L.length-1]||{};
       // CONTROL: the run was logged as an extraction carrying the stall figure, valued as the check valued it, and the money was banked.
       if(L.length<=runs0&&L.length<60) return skip('no run row was logged here');
       if(rec.outcome!=='extract'||rec.pedSold!==carry) return skip('the run row was logged as '+rec.outcome+' with '+rec.pedSold+' sold rather than an extraction with '+carry+' sold here');
       if(rec.haul!==haul||rec.carriedIn!==carriedIn) return skip('the run row valued the backpack at '+rec.haul+' and carried in at '+rec.carriedIn+' rather than '+haul+' and '+carriedIn+' here');
       var banked=(P2.credits||0)-credits0;
       if(banked<carry) return skip('extracting banked '+banked+' Credits, less than the '+carry+' of stall money on him, so the money did not walk out here');
       var want=haul-carriedIn+carry, got=(P2.netEarn||0)-net0;
       if(got!==want) bad.push('a backpack sold at the stall for '+carry+' then carried out moved Net lifetime earnings by '+got+' rather than '+want+' (backpack left '+haul+', carried in '+carriedIn+', the '+carry+' of stall money banked into Credits)');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(g&&keepEnts){ g.ents.length=0; for(var ke=0;ke<keepEnts.length;ke++) g.ents.push(keepEnts[ke]); } }catch(_n){}
       try{ if(g&&!g.over) __endRaid('abandon'); }catch(_e){}
       try{ pendingRun=null; }catch(_pr){}
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'15.83',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
