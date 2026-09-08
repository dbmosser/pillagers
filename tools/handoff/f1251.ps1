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

# v12.51 CHECK, inserted before the v12.50 entry. One Howler alone on an empty
# map with the man parked far outside its reach, so the branch that shells a man
# it can SEE cannot fire at all and the only door left is the report he left
# behind, which is the whole subject. The finding is measured as a DECAY, not a
# level: eight seconds of bearing must have run down by the time the first shell
# lands, and on the old build its own gun winds that back up to eight. The count
# is the supporting number and its ceiling is honest rather than calibrated on
# the bug: an eight second bearing against a five to seven second cooling allows
# a second shell at the same bearing and no more.
SubRx @'
  {v:'12.50',what:'breaking a Crier line of sight for three seconds actually cancels its alarm instead of firing it on the same frame, and the three seconds have to be unbroken; a Crier that keeps eyes on him still raises the alarm exactly as before (2026-09-07 audit)',
'@ @'
  {v:'12.51',what:'a Howler does not shell its own crater: its own gun no longer winds its eight second bearing back to full or moves that bearing onto the burst, and its cooling is its own clock rather than the wander timer, so one noise from a man who then goes quiet brings the shells the bearing honestly allows and no barrage (2026-09-07 audit)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__loop)) return 'SKIP: this fixture cannot deploy a raid and drive a frame';
     if(typeof mkHowler!=='function'||typeof listenersHear!=='function') return 'SKIP: this build has no Howler or no hearing sweep';
     var bad=[];
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],mapIx:0,seed:4242});
       var g=__state(); if(!g||!g.player) return 'SKIP: no live raid to be heard in';
       var p=g.player, i, q, sh;
       g.ents.length=0; g.shells.length=0;      // one Howler and nothing else at all
       p.downed=false; p.iv=99; p.roll=0; p.hp=100; p.moving=false;
       var hw=mkHowler(p.x+400,p.y);
       if(!hw) return 'SKIP: this build would not build a Howler';
       hw.state='patrol'; hw.cd=0; hw.mortT=0; hw.hearT=0; hw.alert=0; hw.elite=0;
       hw.hp=hw.maxhp||hw.hp; hw.downed=false; hw.finished=false; hw.overheat=0;
       g.ents.push(hw);
       // THE MAN IS GONE, WHICH IS THE WHOLE POINT. He is parked far outside the
       // gun reach, so the branch that shells a man it can SEE cannot fire at all
       // and the only door left is the report he left behind. Anything less than
       // this measures an ordinary shelling of a man it is looking at.
       var W=g.map.cols*g.map.cw, H=g.map.rows*g.map.ch;
       p.x=Math.min(W-60,Math.max(60,hw.x+2400)); p.y=Math.min(H-60,Math.max(60,hw.y+2400));
       if(Math.sqrt((p.x-hw.x)*(p.x-hw.x)+(p.y-hw.y)*(p.y-hw.y))<(hw.rng||900)+200)
         return 'SKIP: this map is too small to park him outside the gun reach, so a shelling of a man it can see could not be told from a shelling of his report';
       // THE NOISE, four hundred units off the gun and under open sky, because a
       // report under a roof is refused and this check would measure nothing.
       var _rf=(typeof roofAt==='function')?roofAt:null, NX=0, NY=0, _b;
       for(_b=0;_b<12&&!NX;_b++){
         var _a=_b*0.523, _cx=hw.x+Math.cos(_a)*400, _cy=hw.y+Math.sin(_a)*400;
         if(_cx<60||_cy<60||_cx>W-60||_cy>H-60) continue;
         if(!_rf||(!_rf(_cx,_cy)&&!_rf(hw.x,hw.y))){ NX=_cx; NY=_cy; }
       }
       if(!NX) return 'SKIP: no open sky four hundred units from the gun on this seed, so the shot would be refused for a roof and nothing here would be measured';
       // ONE NOISE, and then twenty seconds of silence.
       listenersHear(NX,NY,300,true);
       if(!(hw.hearT>0)) return 'SKIP: the staged noise was not heard at four hundred units, so there is no bearing here to measure';
       var fired=0, afterFirst=null, landed=0, T=0, keepTs=lastTs;
       var clk=Math.max((typeof performance!=='undefined'&&performance.now)?performance.now():0,(lastTs||0)+100);
       for(i=0;i<400;i++){
         var before=0; for(q=0;q<g.shells.length;q++) if(g.shells[q].mortar) before++;
         p.iv=99; clk+=50; __loop(clk); T+=0.05;
         var after=0;
         for(q=0;q<g.shells.length;q++){ sh=g.shells[q];
           if(sh.mortar){ after++; if(!sh.__counted){ sh.__counted=1; fired++; } } }
         // The frame a shell has just landed: read the bearing straight away,
         // before the clock has had time to run down and blur the difference.
         if(after<before&&landed===0){
           landed=1; afterFirst={t:T,hearT:hw.hearT,hx:hw.heardX,hy:hw.heardY};
         }
       }
       try{ lastTs=keepTs; }catch(_t){}
       if(!fired) return 'SKIP: the Howler fired nothing at all in twenty seconds, so this check cannot see a shell';
       if(!afterFirst) return 'SKIP: no shell landed inside twenty seconds, so the impact under test never happened';
       // THE FINDING, measured as a DECAY against the clock rather than a level.
       var want=8-afterFirst.t+0.3;
       if(afterFirst.hearT>want)
         bad.push('the Howler heard its own gun: '+afterFirst.t.toFixed(1)+' seconds after the noise its eight second bearing reads '+afterFirst.hearT.toFixed(1)+' rather than the '+Math.max(0,want-0.3).toFixed(1)+' it should have run down to, so its own shell has wound it back up to full');
       var moved=Math.sqrt((afterFirst.hx-NX)*(afterFirst.hx-NX)+(afterFirst.hy-NY)*(afterFirst.hy-NY));
       if(moved>1)
         bad.push('the Howler moved its bearing onto its own noise: it was aiming at the report and is now aiming '+Math.round(moved)+' units away, at the hole it made or the spot it fired from');
       // THE SUPPORTING NUMBER, with an honest ceiling: the bearing lasts eight
       // seconds and the cooling is five and a half to seven, so a second shell
       // at the same bearing is the design and a third is the barrage.
       if(fired>2)
         bad.push('a man who made one noise and then went silent for twenty seconds, out of sight the whole time, was shelled '+fired+' times, and an eight second bearing against a five to seven second cooling allows two at the most');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ var gz=__state(); if(gz){ if(gz.ents) gz.ents.length=0; if(gz.shells) gz.shells.length=0;
         if(gz.player) gz.player.iv=0; } }catch(_a){}
       try{ var g2=__state(); if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'12.50',what:'breaking a Crier line of sight for three seconds actually cancels its alarm instead of firing it on the same frame, and the three seconds have to be unbroken; a Crier that keeps eyes on him still raises the alarm exactly as before (2026-09-07 audit)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
