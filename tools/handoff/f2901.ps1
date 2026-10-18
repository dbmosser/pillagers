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

if ($s.Contains("  {v:'29.01',what:")) { throw "check 29.01 is in the fixture already" }

SubRx @'
  {v:'29.00',what:
'@ @'
  {v:'29.01',what:'the stronghold gate needs the hold: standing at it with no key never opens it, holding E opens it, and a defender is kept inside the building after the breach (his order: breach must really need the hold, the enemies in breach houses should not leave the house)',
   run:function(){
     if(!(window.__state&&window.__endRaid&&window.__runPrep&&window.__frame)) return 'SKIP: no raid or frame here';
     if(typeof arcadeDeploy!=='function'||typeof ARCADE!=='object'||typeof flowTick!=='function'||typeof shNear!=='function') return 'SKIP: no arcade or strongholds here';
     var bad=[], g=null, p=null, s=null, SS=null, gp, i, e, b, k0=keys;
     try{
       __topClear(); __runPrep();
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       p=g.player; keys={}; ARCADE.mine=0; ARCADE.holdT=0; g.t=4; flowTick(0.1); SS=g.flow.sh;
       if(!SS||!SS.sites||!SS.sites.length) return 'SKIP: staging: the raid laid out no stronghold';
       s=SS.sites[0]; if(s.kind!=='b') return 'SKIP: staging: the first stronghold is not a building';
       b=g.map.buildings[s.bi]; gp=shGatePt(s);
       p.iv=99; p.x=gp.x+s.nx*40; p.y=gp.y+s.ny*40; p.downed=false;
       g.ents=g.ents.filter(function(q){ return !q||q.shi===s.i||dist(q,p)>1500; });
       for(i=0;i<20;i++){ g.t+=0.25; flowTick(0.25); }
       if(s.open||s.prog>0) bad.push('ONE: five seconds of standing at the gate with no key filled the ring to '+s.prog.toFixed(2)+(s.open?' and opened it':''));
       keys={KeyE:true};
       for(i=0;i<8;i++){ g.t+=0.25; flowTick(0.25); }
       if(s.open||!(s.prog>0.5)) bad.push('TWO: holding E for 2 s left the ring at '+s.prog.toFixed(2)+(s.open?' and the gate open':''));
       for(i=0;i<8&&!s.open;i++){ g.t+=0.25; flowTick(0.25); }
       if(!s.open) bad.push('TWO: holding E for 4 s did not open the gate');
       keys={};
       e=null; for(i=0;i<(s.def||[]).length;i++) if(shAlive(s.def[i])){ e=s.def[i]; break; }
       if(!e) return bad.length?bad.join(' | '):'SKIP: staging: no live defender';
       flowTick(0.1);
       e.x=b.x-40; e.y=b.y+b.h/2; flowTick(0.1);
       if(!(e.x>b.x&&e.x<b.x+b.w&&e.y>b.y&&e.y<b.y+b.h)) bad.push('THREE: a defender put outside the house after the breach stayed outside at '+Math.round(e.x-b.x)+','+Math.round(e.y-b.y));
       return bad.length?bad.join(' | '):null;
     } finally {
       keys=k0;
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     } }},
  {v:'29.00',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
