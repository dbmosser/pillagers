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

if ($s.Contains("  {v:'28.49',what:")) { throw "check 28.49 is in the fixture already" }

SubRx @'
  {v:'28.48',what:
'@ @'
  {v:'28.49',what:'cloud-coop-volatile-boom-seen: a VOLATILE elite that dies on the host blows up in player 2 window too, with the spark, puff, flash, blast and a shake of 6 the host frame shows; a plain body death in his window still shakes nothing',
   run:function(){
     if(!(window.__state&&window.__endRaid&&window.__runPrep&&window.__topClear)) return 'SKIP: no raid here';
     if(typeof arcadeDeploy!=='function'||typeof ARCADE!=='object'||typeof netOnMsg!=='function'||typeof netEntNewWord!=='function'||typeof netEntsInit!=='function'||typeof AFFIX!=='object'||!AFFIX.boom) return 'SKIP: no arcade, volatile affix or pair channel in this fixture';
     var bad=[], g=null, NK={}, k, oS=netSend, oSF=netSendFast, oB=netBroadcast, rs=say, oBF=boomFx, oFl=flash, staged=false, h={seat:0,state:'in'}, hp={seat:1,state:'in'}, vb=null, ct=null, wv, wc, i, e, nb=0, nf=0, r;
     try{
       __topClear(); __runPrep();
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       keys={};
       for(k in NET) NK[k]=NET[k];
       staged=true;
       say=function(){};
       netSendFast=function(q,m){ return true; }; netSend=function(q,m){ return true; }; netBroadcast=function(m){ return 1; };
       NET.on=true; NET.max=4; NET.specG=null; NET.up=[]; NET.upSeed=g.seed>>>0;
       // ONE (host window): number the bodies and make one a VOLATILE elite, one plain
       NET.role='host'; NET.seat=0; NET.peers=[hp];
       netEntsInit(g);
       for(i=0;i<g.ents.length;i++){ e=g.ents[i]; if((e.kind==='sentry'||e.kind==='crawler')&&!e.boss&&e.nid){ if(!vb) vb=e; else if(!ct){ ct=e; break; } } }
       if(!vb||!ct) return 'SKIP: no two numbered bodies';
       vb.elite=1; vb.affix='boom'; ct.elite=0; ct.affix='';
       wv=JSON.stringify(netEntNewWord(vb)); wc=JSON.stringify(netEntNewWord(ct));
       // TWO (player 2 window): his mirrors arrive by the real new words
       NET.role='join'; NET.seat=1; NET.peers=[h]; NET.entMap={}; NET.entGone={}; NET.entDead={};
       g.ents=[];
       r=netOnMsg(h,wv); if(r!=='ent:new') return 'the volatile new word was not taken: '+r;
       r=netOnMsg(h,wc); if(r!=='ent:new') return 'the plain new word was not taken: '+r;
       if(NET.entMap[vb.nid].affix!=='boom') bad.push('the mirror lost the volatile affix: '+NET.entMap[vb.nid].affix);
       boomFx=function(){ nb++; }; flash=function(){ nf++; };
       // control: a plain body dies, nothing blows
       g.shake=0;
       r=netOnMsg(h,JSON.stringify({t:'ent',op:'gone',id:ct.nid,how:'dead',n:(NET.entN|0)+1}));
       if(r!=='ent:gone') bad.push('the plain gone word was not taken: '+r);
       if((g.shake||0)>0||nb||nf) bad.push('a plain body death shook or blew in player 2 window: shake '+g.shake+', boomFx '+nb+', flash '+nf);
       // the volatile dies on the host: player 2 sees and feels the blast
       g.shake=0; nb=0; nf=0;
       r=netOnMsg(h,JSON.stringify({t:'ent',op:'gone',id:vb.nid,how:'dead',n:(NET.entN|0)+2}));
       if(r!=='ent:gone') bad.push('the volatile gone word was not taken: '+r);
       if(!((g.shake||0)>=6)) bad.push('a VOLATILE death did not shake player 2 window (shake '+g.shake+', the host gets 6)');
       if(!nb) bad.push('a VOLATILE death drew no blast (boomFx) in player 2 window');
       if(!nf) bad.push('a VOLATILE death drew no flash in player 2 window');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       boomFx=oBF; flash=oFl; say=rs; netSend=oS; netSendFast=oSF; netBroadcast=oB; keys={};
       if(staged){ for(k in NET) if(!(k in NK)) delete NET[k]; for(k in NK) NET[k]=NK[k]; }
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ __topClear(); }catch(_t){}
     }
     return bad.length?bad.join('; '):null;
   }},
  {v:'28.48',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
