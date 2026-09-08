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

# v12.45 CHECK, inserted before the v12.44 entry. Fifteen seconds of a real
# hold at the real seal, driven by the real key through the real frame loop,
# with the roster cleared so nothing interrupts and a beacon already inbound so
# the extraction clock has something to lose. Everything asserted is a RISE
# against a staged starting value rather than a level, and the control is the
# same fifteen seconds standing beside the seal without cutting, which is what
# the health bar is supposed to do and what the frozen one did not.
SubRx @'
  {v:'12.44',what:'the boarding window never outlives the raid clock: a ship landing with two seconds left announces what the raid actually has and not the three second floor, on the number and on the ring badge alike, while a full clock and a raid with the clock switched off both still give the ordinary thirty seconds (2026-09-07 audit)',
'@ @'
  {v:'12.45',what:'cutting the seal no longer stops the world: through the whole hold his health recovers as it does standing anywhere else and a ship already called keeps coming, while the cut itself still advances at the same rate (2026-09-07 audit, the same fault as v12.34 one door along)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__loop&&window.__keys)) return 'SKIP: this fixture cannot deploy and drive the player';
     if(typeof tickRegen!=='function'||typeof tryExtractTick!=='function') return 'SKIP: this build has no recovery or extraction tick to carry past the return';
     var bad=[];
     // Fifteen seconds of raid at the largest step the frame clock will take,
     // holding E or not, standing at the seal either way.
     function hold(cutting){
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],mapIx:0,seed:4242});
       var g=__state(); if(!g||!g.player) return null;
       if(!g.seal||g.seal.done) return {none:'this map and seed has no uncut seal to stand at'};
       var p=g.player, K=__keys(), k, i;
       for(k in K) delete K[k];
       g.ents.length=0;                          // nobody to interrupt the hold
       p.downed=false; p.roll=0; p.hp=60; p.maxhp=Math.max(100,p.maxhp||100);
       p.combatT=20; p.regenAcc=0; p.healQ=0; p.cooking=0;
       p.x=g.seal.x+30; p.y=g.seal.y;
       var z=g.active||g.zones[0];
       if(z){ g.active=z; z.open=true; z.beaconT=25; z.hold=null; g.beaconT=25; }
       var cut0=(g.seal.gained||0), hp0=p.hp, ct0=p.combatT, bt0=(z?z.beaconT:null);
       if(cutting) K.KeyE=1;
       var clk=Math.max((typeof performance!=='undefined'&&performance.now)?performance.now():0,(lastTs||0)+100);
       for(i=0;i<300;i++){ p.iv=99; clk+=50; __loop(clk); }
       for(k in K) delete K[k];
       return {cut:(g.seal.gained||0)-cut0,hp:p.hp-hp0,ct:p.combatT-ct0,
               bt:(z&&bt0!==null)?(bt0-z.beaconT):null,near:!!g.nearSeal};
     }
     var keepTs=lastTs;
     try{
       // THE FINDING: fifteen seconds of a real cut.
       var A=hold(true);
       if(!A) return 'SKIP: no live raid to stand in';
       if(A.none) return 'SKIP: '+A.none;
       if(!A.near) return 'SKIP: standing 30 units from the seal did not put him at the door, so nothing here is a cut';
       if(!(A.cut>=12)) return 'SKIP: fifteen seconds of holding the key advanced the cut by only '+Math.round(A.cut)+' seconds, so the hold under test never ran';
       if(!(A.ct>=12)) bad.push('through '+Math.round(A.cut)+' seconds of cutting, the recovery clock advanced '+Math.round(A.ct)+' seconds, so the clock that decides when he heals does not run while he cuts');
       if(!(A.hp>=4)) bad.push('through '+Math.round(A.cut)+' seconds of cutting he recovered '+Math.round(A.hp)+' health, so the bar is flat for the whole of a hold that lasts up to two minutes');
       if(A.bt!==null&&!(A.bt>=12)) bad.push('through '+Math.round(A.cut)+' seconds of cutting, a ship already called came only '+Math.round(A.bt)+' seconds closer, so an extraction he had already paid for stops while he makes the loudest noise in the game');
       // CONTROL: the same fifteen seconds standing beside the seal, not cutting.
       // This is what the bar is supposed to do, and it is what the frozen one
       // did not; without it a zero above could be the room rather than the bug.
       var B=hold(false);
       if(B&&!B.none){
         if(!(B.hp>=4)) bad.push('control: standing beside the seal without cutting he recovered only '+Math.round(B.hp)+' health in fifteen seconds, so this check cannot see recovery at all and its findings prove nothing');
         if(B.cut>0.5) bad.push('control: the seal advanced '+Math.round(B.cut)+' seconds with the key not held, so the staging cuts by itself');
         if(B.bt!==null&&!(B.bt>=12)) bad.push('control: a called ship came only '+Math.round(B.bt)+' seconds closer while he stood still, so this check cannot see the extraction clock at all');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ var K3=__keys(); for(var k3 in K3) delete K3[k3]; }catch(_k){}
       try{ lastTs=keepTs; }catch(_t){}
       try{ var gz=__state(); if(gz&&!gz.over){ gz.player.downed=false; gz.player.iv=0; __endRaid('abandon'); } }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'12.44',what:'the boarding window never outlives the raid clock: a ship landing with two seconds left announces what the raid actually has and not the three second floor, on the number and on the ring badge alike, while a full clock and a raid with the clock switched off both still give the ordinary thirty seconds (2026-09-07 audit)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
