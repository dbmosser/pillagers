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

if ($s.Contains("  {v:'25.63',what:")) { throw "check 25.63 is in the fixture already" }

SubRx @'
  {v:'25.62',what:
'@ @'
  {v:'25.63',what:'his order (reload done sound): every finished reload plays exactly one reload done cue on the frame the rounds go in, tactical and empty, each gun class; a reload cut short plays none; nothing under G.sim',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof tickReload!=='function'||typeof reloadFoley!=='function'||typeof WEAPONS!=='object') return 'SKIP: this fixture cannot stage a reload';
     var bad=[], rec=[], kBlip=blip, kFoley=foley, kSim=null, g=null, p=null, sv=null, ids=['pistol','smg','rifle','shotgun','lmg','sniper','magnum','lance','scuttle','dmr'], staged=0, i, w, dry, r, cues, late;
     var run=function(w,dry,cut){
       var ticks=0;
       rec.length=0; p.wep=w; p.ammo=dry?0:Math.max(1,Math.floor(w.mag/2)); p.reserve=w.mag*3; p.reloading=w.reload; p.roll=0; p.downed=false;
       reloadFoley(p);
       while(p.reloading>0&&ticks<600){ tickReload(0.05); ticks++; if(cut&&ticks===cut) p.reloading=0; }
       for(var z=0;z<4;z++) tickReload(0.05);
       return rec.filter(function(x){ return x.t==='reloadin'; });
     };
     try{
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242}); g=__state();
       if(!g||!g.player||g.over) return 'SKIP: no live raid';
       p=g.player; kSim=g.sim; sv={wep:p.wep,ammo:p.ammo,reserve:p.reserve,reloading:p.reloading,roll:p.roll};
       g.sim=false;
       blip=function(t){ rec.push({t:t,rl:p.reloading,ammo:p.ammo}); };
       foley=function(r){ rec.push({t:'f:'+r}); return false; };
       for(i=0;i<ids.length;i++){
         w=WEAPONS[ids[i]]; if(!w||!(w.reload>0)||!(w.mag>1)) continue;
         staged++;
         for(dry=0;dry<2;dry++){
           cues=run(w,!!dry,0);
           if(cues.length!==1) bad.push(ids[i]+(dry?' empty':' tactical')+' reload plays '+cues.length+' done cues, not one');
           else if(cues[0].rl>0||cues[0].ammo<=0) bad.push(ids[i]+(dry?' empty':' tactical')+' done cue plays before the rounds go in');
         }
         cues=run(w,false,3);
         if(cues.length) bad.push(ids[i]+' reload cut short still plays '+cues.length+' done cue(s)');
       }
       if(staged<4) bad.push('only '+staged+' gun classes could be staged');
       g.sim=true; cues=run(WEAPONS.rifle||WEAPONS.pistol,false,0); g.sim=false;
       if(rec.length) bad.push('a reload under G.sim made '+rec.length+' sounds');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ blip=kBlip; foley=kFoley; }catch(_b){}
       try{ if(p&&sv){ p.wep=sv.wep; p.ammo=sv.ammo; p.reserve=sv.reserve; p.reloading=0; p.roll=sv.roll; } if(typeof rlfxStop==='function') rlfxStop(); if(g&&kSim!==null) g.sim=kSim; }catch(_p){}
       try{ var g2=__state(); if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'25.62',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
