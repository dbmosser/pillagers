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

if ($s.Contains("  {v:'28.93',what:")) { throw "check 28.93 is in the fixture already" }

SubRx @'
  {v:'28.92',what:
'@ @'
  {v:'28.93',what:'cloud-coop-p2-mimic-seen: when player 2 opens a mimic crate, the crawler goes for player 2, his window says MIMIC and shakes, and the host window does not',
   run:function(){
     if(!(window.__state&&window.__endRaid&&window.__runPrep&&window.__topClear)) return 'SKIP: no raid here';
     if(typeof arcadeDeploy!=='function'||typeof ARCADE!=='object'||typeof netOnMsg!=='function'||typeof netSrchTake!=='function'||typeof mimicTick!=='function') return 'SKIP: no arcade, party or mimic in this fixture';
     var g=null, p=null, NK={}, k, oSF=netSendFast, oS=netSend, oB=netBroadcast, oSay=say, lines=[], sent=[], h={seat:0,state:'in'}, hp={seat:1,state:'in'}, staged=false, oIv=null, i, c, ct=null, n0, cr, mk=null, bx, by2, r;
     try{
       __topClear(); __runPrep();
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       p=g.player; oIv=p.iv; p.iv=99;
       for(k in NET) NK[k]=NET[k]; staged=true;
       NET.on=true; NET.max=4; NET.specG=null; NET.entMap={}; NET.upSeed=g.seed>>>0;
       NET.role='host'; NET.seat=0; NET.peers=[hp]; NET.roster=[{seat:0,name:'ONE'},{seat:1,name:'TWO'}];
       bx=Math.round(p.x-600); by2=Math.round(p.y+300);
       NET.up=[{seat:1,n:1,age:0,sd:g.seed>>>0,tx:bx,ty:by2,tf:0,dn:0}];
       netSendFast=function(q,m){ sent.push(JSON.parse(JSON.stringify(m))); return true; };
       netSend=function(q,m){ sent.push(JSON.parse(JSON.stringify(m))); return true; };
       netBroadcast=function(m){ sent.push(JSON.parse(JSON.stringify(m))); return 1; };
       say=function(t){ lines.push(String(t)); };
       netEntsInit(g); netContInit(g);
       for(i=0;i<g.containers.length;i++){ c=g.containers[i]; if(c.type==='crate'&&!c.opened&&typeof c.cid==='number'&&c.loot&&c.loot.length){ ct=c; break; } }
       if(!ct) return 'SKIP: no closed crate in this raid';
       ct.mim=1; ct.mimicDone=0; ct.mimicWake=0; ct.prog=0; ct.x=p.x+900; ct.y=p.y; ct.time=30;
       g.shake=0; lines.length=0;
       r=netSrchTake(hp,{t:'srch',op:'start',cid:ct.cid,slow:1});
       n0=g.ents.length;
       for(i=0;i<60&&!ct.mimicDone;i++){ netSrchTick(1/60); mimicTick(1/60); }
       if(!ct.mimicDone) return 'SKIP: the mimic never woke on the host ('+r+', prog '+ct.prog+')';
       cr=g.ents.length>n0?g.ents[g.ents.length-1]:null;
       if(!cr||!cr.mimic) return 'the mimic woke but no crawler came up';
       for(i=0;i<sent.length;i++) if(sent[i]&&sent[i].t==='mark'&&sent[i].k==='mimic') mk=sent[i];
       if(!mk) return 'player 2 opened a mimic and the host sent no mimic mark to his window (crawler goes for '+Math.round(cr.tx)+','+Math.round(cr.ty)+', host at '+Math.round(p.x)+','+Math.round(p.y)+')';
       if((mk.seat|0)!==1) return 'the mimic mark names seat '+mk.seat+', not player 2';
       if(Math.round(cr.tx)!==bx||Math.round(cr.ty)!==by2) return 'the crawler goes for '+Math.round(cr.tx)+','+Math.round(cr.ty)+', not player 2 at '+bx+','+by2;
       if(lines.indexOf('MIMIC')>=0||(g.shake||0)>=4) return 'the host window said MIMIC or shook (shake '+g.shake+') for a mimic player 2 opened 900 away';
       NET.role='join'; NET.seat=1; NET.peers=[h]; NET.up=[]; NET.entMap={};
       lines.length=0; g.shake=0;
       r=netOnMsg(h,JSON.stringify(mk));
       if(lines.indexOf('MIMIC')<0) return 'player 2 window did not say MIMIC ('+r+'; said: '+lines.join(' | ')+')';
       if(!((g.shake||0)>=4)) return 'player 2 window said MIMIC but did not shake (shake '+g.shake+', the host shakes 4)';
       return null;
     }catch(e){ return 'threw: '+(e&&e.message||e); }
     finally{
       netSendFast=oSF; netSend=oS; netBroadcast=oB; say=oSay;
       if(staged){ for(k in NET) if(!(k in NK)) delete NET[k]; for(k in NK) NET[k]=NK[k]; }
       if(p&&oIv!==null) p.iv=oIv;
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
   }},
  {v:'28.92',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
