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

if ($s.Contains("  {v:'23.51',what:")) { throw "check 23.51 is in the fixture already" }

SubRx @'
  {v:'23.50',what:
'@ @'
  {v:'23.51',what:'arcade27, his yes 2026-10-11: the host initials card stays on the host, a top 10 extraction card and its letter ops post no arcinis to player 2, a player 2 on its attract fed whatever the host posted still sends arcjoin with A and no arcini, and at the run end the kept card is posted to player 2 as arcinis',
   run:function(){
     var bad=[], K='', bk=null, ownBk=false, g=null, id, t0=Date.now(), rw=[], i, posts=[], rsp=null, ownSp=false, hc=null, sv={}, fk=['role','wantIn','late','askAt','iniAy'], sent;
     function on(list,t){ var j, o=[]; for(j=0;j<list.length;j++) if(list[j]&&list[j].t===t) o.push(list[j]); return o; }
     try{
       __topClear(); __runPrep();
       if(typeof arcadeDeploy!=='function'||typeof arcadeExtracted!=='function'||typeof arcadeIniPost!=='function'||typeof arcadeIniMirror!=='function'||typeof arcadePadAtt!=='function'||typeof ARCADE!=='object') return 'no arcade initials card in this build';
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(__state()&&!__state().over) __endRaid('abandon');
       K=ARCADE_BOARD_KEY; bk=localStorage.getItem(K); ownBk=true;
       for(i=0;i<10;i++) rw.push({run:'q'+i,i:'ZZZ',s:20000+i*1000,x:1,k:1,t:t0-60000-i});
       localStorage.setItem(K,JSON.stringify({v:1,rows:rw}));
       if(!arcadeDeploy({mapIx:0,seed:4242})||!__state()||!__state().arcade) return 'SKIP: arcadeDeploy built no arcade raid';
       try{ attStop(); }catch(_as){}
       if(ARCADE.role!=='host') return 'SKIP: the arcade sandbox is not the host ('+ARCADE.role+')';
       g=__state(); keys={}; ARCADE.ownAt=Date.now(); ARCADE.waveT=0; ARCADE.mate=0; ARCADE.pot=0;
       id=ARCADE.run&&ARCADE.run.id;
       if(!id) return 'SKIP: the arcade raid has no run id';
       rsp=netSamePost; ownSp=true;
       netSamePost=function(m){ posts.push(m); return true; };
       // the host extracts over tonights 10th score: the card opens on the host
       ARCADE.mine=30000; ARCADE.holdT=0; ARCADE.ownAt=Date.now();
       arcadeExtracted();
       if(!ARCADE.ini||ARCADE.ini.run!==id||ARCADE.ini.mirror||!ARCADE.ini.raid) return 'the top 10 extraction did not open the host initials card';
       if(__state()!==g||g.over) return 'the arcade raid ended at the extraction';
       arcadeIniOp('up'); arcadeIniOp('next');
       if(!ARCADE.ini||ARCADE.ini.l[0]!=='B'||ARCADE.ini.pos!==1) bad.push('the host card did not take its ops ('+(ARCADE.ini?ARCADE.ini.l.join('')+ARCADE.ini.pos:'no card')+')');
       sent=on(posts,'arcinis');
       for(i=0;i<sent.length;i++) if(sent[i].on) { bad.push('the host card in the live raid posted arcinis on to player 2 ('+sent.length+' arcinis posts)'); break; }
       // player 2 on its attract gets whatever the host posted, then presses A
       hc=ARCADE.ini;
       for(i=0;i<fk.length;i++) sv[fk[i]]=ARCADE[fk[i]];
       ARCADE.role='p2'; ARCADE.ini=null;
       for(i=0;i<sent.length;i++) arcadeIniMirror(sent[i]);
       posts=[];
       if(!arcadePadIni([0],[0,0,0,0])) arcadePadAtt(true,true);
       if(!on(posts,'arcjoin').length) bad.push('player 2 A did not send arcjoin while the host card was up ('+posts.map(function(m){ return m&&m.t; }).join(',')+')');
       if(on(posts,'arcini').length) bad.push('player 2 A went to the host card as arcini');
       ARCADE.ini=hc;
       for(i=0;i<fk.length;i++) ARCADE[fk[i]]=sv[fk[i]];
       sv=null;
       // the run ends with the card still up: now player 2 is shown it
       posts=[];
       ARCADE.ownAt=Date.now();
       if(!arcadeRunEnd('end')) bad.push('arcadeRunEnd did not end the run');
       if(!ARCADE.ini||ARCADE.ini.run!==id||ARCADE.ini.l[0]!=='B') bad.push('the run end lost the kept card ('+(ARCADE.ini?ARCADE.ini.run+' '+ARCADE.ini.l.join(''):'no card')+')');
       sent=on(posts,'arcinis');
       if(!sent.length||!sent[sent.length-1].on||sent[sent.length-1].run!==id||sent[sent.length-1].l!=='BAA') bad.push('at the run end the kept card was not posted to player 2 as arcinis ('+JSON.stringify(sent)+')');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       try{ if(sv&&typeof ARCADE==='object'){ for(i=0;i<fk.length;i++) if(fk[i] in sv) ARCADE[fk[i]]=sv[fk[i]]; } }catch(_sv){}
       try{ if(typeof ARCADE==='object') ARCADE.ini=null; }catch(_i){}
       try{ if(ownSp) netSamePost=rsp; }catch(_sp){}
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ if(ownBk){ if(bk===null) localStorage.removeItem(K); else localStorage.setItem(K,bk); } }catch(_b){}
       try{ if(typeof ARCADE==='object'){ ARCADE.over=null; ARCADE.mine=0; ARCADE.mate=0; ARCADE.pot=0; ARCADE.holdT=0; ARCADE.waveT=0; ARCADE.iniX=''; ARCADE.ownAt=0; ARCADE.idleSaid=0; ARCADE.wantIn=0; } }catch(_m){}
       try{ for(var kk in keys) keys[kk]=false; }catch(_k){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'23.50',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
