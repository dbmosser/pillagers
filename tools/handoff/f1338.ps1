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

# v13.38 CHECK, inserted before the v13.37 entry.
#
# ON THE PLAY PATH: a real player round, in the shape the fire path pushes, into a
# downed named pillager, so the kill flag is set where the game sets it and the kill
# handler runs in the frame loop. Four controls make the lines mean something: he
# died, the kill was the player's, the contract finished and was recorded, and the
# grudge was written. Machines and waves are removed first. P.contracts, P.rivals for
# that identity and P.notoriety are restored in finally.
SubRx @'
  {v:'13.37',what:'on a controller, holding B while downed with the self-revive spent fills the surrender bar and ends the raid as the downed screen says, while a tap of B still rolls a standing player, a short hold still does not surrender, an unspent revive still refuses it, and letting go of B lets go of the key (audit, 2026-09-13)',
'@ @'
  {v:'13.38',what:'a real player round that kills the last pillager a kill contract needs shows the contract line and then the grudge line, in that order, so the grudge line no longer writes over the only in-raid word that the contract is done',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__loop&&window.__keys)) return 'SKIP: this fixture cannot start a raid or step the loop';
     if(!__vpAlive()) return 'SKIP: the pane has no layout ('+window.innerWidth+'x'+window.innerHeight+'), so the frame loop cannot draw';
     if(typeof contractKill!=='function'||typeof idRec!=='function'||typeof rayHitG!=='function') return 'SKIP: this build has no kill contracts, no grudge ledger or no wall ray';
     var bad=[], keepC=P.contracts, keepNoto=P.notoriety, recId=null, keepRec=null, hadRec=false;
     function endAny(){ try{ var g0=__state(); if(g0&&!g0.over){ g0.player.downed=false; __endRaid('abandon'); } }catch(_0){} }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile(); endAny();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var G2=__state(); if(!G2||G2.over||G2.sim||!G2.bullets||!G2.tel) return 'SKIP: staging: no live raid started';
       var p=G2.player, rd=null, i, k;
       for(i=0;i<G2.ents.length;i++){ var e0=G2.ents[i]; if(e0.kind==='raider'&&!e0.merc&&!e0.finished&&e0.ident&&e0.name){ rd=e0; break; } }
       if(!rd) return 'SKIP: staging: no named pillager on this map';
       // Nothing else may speak while the lines are read: no machines, no crier, and no wave (the v13.33 lessons).
       G2.ents.length=0; G2.waveT=-1e9; p.iv=99;
       var K=__keys(); for(k in K) delete K[k];
       try{ if(mouse) mouse.down=false; }catch(_m){}
       var t0=performance.now(), f=0;
       for(i=0;i<420;i++){ __loop(t0+(++f)*16.7); }   // landing says what it says first
       if(G2.over||__state()!==G2) return 'SKIP: staging: the raid ended while landing settled';
       // A clear line of fire from where he stands.
       var ux=null, uy=null;
       for(i=0;i<8;i++){ var a=i*Math.PI/4, cx=Math.cos(a), cy=Math.sin(a);
         if(rayHitG(p.x,p.y,cx,cy,60)>=59){ ux=cx; uy=cy; break; } }
       if(ux===null) return 'SKIP: staging: no clear 60 unit line of fire from the landing spot';
       // A kill contract one pillager short, with a description the game never rolls.
       recId=rd.ident; hadRec=!!(P.rivals&&P.rivals[recId]);
       keepRec=hadRec?JSON.parse(JSON.stringify(P.rivals[recId])):null;
       var kills0=idRec(recId).kills||0;
       var desc=['Destroy','2','pillagers','for','check','13','38'].join(' ');
       var C={type:'kill',tgt:'raider',n:2,prog:1,reward:520,desc:desc};
       P.contracts=[C];
       G2.tel.contractsMid=G2.tel.contractsMid||[];
       var mid0=G2.tel.contractsMid.length;
       // He lies downed at the player's feet, already hostile, so the round charges no notoriety and says nothing of its own.
       rd.x=p.x+ux*24; rd.y=p.y+uy*24;
       rd.downed=1; rd.downT=30; rd.hp=5; rd.state='down'; rd.finished=false;
       rd.hostile=true; rd.friendlyPC=0; rd.notoCharged=1; rd.roll=0; rd.rollCd=0; rd.byPlayer=false;
       G2.ents.push(rd);
       var nm=String(rd.name);
       G2.msgQ=[]; G2.msgT=0; G2.msg='';
       // YOUR round, in the shape the fire path pushes, so the kill flag is set where the game sets it.
       G2.bullets.push({x:p.x+ux*17,y:p.y+uy*17,vx:ux*1180,vy:uy*1180,dmg:500,life:0.5,player:true,owner:p,tint:'#ffd48a',thru:0});
       var seen=[];
       function note(){ var g=__state(); if(g&&g.msg&&(seen.length===0||seen[seen.length-1]!==g.msg)) seen.push(String(g.msg)); }
       for(i=0;i<540;i++){ __loop(t0+(++f)*16.7); note(); if(__state()!==G2) break; }
       var head=['CONTRACT','DONE'].join(' ');
       var tail=['will','remember','that.'].join(' ');
       var cIx=-1, rIx=-1;
       for(i=0;i<seen.length;i++){
         if(cIx<0&&seen[i].indexOf(head)===0&&seen[i].indexOf(desc)>=0) cIx=i;
         if(rIx<0&&seen[i]===nm+' '+tail) rIx=i;
       }
       var shown=' [shown: '+seen.join(' | ').slice(0,240)+']';
       // CONTROLS: the round killed him, the kill was yours, the contract finished and the grudge was written, or the lines prove nothing.
       if(G2.ents.indexOf(rd)>=0) bad.push('control: the round did not kill the downed pillager (hp '+rd.hp+', downed '+rd.downed+')');
       if(C.prog!==C.n) bad.push('control: the kill did not finish the contract (progress '+C.prog+' of '+C.n+')');
       if(G2.tel.contractsMid.length!==mid0+1) bad.push('control: the finished contract was not recorded for the report');
       if((idRec(recId).kills||0)!==kills0+1) bad.push('control: the kill wrote no grudge, so the grudge line was never reached');
       // THE FIX.
       if(cIx<0) bad.push('the line that says the contract is done was written over in the same step and never shown'+shown);
       if(rIx<0) bad.push('the grudge line for '+nm+' was never shown'+shown);
       if(cIx>=0&&rIx>=0&&!(cIx<rIx)) bad.push('the grudge line was shown before the contract line'+shown);
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       endAny();
       try{ var K2=__keys(); for(var k2 in K2) delete K2[k2]; }catch(_k){}
       try{
         P.contracts=keepC; P.notoriety=keepNoto;
         if(recId!==null&&P.rivals){ if(hadRec) P.rivals[recId]=keepRec; else delete P.rivals[recId]; }
       }catch(_p){}
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.37',what:'on a controller, holding B while downed with the self-revive spent fills the surrender bar and ends the raid as the downed screen says, while a tap of B still rolls a standing player, a short hold still does not surrender, an unspent revive still refuses it, and letting go of B lets go of the key (audit, 2026-09-13)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
