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

if ($s.Contains("  {v:'26.07',what:")) { throw "check 26.07 is in the fixture already" }

SubRx @'
  {v:'26.06',what:
'@ @'
  {v:'26.07',what:'his note (too many bots at extract): the siege is a flat base plus a haul share capped at 5 machines, the wave director holds its spawns while a ring is called, and a full CAREER haul brings a third fewer machines in the 30 s wait than the 15 before',
   run:function(){
     if(!window.__deploy||!window.__endRaid||!window.__state||typeof tickExtractPoints!=='function'||typeof tickRaiderWaves!=='function'||typeof arcadeWaveTick!=='function'||typeof bagValue!=='function'||typeof ival!=='function'||typeof CAREER_ON!=='number') return 'SKIP: no siege, waves or CAREER raid here';
     var bad=[], c0=CAREER_ON, ks=[], k, g=null, p=null, Z=null, i, dt=1/30, L, M, F, made=0, w0;
     for(k in ITEMS) if(Object.prototype.hasOwnProperty.call(ITEMS,k)&&!ITEMS[k].use&&ival(k)>0) ks.push(k);
     ks.sort(function(a,b){ return ival(b)-ival(a); });
     if(!ks.length) return 'SKIP: no valuable to stage a haul';
     function stageBag(v){ var n=0, j, pick; g.bag.length=0; while(bagValue()<v&&n<400){ n++; pick=ks[ks.length-1]; for(j=0;j<ks.length;j++) if(bagValue()+ival(ks[j])<=v+1500){ pick=ks[j]; break; } g.bag.push(pick); } }
     function call(v,score,secs){
       var r={at30:null,end:null,greed:0}, snap, f, n=Math.round(secs/dt);
       g.ents.length=0; stageBag(v); g.cs.s=score; g.cs.waveT=0; g.cs.waveN=0; g.waveT=0; g.waveN=0;
       snap=g.ents.slice();
       function cnt(){ var o={s:0,w:0,o:0}, j, e; for(j=0;j<g.ents.length;j++){ e=g.ents[j]; if(snap.indexOf(e)>=0) continue; if(e.siegeBorn) o.s++; else if(e.arcWave) o.w++; else o.o++; } return o; }
       Z.beaconT=CFG.extractWait; Z.hold=null; Z.siegeSpawned=0; Z.siegeSpawnT=0; Z.siegeGreed=null; Z.pullN=0; Z.pinged=0; Z.siege=0; Z.callT=0;
       g.active=Z; g.beaconT=Z.beaconT; g.siegeSpawned=0; g.siegeSpawnT=0; g.siege=0;
       for(f=0;f<n;f++){
         g.frameN=(g.frameN||0)+1; g.t=(+g.t||0)+dt; p.x=Z.x; p.y=Z.y;
         tickExtractPoints(dt); tickRaiderWaves(dt); arcadeWaveTick(dt);
         if(f===Math.round(30/dt)-1) r.at30=cnt();
       }
       r.end=cnt(); r.greed=+(+Z.siegeGreed).toFixed(3);
       return r;
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __cleanProfile();
       CAREER_ON=1;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.career||!g.cs) return 'SKIP: no CAREER raid in this build';
       p=g.player; keys={}; p.iv=99; p.hp=p.maxhp=100000;
       for(i=0;i<(g.zones||[]).length&&!Z;i++) if(g.zones[i].open) Z=g.zones[i];
       if(!Z) return 'SKIP: no open ring';
       // a light, a middling and a full haul, each with the score that goes with it (tier 0, 3 and 6 of the wave director), a fresh wave clock, 62 s so the boarding window runs too
       L=call(2000,3000,62); M=call(10000,12000,62); F=call(24000,24000,62);
       if(!(F.greed>=0.99)||!(L.greed<0.2)) return 'SKIP: staging: the hauls gave greed '+L.greed+' and '+F.greed;
       if(F.end.s<1) return 'SKIP: staging: a full haul brought no siege at all';
       // NO WAVE SPAWNS NEAR THE RING WHILE IT IS CALLED, at any haul
       [['light',L],['middling',M],['full',F]].forEach(function(q){ if(q[1].at30.w+q[1].at30.o>0) bad.push('a '+q[0]+' haul: '+q[1].at30.w+' wave bodies and '+q[1].at30.o+' reinforcements spawned in the 30 s wait of a called ring'); });
       // A FULL HAUL: about a third fewer than the 15 (5 siege machines and 10 wave bodies) the old build brought in the same 30 s
       if(F.at30.s+F.at30.w+F.at30.o>10) bad.push('a full haul brought '+(F.at30.s+F.at30.w+F.at30.o)+' machines in the 30 s wait, more than two thirds of the old 15');
       // A LIGHT HAUL STILL BRINGS A COUPLE, so extracting stays tense
       if(L.at30.s<2) bad.push('a light haul brought '+L.at30.s+' siege machines in the 30 s wait, under a couple');
       // THE HAUL IS CAPPED: a full haul brings at most 5 more machines than a light one over the whole call, still more than a light one, and the middling one sits between
       if(F.end.s-L.end.s>5) bad.push('a full haul brought '+F.end.s+' machines and a light one '+L.end.s+', more than 5 apart');
       if(!(F.end.s>L.end.s)) bad.push('control: a full haul brought '+F.end.s+' machines and a light one '+L.end.s+', so the haul changes nothing');
       if(!(M.end.s>=L.end.s&&M.end.s<=F.end.s)) bad.push('a middling haul brought '+M.end.s+' machines, not between the light '+L.end.s+' and the full '+F.end.s);
       // THE CLOCK STANDS STILL while a ring is called, and the director comes back when none is
       g.ents.length=0; Z.beaconT=20; g.cs.waveT=5; w0=arcadeWaveTick(2);
       if(w0||g.cs.waveT!==5) bad.push('the wave clock ran during a called ring ('+g.cs.waveT+' of 5)');
       Z.beaconT=null; Z.hold=null; g.ents.length=0;
       for(i=0;i<40&&!made;i++){ g.cs.waveT=999; made=arcadeWaveTick(0.016); }
       if(!(made>0)) bad.push('control: with no ring called the wave director spawned nothing either');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{ try{ CAREER_ON=c0; }catch(_c){} try{ __resetCfg(); }catch(_r){} keys={}; try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'26.06',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
