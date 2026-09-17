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
  {v:'15.13',what:
'@ @'
  {v:'15.14',what:'a raid keeps the clock it started with: ascended with the raid timer OFF, moving the NEXT RAID timer to 540 in the tuning console mid-raid does not burn the site or down him, and the raid goes on counting up from its own start (dials audit finding 6)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__loop&&window.__P&&window.__applyLoaded)) return 'SKIP: this fixture cannot deploy and step a raid';
     if(typeof toggleTune!=='function'||typeof tunedKeys!=='function'||typeof elapsed!=='function'||typeof SLIDERS==='undefined') return 'SKIP: this build has no tuning console';
     var box=document.getElementById('tunelist'), tm=document.getElementById('tunemodal');
     if(!box||!tm) return 'SKIP: this build has no tuning console in the page';
     var ix=-1, i, k;
     for(i=0;i<SLIDERS.length;i++) if(SLIDERS[i][0]==='raidSec') ix=i;
     if(ix<0) return 'SKIP: the console has no raid timer dial';
     var bad=[], g=null, snap=null, cfg0={};
     for(k in CFG) cfg0[k]=CFG[k];
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       snap=JSON.parse(JSON.stringify(__P()));
       // THE CLOCK OFF, claimed in the console before the raid is built, as a drag of the slider leaves it.
       CFG.raidSec=0; tunedKeys().raidSec=1;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player) return 'SKIP: no live raid';
       // CONTROL: the raid was built with no clock.
       if(g.raidLen!==0||g.timeLeft!==0) return 'SKIP: the raid was not built with the clock off here (raidLen '+g.raidLen+', timeLeft '+g.timeLeft+')';
       keys={};
       // Mid-raid the console opens over the raid, and the raid timer, marked NEXT RAID, is dragged to 540 through its own handler.
       toggleTune(true);
       var rg=box.getElementsByTagName('input')[ix];
       // CONTROL: the console is open, the raid is paused under it, and the row found is the raid timer.
       if(!tm.classList.contains('on')||!g.paused) return 'SKIP: the console did not open over the raid here';
       if(!rg||String(rg.max)!==String(SLIDERS[ix][3])) return 'SKIP: the raid timer row was not found in the console';
       rg.value='540'; rg.dispatchEvent(new Event('input'));
       toggleTune(false);
       // CONTROL: the dial took, and the raid runs again with the console closed.
       if(CFG.raidSec!==540) return 'SKIP: the raid timer dial did not take here ('+CFG.raidSec+')';
       if(g.paused||tm.classList.contains('on')) return 'SKIP: the raid did not resume when the console closed';
       var p=g.player, t0=g.t, ts=Math.max(performance.now(),(typeof lastTs==='number'?lastTs:0))+16.7;
       for(i=0;i<12&&!g.over;i++) __loop(ts+i*16.7);
       // CONTROL: the live loop stepped the raid.
       if(!(g.t>t0+0.1)) return 'SKIP: the live loop did not step the raid here ('+t0+' to '+g.t+')';
       if(g.nuking) bad.push('ascended with the raid timer OFF, moving the timer to 540 in the console mid-raid started burning the site on a raid with no clock (killer '+((g.tel&&g.tel.deathKiller)||'none')+')');
       if(g.over) bad.push('the raid ended as '+g.over+' within 12 frames of the console closing');
       if(p.downed||!(p.hp>0)) bad.push('he went down within 12 frames of the console closing (hp '+p.hp+')');
       if(g.timeLeft!==0) bad.push('the raid clock moved to '+g.timeLeft+' on a raid built with no clock');
       var el=elapsed();
       if(Math.abs(el-g.t)>0.001) bad.push('the run length reads '+el+' s where the raid has been up '+g.t+' s, so it no longer counts up from its own start');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(tuneOpen) toggleTune(false); }catch(_t){}
       try{ var gl=__state(); if(gl&&!gl.over) __endRaid('abandon'); }catch(_e){}
       try{ for(k in CFG) if(!(k in cfg0)) delete CFG[k]; for(k in cfg0) CFG[k]=cfg0[k]; }catch(_k){}
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'15.13',what:
'@
SubRx @'
       CFG.raidSec=clockOn?540:0;
'@ @'
       CFG.raidSec=clockOn?540:0;
       // v15.14: a raid keeps the clock it was built with (dials audit finding 6), so the dial alone no longer switches a running
       // clock off. The clock-off arm switches it off on the raid itself, as check 12.24 does for its clock-on arm.
       if(!clockOn) g.raidLen=0;
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
