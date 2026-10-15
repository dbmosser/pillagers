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

if ($s.Contains("  {v:'28.51',what:")) { throw "check 28.51 is in the fixture already" }

SubRx @'
  {v:'28.50',what:
'@ @'
  {v:'28.51',what:'cloud-feel-closecall-downed: a round inside a roll on his feet pays CLOSE CALL once; a crawler bite that downs him mid-roll leaves no roll, a round on the floor pays nothing, and a round right after the self-revive pays nothing',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: no raid here';
     var bad=[], g, p, own, E0=null, oK=keys, s0, i;
     function shot(){ g.bullets.length=0; g.bullets.push({x:p.x,y:p.y,vx:0.01,vy:0,dmg:20,life:0.5,player:false,owner:own,tint:'#fff',thru:0}); updateBullets(0.001); g.bullets.length=0; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       if(g.sim) return 'SKIP: the fixture raid is a sim raid';
       p=g.player; E0=g.ents;
       own=E0.filter(function(x){ return x.kind==='sentry'||x.kind==='crawler'||x.kind==='raider'; })[0];
       if(!own) return 'SKIP: staging: no enemy in the fixture raid to own the round';
       g.ents=[]; keys={}; g.career=true; g.cs={s:0,k:0}; g.arcade=false; p.revived=false;
       // on his feet: two rounds inside one roll pay once
       p.stam=100; p.ccT=undefined; p.roll=0; p.rollCd=0; p.iv=0; tryRoll();
       if(!(p.roll>0&&p.iv>0)) return 'SKIP: staging: the roll did not start';
       shot(); shot();
       if(g.cs.s!==CC_PTS) bad.push('a roll on his feet paid '+g.cs.s+' (want '+CC_PTS+' once)');
       // a crawler bite downs him mid-roll
       p.roll=0; p.rollCd=0; p.iv=0; p.stam=100; p.ccT=undefined; tryRoll();
       g.t+=0.05; __sim(0.05);
       p.hp=5; p.armor=0;
       LATCH_BITE=1; try{ damagePlayer(20,'crawler','Crawler'); } finally{ LATCH_BITE=0; }
       if(!p.downed) return 'SKIP: staging: the latched bite did not down him';
       if(p.roll>0) bad.push('downed mid-roll, the roll stayed on ('+p.roll+')');
       s0=g.cs.s; p.stam=10; p.ccT=undefined; shot();
       if(g.cs.s!==s0) bad.push('a round on the floor paid CLOSE CALL ('+(g.cs.s-s0)+')');
       for(i=0;i<20;i++){ g.t+=0.016; __sim(0.016); }
       if(!p.downed) return 'SKIP: staging: he did not stay down';
       selfRevive();
       if(p.downed) return 'SKIP: staging: the self-revive did not lift him';
       s0=g.cs.s; p.stam=10; p.ccT=undefined; g.t+=1; shot();
       if(g.cs.s!==s0) bad.push('a round right after the self-revive paid CLOSE CALL ('+(g.cs.s-s0)+', roll '+p.roll+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ LATCH_BITE=0; keys=oK; if(g&&E0) g.ents=E0; if(g) g.bullets.length=0; }catch(_h){}
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'28.50',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
