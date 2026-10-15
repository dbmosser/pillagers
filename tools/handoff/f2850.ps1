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

if ($s.Contains("  {v:'28.50',what:")) { throw "check 28.50 is in the fixture already" }

SubRx @'
  {v:'28.49',what:
'@ @'
  {v:'28.50',what:'cloud-coop-wave-said-to-p2: when the host window makes a wave in a two player raid, player 2 is told WAVE n (with AMBUSH BEHIND YOU on an ambush) and hears the WAVE sting, and his wave count is the host count; a late joiner first word says nothing',
   run:function(){
     if(!(window.__state&&window.__endRaid&&window.__runPrep&&window.__topClear&&window.__P)) return 'SKIP: no raid here';
     if(typeof arcadeDeploy!=='function'||typeof ARCADE!=='object'||typeof arcadeWaveTick!=='function'||typeof netWorldSend!=='function'||typeof netOnMsg!=='function'||typeof annCue!=='function'||typeof flowNetOut!=='function') return 'SKIP: no arcade, party or waves in this fixture';
     var g=null, p=null, NK={}, k, oSF=netSendFast, oS=netSend, oSay=say, oCue=annCue, said=[], cues=[], sent=[], w=null, h={seat:0,state:'in'}, hp={seat:1,state:'in'}, HF=null, PF={}, staged=false, who='', hN=4, hA=0, pN=0, pA=0, oIv=null, oN=0, oA=0, oT=0, made=0, t, r;
     function word(){ var q; for(q=sent.length-1;q>=0;q--) if(sent[q].t==='wd') return sent[q]; return null; }
     function park(){ if(who==='H'){ hN=ARCADE.waveN; hA=ARCADE.waveAmb; } else if(who==='P2'){ pN=ARCADE.waveN; pA=ARCADE.waveAmb; } }
     function asHost(){ park(); NET.role='host'; NET.seat=0; NET.peers=[hp]; NET.upSeed=g.seed>>>0; g.flow=HF; ARCADE.waveN=hN; ARCADE.waveAmb=hA; who='H'; }
     function asTwo(){ park(); NET.role='join'; NET.seat=1; NET.peers=[h]; NET.upSeed=g.seed>>>0; g.flow=PF; ARCADE.waveN=pN; ARCADE.waveAmb=pA; who='P2'; }
     function ship(){ sent.length=0; asHost(); netWorldSend(); w=word(); asTwo(); if(w) netOnMsg(h,JSON.stringify(w)); asHost(); return w; }
     function hostWave(){ var n=0, q; asHost(); for(q=0;q<40&&!n;q++){ g.ents=g.ents.filter(function(e){ return !e.arcWave; }); g.t+=30; ARCADE.waveT=999; n=arcadeWaveTick(0.5); } park(); return n; }
     function p2said(){ return said.filter(function(m){ return m.indexOf('P2|')===0; }); }
     try{
       __topClear(); __runPrep();
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       oN=ARCADE.waveN; oA=ARCADE.waveAmb; oT=ARCADE.waveT;
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       p=g.player; oIv=p.iv; p.iv=99;
       for(k in NET) NK[k]=NET[k]; staged=true;
       NET.on=true; NET.max=4; NET.specG=null; NET.up=[]; NET.entMap={};
       netSendFast=function(q,m){ sent.push(JSON.parse(JSON.stringify(m))); return true; };
       netSend=function(q,m){ return true; };
       say=function(a,b,c){ said.push(who+'|'+String(a)+'|'+((c&&c.sub)||'')); };
       annCue=function(c){ cues.push(who+'|'+c); return true; };
       HF=g.flow||{}; g.t=400;
       // ONE: a late joiner: the first host word sets his count to the host count and says nothing
       if(!ship()) return 'SKIP: the host sent no world word';
       if(!w.fl) return 'SKIP: the host world word carried no raid flow';
       if(p2said().length) return 'ONE: the first host word said '+p2said().join(' / ')+' on player 2 window';
       said.length=0; cues.length=0;
       // TWO: the host makes a wave: player 2 is told WAVE n and hears the sting, and his count is the host count
       made=hostWave(); if(!made) return 'SKIP: the host made no wave';
       if(!said.some(function(m){ return m==='H|WAVE '+hN+'|'+(hA?'AMBUSH BEHIND YOU':''); })) return 'SKIP: the host did not say WAVE '+hN+' ('+said.join(' / ')+')';
       said.length=0; cues.length=0;
       ship(); ship();
       r=p2said();
       if(r.length!==1||r[0]!=='P2|WAVE '+hN+'|'+(hA?'AMBUSH BEHIND YOU':'')) return 'TWO: the host made WAVE '+hN+' and player 2 was told '+(r.length?r.join(' / '):'nothing');
       if(cues.filter(function(c){ return c==='P2|WAVE'; }).length!==1) return 'TWO: player 2 heard the WAVE sting '+cues.filter(function(c){ return c==='P2|WAVE'; }).length+' times, not once';
       if((pN|0)!==(hN|0)) return 'TWO: player 2 wave count is '+pN+' and the host count is '+hN;
       // THREE: an ambush wave on the host comes to player 2 with AMBUSH BEHIND YOU
       said.length=0; cues.length=0;
       asHost(); hN=(hN|0)+1; hA=1; ARCADE.waveN=hN; ARCADE.waveAmb=1;
       ship();
       r=p2said();
       if(r.length!==1||r[0]!=='P2|WAVE '+hN+'|AMBUSH BEHIND YOU') return 'THREE: an ambush WAVE '+hN+' on the host told player 2 '+(r.length?r.join(' / '):'nothing');
       if((pN|0)!==(hN|0)) return 'THREE: player 2 wave count is '+pN+' and the host count is '+hN;
       return null;
     }catch(x){ return 'threw: '+(x&&x.message||x); }
     finally{
       netSendFast=oSF; netSend=oS; say=oSay; annCue=oCue;
       if(staged){ for(k in NET) if(!(k in NK)) delete NET[k]; for(k in NK) NET[k]=NK[k]; }
       if(p&&oIv!==null) p.iv=oIv;
       try{ if(g&&HF) g.flow=HF; }catch(_g){}
       try{ if(ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       ARCADE.waveN=oN; ARCADE.waveT=oT; if(oA===undefined) delete ARCADE.waveAmb; else ARCADE.waveAmb=oA;
       __topClear();
     }
   }},
  {v:'28.49',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
