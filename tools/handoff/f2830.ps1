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

if ($s.Contains("  {v:'28.30',what:")) { throw "check 28.30 is in the fixture already" }

SubRx @'
  {v:'28.29',what:
'@ @'
  {v:'28.30',what:'cloud-coop-host-out-events-end: when the host extracts or dies in a career co-op raid while a coolant rupture is live, player 2 window ends it (no fog left on him for good), and an older live host word does not bring it back',
   run:function(){
     if(!(window.__state&&window.__endRaid&&window.__runPrep&&window.__topClear&&window.__deploy&&window.__P)) return 'SKIP: no raid here';
     if(typeof netWorldSend!=='function'||typeof netOnMsg!=='function'||typeof evLaunch!=='function'||typeof evTick!=='function'||typeof flowTick!=='function'||typeof flowVis!=='function'||typeof CAREER_ON==='undefined') return 'SKIP: no career, party or events in this fixture';
     var g=null, p=null, NK={}, k, oSF=netSendFast, oS=netSend, oSay=say, sent=[], w=null, w0=null, h={seat:0,state:'in'}, HF=null, PF={}, staged=false, c0=CAREER_ON, oIv=null, px=0, py=0, ev, i, c, v;
     function word(){ var q; for(q=sent.length-1;q>=0;q--) if(sent[q].t==='wd') return sent[q]; return null; }
     function asHost(over){ NET.role='host'; NET.seat=0; NET.peers=[{seat:1,state:'in'}]; NET.upSeed=g.seed>>>0; g.flow=HF; g.over=over||false; NET.specG=over?g:null; }
     function asTwo(){ NET.role='join'; NET.seat=1; NET.peers=[h]; NET.upSeed=g.seed>>>0; g.flow=PF; g.over=false; NET.specG=null; }
     function take(over){ sent.length=0; asHost(over); netWorldSend(); w=word(); asTwo(); if(w) netOnMsg(h,JSON.stringify(w)); return w; }
     function cool(){ var q, L=(PF.ev&&PF.ev.live)||[]; for(q=0;q<L.length;q++) if(L[q].id==='cool') return L[q]; return null; }
     try{
       __topClear(); __runPrep(); CAREER_ON=1;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       if(!g.career) return 'SKIP: the raid is not a career raid';
       p=g.player; oIv=p.iv; p.iv=99; px=p.x; py=p.y;
       for(k in NET) NK[k]=NET[k]; staged=true;
       NET.on=true; NET.max=4; NET.specG=null; NET.up=[]; NET.entMap={};
       netSendFast=function(q,m){ sent.push(JSON.parse(JSON.stringify(m))); return true; };
       netSend=function(q,m){ return true; };
       say=function(){};
       HF=g.flow||{}; asHost(); g.t=60; flowTick(0.01);
       HF.ev={plan:[],live:[],n:0,wrecks:[]};
       ev=evLaunch('cool'); if(!ev) return 'SKIP: the host launched no coolant rupture';
       ev.t=ev.warn; evTick(0.01); if(ev.ph!=='live') return 'SKIP: the coolant rupture did not go live on the host';
       if(!take(false)||!w.fl) return 'SKIP: the live host sent no raid flow';
       w0=JSON.parse(JSON.stringify(w));
       c=cool(); if(!c||c.ph!=='live') return 'SKIP: player 2 window did not take the live coolant rupture';
       // the host extracts: endRaid sets G.over, netSpecStart sets NET.specG=G, and the spectating host keeps sending the world word
       if(!take('extract')) return 'the spectating host sent no world word';
       if(w.fl!==null) return 'SKIP: the spectating host world word carried flow '+JSON.stringify(w.fl).slice(0,60);
       c=cool(); if(c&&c.ph!=='end') return 'after the host extracted, player 2 coolant rupture is still '+c.ph+' (lt '+(+c.lt).toFixed(1)+')';
       for(i=0;i<40;i++){ g.t+=0.25; flowTick(0.25); if(i%2===0) take('extract'); }
       c=cool(); if(c) return 'ten seconds after the host extracted, player 2 still has the coolant rupture '+c.ph;
       p.x=ev.x; p.y=ev.y; v=flowVis(); p.x=px; p.y=py;
       if(v!==1) return 'ten seconds after the host extracted, player 2 sight in the rupture is '+v;
       asTwo(); netOnMsg(h,JSON.stringify(w0)); flowTick(0.01);
       c=cool(); if(c&&c.ph==='live') return 'an older live host word brought the coolant rupture back on player 2 after the host extracted';
       p.x=ev.x; p.y=ev.y; v=flowVis(); p.x=px; p.y=py;
       if(v!==1) return 'an older live host word put the fog back on player 2: sight '+v;
       return null;
     }catch(x){ return 'threw: '+(x&&x.message||x); }
     finally{
       netSendFast=oSF; netSend=oS; say=oSay; CAREER_ON=c0;
       if(staged){ for(k in NET) if(!(k in NK)) delete NET[k]; for(k in NK) NET[k]=NK[k]; }
       if(p){ p.x=px; p.y=py; if(oIv!==null) p.iv=oIv; }
       try{ if(g){ g.over=false; g.flow=HF; } }catch(_g){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
   }},
  {v:'28.29',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
