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

# v12.50 CHECK, inserted before the v12.49 entry. One Crier alone on the map,
# already in its alarm with the windup still running and the counter one
# hundredth of a second short of the three seconds. One step of the machines
# takes it over, which is the exact frame the cancel is supposed to happen and
# the exact frame the old code fired the alarm instead. The control is the same
# Crier with the same windup and the player in plain sight: the alarm must still
# fire, or a build that simply broke the Crier would read green.
SubRx @'
  {v:'12.49',what:'a Howler shell bursting in the street does not reach through a solid wall: the man forty units inside loses nothing and a pillager behind the same wall loses nothing, while the same shell still hurts anyone standing in the open the same distance away (2026-09-07 audit, the remaining half of his 2026-09-06 note)',
'@ @'
  {v:'12.50',what:'breaking a Crier line of sight for three seconds actually cancels its alarm instead of firing it on the same frame, and the three seconds have to be unbroken; a Crier that keeps eyes on him still raises the alarm exactly as before (2026-09-07 audit)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__ents&&window.__endRaid)) return 'SKIP: this fixture cannot deploy a raid and step the machines';
     if(typeof mkSnitch!=='function') return 'SKIP: this build has no Crier to stage';
     var bad=[];
     // Assembled, never written whole: a check that greps the page for a line it
     // spells out finds itself, which has cost three builds already.
     var RAISED='The Crier raised '+'the alarm';
     function arm(hidden){
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],mapIx:0,seed:4242});
       var g=__state(); if(!g||!g.player) return null;
       var p=g.player;
       g.ents.length=0;                      // one Crier and nobody else at all
       p.downed=!!hidden; p.iv=99; p.roll=0; p.hp=100;
       var cr=mkSnitch(p.x+240,p.y);
       if(!cr) return {none:'this build would not build a Crier'};
       cr.face=Math.atan2(p.y-cr.y,p.x-cr.x);
       cr.state='alarm'; cr.wind=3.9; cr.lost=hidden?2.99:0; cr.markX=p.x; cr.markY=p.y;
       cr.hp=cr.maxhp||cr.hp; cr.downed=false; cr.finished=false; cr.overheat=0;
       if(!hidden) cr.wind=0.01;             // the control is a windup about to end
       g.ents.push(cr);
       g.marked=0; if(g.tel) g.tel.marked=0;
       g.msg='';
       var m0=g.marked||0, t0=(g.tel&&g.tel.marked)||0;
       __ents(0.05);
       return {state:cr.state,wind:cr.wind,lost:cr.lost,
               marked:(g.marked||0)-m0,tel:((g.tel&&g.tel.marked)||0)-t0,
               said:String(g.msg||'')};
     }
     try{
       // THE FINDING: he has been out of its sight for three seconds, which is
       // the one thing the game says calls an alarm off.
       var A=arm(true);
       if(!A) return 'SKIP: no live raid to stage a Crier in';
       if(A.none) return 'SKIP: '+A.none;
       if(A.state==='alarm') return 'SKIP: three seconds out of sight did not take the Crier out of its alarm at all, so the cancel under test never ran';
       if(A.said.indexOf(RAISED)>=0)
         bad.push('the cancel fired the alarm it was cancelling: three seconds out of sight put the Crier back on patrol and it called the alarm in on the very same frame, saying "'+A.said+'"');
       if(A.marked>0) bad.push('the cancelled alarm still marked him: the marked flag went up by '+A.marked+' on the frame the alarm was called off');
       if(A.tel>0) bad.push('the cancelled alarm still counted against him: the marked figure in his run report went up by '+A.tel);
       if(A.wind!==null&&A.wind!==undefined&&A.wind<0)
         bad.push('the cleared windup came out at '+A.wind+' rather than nothing, which is what let the next test read it as an alarm that had finished');
       // CONTROL: the same Crier, the same windup, and he is in plain sight. The
       // alarm MUST still fire, or a build that simply broke the Crier is green.
       var B=arm(false);
       if(B&&!B.none){
         if(B.said.indexOf(RAISED)<0) bad.push('control: a Crier that kept eyes on him no longer raises the alarm at all, it said "'+B.said+'", so the counterplay has been turned into an escape');
         if(!(B.marked>0)) bad.push('control: a Crier that kept eyes on him no longer marks him, so this check cannot see an alarm and its findings prove nothing');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ var gz=__state(); if(gz){ if(gz.ents) gz.ents.length=0; gz.marked=0;
         if(gz.player){ gz.player.downed=false; gz.player.iv=0; } } }catch(_a){}
       try{ var g2=__state(); if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'12.49',what:'a Howler shell bursting in the street does not reach through a solid wall: the man forty units inside loses nothing and a pillager behind the same wall loses nothing, while the same shell still hurts anyone standing in the open the same distance away (2026-09-07 audit, the remaining half of his 2026-09-06 note)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
