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

if ($s.Contains("  {v:'28.44',what:")) { throw "check 28.44 is in the fixture already" }

SubRx @'
  {v:'28.43',what:
'@ @'
  {v:'28.44',what:'cloud-coop-takeover-no-free-event: when the host leaves while a machine convoy, a bounty pillager and an Overseer rampage are live, player 2 picks up the raid and those events end quietly: no free CONVOY CRATE, no CONVOY DOWN, no BOUNTY line, no score or credits, and no rampage ring or map mark left on the spot of a body that went with the host',
   run:function(){
     if(!(window.__state&&window.__endRaid&&window.__runPrep&&window.__topClear&&window.__deploy&&window.__P)) return 'SKIP: no raid here';
     if(typeof netWorldSend!=='function'||typeof netOnMsg!=='function'||typeof netHostGone!=='function'||typeof netEntMake!=='function'||typeof evLaunch!=='function'||typeof evTick!=='function'||typeof flowTick!=='function'||typeof careerSettle!=='function'||typeof evMarks!=='function'||typeof bossTick!=='function'||typeof BOSS_NAME==='undefined'||typeof CAREER_ON==='undefined') return 'SKIP: no career, party or events in this fixture';
     var g=null, p=null, NK={}, k, oSF=netSendFast, oS=netSend, oSay=say, said=[], sent=[], w=null, h={seat:0,state:'in'}, HF=null, PF={}, staged=false, c0=CAREER_ON, cr0=null, cb0='[]', oIv=null;
     var cv, bt, rv, bo, hb=[], nb=[], hostEnts, i, e, n, cs0, gain, L=[], wr, mk=[];
     function word(){ var q; for(q=sent.length-1;q>=0;q--) if(sent[q].t==='wd') return sent[q]; return null; }
     function asHost(){ NET.role='host'; NET.seat=0; NET.peers=[{seat:1,state:'in'}]; NET.upSeed=g.seed>>>0; g.flow=HF; }
     function asTwo(){ NET.role='join'; NET.seat=1; NET.peers=[h]; NET.upSeed=g.seed>>>0; g.flow=PF; }
     try{
       __topClear(); __runPrep(); CAREER_ON=1;
       cr0=+__P().credits||0; cb0=JSON.stringify(__P().careerBoard||[]);
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       if(!g.career||!g.cs) return 'SKIP: the raid is not a career raid';
       p=g.player; oIv=p.iv; p.iv=99;
       for(k in NET) NK[k]=NET[k]; staged=true;
       NET.on=true; NET.max=4; NET.specG=null; NET.up=[]; NET.entMap={};
       netSendFast=function(q,m){ sent.push(JSON.parse(JSON.stringify(m))); return true; };
       netSend=function(q,m){ return true; };
       say=function(a,b2,c){ said.push(String(a)+((c&&c.sub)?' / '+c.sub:'')); };
       HF=g.flow||{}; asHost(); g.t=200; flowTick(0.01);
       if(!HF.ev) return 'SKIP: the host has no raid events';
       for(i=0;HF.ev.plan&&i<HF.ev.plan.length;i++) HF.ev.plan[i].on=1; HF.ev.live=[];
       if(!g.bossRef){ g.bossDone=0; bossTick(); } bo=g.bossRef; if(!bo) return 'SKIP: the host has no Overseer';
       rv=evLaunch('rampage'); cv=evLaunch('convoy'); bt=evLaunch('bounty'); if(!cv||!bt||!rv) return 'SKIP: the host launched no convoy, bounty or rampage';
       cv.t=cv.warn; bt.t=bt.warn; rv.t=rv.warn; evTick(0.01);
       if(cv.ph!=='live'||bt.ph!=='live'||rv.ph!=='live'||!cv.d.car||!bt.d.e||rv.d.b!==bo) return 'SKIP: the convoy, the bounty or the rampage did not go live on the host';
       bo.x+=500;
       hb=cv.d.crew.concat([bt.d.e,bo]);
       for(i=0;i<hb.length;i++) hb[i].nid=880+i;
       // on player 2 window these bodies came only in host words: real join-side net bodies, in its ents and its map
       hostEnts=g.ents.filter(function(x){ return hb.indexOf(x)<0; });
       sent.length=0; netWorldSend(); w=word(); if(!w) return 'the host sent no world word';
       g.ents=hostEnts;
       for(i=0;i<hb.length;i++){ e=netEntMake(hb[i].nid,(hb[i]===bo)?'warden':(hb[i].kind||'raider'),hb[i].x,hb[i].y); if(hb[i]===bo) e.name=BOSS_NAME; e.hp=hb[i].hp; e.maxhp=hb[i].maxhp; e.nIn=1; NET.entMap[e.nid]=e; g.ents.push(e); nb.push(e); }
       g.bossRef=null;
       asTwo(); netOnMsg(h,JSON.stringify(w));
       n=0; for(i=0;PF.ev&&i<PF.ev.live.length;i++){ e=PF.ev.live[i]; if(e.id==='convoy'&&e.d.car===nb[0]) n++; if(e.id==='bounty'&&e.d.e===nb[nb.length-2]) n++; if(e.id==='rampage'&&e.d.b===nb[nb.length-1]) n++; }
       if(n!==3) return 'SKIP: player 2 window did not take the three live events onto its net bodies';
       cs0=g.cs.s|0; said.length=0;
       if(!netHostGone('out')) return 'player 2 window did not take over the raid';
       for(i=0;i<8;i++){ g.t+=0.25; flowTick(0.25); }
       gain=(g.cs.s|0)-cs0;
       wr=(PF.ev&&PF.ev.wrecks||[]).filter(function(c){ return c&&c.tag==='CONVOY CRATE'; }).length;
       for(i=0;i<said.length;i++) if((/^(CONVOY DOWN|BOUNTY )/).test(said[i])) return 'after the takeover player 2 window said '+said[i]+' for a body that only went with the host';
       evMarks(mk); for(i=0;i<mk.length;i++) if(mk[i].kind==='ev'&&(/^OVERSEER RAMPAGE/).test(mk[i].txt)) return 'after the takeover the rampage mark still sits at '+Math.round(mk[i].x)+','+Math.round(mk[i].y)+' on a body that went with the host';
       if(wr) return 'after the takeover a free CONVOY CRATE dropped in player 2 window';
       if(gain) return 'after the takeover player 2 run score went up '+gain+' for a body that only went with the host';
       careerSettle('extract',L);
       if((+__P().credits||0)!==cr0+Math.max(0,cs0)*2) return 'his save gained '+((+__P().credits||0)-cr0-Math.max(0,cs0)*2)+' credits from the takeover';
       return null;
     }catch(x){ return 'threw: '+(x&&x.message||x); }
     finally{
       netSendFast=oSF; netSend=oS; say=oSay; CAREER_ON=c0;
       try{ if(cr0!==null){ __P().credits=cr0; __P().careerBoard=JSON.parse(cb0); } }catch(_r){}
       if(staged){ for(k in NET) if(!(k in NK)) delete NET[k]; for(k in NK) NET[k]=NK[k]; }
       if(p&&oIv!==null) p.iv=oIv;
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
   }},
  {v:'28.43',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
