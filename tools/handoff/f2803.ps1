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

if ($s.Contains("  {v:'28.03',what:")) { throw "check 28.03 is in the fixture already" }

SubRx @'
  {v:'28.02',what:
'@ @'
  {v:'28.03',what:'his order 2026-10-15 (score and haul reconciled): a CAREER run card is one ledger of raid score rows, credits, haul and a RAID TOTAL of credits plus haul, with stat tiles instead of sentences, a death shows credits and haul as LOST, the first press lands the tally, and any other card keeps its sentences',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__runPrep&&window.__endRaid&&window.__resetCfg&&window.__pinDefaults&&window.__cleanProfile&&window.__P&&window.__applyLoaded)) return 'SKIP: this fixture cannot deploy';
     if(typeof ocLedger!=='function') return 'the run card has no ledger (cboard2)';
     var bad=[], g, c0=(typeof CAREER_ON==='number')?CAREER_ON:0, snap=null, lg, tx, rows, i, sc, cr, tt, hv, ds, man, t0;
     function raid(bag,on){
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       CAREER_ON=on;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over) return false;
       g.player.iv=99; g.player.hp=100; g.player.downed=false;
       g.bag=bag.slice();
       return true;
     }
     function dto(sel){ var e=document.querySelector('#oc_manifest '+sel+' [data-to]'); return e?+e.getAttribute('data-to'):-1; }
     try{
       snap=JSON.parse(JSON.stringify(__P()));
       if(!raid(['scrap','board','optic','servo','core','medkit'],1)) return 'SKIP: no live raid';
       if(!g.career||!g.cs) return 'SKIP: no CAREER raid in this build';
       g.cs.s=750; g.cs.k=4; g.cs.b={kill:600,style:50,goal:100};
       __endRaid('extract');
       man=document.getElementById('oc_manifest'); lg=man.querySelector('.lg'); tx=man.textContent||'';
       if(!lg) return 'the CAREER extraction card has no ledger';
       for(i=0,rows=['KILLS','MEDALS','GOALS','EXTRACTION','RAID SCORE','CREDITS','ITEMS SECURED','HAUL VALUE','RAID TOTAL','ACCURACY','CONTAINERS','HEALTH'];i<rows.length;i++) if(lg.textContent.indexOf(rows[i])<0) bad.push('the ledger has no '+rows[i]);
       if(lg.textContent.indexOf('OBJECTIVES')<0||lg.textContent.indexOf('COMBAT')<0) bad.push('the ledger rows are not grouped COMBAT and OBJECTIVES');
       if(/items? secured for|You extracted with|ACHIEVEMENT:|CAREER SCORE/.test(tx)) bad.push('a sentence the ledger replaces is still on the card');
       if(dto('.sc')!==1500) bad.push('RAID SCORE is '+dto('.sc')+', not 1500 (750 x2)');
       if(dto('.cr')!==1500) bad.push('CREDITS is '+dto('.cr')+', not 1500 (one credit a point)');
       if(!(document.getElementById('haultot'))) bad.push('no HAUL VALUE figure');
       if(!ocLgTally()) bad.push('the tally is not running on a fresh card');
       haulRevealSkip();
       if(ocLgTally()||!lg.classList.contains('lgdone')) bad.push('the first press did not land the tally');
       haulRevealSkip();
       ds=document.querySelector('#oc_manifest .haulstrip'); hv=ds?+ds.getAttribute('data-sec'):0;
       if(!(hv>0)) bad.push('the strip carries no haul value');
       if((document.getElementById('haultot').textContent||'').replace(/[^0-9]/g,'')!==String(hv)) bad.push('HAUL VALUE reads '+document.getElementById('haultot').textContent+', not '+hv);
       if(dto('.tot')!==1500+hv) bad.push('RAID TOTAL is '+dto('.tot')+', not credits 1500 plus haul '+hv);
       tt=lg.querySelectorAll('.lgti'); if(tt.length!==5) bad.push('there are '+tt.length+' stat tiles, not 5');
       if(g.achNew&&g.achNew.length&&lg.querySelectorAll('.lgeb').length!==g.achNew.length) bad.push('the achievements are not one emblem each');
       if(lg.querySelectorAll('.lgeb svg').length!==lg.querySelectorAll('.lgeb').length) bad.push('an emblem has no picture');
       __endRaid('abandon');
       // a death
       if(!raid(['scrap','board','optic','servo','core','medkit'],1)) return bad.concat(['SKIP: no second raid']).join('; ');
       g.cs.s=400; g.cs.k=2; g.cs.b={kill:400};
       __endRaid('dead');
       man=document.getElementById('oc_manifest'); lg=man.querySelector('.lg'); tx=man.textContent||'';
       if(!lg) bad.push('the KIA card has no ledger');
       else {
         if(dto('.sc')!==400) bad.push('the KIA RAID SCORE is '+dto('.sc')+', not 400');
         if(lg.querySelectorAll('.lgr.lost s').length<2) bad.push('the KIA credits and haul are not both struck through as LOST');
         if(lg.querySelector('.lgr.cr')) bad.push('a death card shows banked credits');
         if(lg.querySelector('.lgr.tot [data-to]')) bad.push('a death card has a RAID TOTAL above nothing');
         if(lg.textContent.indexOf('LOST')<0) bad.push('the KIA ledger never says LOST');
         if(g.careerPaid!==0) bad.push('a death paid '+g.careerPaid);
       }
       // another raid keeps its sentences
       if(!raid(['scrap','board','optic','servo','core','medkit'],0)) return bad.concat(['SKIP: no third raid']).join('; ');
       __endRaid('extract');
       man=document.getElementById('oc_manifest');
       if(man.querySelector('.lg')) bad.push('a non-CAREER card got the ledger');
       if((man.textContent||'').indexOf('secured for')<0) bad.push('a non-CAREER card lost its items secured line');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       try{ CAREER_ON=c0; }catch(_r){}
       try{ var g2=__state(); if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){}
       try{ if(snap&&window.__applyLoaded) __applyLoaded(snap); }catch(_s){}
       __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'28.02',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
