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

if ($s.Contains("  {v:'28.55',what:")) { throw "check 28.55 is in the fixture already" }

SubRx @'
  {v:'28.54',what:
'@ @'
  {v:'28.55',what:'cloud-feel-reload-swap-ring: an empty LMG reloading with the trigger held, swapped (F) to an empty pistol: the pistol reload ring starts near empty and an R pressed at once does not finish it',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: no raid here';
     var bad=[], g, p, f0, rl0, i;
     function kd(c){ window.dispatchEvent(new KeyboardEvent('keydown',{code:c,key:c,bubbles:true})); }
     function ku(c){ window.dispatchEvent(new KeyboardEvent('keyup',{code:c,key:c,bubbles:true})); }
     function st(n){ for(i=0;i<n;i++){ g.t+=0.016; __sim(0.016); } }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       if(g.sim) return 'SKIP: the fixture raid is a sim raid';
       p=g.player; g.ents=[]; p.iv=99;
       p.wep=cloneObj(WEAPONS.lmg); p.ammo=0; p.reserve=200; p.reloading=0; p.sec=cloneObj(WEAPONS.pistol); p.secAmmo=0; p.drawRef=undefined;
       st(80);
       mouse.down=true; st(30);
       if(!(p.reloading>0&&p.rlTot>0)) return 'SKIP: staging: the empty LMG did not start its reload with the trigger held';
       kd('KeyF'); ku('KeyF');
       if(!p.wep||p.wep.id!=='pistol') return 'SKIP: staging: F did not swap to the pistol';
       st(1);
       if(!(p.reloading>0)) return 'SKIP: staging: the empty pistol did not start its reload with the trigger held';
       f0=1-p.reloading/((p.rlTot>0)?p.rlTot:p.wep.reload);
       if(!(f0<0.1)) bad.push('the pistol reload ring opened at '+Math.round(f0*100)+' percent');
       mouse.down=false; rl0=p.reloading;
       kd('KeyR'); st(1); ku('KeyR'); st(1);
       if(!(p.reloading>0)||p.arBonus) bad.push('an R pressed at once finished the pistol reload (reloading '+Math.round(rl0)+' to '+Math.round(p.reloading)+', bonus '+(p.arBonus?1:0)+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ mouse.down=false; ku('KeyR'); ku('KeyF'); keys['KeyR']=false; keys['KeyF']=false; }catch(_k){}
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'28.54',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
