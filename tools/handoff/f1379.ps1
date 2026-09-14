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
  {v:'13.78',what:
'@ @'
  {v:'13.79',what:'the raid clock lets a boarding hold finish: E held in a landed ring with one second on the clock extracts instead of dying to the timer, as it does with five seconds left (downed and extraction audit 2026-09-14, finding 2)',
   run:function(){
     if(!(window.__startRaid&&window.__state&&window.__loop&&window.__P)) return 'SKIP: this fixture cannot run raid frames';
     var bad=[], P2=__P();
     var keep={st:(P2.stash||[]).slice(),w:(P2.weapons||[]).slice(),cr:P2.credits,eq:P2.equipped,es:P2.equippedSec};
     function board(tl){
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       if(!(CFG.raidSec>0)) return {skip:'this build runs raids with no clock'};
       __startRaid({mapIx:0,seed:4242});
       var g=__state(); if(!g||!g.player) return null;
       var p=g.player;
       g.ents.length=0;
       var z=null; for(var i=0;i<g.zones.length;i++) if(g.zones[i].open!==false){ z=g.zones[i]; break; }
       if(!z) return {skip:'no open ring to board at'};
       z.beaconT=0; z.hold=25; z.holdMax=25; z.callT=0; z.pullT=null;
       g.active=z; g.beaconT=0; g.shipHold=25; g.shipHoldMax=25;
       p.x=z.x; p.y=z.y; p.iv=99; p.downed=false;
       g.timeLeft=tl;
       var K=__keysRef(); for(var k in K) K[k]=false; K['KeyE']=true;
       var f=0;
       for(;f<150&&__state()&&!__state().over;f++) __loop(performance.now()+f*16.7);
       K['KeyE']=false;
       var s2=__state();
       return {over:(s2?s2.over:'gone'), pull:z.pullT, frames:f};
     }
     try{
       // THE FINDING: one second on the clock, E held in a landed ring.
       var A=board(1.0);
       if(A===null) return 'SKIP: no live raid';
       if(A.skip) return 'SKIP: '+A.skip;
       if(A.over!=='extract') bad.push('holding E in a landed ring with one second left ended the raid as '+A.over+' after '+A.frames+' frames, pull at '+A.pull);
       // CONTROL: five seconds left, the same hold extracts.
       var B=board(5.0);
       if(B&&!B.skip&&B.over!=='extract') bad.push('control: the same hold with five seconds left ended as '+B.over+', so this check cannot see a boarding');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ var K3=__keysRef(); for(var k3 in K3) K3[k3]=false; }catch(_k){}
       try{ P2.stash=keep.st; P2.weapons=keep.w; P2.credits=keep.cr; P2.equipped=keep.eq; P2.equippedSec=keep.es; saveProfile(); }catch(_s){}
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.78',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
