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
# map, four hundred units from a single staged noise, pointed away so it cannot
# see him, and then twenty seconds of raid with the man making no sound at all.
# The finding is measured as a DECAY, not a level: eight seconds of bearing must
# have run down by the time the first shell lands, and on the old build the
# impact winds it back up to eight. The shell count is the supporting number and
# its ceiling is honest: an eight second bearing against a five to seven second
# cooldown allows a second shell at the same bearing and no more.
SubRx @'
  {v:'12.50',what:'breaking a Crier line of sight for three seconds actually cancels its alarm instead of firing it on the same frame, and the three seconds have to be unbroken; a Crier that keeps eyes on him still raises the alarm exactly as before (2026-09-07 audit)',
'@ @'
  {v:'12.51',what:'a Howler does not shell its own crater: its own impact no longer winds its eight second bearing back to full or moves that bearing onto the burst, so one noise from a man who then goes quiet brings the shells the bearing honestly allows and no barrage (2026-09-07 audit)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__ents&&window.__endRaid)) return 'SKIP: this fixture cannot deploy a raid and step the machines';
     if(typeof mkHowler!=='function'||typeof listenersHear!=='function'||typeof updateThrowables!=='function') return 'SKIP: this build has no Howler, no hearing sweep or no shells to step';
     var bad=[];
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],mapIx:0,seed:4242});
       var g=__state(); if(!g||!g.player) return 'SKIP: no live raid to be heard in';
       var p=g.player, i;
       g.ents.length=0; g.shells.length=0;      // one Howler and nothing else at all
       p.downed=false; p.iv=99; p.roll=0; p.hp=100; p.moving=false;
       var hw=mkHowler(p.x+400,p.y);
       if(!hw) return 'SKIP: this build would not build a Howler';
       // Pointed AWAY from him, so nothing here can come down the sighted path:
       // that branch needs sight or an alert above 1.2, and the impact noise
       // only ever lifts an alert to 1.
       hw.face=Math.atan2(hw.y-p.y,hw.x-p.x);
       hw.state='patrol'; hw.cd=0; hw.hearT=0; hw.alert=0; hw.elite=0;
       hw.hp=hw.maxhp||hw.hp; hw.downed=false; hw.finished=false; hw.overheat=0;
       g.ents.push(hw);
       // ONE NOISE, at his feet, and then silence for twenty seconds.
       var NX=p.x, NY=p.y;
       listenersHear(NX,NY,300,true);
       if(!(hw.hearT>0)) return 'SKIP: the staged noise was not heard at four hundred units, so there is no bearing here to measure';
       var fired=0, afterFirst=null, landed=0, T=0, sh;
       for(i=0;i<400;i++){
         for(var q=0;q<g.shells.length;q++){ sh=g.shells[q];
           if(sh.mortar&&!sh.__counted){ sh.__counted=1; fired++; } }
         var before=0; for(var m0=0;m0<g.shells.length;m0++) if(g.shells[m0].mortar) before++;
         __ents(0.05); updateThrowables(0.05); T+=0.05;
         // The frame a shell has just landed: read the bearing straight away,
         // before the clock has had time to run down and blur the difference.
         for(var q2=0;q2<g.shells.length;q2++){ sh=g.shells[q2];
           if(sh.mortar&&!sh.__counted){ sh.__counted=1; fired++; } }
         var after=0; for(var m1=0;m1<g.shells.length;m1++) if(g.shells[m1].mortar) after++;
         if(after<before&&landed===0){
           landed=1; afterFirst={t:T,hearT:hw.hearT,hx:hw.heardX,hy:hw.heardY};
         }
       }
       if(!fired) return 'SKIP: the Howler fired nothing at all in twenty seconds, so this check cannot see a shell';
       if(!afterFirst) return 'SKIP: no shell landed inside twenty seconds, so the impact under test never happened';
       // THE FINDING, measured as a DECAY against the clock rather than a level.
       var want=8-afterFirst.t+0.3;
       if(afterFirst.hearT>want)
         bad.push('the Howler heard its own shell land: '+afterFirst.t.toFixed(1)+' seconds after the noise its eight second bearing reads '+afterFirst.hearT.toFixed(1)+' rather than the '+Math.max(0,want-0.3).toFixed(1)+' it should have run down to, so the crater has wound it back up to full');
       var moved=Math.sqrt((afterFirst.hx-NX)*(afterFirst.hx-NX)+(afterFirst.hy-NY)*(afterFirst.hy-NY));
       if(moved>1)
         bad.push('the Howler moved its bearing onto its own crater: it was aiming at the noise and is now aiming '+Math.round(moved)+' units away at the hole it just made');
       // THE SUPPORTING NUMBER, with an honest ceiling: the bearing lasts eight
       // seconds and the cooldown is five and a half to seven, so a second shell
       // at the same bearing is the design and a third is the barrage.
       if(fired>2)
         bad.push('a man who made one noise and then went silent for twenty seconds was shelled '+fired+' times, and an eight second bearing against a five to seven second cooldown allows two at the most');
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
