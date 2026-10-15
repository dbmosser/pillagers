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

if ($s.Contains("  {v:'28.57',what:")) { throw "check 28.57 is in the fixture already" }

SubRx @'
  {v:'28.56',what:
'@ @'
  {v:'28.57',what:'cloud-feel-spin-downed: a Support MG spun up to full, then downed and picked up, fires nothing in the first 0.1 s of a fresh pull (the spin starts over)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: no raid here';
     var bad=[], g, p, i, a0, sp0;
     function st(n){ for(i=0;i<n;i++){ g.t+=0.016; __sim(0.016); } }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       if(g.sim) return 'SKIP: the fixture raid is a sim raid';
       p=g.player; g.ents=[];
       p.wep=cloneObj(WEAPONS.lmg); p.ammo=60; p.reserve=200; p.reloading=0; p.drawRef=undefined;
       st(80);
       mouse.down=true; st(60); sp0=p.spin||0;
       if(!(sp0>0.9)) return 'SKIP: staging: the Support MG did not spin up ('+sp0.toFixed(2)+')';
       mouse.down=false;
       p.iv=0; damagePlayer(p.hp+500,'test');
       if(!p.downed) return 'SKIP: staging: the hit did not down the player';
       st(120);
       if(!p.downed) return 'SKIP: staging: the player did not stay down';
       if(LMGSPIN.hum) bad.push('the spin whirr is still playing while downed');
       selfRevive();
       if(p.downed) return 'SKIP: staging: the self-revive did not pick him up';
       st(1); p.iv=99;
       if(p.drawT>0) st(Math.ceil(p.drawT/0.016)+1);
       a0=p.ammo; mouse.down=true; st(6); mouse.down=false;
       if(a0-p.ammo>0) bad.push('the first 0.1 s of a fresh pull after the pick-up fired '+(a0-p.ammo)+' rounds (spin '+(p.spin||0).toFixed(2)+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ mouse.down=false; keys['KeyF']=false; lmgWhirrStop(); }catch(_k){}
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'28.56',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
