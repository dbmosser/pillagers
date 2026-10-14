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

if ($s.Contains("  {v:'26.16',what:")) { throw "check 26.16 is in the fixture already" }

SubRx @'
  {v:'26.15',what:
'@ @'
  {v:'26.16',what:'wheel1, his order: a gun that comes into his hands cannot fire until it is ready, and the time is the gun class: pistol 0.25 s, SMG 0.4, rifle 0.55, shotgun 0.6, marksman 0.7, sniper 0.85, machine gun 1.0; a fresh raid starts with the gun already drawn',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: no raid here';
     if(typeof updatePlayer!=='function'||typeof swapGuns!=='function') return 'SKIP: no player step here';
     if(typeof G!=='undefined'&&G&&(G.sim||!G.over)) return 'SKIP: a raid or a sim is live';
     var bad=[], g=null, p=null, ids=['pistol','smg','rifle','shotgun','dmr','sniper','lmg'], want={pistol:0.25,smg:0.4,rifle:0.55,shotgun:0.6,dmr:0.7,sniper:0.85,lmg:1.0}, i, id, t, f;
     function cl(q){ var o={}, k; for(k in WEAPONS[q]) o[k]=WEAPONS[q][k]; o.q='field'; o.qRank=1; return o; }
     function firstShot(){
       var a0=p.ammo, n;
       p.lastShot=-1e9; p.fired=false; p.reloading=0; p.jam=0; p.trigYield=false; p.cooking=false; mouse.down=true;
       for(n=0;n<400;n++){ updatePlayer(0.01); if(p.ammo<a0) break; }
       mouse.down=false; updatePlayer(0.01);
       return (p.ammo<a0)?n*0.01:-1;
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: staging: no raid';
       p=g.player; p.iv=99; p.maxhp=100; g.ents.length=0; g.bagOpen=false; g.mapOpen=false; g.paused=false; g.trade=null; keys={}; mouse.down=false;
       p.reserve=60; if(p.wep&&p.wep.mag>0) p.ammo=p.wep.mag;
       t=(p.wep&&p.wep.mag>0)?firstShot():0;
       if(t<0||t>0.04) bad.push('the first gun of a fresh raid took '+t+' s to fire, not at once');
       for(i=0;i<ids.length;i++){
         id=ids[i];
         for(f=0;f<150;f++) updatePlayer(0.01);
         p.sec=cl(id); p.secAmmo=p.sec.mag; p.reserve=60;
         swapGuns();
         if(!p.wep||p.wep.id!==id){ bad.push(id+': the swap did not bring the gun up'); continue; }
         t=(p.wep&&p.wep.mag>0)?firstShot():0;
         if(t<0) bad.push(id+': never fired within 4 s');
         else if(Math.abs(t-want[id])>0.035) bad.push(id+': first shot after '+t.toFixed(2)+' s, not '+want[id]+' s');
       }
       if(!(DRAWT.pistol<DRAWT.smg&&DRAWT.smg<DRAWT.rifle&&DRAWT.rifle<DRAWT.shotgun&&DRAWT.shotgun<DRAWT.dmr&&DRAWT.dmr<DRAWT.sniper&&DRAWT.sniper<DRAWT.lmg)) bad.push('the draw times do not rise from pistol to machine gun');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ mouse.down=false; keys={}; var g2=__state(); if(g2&&!g2.over){ g2.player.iv=0; __endRaid('abandon'); } }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'26.15',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
