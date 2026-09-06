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

# v11.46 CHECK, before the v11.45 entry. THE LINE-OF-SIGHT HARNESS the STILL OPEN
# line asked for: both parties parked off the built map where there are no walls,
# the pillager facing the player, hostile, in extract (a state that persists while
# he sees you), cooldown clear. Sight is asserted through the game's own canSee
# before anything is counted, so a bad seat skips rather than passing.
SubRx @'
  {v:'11.45',what:'the title screen does not answer the floor keys: P and ESC on the boot title leave the pause box closed, ENTER there does not stamp the NEW IN card as seen, and ENTER still starts the game',
'@ @'
  {v:'11.46',what:'a hostile pillager who can see you and is not chasing gets ONE beat and then fires, instead of having his cooldown floored every frame so he never shoots; and a pillager facing away with no sight of you still does not fire',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__rawStep&&window.__nav&&__nav.canSee)) return 'SKIP: this fixture cannot stage a line-of-sight shot';
     var bad=[], dt=0.15;
     function stage(faceAtPlayer){
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g.player, R=null, i;
       for(i=0;i<g.ents.length;i++){ var e=g.ents[i]; if(e.kind==='raider'&&!e.downed&&!e.finished&&!e.merc){ R=e; break; } }
       if(!R) return null;
       // OPEN GROUND: off the map to the north-west, no walls anywhere near, so
       // sight is a matter of geometry, not luck. The player is pinned and does
       // nothing; the pillager stands 150 units east and faces west (PI) at him,
       // or east (0) away from him for the control.
       function pin(){ p.x=-2000; p.y=-2000; p.downed=false; R.x=p.x+150; R.y=p.y; R.face=faceAtPlayer?Math.PI:0; R.state='extract'; R.hostile=true; R.friendlyPC=0; R.merc=0; R.downed=false; R.finished=false; }
       pin(); R.cd=0; R.windup=null; R.alert=2; R.beat=0;
       var sees=null; try{ sees=!!__nav.canSee(R.x,R.y,R.face,p.x,p.y,g.vseg,Math.max(R.rng||0,600),R.cone,100); }catch(e2){ sees=null; }
       var b0=g.bullets.length;
       for(var s=0;s<60;s++){ pin(); __rawStep(dt); }
       return {sees:sees, fired:__state().bullets.length-b0, rng:R.rng, tooFar:(150>=(R.rng||0))};
     }
     // THE FINDING: facing him, in clear sight, he must fire after one beat.
     var on=stage(true);
     if(!on) return 'SKIP: no pillager to stage';
     if(on.tooFar) return 'SKIP: the gun of the staged pillager reaches only '+Math.round(on.rng)+' units, inside the 150 unit seat';
     if(on.sees===false) return 'SKIP: the staged pillager cannot see the pinned player even in open ground, so the seat is wrong, not the game';
     if(on.fired<1) bad.push('a hostile pillager in extract with clear sight of you at 150 units fired '+on.fired+' rounds in nine seconds, so his reaction beat is still a permanent floor');
     // CONTROL: facing AWAY, no sight, he stays quiet - the beat fix did not make him shoot blind.
     var off=stage(false);
     if(off&&off.fired>0) bad.push('control: a pillager facing away with no sight of you fired '+off.fired+' rounds, so the beat fix made him shoot blind');
     if(off&&off.sees===true) bad.push('control: the game says the pillager facing away can see the player, so the seat does not isolate sight');
     __topClear();
     return bad.length?bad.join('; '):null; }},
  {v:'11.45',what:'the title screen does not answer the floor keys: P and ESC on the boot title leave the pause box closed, ENTER there does not stamp the NEW IN card as seen, and ENTER still starts the game',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
