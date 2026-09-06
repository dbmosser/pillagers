$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
# Replace the whole 11.46 check (from its first line up to the 11.45 entry) with the
# confirmed ring seat. Regex on the two unique anchors; exactly one match required.
$start=[regex]::Escape("  {v:'11.46',what:")
$end=[regex]::Escape("  {v:'11.45',what:")
$pat="(?s)$start.*?(?=$end)"
$c=([regex]::Matches($s,$pat)).Count
if($c -ne 1){ throw "11.46 block matched $c times" }
$new=@'
  {v:'11.46',what:'a hostile pillager standing in the extraction ring who can see you returns fire after ONE beat, instead of having his cooldown floored every frame so he never shoots; and a downed player is still not fired on',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__rawStep&&window.__see&&window.__cfg)) return 'SKIP: this fixture cannot stage the ring seat';
     var bad=[], dt=0.15;
     function seat(downed){
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       // The beacon call and the rival feud both pull a man OUT of the ring block
       // (standoff, or a fight with a rival crew), and the fire block only runs
       // inside it, so both are pinned off for the seat. Harness pins, not the game.
       __cfg({raiderBeacon:0, raiderFeud:0});
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g.player, z=g.active, R=null, i;
       if(!z) return null;
       for(i=0;i<g.ents.length;i++){ var e=g.ents[i]; if(e.kind==='raider'&&!e.downed&&!e.finished&&!e.merc){ R=e; break; } }
       if(!R) return null;
       __rawStep(dt);   // builds the sight segments
       // THE SEAT: the pillager at the ring centre (the extract fire block only runs
       // inside the ring), the player 60 units west, inside the ring too so the line
       // of sight never crosses the pylon edge. He faces the player, hostile, in
       // extract, cooldown clear, beat unarmed. Both re-pinned every step.
       function pin(){ R.x=z.x; R.y=z.y; p.x=z.x-60; p.y=z.y; p.downed=!!downed; R.face=Math.PI; R.state='extract'; R.hostile=true; R.friendlyPC=0; R.merc=0; R.downed=false; R.finished=false; R.extracting=0; }
       pin(); R.cd=0; R.windup=null; R.alert=2; R.beat=0; R.beatLost=0; R.acqT=0;
       var sees=null; try{ sees=!!__see(R.x,R.y,R.face,p.x,p.y,g.vseg,600,R.cone,100); }catch(e2){ sees=null; }
       var inRing=(Math.sqrt((R.x-z.x)*(R.x-z.x)+(R.y-z.y)*(R.y-z.y))<z.r);
       var near=0, first=-1;
       for(var s=0;s<60;s++){ pin(); __rawStep(dt);
         for(var b=0;b<g.bullets.length;b++){ var B=g.bullets[b]; if(!B.__cnt){ var dx=B.x-R.x, dy=B.y-R.y; if(dx*dx+dy*dy<3600){ B.__cnt=1; near++; if(first<0) first=s; } } } }
       return {sees:sees, inRing:inRing, fired:near, first:first};
     }
     var on=seat(false);
     if(!on) return 'SKIP: no active ring or no pillager to stage';
     if(!on.inRing) return 'SKIP: the pillager could not be seated inside the ring';
     if(on.sees===false) return 'SKIP: the game says the seated pillager cannot see the player, so the seat is wrong, not the game';
     // THE FIX: in the ring, with sight, he returns fire after one beat.
     if(on.fired<1) bad.push('a hostile pillager in the extraction ring with sight of you at 60 units fired '+on.fired+' rounds in nine seconds, so his reaction beat is still a permanent floor');
     // CONTROL: a downed player is not fired on, so the fix did not make him shoot regardless of the gate.
     var off=seat(true);
     if(off&&off.fired>0) bad.push('control: with the player downed he fired '+off.fired+' rounds, so the fix made him shoot regardless of the gate');
     __topClear(); __resetCfg();
     return bad.length?bad.join('; '):null; }},

'@
$s=[regex]::Replace($s,$pat,{ param($m) $new })
[IO.File]::WriteAllText($p,$s,(New-Object Text.UTF8Encoding $false))
Write-Output "OK, 11.46 check replaced"
