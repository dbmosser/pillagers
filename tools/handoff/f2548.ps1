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

if ($s.Contains("  {v:'25.48',what:")) { throw "check 25.48 is in the fixture already" }

SubRx @'
  {v:'25.47',what:
'@ @'
  {v:'25.48',what:'forge7: player 2s MK III round sends its element in the shot word, and the host burns the body for his seat, credits a burn kill to seat 1, eats a plate with his acid before the soak and ignores a bogus element',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof NET!=='object'||!NET||typeof netShotTake!=='function'||typeof netShotSend!=='function'||typeof netEntsInit!=='function'||typeof elemHit!=='function') return 'SKIP: no raid, party or elements here';
     var NK={}, k, bad=[], g, p, all=null, oSend=netSend, cap=[], cr=null, rd=null, pa={state:'in',seat:1}, r, h0, oPX, oPY, X0, Y0, dx=1, dy=0, ok=false, m, oWK=null;
     for(k in NET) NK[k]=NET[k];
     try{
       NET.on=false; NET.role=null; NET.peers=[];
       __topClear(); __runPrep(); __resetCfg(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       p=g.player; all=g.ents.slice(); oPX=p.x; oPY=p.y; X0=p.x; Y0=p.y;
       for(k=0;k<8;k++){ var ux=Math.cos(k*0.7854), uy=Math.sin(k*0.7854); if(losClear(X0,Y0,X0+ux*180,Y0+uy*180,g.map.segs)){ dx=ux; dy=uy; ok=true; break; } }
       if(!ok) return 'SKIP: staging: no open line from the drop point';
       cr=all.filter(function(x){ return x.kind==='crawler'&&x.hp>0&&!x.downed; })[0];
       rd=all.filter(function(x){ return x.kind==='raider'&&!x.merc&&!x.friendlyPC&&x.hp>0&&!x.downed; })[0];
       if(!cr) return 'SKIP: no crawler on this map';
       // THE LINKED WINDOW: his round sends the element
       NET.specG=null; NET.on=true; NET.role='join'; NET.seat=1; NET.upSeed=g.seed>>>0; NET.peers=[{state:'in',seat:0}]; NET.up=[];
       netSend=function(q,w){ cap.push(w); return true; };
       cr.nid=cr.nid||9001;
       netShotSend(cr,20,0,null,0,'fire');
       m=cap.length?cap[cap.length-1]:null;
       if(!m||m.t!=='shot') bad.push('no shot word was sent');
       else if(m.el!=='fire') bad.push('the shot word does not carry fire ('+m.el+')');
       cap.length=0; netShotSend(cr,20,0,null,0,'bogus');
       m=cap.length?cap[cap.length-1]:null;
       if(m&&m.el) bad.push('a bogus element went into the shot word');
       oWK=WEAKPTS.crawler; WEAKPTS.crawler=null;
       g.ents=[cr]; cr.x=X0; cr.y=Y0; cr.hp=cr.maxhp=2000; cr.face=Math.atan2(dy,dx); cr.burnT=0;
       p.x=X0-dx*200; p.y=Y0-dy*200;
       cap.length=0; g.bullets.length=0;
       g.bullets.push({x:X0+dx*6,y:Y0+dy*6,vx:-dx*1180,vy:-dy*1180,dmg:20,life:0.5,player:true,owner:p,tint:ELEM.fire.c,el:'fire',thru:0});
       updateBullets(0.001);
       m=cap.filter(function(w){ return w&&w.t==='shot'; })[0];
       if(!m) bad.push('a fire round on the linked window sent no shot word');
       else if(m.el!=='fire') bad.push('the fire round shot word carries '+m.el);
       if(cr.hp!==2000||cr.burnT>0) bad.push('the linked window burned or hurt the body itself');
       netSend=oSend; WEAKPTS.crawler=oWK; oWK=null;
       // THE HOST: it applies the element for seat 1
       g.ents=all.slice(); p.x=oPX; p.y=oPY;
       NET.on=true; NET.role='host'; NET.seat=0; NET.peers=[pa]; NET.up=[];
       if(!netEntsHost()) return 'SKIP: staging: the window does not read as the host';
       netEntsInit(g);
       netSend=function(q,w){ cap.push(w); return true; };
       cr.hp=2000; cr.burnT=0; cr.burnDps=0; cr.byPlayer=false; cr.bySeat=0;
       r=netShotTake(pa,{t:'shot',id:cr.nid,dmg:20,el:'fire'});
       if(r!=='shot') bad.push('the host did not take the fire shot ('+r+')');
       if(!(cr.burnT>0)) bad.push('the host did not burn the body for player 2s fire round');
       if(cr.burnBy!==1) bad.push('the burn is not credited to seat 1 ('+cr.burnBy+')');
       cr.hp=1; elemTick(0.5);
       if(!(cr.hp<=0)) bad.push('the burn did not finish the crawler');
       else if(cr.bySeat!==1||cr.byPlayer!==false) bad.push('a burn kill from player 2s round is marked seat '+cr.bySeat+' byPlayer '+cr.byPlayer);
       cr.hp=2000; cr.burnT=0; cr.chillT=0; cr.corrT=0; cr.stunT=0; cr.stunImm=0;
       r=netShotTake(pa,{t:'shot',id:cr.nid,dmg:20,el:'bogus'});
       if(r!=='shot') bad.push('a shot word with a bogus element was thrown away ('+r+')');
       if(cr.burnT>0||cr.chillT>0||cr.corrT>0||cr.stunT>0) bad.push('a bogus element set a status');
       if(Math.abs(cr.hp-1980)>0.01) bad.push('the bogus element shot dealt '+(2000-cr.hp));
       if(rd&&rd.nid){
         rd.hp=rd.maxhp=2000; rd.rig='heavy'; rd.armor=120; rd.corrT=0; rd.hostile=true;
         r=netShotTake(pa,{t:'shot',id:rd.nid,dmg:30,ar:1,el:'acid'});
         var want=120-18; want-=Math.min(want,30*0.66*0.5);
         if(r!=='shot') bad.push('the host did not take the acid shot ('+r+')');
         else if(Math.abs(rd.armor-want)>0.05) bad.push('player 2s acid round left the plate at '+rd.armor.toFixed(2)+', want '+want.toFixed(2));
       }
     }catch(ex){ bad.push('threw: '+(ex&&ex.message||ex)); }
     finally{
       netSend=oSend;
       try{ if(oWK!==null) WEAKPTS.crawler=oWK; }catch(_w){}
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
       try{ var g2=__state(); if(g2){ if(all) g2.ents=all; g2.bullets.length=0; if(g2.player){ g2.player.x=oPX; g2.player.y=oPY; } if(!g2.over){ g2.player.downed=false; g2.player.hp=100; __endRaid('abandon'); } } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'25.47',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
