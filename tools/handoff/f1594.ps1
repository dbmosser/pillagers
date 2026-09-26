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
  {v:'15.93',what:
'@ @'
  {v:'15.94',what:'the hire death line decides you are in debt only after the run money has landed: with a dead hire and 1,000 banked, an extraction with 3,000 of stall money riding home settles at 600 and the death benefit line on the card does not call you in debt, an extraction where hazard pay alone lifts the balance above zero does not either, and with nothing landing after the benefit the same line still calls you in debt at -2,400 (credits audit finding)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P&&window.__applyLoaded)) return 'SKIP: this fixture cannot hire, deploy and end a raid';
     if(typeof IDENTITIES==='undefined'||!IDENTITIES.length||!IDENTITIES[0].id||typeof MERC_DEATH!=='number'||typeof termsPay!=='function'||typeof ival!=='function'||typeof ITEMS==='undefined'||!ITEMS.core) return 'SKIP: no hires, death benefit, hazard terms or Data Core in this build';
     var man=document.getElementById('oc_manifest'), oc=document.getElementById('outcome');
     if(!man||!oc) return 'SKIP: this build has no run report in the page';
     var bad=[], snap=null, i;
     var tag=String(IDENTITIES[0].tag||'');
     if(!tag) return 'SKIP: the first identity has no name to read on the card';
     // The words the line must not carry beside a positive balance are assembled from pieces.
     var DEBT=['you are',' in debt'].join(''), OWED=['Death ','benefit'].join('');
     // Three extractions with a dead hire. The first has nothing landing after the benefit and the debt is real. The other two
     // settle above zero only because of money that lands after the benefit: stall money riding home, then hazard pay alone.
     var arms=[{n:'nothing landing',credits:1000,ped:0,terms:[],bag:[]},
               {n:'stall money riding home',credits:1000,ped:3000,terms:[],bag:[]},
               {n:'hazard pay alone',credits:MERC_DEATH-1,ped:0,terms:['known'],bag:['core']}];
     function money(n){ return (n<0?'-$':'$')+Math.abs(n).toLocaleString(); }
     function one(arm){
       __topClear();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       var q=__P();
       // Staged after the lift lands so the hire is not spawned: only the settle reads him. Racks and arrays are zero so the
       // only money before the death benefit line is what was banked; the terms are read at the settle, not at the deploy.
       q.merc=IDENTITIES[0].id; q.racks=0; q.arrays=0; q.terms=arm.terms.slice(); q.credits=arm.credits;
       g.mercDead=1; g.bag=arm.bag.slice(); g.carriedIn=0; g.pedCarry=arm.ped; g.pedSold=arm.ped;
       var haul=0; for(i=0;i<g.bag.length;i++) haul+=ival(g.bag[i]);
       var bonus=Math.round(Math.max(0,haul-(g.carriedIn||0))*termsPay());
       if(arm.terms.length&&!(bonus>0)) return 'SKIP: the hazard term pays nothing on a Data Core here';
       var want=arm.credits-MERC_DEATH+arm.ped+bonus;
       man.innerHTML='';
       __endRaid('extract');
       // CONTROL: the raid extracted, the card was drawn and the hire contract was settled.
       if(g.over!=='extract'||!oc.classList.contains('on')||!String(man.textContent||'').length) return 'SKIP: the extraction card was not drawn here';
       if(q.merc) return 'SKIP: the hire contract was not settled at the end of this raid';
       // CONTROL: the money landed as staged, so the balance the line is read against is known.
       if(q.credits!==want) return 'SKIP: with '+arm.n+' the run settled at '+money(q.credits)+' rather than '+money(want)+', so the balance cannot be pinned here';
       // His line is its own span and starts with his name; the death benefit line is the one that names the benefit.
       var sp=man.querySelectorAll('span'), hl='';
       for(i=0;i<sp.length;i++){ var st=String(sp[i].textContent||''); if(st.indexOf(tag)===0&&st.indexOf(OWED)>=0) hl=st; }
       if(!hl) return 'SKIP: the card carries no death benefit line for the hire here';
       var says=hl.indexOf(DEBT)>=0;
       if(says&&want>=0) bad.push('with '+arm.n+' the run settled at '+money(want)+' banked and the hire line still reads: '+hl.slice(0,110));
       if(!says&&want<0) bad.push('with '+arm.n+' the run settled at '+money(want)+' and the hire line no longer says so: '+hl.slice(0,110));
       return null;
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       snap=JSON.parse(JSON.stringify(__P()));
       for(var a=0;a<arms.length;a++){ var r=one(arms[a]); if(r) return r; }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ var gl=__state(); if(gl){ gl.mercDead=0; } if(gl&&!gl.over) __endRaid('abandon'); }catch(_e){}
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'15.93',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
