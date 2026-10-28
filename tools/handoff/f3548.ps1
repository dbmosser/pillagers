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

if ($s.Contains("  {v:'35.48',what:")) { throw "check 35.48 is in the fixture already" }

SubRx @'
  {v:'35.47',what:
'@ @'
  {v:'35.48',what:'cloud-p2-easy-card: player 2 joining a 2 player demo run gets the easy or normal card in its own window and starts the run on normal, as player 1 does (his 2.28 c: each player chooses before the run)',
   run:function(){
     var bad=[], out=[], sv=null, m=null, peer, r, g1, ck=null, k;
     try{
       __topClear(); __runPrep();
       if(typeof arcadeEnter!=='function'||typeof arcadeDeploy!=='function'||typeof netUpTake!=='function'||typeof netUpAnnounce!=='function'||typeof easyStartAsk!=='function'||typeof easyLive!=='function'||typeof ARCADE!=='object') return 'SKIP: no arcade or easy card in this build';
       if(__state()&&!__state().over) __endRaid('abandon');
       if(__state()) return 'SKIP: a raid is still up after __topClear';
       if(NET.on) return 'SKIP: a party link is up in the fixture';
       sv={bc:NET.bc,same:NET.same,pair:NET.pair,mode:NET.mode,arcPick:NET.arcPick,busy:NET.sameBusy,role:NET.role,on:NET.on,hostSeed:NET.hostSeed,lateBan:NET.lateBan,up:NET.up,upWord:NET.upWord,upSeed:NET.upSeed,upFp:NET.upFp,lateOut:NET.lateOut,status:NET.status,err:NET.err,sum:NET.sum,wps:NET.wps,pings:NET.pings,upAcc:NET.upAcc,upN:NET.upN};
       NET.bc={postMessage:function(o){ out.push(o); },close:function(){}}; NET.same='host'; NET.pair='tp'; NET.sameBusy=true;
       if(!arcadeEnter('host')) return 'SKIP: arcadeEnter(host) failed';
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy failed';
       if(!ARCADE.easyAsk) return 'SKIP: player 1 got no easy card either';
       NET.on=true; NET.role='host';
       try{ m=netUpAnnounce(__state()); } finally{ NET.on=sv.on; NET.role=sv.role; }
       if(!m||m.arc!==1) return 'SKIP: the arcade raid word carries no arc';
       arcadeRaidStop();
       NET.role='join'; NET.same='p2'; peer={state:'in',seat:0}; ARCADE.role='p2'; ARCADE.wantIn=1;
       ARCADE.easyAsk=null; ARCADE.easyAsked=1; ARCADE.easy=1;   // what the player 2 window holds after a yes on the run before
       ck=commitKit; commitKit=function(){};
       r=netUpTake(peer,m); g1=__state();
       if(r!=='up'||!g1||g1.arcade!==1) return 'SKIP: player 2 did not join the arcade raid ('+r+')';
       if(!ARCADE.easyAsk) bad.push('player 2 joined the demo run and got no easy or normal card');
       if(ARCADE.easy) bad.push('player 2 starts the new run on easy without choosing it');
       if(ARCADE.easyAsk&&ARCADE.easyAsk.waitMap){ try{ mapFirstEnd('test'); }catch(_mf){} }
       if(ARCADE.easyAsk&&!easyLive()) bad.push('the card is not live in the player 2 window');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       try{ if(ck) commitKit=ck; }catch(_c){}
       try{ ARCADE.easyAsk=null; ARCADE.easyAsked=0; ARCADE.easy=0; }catch(_ez){}
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ if(sv){ netSameStop(); NET.bc=sv.bc||null; NET.same=sv.same||''; NET.pair=sv.pair||''; NET.mode=sv.mode||''; NET.arcPick=sv.arcPick||0; NET.sameBusy=!!sv.busy;
         NET.role=sv.role; NET.on=sv.on; NET.hostSeed=sv.hostSeed; NET.lateBan=sv.lateBan; NET.up=sv.up; NET.upWord=sv.upWord; NET.upSeed=sv.upSeed; NET.upFp=sv.upFp;
         NET.lateOut=sv.lateOut; NET.status=sv.status; NET.err=sv.err; NET.sum=sv.sum; NET.wps=sv.wps; NET.pings=sv.pings; NET.upAcc=sv.upAcc; NET.upN=sv.upN; } }catch(_ns){}
       try{ for(k in keys) keys[k]=false; }catch(_k){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'35.47',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
