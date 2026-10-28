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

if ($s.Contains("  {v:'35.75',what:")) { throw "check 35.75 is in the fixture already" }

SubRx @'
  {v:'35.74',what:
'@ @'
  {v:'35.75',what:'his order 2026-10-28 (the pause box shows what the raid pays in sp): in a raid the pause box lists, under its title and above its buttons, the settings multiplier, one row per setting that moves it (pillager bots, machines, how hard they hit, heat when you call for extraction, fog of war, superhot) with its choice and factor, the rows multiplying to the headline, and the extract x2 and killed in action -50% rules; the run log list is gone; superhot switched in Settings mid raid shows when Settings closes',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__runPrep&&window.__endRaid&&window.__resetCfg&&window.__pinDefaults&&window.__cleanProfile&&window.__P&&window.__applyLoaded)) return 'SKIP: this fixture cannot deploy';
     if(typeof diffMul!=='function'||typeof DMUL_STEP!=='object'||typeof togglePauseBox!=='function') return 'SKIP: no settings multiplier in this build';
     var bad=[], g, c0=(typeof CAREER_ON==='number')?CAREER_ON:0, d0=DMUL_ON, snap=null, cf={}, ks=['nRaider','superhot','fogWar'], pb=false, el, box, h3, btns, rows, rr, i, x, prod, hd, lab, want, r1, r2, r3, sm;
     function rowOf(l){ for(var j=0;j<rows.length;j++){ var s=rows[j].querySelector('span'); if(s&&s.textContent===l) return rows[j]; } return null; }
     function fac(r){ var b=r&&r.querySelector('b'); return b?parseFloat(String(b.textContent).replace(/^x/,'')):NaN; }
     function word(r){ var w=r&&r.querySelector('i'); return w?w.textContent:''; }
     try{
       snap=JSON.parse(JSON.stringify(__P()));
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       for(i=0;i<ks.length;i++) cf[ks[i]]=CFG[ks[i]];
       CAREER_ON=1; DMUL_ON=1;
       CFG.nRaider=15; CFG.superhot=0; CFG.fogWar=1;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over) return 'SKIP: no live raid';
       g.player.iv=99;
       togglePauseBox(true); pb=true;
       el=document.getElementById('pausesp'); box=document.getElementById('pausebox');
       if(!el) return 'the pause box has no score panel';
       if(el.style.display==='none'||!el.offsetHeight) return 'the score panel is hidden in a raid';
       if(document.getElementById('pauselog')&&document.getElementById('pauselog').offsetHeight) bad.push('the run log list is still on the pause box');
       if(/run log/i.test(box.innerText||'')) bad.push('the pause box still says run log');
       hd=el.querySelector('.psph b');
       if(!hd||hd.textContent!=='x'+diffMul().toFixed(2)) bad.push('the headline reads '+(hd&&hd.textContent)+', not x'+diffMul().toFixed(2));
       rows=el.querySelectorAll('.psprow');
       if(rows.length!==6) bad.push('there are '+rows.length+' setting rows, not 6');
       lab=['raiders','robots','hits','ext','fogWar','superhot'];
       for(i=0;i<lab.length;i++){ want=gameOptLabel(lab[i]); if(!rowOf(want)) bad.push('no row for '+want); }
       rr=rowOf(gameOptLabel('raiders')); if(word(rr)!=='many'||Math.abs(fac(rr)-1.10)>0.001) bad.push('pillager bots reads '+word(rr)+' x'+fac(rr)+', not many x1.10');
       rr=rowOf(gameOptLabel('fogWar')); if(word(rr)!=='on'||Math.abs(fac(rr)-1.05)>0.001) bad.push('fog of war reads '+word(rr)+' x'+fac(rr)+', not on x1.05');
       rr=rowOf(gameOptLabel('superhot')); if(word(rr)!=='off'||Math.abs(fac(rr)-1.05)>0.001) bad.push('superhot reads '+word(rr)+' x'+fac(rr)+', not off x1.05');
       for(prod=1,i=0;i<rows.length;i++){ x=fac(rows[i]); if(!(x>=1)) bad.push('a row has no factor: '+rows[i].textContent); else prod*=x; }
       if(Math.abs(prod-diffMul())>0.011) bad.push('the rows multiply to '+prod.toFixed(4)+', not the headline '+diffMul());
       if(!/extract\s*x2/i.test(el.innerText||'')||!/killed in action\s*-50%/i.test(el.innerText||'')) bad.push('the end rules are not listed ('+JSON.stringify((el.innerText||'').slice(-60))+')');
       h3=box.querySelector('h3'); btns=document.getElementById('resumebtn'); btns=btns&&btns.parentNode;
       if(h3&&btns){ r1=h3.getBoundingClientRect(); r2=el.getBoundingClientRect(); r3=btns.getBoundingClientRect(); if(!(r2.top>=r1.bottom-1&&r2.bottom<=r3.top+1)) bad.push('the panel is not between the title and the buttons ('+[r1.bottom,r2.top,r2.bottom,r3.top].map(Math.round).join(',')+')'); }
       // superhot switched on in Settings mid raid shows when Settings closes
       sm=document.getElementById('settingsmodal'); if(sm) sm.classList.add('on');
       CFG.superhot=1; document.getElementById('closesettings').onclick();
       rows=el.querySelectorAll('.psprow'); rr=rowOf(gameOptLabel('superhot'));
       if(word(rr)!=='on'||Math.abs(fac(rr)-1)>0.001) bad.push('after Settings closed superhot reads '+word(rr)+' x'+fac(rr)+', not on x1.00');
       hd=el.querySelector('.psph b'); if(!hd||hd.textContent!=='x'+diffMul().toFixed(2)) bad.push('after Settings closed the headline reads '+(hd&&hd.textContent)+', not x'+diffMul().toFixed(2));
       togglePauseBox(false); pb=false;
       if(el.style.display!=='none') bad.push('the panel stays up with the box shut');
     }catch(x2){ bad.push('threw: '+(x2&&x2.message||x2)); }
     finally{
       try{ if(pb) togglePauseBox(false); }catch(_p){}
       try{ for(var k in cf) CFG[k]=cf[k]; CAREER_ON=c0; DMUL_ON=d0; }catch(_r){}
       try{ var g2=__state(); if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){}
       try{ if(snap&&window.__applyLoaded) __applyLoaded(snap); }catch(_s){}
       __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'35.74',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
