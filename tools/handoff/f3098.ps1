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

if ($s.Contains("  {v:'30.98',what:")) { throw "check 30.98 is in the fixture already" }

SubRx @'
  {v:'30.97',what:
'@ @'
  {v:'30.98',what:'player 2 gets the RUN OVER card too (his order of 2026-10-18: p1 and p2 should look and behave the same): when the host run end arrives the player 2 window builds the card from its own score and the host score, doubled for an extraction and halved for a death or the burn exactly as the host does, with the team score, a row each and the EXTRACTED x2 or KIA -50% line, shown on its attract; a repeat of the same run end changes nothing; the host card is untouched',
   run:function(){
     if(typeof ARCADE!=='object'||typeof arcadeOnMsg!=='function'||typeof arcadeDeploy!=='function'||typeof arcadeLeave!=='function') return 'no arcade in this build';
     if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
     var bad=[], nsv=null, k, src0, tried0, ownAtt=false, BK='', bk=null, ownBk=false, g, r, o, o2, card, txt, oPost=netSamePost, ownSp=false;
     function stage(run){
       var gg;
       NET.on=false; NET.role=''; NET.same='p2';
       if(!arcadeDeploy({role:'p2',mapIx:0,seed:4242})||!__state()||!__state().arcade) return null;
       try{ attStop(); }catch(_as){}
       gg=__state(); ARCADE.role='p2'; ARCADE.endRun=''; ARCADE.holdT=0; ARCADE.ownAt=Date.now(); ARCADE.over=null;
       NET.on=true; NET.role='join'; NET.same='p2'; NET.seat=1; NET.upSeed=gg.seed>>>0; NET.up=[]; NET.peers=[]; NET.upOut={};
       ARCADE.mine=1200; ARCADE.kills=5; ARCADE.ext=1; ARCADE.deaths=1; ARCADE.mate=300; ARCADE.mateK=2; ARCADE.mateX=0;
       return gg;
     }
     function cardText(){ var c=document.querySelector('#attract .arcover'); return (c&&c.style.display!=='none')?String(c.textContent).toLowerCase():''; }
     try{
       __topClear(); __runPrep();
       if(__state()&&!__state().over) __endRaid('abandon');
       if(__state()) return 'SKIP: a raid is still up after __topClear';
       if(NET.on) return 'SKIP: a party link is up in the fixture';
       nsv={}; for(k in NET) if(Object.prototype.hasOwnProperty.call(NET,k)) nsv[k]=NET[k];
       NET.bc={postMessage:function(m){},close:function(){}}; NET.pair='tp';
       src0=ATT.src; tried0=ATT.tried; ATT.src=null; ATT.tried=true; ownAtt=true;
       BK=ARCADE_BOARD_KEY; bk=localStorage.getItem(BK); ownBk=true;
       // ONE: an extraction run end. Both scores are doubled, then the card is built, player 1 on top.
       g=stage(); if(!g) return 'SKIP: arcadeDeploy built no player 2 arcade raid';
       r=arcadeOnMsg({t:'arcend',pair:'tp',run:'zzov1',x2:1});
       o=ARCADE.over;
       if(r!=='arcend') bad.push('arcend answered '+r);
       if(!o) bad.push('player 2 built no RUN OVER card from the host run end of an extraction');
       else {
         if(o.team!==3000) bad.push('the player 2 team score after an extraction is '+o.team+', not 3000 (both scores doubled)');
         if(!o.p2||o.p2.s!==2400||o.p2.k!==5||o.p2.x!==1||o.p2.d!==1) bad.push('the player 2 row is '+JSON.stringify(o.p2));
         if(!o.p1||o.p1.s!==600||o.p1.k!==2) bad.push('the player 1 row is '+JSON.stringify(o.p1));
         if(o.why!=='extract') bad.push('the run end of an extraction is called '+o.why);
       }
       txt=cardText();
       if(txt.indexOf('run over')<0||txt.indexOf('team score')<0) bad.push('the player 2 attract shows no RUN OVER card with a team score ('+txt.slice(0,80)+')');
       if(txt.indexOf('extracted')<0) bad.push('the player 2 card never says the run extracted');
       if(txt.indexOf('p1')<0||txt.indexOf('p2')<0) bad.push('the player 2 card has no row each for player 1 and player 2');
       // THREE: a repeat of the same run end changes nothing.
       o2=ARCADE.over; arcadeOnMsg({t:'arcend',pair:'tp',run:'zzov1',x2:1});
       if(ARCADE.over!==o2) bad.push('a repeat of the same run end built the card again');
       arcadeLeave();
       // TWO: a death run end. Both scores are halved.
       g=stage(); if(!g) return bad.concat(['no second player 2 drop']).join('; ');
       arcadeOnMsg({t:'arcend',pair:'tp',run:'zzov2',ko:1});
       o=ARCADE.over;
       if(!o) bad.push('player 2 built no RUN OVER card from the host run end of a death');
       else {
         if(o.team!==750) bad.push('the player 2 team score after a death is '+o.team+', not 750 (both scores halved)');
         if(o.why!=='dead') bad.push('the run end of a death is called '+o.why);
       }
       txt=cardText();
       if(txt.indexOf('kia')<0) bad.push('the player 2 card never says KIA after a death ('+txt.slice(0,80)+')');
       arcadeLeave();
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       try{ NET.on=false; NET.role=''; }catch(_o){}
       try{ if(typeof ARCADE==='object'){ ARCADE.endSend=null; ARCADE.endRun=''; ARCADE.ini=null; ARCADE.over=null; } }catch(_z){}
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ if(nsv){ for(k in NET) if(Object.prototype.hasOwnProperty.call(NET,k)&&!Object.prototype.hasOwnProperty.call(nsv,k)) delete NET[k]; for(k in nsv) NET[k]=nsv[k]; } }catch(_n){}
       try{ if(ownAtt){ ATT.src=src0; ATT.tried=tried0; } }catch(_a){}
       try{ if(ownBk){ if(bk===null) localStorage.removeItem(BK); else localStorage.setItem(BK,bk); } }catch(_k){}
       try{ if(typeof ARCADE==='object'){ ARCADE.mine=0; ARCADE.mate=0; ARCADE.mateK=0; ARCADE.mateX=0; ARCADE.kills=0; ARCADE.ext=0; ARCADE.deaths=0; ARCADE.holdT=0; ARCADE.waveT=0; ARCADE.ownAt=0; ARCADE.idleSaid=0; ARCADE.wantIn=0; ARCADE.late=0; ARCADE.hiRun=''; ARCADE.hiSaid=0; } }catch(_m){}
       try{ var oc=document.querySelector('#attract .arcover'); if(oc) oc.style.display='none'; }catch(_oc){}
       try{ for(var kk in keys) keys[kk]=false; }catch(_kk){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'30.97',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
