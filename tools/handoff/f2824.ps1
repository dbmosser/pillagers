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

if ($s.Contains("  {v:'28.24',what:")) { throw "check 28.24 is in the fixture already" }

SubRx @'
  {v:'28.23',what:
'@ @'
  {v:'28.24',what:'his answer 43: the camera zooms out a little while sprinting: with the row ON the zoom eases to about 0.93 of the normal one in a sprint and back, OFF holds it; the row is in DISPLAY and ON by default',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame&&window.__opts&&window.__opts.apply&&window.__opts.cycle&&window.__opts.rows)) return 'SKIP: this fixture cannot deploy, draw or reach the Settings rows';
     if(typeof renderSettings!=='function'||typeof ZOOM!=='function') return 'SKIP: no Settings or zoom here';
     var bad=[], g=null, p=null, md=document.getElementById('settingsmodal'), was=md&&md.classList.contains('on'), kGO=P.gameOpts, kTU=P.tuned, kS=CFG.sprintZoom, rows, rr=null, i, z0, z1, z2, z3;
     function secOf(id){ var el=document.getElementById(id), s=el&&el.closest('.row'), b; while(s){ if(/opacity:\s*\.7/.test(s.getAttribute('style')||'')){ b=s.querySelector('b'); return b?b.textContent:''; } s=s.previousElementSibling; } return ''; }
     function settle(sp){ var q; g.sprinting=sp; for(q=0;q<40;q++) __frame(0.1); return ZOOM(); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g&&g.player; if(!g||g.over||g.sim||!p) return 'SKIP: staging: no live raid';
       p.iv=99; p.downed=false; p.ads=false; g.ents.length=0;
       P.gameOpts={}; P.tuned={}; __opts.apply();
       md.classList.add('on'); renderSettings(); rows=__opts.rows()||[];
       for(i=0;i<rows.length;i++) if(rows[i].k==='sprintZoom') rr=rows[i];
       if(!rr) bad.push('Settings has no SPRINT ZOOM-OUT row');
       else {
         if(secOf('go_sprintZoom')!=='DISPLAY') bad.push('the row sits under '+secOf('go_sprintZoom')+', not DISPLAY');
         if(CFG.sprintZoom!==1) bad.push('a fresh profile has the sprint zoom-out '+CFG.sprintZoom+', not ON');
       }
       z0=settle(false);
       z1=settle(true);
       if(!(z1<z0*0.97&&z1>z0*0.85)) bad.push('sprinting moved the zoom from '+z0.toFixed(3)+' to '+z1.toFixed(3)+', not a little out (0.85 to 0.97 of it)');
       z2=settle(false);
       if(Math.abs(z2-z0)>z0*0.005) bad.push('the zoom did not come back after the sprint ('+z0.toFixed(3)+' then '+z2.toFixed(3)+')');
       if(rr){
         __opts.cycle('sprintZoom');
         if(CFG.sprintZoom!==0) bad.push('one click did not turn the sprint zoom-out OFF');
         z3=settle(true);
         if(Math.abs(z3-z0)>z0*0.005) bad.push('with the row OFF a sprint still moved the zoom ('+z0.toFixed(3)+' to '+z3.toFixed(3)+')');
         __opts.cycle('sprintZoom');
       }
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       try{ if(g) g.sprinting=false; }catch(_s){}
       try{ CFG.sprintZoom=kS; P.gameOpts=kGO||{}; P.tuned=kTU||{}; __opts.apply(); renderSettings(); if(!was) md.classList.remove('on'); }catch(_r){}
       try{ var g2=__state(); if(g2&&!g2.over){ g2.adsZ=1; g2.player.iv=0; __endRaid('abandon'); } }catch(_e){}
       try{ __cleanProfile(); }catch(_cp){}
       __topClear();
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'28.23',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
