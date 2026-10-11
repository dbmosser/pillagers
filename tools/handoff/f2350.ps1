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

if ($s.Contains("  {v:'23.50',what:")) { throw "check 23.50 is in the fixture already" }

SubRx @'
  {v:'23.49',what:
'@ @'
  {v:'23.50',what:'arcade26, his yes 2026-10-11: run end always reaches player 2, player 2 in an arcade raid that hears only the host out word for a run end (ae) stops its raid back to its attract instead of playing on alone and acknowledges it (arcendok), an out word with no mark still hands player 2 the raid, player 2 that hears only arcend stops too and acknowledges it with the run, a repeat of the same arcend changes nothing, the host run end sends arcend with its run and an out word marked ae, repeats arcend every half second until arcendok, stops after 3 s with no answer, and a normal raid out word carries no ae',
   run:function(){
     var bad=[], posted=[], bcast=[], nsv=null, k, nb0=null, ownNb=false, src0, tried0, ownAtt=false, BK='', bk=null, ownBk=false, g, r, peer, id, n0, t0;
     function sent(t){ var q, c=0; for(q=0;q<posted.length;q++) if(posted[q]&&posted[q].t===t) c++; return c; }
     function last(t){ for(var q=posted.length-1;q>=0;q--) if(posted[q]&&posted[q].t===t) return posted[q]; return null; }
     function stage(){
       var gg;
       NET.on=false; NET.role=''; NET.same='p2';
       if(!arcadeDeploy({role:'p2',mapIx:0,seed:4242})||!__state()||!__state().arcade) return null;
       try{ attStop(); }catch(_as){}
       gg=__state(); ARCADE.role='p2'; ARCADE.endRun=''; ARCADE.holdT=0; ARCADE.ownAt=Date.now();
       NET.on=true; NET.role='join'; NET.same='p2'; NET.seat=1; NET.upSeed=gg.seed>>>0; NET.up=[]; NET.peers=[]; NET.upOut={};
       posted.length=0; bcast.length=0;
       return gg;
     }
     try{
       __topClear(); __runPrep();
       if(typeof arcadeRunEnd!=='function'||typeof arcadeOnMsg!=='function'||typeof netUpWord!=='function'||typeof ARCADE!=='object') return 'no arcade run end in this build';
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(__state()&&!__state().over) __endRaid('abandon');
       if(__state()) return 'SKIP: a raid is still up after __topClear';
       if(NET.on) return 'SKIP: a party link is up in the fixture';
       nsv={}; for(k in NET) if(Object.prototype.hasOwnProperty.call(NET,k)) nsv[k]=NET[k];
       NET.bc={postMessage:function(m){ posted.push(m); },close:function(){}}; NET.pair='tp';
       nb0=netBroadcast; netBroadcast=function(m){ bcast.push(m); }; ownNb=true;
       src0=ATT.src; tried0=ATT.tried; ATT.src=null; ATT.tried=true; ownAtt=true;
       BK=ARCADE_BOARD_KEY; bk=localStorage.getItem(BK); ownBk=true;
       peer={state:'in',seat:0};
       // 1. only the host out word for the run end (ae) reaches player 2
       g=stage(); if(!g) return 'SKIP: arcadeDeploy built no player 2 arcade raid';
       r=netUpWord(peer,{t:'up',st:'out',how:'abandon',sd:NET.upSeed>>>0,ae:1});
       if(__state()&&__state().arcade) bad.push('player 2 played on alone after the host run end out word ('+r+', netWasJoin '+(__state().netWasJoin|0)+')');
       if(!ATT.on) bad.push('player 2 is not on its attract after the host run end out word');
       if(!sent('arcendok')) bad.push('player 2 did not acknowledge the run end it took from the out word');
       // 2. an out word with no mark still hands player 2 the raid (the host window went away)
       g=stage(); if(!g) return bad.concat(['no second player 2 drop']).join('; ');
       r=netUpWord(peer,{t:'up',st:'out',how:'abandon',sd:NET.upSeed>>>0});
       if(__state()!==g||!g.arcade) bad.push('an out word with no mark stopped the player 2 raid ('+r+')');
       else if((g.netWasJoin|0)!==1) bad.push('an out word with no mark did not hand player 2 the raid');
       if(sent('arcendok')) bad.push('player 2 acknowledged a run end nobody sent');
       // 3. only arcend reaches player 2
       g=stage(); if(!g) return bad.concat(['no third player 2 drop']).join('; ');
       r=arcadeOnMsg({t:'arcend',pair:'tp',run:'zz26'});
       if(r!=='arcend') bad.push('arcend answered '+r);
       if(__state()&&__state().arcade) bad.push('player 2 played on after arcend');
       if(!ATT.on) bad.push('player 2 is not on its attract after arcend');
       r=last('arcendok');
       if(!r||r.run!=='zz26') bad.push('player 2 did not acknowledge arcend with its run ('+JSON.stringify(r)+')');
       n0=sent('arcendok');
       r=arcadeOnMsg({t:'arcend',pair:'tp',run:'zz26'});
       if(r!=='ignored') bad.push('a repeat of the same arcend answered '+r);
       if(sent('arcendok')!==n0+1) bad.push('a repeat arcend was not acknowledged');
       NET.on=false; NET.role='';
       arcadeLeave();
       // 4. the host run end: arcend with its run, the out word marked ae, repeated until arcendok or 3 s
       NET.same='host';
       if(!arcadeDeploy({mapIx:0,seed:4242})||!__state()||!__state().arcade) return bad.concat(['no host arcade drop']).join('; ');
       try{ attStop(); }catch(_as2){}
       NET.on=true; NET.role='host'; NET.same='host'; NET.seat=0; NET.peers=[]; NET.upSeed=__state().seed>>>0;
       id=String((ARCADE.run&&ARCADE.run.id)||''); posted.length=0; bcast.length=0;
       if(!arcadeRunEnd('menu')) bad.push('arcadeRunEnd failed on the host');
       r=last('arcend');
       if(!r||!id||r.run!==id) bad.push('the host arcend does not name its run ('+JSON.stringify(r)+' against '+id+')');
       r=null; for(k=0;k<bcast.length;k++) if(bcast[k]&&bcast[k].t==='up'&&bcast[k].st==='out') r=bcast[k];
       if(!r||r.ae!==1) bad.push('the host out word for the run end is not marked ae ('+JSON.stringify(r)+')');
       if(typeof arcadeEndTick!=='function') bad.push('no arcend repeat in this build');
       else {
         t0=Date.now(); n0=sent('arcend');
         arcadeEndTick(t0+100);
         if(sent('arcend')!==n0) bad.push('arcend repeated inside half a second');
         arcadeEndTick(t0+600);
         if(sent('arcend')!==n0+1) bad.push('arcend was not repeated after half a second with no arcendok');
         r=arcadeOnMsg({t:'arcendok',pair:'tp',run:id});
         if(r!=='arcendok') bad.push('the host answered arcendok with '+r);
         n0=sent('arcend');
         arcadeEndTick(t0+1200); arcadeEndTick(t0+1800);
         if(sent('arcend')!==n0) bad.push('arcend was repeated after arcendok');
         ARCADE.over=null; ARCADE.ini=null;
         NET.on=false; NET.role='';
         if(!arcadeDeploy({mapIx:0,seed:4242})||!__state()||!__state().arcade) bad.push('no second host arcade drop');
         else {
           try{ attStop(); }catch(_as3){}
           NET.on=true; NET.role='host'; NET.peers=[]; NET.upSeed=__state().seed>>>0;
           posted.length=0; t0=Date.now(); arcadeRunEnd('menu'); n0=sent('arcend');
           arcadeEndTick(t0+700);
           if(sent('arcend')!==n0+1) bad.push('the second run end was not repeated');
           arcadeEndTick(t0+3100); arcadeEndTick(t0+3700);
           if(sent('arcend')!==n0+1) bad.push('arcend was repeated after 3 s');
         }
       }
       NET.on=false; NET.role='';
       ARCADE.over=null; ARCADE.ini=null;
       arcadeLeave();
       // 5. a normal raid out word carries no ae
       NET.same='';
       __topClear(); __runPrep();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!__state()) return bad.length?bad.join('; '):'SKIP: __deploy built no raid';
       if(__state().arcade) bad.push('a normal raid is flagged arcade');
       NET.on=true; NET.role='host'; NET.peers=[]; bcast.length=0;
       netUpEnd('abandon');
       r=bcast[bcast.length-1];
       if(!r||r.t!=='up'||r.st!=='out') bad.push('a normal raid sent no out word');
       else if(r.ae!==undefined) bad.push('a normal raid out word carries ae');
       NET.on=false; NET.role='';
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       try{ NET.on=false; NET.role=''; }catch(_o){}
       try{ if(typeof ARCADE==='object'){ ARCADE.endSend=null; ARCADE.endRun=''; ARCADE.ini=null; ARCADE.over=null; } }catch(_z){}
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ if(ownNb) netBroadcast=nb0; }catch(_b){}
       try{ if(nsv){ for(k in NET) if(Object.prototype.hasOwnProperty.call(NET,k)&&!Object.prototype.hasOwnProperty.call(nsv,k)) delete NET[k]; for(k in nsv) NET[k]=nsv[k]; } }catch(_n){}
       try{ if(ownAtt){ ATT.src=src0; ATT.tried=tried0; } }catch(_a){}
       try{ if(ownBk){ if(bk===null) localStorage.removeItem(BK); else localStorage.setItem(BK,bk); } }catch(_k){}
       try{ if(typeof ARCADE==='object'){ ARCADE.mine=0; ARCADE.mate=0; ARCADE.holdT=0; ARCADE.waveT=0; ARCADE.ownAt=0; ARCADE.idleSaid=0; ARCADE.wantIn=0; ARCADE.late=0; ARCADE.hiRun=''; ARCADE.hiSaid=0; } }catch(_m){}
       try{ for(var kk in keys) keys[kk]=false; }catch(_kk){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'23.49',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
