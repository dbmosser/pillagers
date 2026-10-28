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

if ($s.Contains("  {v:'35.45',what:")) { throw "check 35.45 is in the fixture already" }

SubRx @'
  {v:'35.44',what:
'@ @'
  {v:'35.45',what:'his order 2026-10-28 (sp and money never intermingled): the CAREER extracted card shows a RAID SCORE panel of sp figures only and a MONEY panel of dollar figures only, side by side in two colours, the money total in the money panel and no RAID TOTAL row; the KIA card splits the same way; the xp line hides the season total and the next reward sentence; DAMAGE TAKEN comes after the ledger on an extraction',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__runPrep&&window.__endRaid&&window.__resetCfg&&window.__pinDefaults&&window.__cleanProfile&&window.__P&&window.__applyLoaded)) return 'SKIP: this fixture cannot deploy';
     if(typeof ocLedger!=='function'||typeof lbCountEnd!=='function'||typeof haulRevealSkip!=='function') return 'SKIP: no ledger here';
     var bad=[], g, c0=(typeof CAREER_ON==='number')?CAREER_ON:0, snap=null, man, lg, ps, pm, r1, r2, i, bs, t, rc, cs, ct, cc;
     function raid(){
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       CAREER_ON=1;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over) return false;
       g.player.iv=99; g.player.hp=100; g.player.downed=false;
       g.bag=['scrap','board','optic','servo','core','medkit','gun_carbine'];
       g.cs.s=750; g.cs.k=4; g.cs.b={kill:600,style:150};
       if(G.tel) G.tel.hitLog=[{t:30,n:'SENTRY R-34',w:'AUTOCANNON',a:20,hp:80}];
       return true;
     }
     function units(tag){
       var k, txt;
       bs=ps.querySelectorAll('.lgr b');
       if(!bs.length) bad.push(tag+': the RAID SCORE panel has no figures');
       for(k=0;k<bs.length;k++){ txt=bs[k].textContent||''; if(/\$/.test(txt)||!/ SP$/.test(txt)) bad.push(tag+': the RAID SCORE panel shows "'+txt+'", not an sp figure'); }
       bs=pm.querySelectorAll('.lgr b');
       if(!bs.length) bad.push(tag+': the MONEY panel has no figures');
       for(k=0;k<bs.length;k++){ txt=bs[k].textContent||''; if(/SP/.test(txt)) bad.push(tag+': the MONEY panel shows "'+txt+'", an sp figure'); else if(!bs[k].closest('.ni')&&txt.indexOf('$')<0) bad.push(tag+': the MONEY panel shows "'+txt+'", not a dollar figure'); }
     }
     try{
       snap=JSON.parse(JSON.stringify(__P()));
       if(!raid()) return 'SKIP: no live raid';
       if(!g.career||!g.cs) return 'SKIP: no CAREER raid in this build';
       __endRaid('extract');
       haulRevealSkip(); haulRevealSkip();
       man=document.getElementById('oc_manifest'); lg=man?man.querySelector('.lg'):null;
       if(!lg) return 'the CAREER extraction card has no ledger';
       lbCountEnd(lg);
       ps=lg.querySelector('.lgps'); pm=lg.querySelector('.lgpm');
       if(!ps||!pm) return 'the ledger is one list, not a RAID SCORE panel and a MONEY panel ('+(lg.textContent||'').slice(0,100)+')';
       r1=ps.getBoundingClientRect(); r2=pm.getBoundingClientRect();
       if(!(r1.width>100&&r2.width>100&&r2.left>=r1.right-1&&Math.abs(r1.top-r2.top)<2)) bad.push('the two panels are not side by side ('+[r1.left,r1.top,r1.width,r2.left,r2.top,r2.width].map(Math.round).join(',')+')');
       if((ps.querySelector('.lgh')||{}).textContent.indexOf('RAID SCORE')!==0) bad.push('the score panel is not headed RAID SCORE');
       if((pm.querySelector('.lgh')||{}).textContent!=='MONEY') bad.push('the money panel is not headed MONEY');
       if(!ps.querySelector('.lgr.sc [data-to]')) bad.push('the raid score total is not in the score panel');
       if(!pm.querySelector('.lgr.tot [data-to]')) bad.push('the money total is not in the money panel');
       if(!pm.querySelector('.lgr.cr [data-to]')) bad.push('the credits banked are not in the money panel');
       if(!pm.contains(document.getElementById('haultot'))) bad.push('the haul value is not in the money panel');
       if((lg.textContent||'').indexOf('RAID TOTAL')>=0) bad.push('a RAID TOTAL row is still on the card');
       if(+pm.querySelector('.lgr.tot [data-to]').getAttribute('data-to')!==1500+(+document.querySelector('#oc_manifest .haulstrip').getAttribute('data-sec')||0)) bad.push('the money total is not credits 1500 plus the haul');
       units('extracted');
       cs=getComputedStyle(ps.querySelector('.lgr.sc b')).color; ct=getComputedStyle(pm.querySelector('.lgr.tot b')).color; cc=getComputedStyle(pm.querySelector('.lgr.cr b')).color;
       if(cs===ct) bad.push('the money total is drawn in the score colour '+cs);
       if(ct!==cc) bad.push('the money total ('+ct+') and the credits banked ('+cc+') are not one money colour');
       rc=man.querySelector('.ocrecap');
       if(!rc) bad.push('the extracted card has no DAMAGE TAKEN block after a hit');
       else if(!(lg.compareDocumentPosition(rc)&Node.DOCUMENT_POSITION_FOLLOWING)) bad.push('DAMAGE TAKEN still sits above the result');
       t=man.innerText||'';
       if(/Claim it at the Mainframe|XP away/i.test(t)) bad.push('the next reward sentence is still shown');
       if(/XP\s+\S\s+[\d,]+ of [\d,]+/i.test(t)) bad.push('the xp line still shows the season total');
       // a death splits the same way
       __endRaid('abandon');
       if(!raid()) return bad.concat(['SKIP: no second raid']).join('; ');
       __endRaid('dead');
       man=document.getElementById('oc_manifest'); lg=man?man.querySelector('.lg'):null;
       if(!lg) bad.push('the KIA card has no ledger');
       else {
         lbCountEnd(lg);
         ps=lg.querySelector('.lgps'); pm=lg.querySelector('.lgpm');
         if(!ps||!pm) bad.push('the KIA ledger is not split into two panels');
         else {
           units('kia');
           if(pm.querySelectorAll('.lgr.lost s').length<2) bad.push('the KIA money panel does not strike the haul and the credits as LOST');
           if(!ps.querySelector('.lgr.lost')) bad.push('the KIA score panel has no -50% row');
         }
       }
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       try{ CAREER_ON=c0; }catch(_r){}
       try{ var g2=__state(); if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){}
       try{ if(snap&&window.__applyLoaded) __applyLoaded(snap); }catch(_s){}
       __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'35.44',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
