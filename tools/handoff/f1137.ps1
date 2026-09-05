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
  {v:'11.36',what:'a frag by the Peddler does not send him chasing and does not move his pitch; a frag by a downed pillager leaves him down; a frag by a live crawler still turns it to chase',
'@ @'
  {v:'11.37',what:'a machine hit on a pillager you have won over does not turn him against you or write a grudge (provokeReal 1); a hit you land does; the old hitT reading (provokeReal 0) turns him on the machine hit',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__rawStep&&window.__cfg&&window.__los)) return 'SKIP: this fixture cannot step a raid with line of sight';
     var bad=[];
     // A friendlyPC pillager (one you parleyed) HOLDS even while he sees you,
     // so this isolates the hit: a passive seeing pillager engages on sight and
     // could not tell a machine hit from a decision, but a friendlyPC man does
     // not engage, so a flip there is the hit and nothing else. Placed with a
     // clear line to the player and more than 180 units off.
     function seat(provoke){
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile(); __cfg({provokeReal:provoke});
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g.player, R=null, i;
       for(i=0;i<g.ents.length;i++){ var e=g.ents[i]; if(e.kind==='raider'&&!e.merc){ R=e; break; } }
       if(!R) return null;
       R.hostile=false; R.friendlyPC=1; R.grudge=false; R.downed=false; R.finished=false; R.state='loot'; R.cone=1.4; R.alert=0.5;
       var placed=false;
       for(var a=0;a<16;a++){ var ang=a*0.3927, ex=p.x+Math.cos(ang)*260, ey=p.y+Math.sin(ang)*260;
         if(__los.clear(ex,ey,p.x,p.y)){ R.x=ex; R.y=ey; R.face=Math.atan2(p.y-ey,p.x-ex); R._ex=ex; R._ey=ey; R._af=R.face; placed=true; break; } }
       return {p:p,R:R,placed:placed};
     }
     function run(o,useP){ for(var s=0;s<3;s++){ o.R.x=o.R._ex; o.R.y=o.R._ey; o.R.face=o.R._af; o.R.hitT=0.2; o.R.pHitT=useP?0.3:0; o.R.grudge=(o.R.grudge&&false); __rawStep(0.15); if(o.R.hostile||!o.R.friendlyPC) break; } }
     // ARM A, provokeReal 1, a machine hit (hitT only): he stays loyal.
     var A=seat(1); if(!A||!A.R) return 'SKIP: no pillager available';
     if(!A.placed) return 'SKIP: no clear line of sight to the player at 260 units on this seed';
     run(A,false);
     if(!A.R.friendlyPC||A.R.hostile) bad.push('with provokeReal 1 a machine hit turned a won-over pillager against you (friendlyPC '+A.R.friendlyPC+', hostile '+A.R.hostile+')');
     // ARM B, provokeReal 1, a hit YOU land (pHitT): he turns, as betrayal should.
     var B=seat(1); if(B&&B.placed){ run(B,true);
       if(B.R.friendlyPC||!B.R.hostile) bad.push('control: with provokeReal 1 a hit you landed did not turn a won-over pillager, so the fix disarmed betrayal (friendlyPC '+B.R.friendlyPC+', hostile '+B.R.hostile+')'); }
     // ARM C, provokeReal 0, a machine hit: the old reading turns him, which the dial restores.
     var C=seat(0); if(C&&C.placed){ if(__cfg().provokeReal!==0) return 'SKIP: provokeReal cannot be set to 0 here';
       run(C,false);
       if(C.R.friendlyPC&&!C.R.hostile) bad.push('control: with provokeReal 0 a machine hit did NOT turn the won-over pillager, so the dial does not restore the old behaviour and the finding proves nothing'); }
     __topClear();
     return bad.length?bad.join('; '):null; }},
  {v:'11.36',what:'a frag by the Peddler does not send him chasing and does not move his pitch; a frag by a downed pillager leaves him down; a frag by a live crawler still turns it to chase',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
