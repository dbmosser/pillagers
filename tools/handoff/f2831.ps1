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

if ($s.Contains("  {v:'28.31',what:")) { throw "check 28.31 is in the fixture already" }

SubRx @'
  {v:'28.30',what:
'@ @'
  {v:'28.31',what:'cloud-coop-kid-firing-no-item: with Kid firing on, an item player 2 takes out from the wheel stays in his hand until he pulls the trigger himself; kid firing does not cook and throw his frag (control: with no item out, kid firing still shoots the machine)',
   run:function(){
     if(typeof netAutoFire!=='function'||typeof handTake!=='function'||typeof afTarget!=='function'||typeof wheelHave!=='function') return 'SKIP: no kid firing or wheel hand in this fixture';
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__sim&&window.__topClear&&window.__runPrep)) return 'SKIP: this fixture cannot deploy';
     var bad=[], NK={}, k, staged=false, oS=netSend, oSF=netSendFast, oB=netBroadcast, hk=Object.prototype.hasOwnProperty, hasAf=hk.call(P,'p2Auto'), af0=P.p2Auto,
         keep={aim:PAD.aiming,rs:PAD.afRsT,af:PAD.afire,fire:PAD.firing,mx:mouse.x,my:mouse.y,md:mouse.down,mi:mouse.init};
     function stage(){
       var g, p, e=null, a, x=0, y=0;
       __topClear(); __runPrep(); __resetCfg(); __cleanProfile();
       __deploy({kit:['frag','frag'],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return null;
       p=g.player; p.iv=99; keys={}; mouse.down=false; g.bagOpen=false; g.mapOpen=false;
       NET.on=true; NET.max=4; NET.role='join'; NET.seat=1; NET.same='p2'; NET.up=[]; NET.upSeed=g.seed>>>0; NET.peers=[{seat:0,state:'in'}]; NET.roster=[{seat:0,name:'HOST'},{seat:1,name:'P2'}]; NET.afHost=0;
       P.p2Auto=1; PAD.aiming=false; PAD.afRsT=null; PAD.afire=0; PAD.firing=false;
       g.ents.length=0;
       for(a=0;a<16&&!e;a++){ x=p.x+Math.cos(a*0.39)*220; y=p.y+Math.sin(a*0.39)*220; if(spotFree(g.map,x,y,20)&&losClear(p.x,p.y,x,y,g.vseg||g.map.segs)){ e=mkCrawler(x,y); e.hp=e.maxhp=5000; e.spd=0; e.speed=0; e.stun=99; g.ents.push(e); } }
       if(!e) return null;
       if(G.bag.indexOf('frag')<0) G.bag.push('frag');
       return {g:g,p:p,e:e,x:x,y:y};
     }
     function hold(s){ s.e.x=s.x; s.e.y=s.y; s.e.hp=5000; if(s.g.ents.indexOf(s.e)<0) s.g.ents.push(s.e); s.p.hp=100; }
     function end(){ var kk; for(kk in NET) if(!(kk in NK)) delete NET[kk]; for(kk in NK) NET[kk]=NK[kk]; try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} }
     try{
       for(k in NET) NK[k]=NET[k];
       staged=true;
       netSendFast=function(){ return true; }; netSend=netSendFast; netBroadcast=function(){ return 0; };
       var s, i, n0, shots=0, r;
       // ONE: he takes a frag out with a machine in range and in sight; kid firing must not pull the trigger on it
       s=stage(); if(!s) return 'SKIP: no clear spot for a machine here';
       for(i=0;i<5;i++){ __sim(0.016); hold(s); }
       if(!afTarget(s.p)) return 'SKIP: the machine is not a kid firing target here';
       mouse.down=false; PAD.afire=0;
       n0=wheelHave('frag');
       if(!handTake('frag')) return 'SKIP: handTake did not take the frag out';
       for(i=0;i<90;i++){ __sim(0.016); hold(s); if(!s.p.hand) break; }
       if(!s.p.hand||s.p.hand.k!=='frag') bad.push('ONE: kid firing used the frag he only took out (hand now '+(s.p.hand?s.p.hand.k:'empty')+' after '+i+' frames, cooking '+!!s.p.cooking+')');
       if(wheelHave('frag')!==n0) bad.push('ONE: frags went from '+n0+' to '+wheelHave('frag')+' without him pulling the trigger');
       if(s.p.hand&&s.p.hand.armed) bad.push('ONE: the frag in his hand was armed');
       end(); mouse.down=false; PAD.afire=0;
       // TWO (control): the same spot with no item out, kid firing still shoots
       s=stage(); if(!s) return bad.length?bad.join(' | '):'SKIP: no clear spot for a machine here (control)';
       for(i=0;i<30;i++){ __sim(0.016); hold(s); r=netAutoFire(s.p); if(r) shots++; }
       if(!shots) bad.push('TWO: with no item out kid firing never fired on the machine in range');
       if(s.p.hand) bad.push('TWO: an item came out by itself');
     }catch(err){ bad.push('threw: '+String(err&&err.stack||err).slice(0,300)); }
     finally{
       netSend=oS; netSendFast=oSF; netBroadcast=oB; keys={};
       if(staged){ for(k in NET) if(!(k in NK)) delete NET[k]; for(k in NK) NET[k]=NK[k]; }
       try{ if(hasAf) P.p2Auto=af0; else delete P.p2Auto; }catch(_p){}
       PAD.aiming=keep.aim; PAD.afRsT=keep.rs; PAD.afire=keep.af; PAD.firing=keep.fire; mouse.x=keep.mx; mouse.y=keep.my; mouse.down=keep.md; mouse.init=keep.mi;
       end(); __topClear(); __cleanProfile();
     }
     return bad.length?bad.join(' | '):null;
   }},
  {v:'28.30',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
