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

if ($s.Contains("  {v:'28.95',what:")) { throw "check 28.95 is in the fixture already" }

SubRx @'
  {v:'28.94',what:
'@ @'
  {v:'28.95',what:'cloud-coop-p2-near-miss-pins: on the host, four rounds of player 2 that go past a hostile pillager pin him as four of the host own do, a landed player 2 round counts once, and a man behind the one hit is not counted',
   run:function(){
     if(!(window.__state&&window.__endRaid&&window.__runPrep&&window.__deploy)) return 'SKIP: no raid here';
     if(typeof netOnMsg!=='function'||typeof netShotTake!=='function'||typeof updateBullets!=='function'||typeof mkRaider!=='function'||typeof netEntMake!=='function'||typeof suppHit!=='function') return 'SKIP: the co-op shot path is not here';
     var bad=[], g=null, p=null, NK={}, k, oS=netSend, oSF=netSendFast, h={seat:0,state:'in'}, hp={seat:1,state:'in'}, staged=false, posted=[], A=null, B=null, mA=null, mB=null, n, a, aa, x=0, y=0, dx=1, dy=0, nx=0, ny=0, found=false, sup, oSH=suppHit, hostN=0, ofs=0;
     function mk(xx,yy){ var e=mkRaider(xx,yy); e.x=xx; e.y=yy; e.hp=e.maxhp=9999; e.hostile=true; e.merc=false; e.friendlyPC=false; e.downed=false; e.finished=false; e.roll=0; e.rollCd=99; e.supp=0; e.suppT=0; e.pinT=0; e.suppB=null; return e; }
     function mir(id,e){ var m=netEntMake(id,'raider',e.x,e.y); m.hp=m.maxhp=9999; m.r=e.r; m.nIn=1; m.hostile=true; m.roll=0; m.rollCd=99; return m; }
     function asHost(){ NET.role='host'; NET.seat=0; NET.peers=[hp]; NET.entMap={901:A,902:B}; g.ents=[A,B]; }
     function asTwo(){ NET.role='join'; NET.seat=1; NET.peers=[h]; NET.entMap={901:mA,902:mB}; g.ents=[mA,mB]; }
     function fire(ox,oy,cnt){ var b; g.bullets.length=0; for(b=0;b<cnt;b++) g.bullets.push({sx:ox,sy:oy,mzd:0,x:ox-dx*b*85,y:oy-dy*b*85,vx:dx*1180,vy:dy*1180,dmg:1,life:0.6,player:true,owner:p,tint:'#ffd48a',el:'',thru:0,gid:'lmg'}); for(n=0;n<80&&g.bullets.length;n++) updateBullets(1/120); }
     function feed(){ var i, w; NET.supAcc=0; netFxStep(NET_HUB_STEP); w=posted.slice(); posted.length=0; asHost(); for(i=0;i<w.length;i++) netOnMsg(hp,JSON.stringify(w[i])); return w; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       p=g.player; p.iv=99; p.hp=100;
       for(a=0;a<32;a++){ aa=a/32*6.2832; dx=Math.cos(aa); dy=Math.sin(aa); x=p.x+dx*220; y=p.y+dy*220; if(spotFree(g.map,x,y,50)&&spotFree(g.map,x+dx*170,y+dy*170,50)&&rayHitG(x-dx*160,y-dy*160,dx,dy,520)>=519.5){ found=true; break; } }
       if(!found) return 'SKIP: no clear lane next to the player';
       nx=-dy; ny=dx;
       for(k in NET) NK[k]=NET[k];
       staged=true;
       NET.on=true; NET.max=4; NET.specG=null; NET.up=[]; NET.upSeed=g.seed>>>0;
       netSendFast=function(q,mm){ return true; };
       netSend=function(q,mm){ posted.push(JSON.parse(JSON.stringify(mm))); return true; };
       A=mk(x,y); B=mk(x+dx*170,y+dy*170); mA=mir(901,A); mB=mir(902,B); mB.x=B.x+20000; B.x+=20000;
       // ONE: four rounds go past A 30 px off his line; first the host own, counted, then the same four on player 2 window, whose words reach the host
       asHost(); suppHit=function(e){ if(e===A) hostN++; return oSH(e); };
       try{ fire(x-dx*150+nx*30,y-dy*150+ny*30,4); } finally { suppHit=oSH; }
       ofs=(+A.pinT||0); A.supp=0; A.suppT=0; A.pinT=0; A.suppB=null; posted.length=0;
       if(hostN<4||Math.abs(ofs-SUPP_PIN)>0.05) return 'SKIP: four host rounds past the pillager counted '+hostN+' and pinned '+ofs+' here';
       asTwo(); posted.length=0; fire(x-dx*150+nx*30,y-dy*150+ny*30,4);
       sup=feed().filter(function(q){ return q&&q.t==='sup'; });
       if(sup.length!==1) bad.push('ONE: one flush of player 2 window sent '+sup.length+' near miss words to the host, not one');
       else if(!sup[0].q||(sup[0].q[901]|0)!==hostN) bad.push('ONE: player 2 near miss word counted '+JSON.stringify(sup[0].q)+' for four rounds past a hostile pillager, the same four of the host count '+hostN);
       asTwo(); posted.length=0; NET.supAcc=0; netFxStep(NET_HUB_STEP);
       if(posted.filter(function(q){ return q&&q.t==='sup'; }).length) bad.push('ONE: a flush with nothing new sent a near miss word again');
       if(Math.abs((+A.pinT||0)-SUPP_PIN)>0.05) bad.push('ONE: four rounds of player 2 past a hostile pillager left him unpinned on the host (pinT '+(+A.pinT||0)+', count '+(A.supp|0)+'), four of the host own pin him');
       // TWO: shot words alone count nothing (the near miss word of the round already counted), so no double count
       asHost(); A.supp=0; A.suppT=0; A.pinT=0; A.hp=9999;
       for(n=0;n<4;n++) netOnMsg(hp,JSON.stringify({t:'shot',id:901,dmg:1,x:x-dx*100,y:y-dy*100,a:0}));
       if((A.supp|0)!==0||(+A.pinT||0)!==0) bad.push('TWO: four shot words alone counted '+(A.supp|0)+' and pinT '+(+A.pinT||0)+', a landed round was counted twice');
       // THREE: a round straight into A stops on A; B stands on the same line behind him and is not suppressed
       A.supp=0; A.suppT=0; A.pinT=0; A.hp=9999; B.x-=20000; mB.x-=20000; B.supp=0; B.pinT=0; mA.hp=9999; mA.suppB=null; mB.suppB=null;
       asTwo(); posted.length=0; fire(x-dx*150,y-dy*150,1);
       sup=feed();
       if((A.supp|0)!==1) bad.push('THREE: the round that landed on the pillager counted '+(A.supp|0)+' on the host, one round is one count');
       if((B.supp|0)!==0) bad.push('THREE: a pillager standing behind the one hit was suppressed by a round that stopped in front of him ('+(B.supp|0)+')');
     }catch(x2){ bad.push('threw: '+String(x2&&x2.message||x2)); }
     finally{
       netSend=oS; netSendFast=oSF; suppHit=oSH;
       if(staged){ for(k in NET) if(!(k in NK)) delete NET[k]; for(k in NK) NET[k]=NK[k]; }
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join(' | '):null;
   }},
  {v:'28.94',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
