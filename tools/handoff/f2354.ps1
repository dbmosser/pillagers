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

if ($s.Contains("  {v:'23.54',what:")) { throw "check 23.54 is in the fixture already" }

SubRx @'
  {v:'23.53',what:
'@ @'
  {v:'23.54',what:'arcade30, his order 2026-10-11 evening (arcade mode also needs a single player option): the title has a 1 PLAYER ARCADE DEMO row; pressing it enters the arcade in this one window with no player 2 window, no pair channel and the net section off; an arcade raid built there is a 1 player arcade raid whose HUD shows SCORE with no TEAM SCORE and no YOU and P2 split; its board row is tagged m 1, is on the 1 player list and stays off the 2 player list; leaving clears the 1 player mode',
   run:function(){
     var bad=[], row, sv=null, opens=0, chans=0, wo=null, BCo=null, swapped=false, starts=0, cx=null, ft=null, own=false, seen=[], f, bk=null, hadBk=false, g, id, rs, i, hit, b2=0, nT='TEAM SC'+'ORE';
     function inList(a,rn){ for(var q=0;q<a.length;q++) if(a[q]&&a[q].run===rn) return a[q]; return null; }
     try{
       __topClear(); __runPrep();
       if(typeof ARCADE!=='object'||typeof arcadeDeploy!=='function'||typeof arcadeBoardLoad!=='function') return 'no arcade in this build';
       row=document.getElementById('modearcade'+'1');
       if(!row) return 'the title has no 1 PLAYER ARCADE DEMO row';
       if(String(row.textContent).trim()!=='1 PLAYER ARCADE'+' DEMO') bad.push('the 1 player arcade row reads '+row.textContent);
       if(row.getAttribute('data-mode')!=='arcade1') bad.push('the 1 player arcade row is not a mode row the arrows and the pad land on');
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(__state()&&!__state().over) __endRaid('abandon');
       if(NET.on) return 'SKIP: the net section is on in the fixture';
       try{ bk=localStorage.getItem(ARCADE_BOARD_KEY); hadBk=true; }catch(_b){}
       sv={bc:NET.bc,same:NET.same,pair:NET.pair,arcPick:NET.arcPick,start:NET.start};
       NET.bc=null; NET.same=''; NET.pair='';
       wo=window.open; BCo=window.BroadcastChannel; swapped=true;
       window.open=function(){ opens++; return null; };
       window.BroadcastChannel=function(){ chans++; this.postMessage=function(){}; this.close=function(){}; };
       NET.start=function(){ starts++; };
       row.click();
       if(!ARCADE.on) return (bad.concat(['the 1 PLAYER ARCADE DEMO row did not enter the arcade'])).join('; ');
       if(!ARCADE.solo) bad.push('the arcade the 1 player row entered is not the 1 player arcade (ARCADE.solo '+ARCADE.solo+')');
       if(ARCADE.role!=='host') bad.push('the 1 player arcade window is not the host (role '+ARCADE.role+')');
       if(NET.bc) bad.push('entering the 1 player arcade opened a pair channel');
       if(chans) bad.push('entering the 1 player arcade made '+chans+' channel(s) between windows');
       if(opens) bad.push('entering the 1 player arcade opened '+opens+' window(s)');
       if(NET.on||NET.same) bad.push('entering the 1 player arcade switched the net section on (on '+NET.on+', same '+NET.same+')');
       if(starts!==1) bad.push('the 1 player row ran the title start '+starts+' times, not once');
       window.open=wo; window.BroadcastChannel=BCo; swapped=false;
       if(!arcadeDeploy({mapIx:0,seed:4242})||!__state()||!__state().arcade) return (bad.concat(['SKIP: arcadeDeploy built no arcade raid'])).join('; ');
       try{ attStop(); }catch(_as){}
       g=__state(); keys={};
       if(!ARCADE.solo) bad.push('the arcade raid is not a 1 player arcade raid');
       if(NET.bc) bad.push('the 1 player arcade raid opened a pair channel');
       ARCADE.banner=null; ARCADE.mine=1234; ARCADE.mate=0;
       if(!g.over&&__state()===g){
         cx=hcv.getContext('2d'); ft=cx.fillText; own=true;
         cx.fillText=function(s){ seen.push(String(s)); return ft.apply(this,arguments); };
         for(f=0;f<3;f++) __loop(performance.now()+f*16.7);
         if(!seen.length){ try{ drawHUD(); }catch(_dh){} }
         delete cx.fillText; own=false;
         if(seen.indexOf('SC'+'ORE')<0) bad.push('the 1 player arcade HUD shows no SCORE label');
         if(seen.indexOf(nT)>=0) bad.push('the 1 player arcade HUD still shows TEAM SCORE');
         if(seen.indexOf('1,2'+'34')<0) bad.push('the 1 player arcade HUD shows no score of 1,234');
         for(i=0;i<seen.length;i++) if(/^(YOU|P1|P2) [\d,]+$/.test(seen[i])){ bad.push('the 1 player arcade HUD still shows the split: '+seen[i]); break; }
       } else bad.push('the arcade raid ended');
       id=ARCADE.run&&ARCADE.run.id;
       if(!id) bad.push('the 1 player arcade raid has no run id');
       else {
         b2=arcadeBoardBest(2);
         if(!arcadeBoardPut()) bad.push('the 1 player run wrote no board row');
         hit=inList(arcadeBoardLoad(),id);
         if(!hit) bad.push('the 1 player run row is not on the board');
         else if(hit.m!==1) bad.push('the 1 player run row is tagged m '+hit.m+', not 1');
         if(inList(arcadeBoardTonight(Date.now(),2),id)) bad.push('the 1 player run is on the 2 player list');
         if(!inList(arcadeBoardTonight(Date.now(),1),id)) bad.push('the 1 player run is not on the 1 player list');
         if(!inList(arcadeBoardTonight(),id)) bad.push('TONIGHTS BEST in the 1 player arcade does not show the 1 player run');
         if(arcadeBoardBest(2)!==b2) bad.push('the 2 player BEST EVER counts the 1 player run');
       }
       arcadeLeave();
       if(ARCADE.on) bad.push('arcadeLeave left the arcade on');
       if(ARCADE.solo) bad.push('leaving the arcade kept the 1 player mode');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       if(own&&cx){ try{ delete cx.fillText; }catch(_df){} }
       if(swapped){ try{ window.open=wo; window.BroadcastChannel=BCo; }catch(_sw){} }
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(typeof ARCADE==='object') ARCADE.solo=0; }catch(_so){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ if(sv){ NET.bc=sv.bc||null; NET.same=sv.same||''; NET.pair=sv.pair||''; NET.arcPick=sv.arcPick; NET.start=sv.start; } }catch(_ns){}
       try{ if(hadBk){ if(bk===null) localStorage.removeItem(ARCADE_BOARD_KEY); else localStorage.setItem(ARCADE_BOARD_KEY,bk); } }catch(_rb){}
       try{ if(typeof ARCADE==='object'){ ARCADE.over=null; ARCADE.mine=0; ARCADE.mate=0; ARCADE.pot=0; ARCADE.holdT=0; ARCADE.waveT=0; ARCADE.ownAt=0; ARCADE.idleSaid=0; ARCADE.wantIn=0; ARCADE.ini=null; ARCADE.hiRun=''; } }catch(_m){}
       try{ for(var kk in keys) keys[kk]=false; }catch(_k){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'23.53',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
