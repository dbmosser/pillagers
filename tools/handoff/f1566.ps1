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
  {v:'15.65',what:
'@ @'
  {v:'15.66',what:'pillagers see a downed or rolling player at their normal range: with one hostile pillager 200 units away on a clear line, past the 170 of the crouch rule, he takes aim at a player shot down from a crouch and at a player rolling out of a crouch, as he does at a player shot down standing, while the same player crouched on his feet stays hidden from him; and shot down crouched in a bush, the body is concealed as a man lying still there, not as a man crouching (stealth audit finding)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__runPrep&&window.__P&&window.__applyLoaded)) return 'SKIP: this fixture cannot deploy a raid';
     if(typeof updatePlayer!=='function'||typeof updateEnts!=='function'||typeof damagePlayer!=='function'||typeof tryRoll!=='function') return 'SKIP: no player update, entity update, damage or roll in this build';
     if(typeof losClear!=='function'||typeof inBush!=='function'||typeof concealAt!=='function') return 'SKIP: no sight line, bush or concealment test in this build';
     if(typeof keys==='undefined'||!keys||typeof mouse==='undefined'||!mouse||typeof CFG==='undefined') return 'SKIP: no keys, mouse or dials in this build';
     if(typeof G!=='undefined'&&G&&G.sim) return 'SKIP: a sim is running';
     var bad=[], snap=null, g=null, p=null, keep=null, keepEnts=null, mouseWas=null, R=null, spot=null, dir=null, DT=1/60, GAP=200, N=8, i;
     // A later control that cannot run keeps a failure already found, so the old build fails rather than skips.
     function skip(m){ return bad.length?(bad.join('; ')+' (then SKIP: '+m+')'):('SKIP: '+m); }
     function clearKeys(){ for(var kk in keys) keys[kk]=false; }
     // On his feet at the spot with every key up, full health and no roll; one frame, so G.pCrouch shows the stance given.
     function stand(crouched){
       clearKeys(); mouse.down=false;
       p.x=spot.x; p.y=spot.y; p.vx=0; p.vy=0; p.downed=false; p.hp=p.maxhp; p.downT=0; p.pendKiller=null; p.healLock=false;
       p.roll=0; p.rollCd=0; p.iv=0; p.autoJog=false; p.ads=false; p.stam=100; p.stamLock=0; p.stamRelease=0;
       g.crouchTog=!!crouched; g.sprinting=false;
       updatePlayer(DT);
       return !!g.pCrouch;
     }
     // Shot to the floor where he stands.
     function down(){ p.iv=0; damagePlayer(999,'test','TEST'); return !!p.downed; }
     // The pillager 200 units out along the clear line, facing him, hostile and hunting him, his gun held so he never fires.
     function pin(){
       R.x=spot.x+dir.x*GAP; R.y=spot.y+dir.y*GAP; R.face=Math.atan2(spot.y-R.y,spot.x-R.x);
       R.state='chase'; R.hostile=true; R.merc=0; R.friendlyPC=0; R.downed=0; R.finished=0; R.hp=R.maxhp;
       R.cd=9; R.roll=0; R.rollCd=9; R.kitT=99; R.alert=2; R.blind=0; R.beat=1;
     }
     // The longest he held his aim on the player over N frames, each frame the player update and then the entity update, as
     // the raid loop runs them, with the player held at the spot.
     function watch(){
       var most=0; R.acqT=0;
       for(var f=0;f<N;f++){
         updatePlayer(DT); p.x=spot.x; p.y=spot.y; p.vx=0; p.vy=0;
         pin(); updateEnts(DT);
         if((R.acqT||0)>most) most=R.acqT;
         if(g.over) break;
       }
       return most;
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       snap=JSON.parse(JSON.stringify(__P()));
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state();
       if(!g||!g.player||!g.map||!g.ents||g.over) return 'SKIP: no live raid';
       p=g.player;
       var chid=(CFG.crouchHide===undefined?170:CFG.crouchHide);
       if(!(chid>0&&chid<GAP-20)) return 'SKIP: the crouch rule hides past '+chid+' here, not well inside the '+GAP+' units this check stands the pillager at';
       keep={x:p.x,y:p.y,stam:p.stam,hp:p.hp};
       mouseWas={x:mouse.x,y:mouse.y,down:mouse.down};
       keepEnts=g.ents.slice();
       for(i=0;i<keepEnts.length;i++){ var e0=keepEnts[i]; if(e0&&e0.kind==='raider'&&!e0.merc&&!e0.downed&&!e0.finished&&!e0.ghost&&e0.wep){ R=e0; break; } }
       if(!R) return 'SKIP: no pillager on this raid to stand at the range';
       if(typeof refreshVseg==='function') refreshVseg();
       var segs=g.vseg||g.map.segs;
       // A spot outside any bush with a clear line 30 units past the range: where he lands first, then the map spawn points.
       var cands=[{x:p.x,y:p.y}], sp=g.map.spawns||[];
       for(i=0;i<sp.length&&cands.length<9;i++) if(sp[i]&&isFinite(sp[i].x)&&isFinite(sp[i].y)) cands.push({x:sp[i].x,y:sp[i].y});
       for(i=0;i<cands.length&&!spot;i++){
         var c=cands[i]; if(inBush(c.x,c.y)) continue;
         for(var a=0;a<16;a++){
           var ca=Math.cos(a*Math.PI/8), sa=Math.sin(a*Math.PI/8);
           if(losClear(c.x,c.y,c.x+ca*(GAP+30),c.y+sa*(GAP+30),segs)){ spot=c; dir={x:ca,y:sa}; break; }
         }
       }
       if(!spot) return 'SKIP: no spot on this map with a clear line '+GAP+' units long here';
       g.ents.length=0; g.ents.push(R);
       // CONTROL: on his feet and upright he is seen at 200 on either build, so the line and the range hold.
       if(stand(false)) return 'SKIP: standing with the crouch toggle off he still counted as crouched here';
       var c0=watch();
       if(!(c0>0)) return 'SKIP: standing upright '+GAP+' units from a hostile pillager on a clear line, he was never seen here, so sight at this range cannot be measured';
       // CONTROL: on his feet and crouched, the crouch rule hides him at 200 on either build, so the rule is live here.
       if(!stand(true)) return 'SKIP: the crouch toggle did not crouch him here';
       var c1=watch();
       if(c1>0) return 'SKIP: crouched on his feet '+GAP+' units away he was still seen here ('+c1.toFixed(3)+' s of aim), so the crouch rule does not decide this range';
       // CONTROL: shot down standing, the body is seen on either build: machines are blinded to a downed man, pillagers are not.
       stand(false);
       if(!down()) return 'SKIP: a 999 point hit did not put him on the floor here';
       var c2=watch();
       if(!(c2>0)) return 'SKIP: shot down standing '+GAP+' units from the pillager, the body was never seen here, so pillagers do not see a downed man in this build';
       // THE FINDING: shot down from a crouch, the body is seen the same way.
       if(!stand(true)) return 'SKIP: the crouch toggle did not crouch him a second time here';
       if(!down()) return 'SKIP: the second 999 point hit did not put him on the floor here';
       var a1=watch(), low1=!!g.pCrouch;
       if(!(a1>0)) bad.push('shot down from a crouch '+GAP+' units from a hostile pillager on a clear line, the body was never seen in '+N+' frames'+(low1?' and still counted as crouched':'')+', while the same man shot down standing was seen ('+c2.toFixed(3)+' s of aim), so nothing past '+chid+' can shoot him for the whole bleed-out');
       else if(low1) bad.push('shot down from a crouch, the body still counted as crouched after '+N+' frames on the floor');
       // THE ROLL: a roll out of a crouch leaves the crouch for the pillager too, not only for the toggle.
       if(!stand(true)) return skip('the crouch toggle did not crouch him before the roll here');
       p.stam=100; p.roll=0; p.rollCd=0;
       tryRoll();
       if(!(p.roll>0)) return skip('the roll did not start here');
       if(g.crouchTog) return skip('the roll left the crouch toggle on here, so his v11.53 note does not hold in this build');
       var a2=watch(), still=(p.roll>0), low2=!!g.pCrouch;
       p.roll=0;
       if(!still) return skip('the roll ended inside '+N+' frames here');
       if(!(a2>0)) bad.push('rolling out of a crouch '+GAP+' units from the pillager, he was never seen in '+N+' frames of the roll'+(low2?' and still counted as crouched':'')+', though the roll had already taken the crouch toggle off');
       // THE BUSH: crouched still in a bush and shot down, the body is concealed as a man lying still there. The first bush he can
       // stand crouched inside where the crouch conceals more than lying still would, so the bush and the dial are live.
       var bs=g.map.bushes||[], found=false;
       for(i=0;i<bs.length&&i<40&&!found;i++){
         var b=bs[i]; if(!b||!isFinite(b.x)||!isFinite(b.y)) continue;
         spot={x:b.x,y:b.y};
         stand(true);
         if(g.pBush&&g.pConceal<concealAt(p.x,p.y,false,false,false)-0.01) found=true;
       }
       if(found){
         var crc=g.pConceal;
         if(!down()) return skip('the hit in the bush did not put him on the floor here');
         updatePlayer(DT);
         var lie=concealAt(p.x,p.y,false,false,false), lc=g.pConceal;
         if(!(Math.abs(lc-lie)<1e-6)) bad.push('shot down crouched in a bush, the body lying still there was concealed at '+(+lc).toFixed(2)+' of every sight range, the crouched '+(+crc).toFixed(2)+', not the '+lie.toFixed(2)+' of a man lying still in that bush');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ clearKeys(); if(mouseWas){ mouse.x=mouseWas.x; mouse.y=mouseWas.y; mouse.down=mouseWas.down; } }catch(_k){}
       try{ if(g&&keepEnts){ g.ents.length=0; for(var ke=0;ke<keepEnts.length;ke++) g.ents.push(keepEnts[ke]); } }catch(_n){}
       try{ if(p&&keep){ p.x=keep.x; p.y=keep.y; p.vx=0; p.vy=0; p.roll=0; p.downed=false; p.hp=keep.hp; p.stam=keep.stam; p.pendKiller=null; p.healLock=false; } }catch(_p){}
       try{ if(g){ g.crouchTog=false; g.sprinting=false; g.pCrouch=false; } }catch(_g){}
       try{ if(g&&!g.over) __endRaid('abandon'); }catch(_e){}
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'15.65',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
