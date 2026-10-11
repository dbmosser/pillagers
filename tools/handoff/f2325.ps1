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

if ($s.Contains("  {v:'23.25',what:")) { throw "check 23.25 is in the fixture already" }

SubRx @'
  {v:'23.24',what:
'@ @'
  {v:'23.25',what:'his order: player 2 joins the arcade with A. arcjoin with no arcade raid on builds one with player 1 benched and frozen under the attract and tells player 2 arcgo fresh 1, a press brings player 1 back with no death counted, the rebuild keeps his score and says arcnew, the host raid word carries arc, player 2 takes an arcade raid word only after A, builds the same surface without committing a kit, keeps the same raid on a second word, and starts at a map spawn while player 1 is benched',
   run:function(){
     var bad=[], out=[], sv=null, g0, g1, p, x0, y0, f, r, m=null, peer, ck=null, nCk=0, i, k, onSp, ap, mm;
     function has(t,fr){ for(var q=0;q<out.length;q++) if(out[q]&&out[q].t===t&&out[q].pair==='tp'&&(fr===undefined||out[q].fresh===fr)) return true; return false; }
     function kd(code,key){ window.dispatchEvent(new KeyboardEvent('keydown',{code:code,key:key,bubbles:true,cancelable:true})); window.dispatchEvent(new KeyboardEvent('keyup',{code:code,key:key,bubbles:true})); }
     try{
       __topClear(); __runPrep();
       if(typeof arcadeEnter!=='function'||typeof arcadeOnMsg!=='function'||typeof ARCADE!=='object'||typeof arcadeDeploy!=='function') return 'no arcade in this build';
       if(__state()&&!__state().over) __endRaid('abandon');
       if(__state()) return 'SKIP: a raid is still up after __topClear';
       if(NET.on) return 'SKIP: a party link is up in the fixture';
       sv={bc:NET.bc,same:NET.same,pair:NET.pair,mode:NET.mode,arcPick:NET.arcPick,busy:NET.sameBusy,role:NET.role,on:NET.on,hostSeed:NET.hostSeed,lateBan:NET.lateBan,up:NET.up,upWord:NET.upWord,upSeed:NET.upSeed,upFp:NET.upFp,lateOut:NET.lateOut,status:NET.status,err:NET.err,sum:NET.sum,wps:NET.wps,pings:NET.pings,upAcc:NET.upAcc,upN:NET.upN};
       NET.bc={postMessage:function(o){ out.push(o); },close:function(){}}; NET.same='host'; NET.pair='tp'; NET.sameBusy=true;
       if(!arcadeEnter('host')) bad.push('arcadeEnter(host) failed');
       out.length=0;
       r=netSameOnMsg({t:'arcjoin',pair:'tp'});
       g0=__state();
       if(!g0||g0.arcade!==1) bad.push('arcjoin with no raid on built no arcade raid ('+r+')');
       else {
         p=g0.player;
         if(!p.specOut) bad.push('player 1 is not benched in the raid built for player 2');
         if(!has('arcgo',1)) bad.push('player 2 was not told arcgo fresh 1');
         arcadeAttTick();
         ap=ATT.el&&ATT.el.querySelector('.attpress');
         if(!ATT.on||!ap||ap.textContent!=='PLAYER 1: PRESS ANY'+' BUTTON') bad.push('the benched attract reads '+(ap&&ap.textContent)+' (on '+ATT.on+')');
         x0=p.x; y0=p.y; keys.KeyD=true; keys.KeyS=true;
         for(f=0;f<20;f++) __loop(performance.now()+f*16.7);
         keys.KeyD=false; keys.KeyS=false;
         if(__state()!==g0) bad.push('the benched raid did not go on');
         if(Math.abs(p.x-x0)>1||Math.abs(p.y-y0)>1) bad.push('a benched player 1 moved');
         out.length=0;
         r=netSameOnMsg({t:'arcjoin',pair:'tp'});
         if(__state()!==g0) bad.push('a second arcjoin with no link built another raid ('+r+')');
         kd('KeyJ','j');
         if(p.specOut) bad.push('a key press did not bring player 1 off the bench');
         else {
           if(ATT.on) bad.push('the attract stayed up after player 1 came off the bench');
           if((ARCADE.deaths|0)!==0) bad.push('coming off the bench counted a death');
           if(!(ARCADE.holdT>2)) bad.push('no drop-in hold after the bench ('+ARCADE.holdT+')');
         }
         ARCADE.mine=777; out.length=0;
         if(!arcadeRebuild()) bad.push('arcadeRebuild failed');
         g1=__state();
         if(!g1||g1===g0||g1.arcade!==1) bad.push('arcadeRebuild built no new arcade raid');
         if(ARCADE.mine!==777) bad.push('player 1 lost his score in the rebuild ('+ARCADE.mine+')');
         if(!has('arcnew')) bad.push('the rebuild did not tell player 2 arcnew');
       }
       arcadeRaidStop();
       if(!arcadeDeploy({mapIx:0,seed:4242})) bad.push('arcadeDeploy failed');
       else {
         NET.on=true; NET.role='host';
         try{ m=netUpAnnounce(__state()); } finally{ NET.on=sv.on; NET.role=sv.role; }
         if(!m||m.arc!==1) bad.push('the arcade raid word carries no arc ('+(m&&m.arc)+')');
       }
       arcadeRaidStop();
       if(m){
         NET.role='join'; peer={state:'in',seat:0}; ARCADE.role='p2'; ARCADE.wantIn=0;
         ck=commitKit; commitKit=function(){ nCk++; };
         r=netUpTake(peer,m);
         if(r!=='arc:wait') bad.push('player 2 who did not press A took the raid word ('+r+')');
         if(__state()) bad.push('player 2 who did not press A was pulled up');
         ARCADE.wantIn=1;
         r=netUpTake(peer,m);
         g1=__state();
         if(r!=='up'||!g1||g1.arcade!==1) bad.push('player 2 who pressed A did not join the arcade raid ('+r+')');
         else {
           if(!netUpFpSame(netUpFp(g1),m.fp)) bad.push('player 2 built a different surface: '+netUpFpText(netUpFp(g1))+' against '+netUpFpText(m.fp));
           if(nCk) bad.push('player 2 committed a packed kit');
           if(ARCADE.wantIn) bad.push('wantIn still set after the join');
           r=netUpTake(peer,m);
           if(r!=='arc:have'||__state()!==g1) bad.push('a second word for the same raid rebuilt it ('+r+')');
           mm={}; for(k in m) if(Object.prototype.hasOwnProperty.call(m,k)) mm[k]=m[k];
           mm.late={t:5,left:0,x:Math.round(g1.player.x)+3,y:Math.round(g1.player.y)+3,bench:1}; mm.gone=[]; mm.wg=[];
           netLateApply(mm);
           onSp=false; for(i=0;i<(g1.map.spawns||[]).length;i++){ if(g1.map.spawns[i]&&Math.abs(g1.map.spawns[i].x-g1.player.x)<1&&Math.abs(g1.map.spawns[i].y-g1.player.y)<1) onSp=true; }
           if(!onSp) bad.push('player 2 joining a benched player 1 is not at a map spawn');
         }
       }
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       try{ if(ck) commitKit=ck; }catch(_c){}
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ if(sv){ netSameStop(); NET.bc=sv.bc||null; NET.same=sv.same||''; NET.pair=sv.pair||''; NET.mode=sv.mode||''; NET.arcPick=sv.arcPick||0; NET.sameBusy=!!sv.busy;
         NET.role=sv.role; NET.on=sv.on; NET.hostSeed=sv.hostSeed; NET.lateBan=sv.lateBan; NET.up=sv.up; NET.upWord=sv.upWord; NET.upSeed=sv.upSeed; NET.upFp=sv.upFp;
         NET.lateOut=sv.lateOut; NET.status=sv.status; NET.err=sv.err; NET.sum=sv.sum; NET.wps=sv.wps; NET.pings=sv.pings; NET.upAcc=sv.upAcc; NET.upN=sv.upN; } }catch(_ns){}
       try{ for(k in keys) keys[k]=false; }catch(_k){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'23.24',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
