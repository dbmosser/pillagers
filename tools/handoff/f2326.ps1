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

if ($s.Contains("  {v:'23.26',what:")) { throw "check 23.26 is in the fixture already" }

SubRx @'
  {v:'23.25',what:
'@ @'
  {v:'23.26',what:'from the arcade core review: a linked player 2 outside the arcade never takes an arcade raid word but takes it as the arcade offer (enters the arcade attract from the Undercroft and says arcin, says busy from a normal raid), a repeated offer leaves a player 2 already in the arcade as it was, and the host offers the arcade again every 3 s after a busy until player 2 says it is in',
   run:function(){
     var bad=[], out=[], sv=null, m=null, peer, r, g0, k;
     function has(t){ for(var q=0;q<out.length;q++) if(out[q]&&out[q].t===t&&out[q].pair==='tp') return true; return false; }
     try{
       __topClear(); __runPrep();
       if(typeof arcadeEnter!=='function'||typeof arcadeOnMsg!=='function'||typeof ARCADE!=='object'||typeof arcadeDeploy!=='function') return 'no arcade in this build';
       if(__state()&&!__state().over) __endRaid('abandon');
       if(__state()) return 'SKIP: a raid is still up after __topClear';
       if(NET.on) return 'SKIP: a party link is up in the fixture';
       sv={bc:NET.bc,same:NET.same,pair:NET.pair,mode:NET.mode,arcPick:NET.arcPick,busy:NET.sameBusy,role:NET.role,on:NET.on,hostSeed:NET.hostSeed,lateBan:NET.lateBan,up:NET.up,upWord:NET.upWord,upSeed:NET.upSeed,upFp:NET.upFp,lateOut:NET.lateOut,status:NET.status,err:NET.err,sum:NET.sum,wps:NET.wps,pings:NET.pings,upAcc:NET.upAcc,upN:NET.upN};
       NET.bc={postMessage:function(o){ out.push(o); },close:function(){}}; NET.same='host'; NET.pair='tp'; NET.sameBusy=true;
       if(!arcadeDeploy({mapIx:0,seed:4242})) bad.push('arcadeDeploy failed');
       else { NET.on=true; NET.role='host'; try{ m=netUpAnnounce(__state()); } finally{ NET.on=sv.on; NET.role=sv.role; } }
       arcadeRaidStop(); arcadeLeave();
       if(!m||m.arc!==1) bad.push('no arcade raid word ('+(m&&m.arc)+')');
       if(m){
         // player 2 in the Undercroft, outside the arcade
         NET.same='p2'; NET.role='join'; peer={state:'in',seat:0}; out.length=0;
         r=netUpTake(peer,m);
         if(r!=='arc:out') bad.push('player 2 outside the arcade took the arcade raid word ('+r+')');
         if(__state()){ bad.push('player 2 outside the arcade is up in a raid'); }
         if(!ARCADE.on||ARCADE.role!=='p2') bad.push('player 2 did not take the arcade word as the arcade offer (on '+ARCADE.on+', role '+ARCADE.role+')');
         else {
           if(ARCADE.wantIn) bad.push('player 2 is set to join without pressing A');
           if(!has('arcin')) bad.push('player 2 did not tell the host it is in (no arcin)');
           ARCADE.wantIn=1; out.length=0;
           r=arcadeOnMsg({t:'arcon',pair:'tp'});
           if(!ARCADE.wantIn) bad.push('an arcade offer that came again undid the press of A ('+r+')');
           if(!has('arcin')) bad.push('player 2 in the arcade did not answer a repeated offer with arcin');
           ARCADE.wantIn=0;
         }
         arcadeLeave();
         if(__state()&&!__state().over) __endRaid('abandon');
         // player 2 in a normal raid
         NET.same=sv.same||''; NET.role=sv.role;
         __deploy({kit:[],safe:null,mapIx:0,seed:4242}); g0=__state();
         if(!g0||g0.over) bad.push('no normal raid to stand player 2 in');
         else {
           NET.same='p2'; NET.role='join'; out.length=0;
           r=netUpTake(peer,m);
           if(r!=='arc:out') bad.push('player 2 in a normal raid took the arcade raid word ('+r+')');
           if(__state()!==g0) bad.push('the normal raid of player 2 was replaced');
           if(!has('arcbusy')) bad.push('player 2 in a normal raid did not say busy');
           if(ARCADE.on) bad.push('player 2 entered the arcade from the middle of a normal raid');
         }
         NET.same=sv.same||''; NET.role=sv.role;
         if(__state()&&!__state().over) __endRaid('abandon');
         __topClear();
       }
       // the host offers again after a busy, and stops once player 2 is in
       NET.same='host'; NET.pair='tp';
       if(!arcadeEnter('host')) bad.push('arcadeEnter(host) failed');
       out.length=0;
       arcadeOnMsg({t:'arcbusy',pair:'tp'});
       ARCADE.offerAt=Date.now()-4000;
       arcadeAttTick();
       if(!has('arcon')) bad.push('the host did not offer the arcade again after player 2 said busy');
       out.length=0;
       arcadeOnMsg({t:'arcin',pair:'tp'});
       ARCADE.offerAt=0;
       arcadeAttTick();
       if(has('arcon')) bad.push('the host kept offering the arcade after player 2 said it is in');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ if(sv){ netSameStop(); NET.bc=sv.bc||null; NET.same=sv.same||''; NET.pair=sv.pair||''; NET.mode=sv.mode||''; NET.arcPick=sv.arcPick||0; NET.sameBusy=!!sv.busy;
         NET.role=sv.role; NET.on=sv.on; NET.hostSeed=sv.hostSeed; NET.lateBan=sv.lateBan; NET.up=sv.up; NET.upWord=sv.upWord; NET.upSeed=sv.upSeed; NET.upFp=sv.upFp;
         NET.lateOut=sv.lateOut; NET.status=sv.status; NET.err=sv.err; NET.sum=sv.sum; NET.wps=sv.wps; NET.pings=sv.pings; NET.upAcc=sv.upAcc; NET.upN=sv.upN; } }catch(_ns){}
       try{ ARCADE.p2Busy=0; ARCADE.offerAt=0; }catch(_ab){}
       try{ for(k in keys) keys[k]=false; }catch(_k){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'23.25',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
