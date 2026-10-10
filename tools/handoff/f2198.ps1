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

if ($s.Contains("  {v:'21.98',what:")) { throw "check 21.98 is in the fixture already" }

SubRx @'
  {v:'21.97',what:
'@ @'
  {v:'21.98',what:'in co-op a pillager charge, a pillager smoke and a Howler shell on the host reach the other window, a charge player 2 throws reaches the host and is passed on, and every copy only draws: it hurts nobody and is never told on again',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof NET!=='object'||!NET||typeof netThrTake!=='function'||typeof raiderThrow!=='function'||typeof updateThrowables!=='function'||typeof activateThrow!=='function'||typeof netEntsPeer!=='function') return 'SKIP: no raid or party here';
     if(CFG.raiderKit===0) return 'SKIP: pillagers carry no kit in this fixture';
     if(!ITEMS.frag||ITEMS.frag.use!=='throw'||ITEMS.frag.tk!=='frag') return 'SKIP: no Frag Charge item here';
     var NK={}, k, bad=[], oSend=netSend, oDmg=damagePlayer, sent=[], hurt=0, g=null, p, e=null, i, c, r, s, rng0, fd,
         ha={state:'in',seat:0}, pa={state:'in',seat:1}, pb={state:'in',seat:2};
     function got(kk,q){ return sent.filter(function(w){ return w.m&&w.m.t==='thr'&&w.m.k===kk&&(!q||w.q===q); }); }
     function mortars(){ return g.shells.filter(function(q){ return q&&q.mortar; }).length; }
     function noMortars(){ for(var j=g.shells.length-1;j>=0;j--) if(g.shells[j]&&g.shells[j].mortar) g.shells.splice(j,1); }
     for(k in NET) NK[k]=NET[k];
     try{
       NET.on=false; NET.role=null; NET.peers=[];
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player||!g.frags||!g.shells||!g.smokes) return 'SKIP: no live raid';
       p=g.player;
       for(i=0;i<g.ents.length;i++){ c=g.ents[i]; if(c&&c.kind==='raider'&&!c.merc&&!c.friendlyPC&&!c.downed&&!c.finished&&c.hp>0){ e=c; break; } }
       if(!e) return 'SKIP: staging: no pillager';
       netSend=function(q,m){ sent.push({q:q,m:JSON.parse(JSON.stringify(m))}); return true; };
       damagePlayer=function(){ hurt++; };
       NET.specG=null; NET.on=true; NET.role='host'; NET.seat=0; NET.upSeed=g.seed>>>0; NET.peers=[pa]; NET.up=[];
       g.frags.length=0; g.smokes.length=0; noMortars();
       e.thrT=0; e.smkT=0; e.hp=Math.max(1,Math.floor((e.maxhp||100)*0.3));
       raiderThrow(e,{x:p.x+700,y:p.y},300,0.016);
       if(g.smokes.length!==1) return 'SKIP: staging: the hurt pillager did not smoke ('+g.smokes.length+')';
       if(!got('smoke',pa).length) bad.push('a pillager smoke on the host was not told to the other window');
       fd=(CFG.fragR===undefined?190:CFG.fragR)+80;
       if(fd>520) return 'SKIP: the charge blast is set too wide for a pillager to throw';
       e.thrT=0; e.smkT=14; e.hp=e.maxhp||100; rng0=e.rng; e.rng=fd+200; e.bag=['frag'];
       raiderThrow(e,{x:p.x+700,y:p.y},fd,0.016);
       e.rng=rng0;
       if(g.frags.length!==1) return 'SKIP: staging: the pillager did not throw his charge ('+g.frags.length+')';
       g.shells.push({mortar:1,x0:p.x+500,y0:p.y,by:null,tx:p.x+900,ty:p.y,t:0,air:2.1,dmg:35});
       updateThrowables(0.02);
       s=got('frag',pa);
       if(!s.length) bad.push('a pillager charge on the host was not told to the other window');
       else if(!(s[0].m.f>0.9&&s[0].m.f<=1.1)) bad.push('the charge word carries a fuse of '+s[0].m.f);
       s=got('sh',pa);
       if(!s.length) bad.push('a Howler shell on the host was not told to the other window');
       else if(!(Math.abs(s[0].m.x0-Math.round(p.x+500))<=1&&s[0].m.air>1.9&&s[0].m.air<=2.1)) bad.push('the shell word reads '+JSON.stringify(s[0].m));
       sent.length=0;
       updateThrowables(0.02);
       if(got('frag').length||got('sh').length) bad.push('the host told the same charge or shell twice');
       g.frags.length=0; noMortars(); sent.length=0;
       NET.role='join'; NET.seat=1; NET.peers=[ha];
       if(!netEntsPeer()) return 'SKIP: staging: the window does not read as player 2 up top';
       r=netThrTake(ha,{t:'thr',k:'frag',x:Math.round(p.x+30),y:Math.round(p.y),f:0.4});
       if(r!=='thr:frag'||g.frags.length!==1) bad.push('the player 2 window did not draw a charge the host told it of ('+r+')');
       r=netThrTake(ha,{t:'thr',k:'sh',x:Math.round(p.x+20),y:Math.round(p.y),x0:Math.round(p.x+600),y0:Math.round(p.y),air:0.5});
       if(r!=='thr:sh'||mortars()!==1) bad.push('the player 2 window did not draw a Howler shell the host told it of ('+r+')');
       updateThrowables(0.3); updateThrowables(0.3);
       if(g.frags.length) bad.push('a drawn charge never went off');
       if(mortars()) bad.push('a drawn shell never landed');
       if(hurt) bad.push('a charge or shell drawn in the player 2 window hurt him a second time ('+hurt+' blows)');
       if(sent.length) bad.push('the player 2 window sent '+sent.length+' words about copies it only draws');
       g.frags.length=0; noMortars(); sent.length=0; hurt=0;
       activateThrow({kind:'frag',tx:p.x+700,ty:p.y,cook:0});
       updateThrowables(0.02);
       if(!got('frag',ha).length) bad.push('a charge player 2 threw was not told to the host');
       g.frags.length=0; sent.length=0;
       NET.role='host'; NET.seat=0; NET.peers=[pa,pb];
       r=netThrTake(pa,{t:'thr',k:'frag',x:Math.round(p.x+30),y:Math.round(p.y),f:0.4});
       if(r!=='thr:frag'||g.frags.length!==1) bad.push('the host did not draw a charge player 2 threw ('+r+')');
       s=got('frag',pb);
       if(!s.length||!(s[0].m.f>0.39&&s[0].m.f<0.41)) bad.push('the host did not pass the charge of player 2 on to the other window with its fuse');
       if(got('frag',pa).length) bad.push('the host sent player 2 his own charge back');
       r=netThrTake(pa,{t:'thr',k:'sh',x:Math.round(p.x+20),y:Math.round(p.y),air:1});
       if(r!=='ignored'||mortars()) bad.push('the host took a Howler shell word from player 2 ('+r+')');
       sent.length=0;
       updateThrowables(0.3); updateThrowables(0.3);
       if(g.frags.length) bad.push('the copy of his charge on the host never went off');
       if(hurt) bad.push('the copy of a charge player 2 threw hurt the host player');
       if(got('nz').length||got('frag').length) bad.push('the copy of his charge was told on again from the host');
     }catch(ex){ bad.push('threw: '+(ex&&ex.message||ex)); }
     finally{
       netSend=oSend; damagePlayer=oDmg;
       try{ if(g){ g.frags.length=0; noMortars(); } }catch(_f){}
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'21.97',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
