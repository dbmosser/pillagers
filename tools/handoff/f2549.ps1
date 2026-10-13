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

if ($s.Contains("  {v:'25.49',what:")) { throw "check 25.49 is in the fixture already" }

SubRx @'
  {v:'25.48',what:
'@ @'
  {v:'25.49',what:'forge8: the five element statuses ride the body flags to player 2, a fire hit plays the fire sound, the body effects draw on a burning body only, a forged gun glows at the hands, and the state word carries the forged gun both ways',
   run:function(){
     if(!window.__deploy||!window.__endRaid||!window.__gfxCount||typeof elemHit!=='function'||typeof netEntFlags!=='function'||typeof netEntFlagsApply!=='function') return 'SKIP: no raid, flags or elements here';
     if(typeof drawElemFx!=='function'||typeof forgeGlow!=='function') return 'no element effects (drawElemFx, forgeGlow)';
     var NK={}, k, bad=[], g, p, all=null, oW, oSfx=sfx, heard=[], cr, f, o={}, c0, c1, box=[], A, w, nm, S, i;
     for(k in NET) NK[k]=NET[k];
     try{
       NET.on=false; NET.role=null; NET.peers=[];
       __topClear(); __runPrep(); __resetCfg(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g.player; if(!g||g.over) return 'SKIP: no live raid';
       all=g.ents.slice(); oW=p.wep;
       cr=all.filter(function(x){ return x.kind==='crawler'&&x.hp>0&&!x.downed; })[0];
       if(!cr) return 'SKIP: no crawler on this map';
       cr.burnT=1; cr.chillT=1; cr.stunT=0; cr.frozenT=0; cr.corrT=0;
       f=netEntFlags(cr);
       if(!(f&8388608)) bad.push('a burning body does not carry the burning bit');
       if(!(f&33554432)) bad.push('a chilled body does not carry the chilled bit');
       if(f&(16777216|67108864|134217728)) bad.push('a body carries a status it does not have');
       netEntFlagsApply(o,f);
       if(!(o.burnT>0)||!(o.chillT>0)||o.stunT>0||o.frozenT>0||o.corrT>0) bad.push('the flags did not come back as burning and chilled ('+o.burnT+' '+o.chillT+' '+o.stunT+')');
       cr.burnT=0; cr.chillT=0; cr.stunT=1; cr.frozenT=1; cr.corrT=1;
       netEntFlagsApply(o,netEntFlags(cr));
       if(o.burnT>0||o.chillT>0||!(o.stunT>0)||!(o.frozenT>0)||!(o.corrT>0)) bad.push('stunned, frozen and corroded did not round trip');
       netEntFlagsApply(o,0);
       if(o.burnT||o.stunT||o.chillT||o.frozenT||o.corrT) bad.push('a clear flag word left a status on');
       cr.stunT=0; cr.frozenT=0; cr.corrT=0; cr.stunImm=0; cr.hp=cr.maxhp=2000;
       sfx=function(t){ heard.push(String(t)); };
       cr.elSndT=undefined; elemHit(cr,'fire',20,0,p.x,p.y);
       if(heard.indexOf('elFire')<0) bad.push('a fire hit played no fire sound ('+heard.join(',')+')');
       heard.length=0; cr.chill=0; cr.freezeImm=0; cr.frozenT=0;
       for(k=0;k<5;k++){ cr.elSndT=undefined; elemHit(cr,'cryo',30,0,p.x,p.y); }
       if(heard.indexOf('elFreeze')<0) bad.push('a freeze played no crack');
       sfx=oSfx;
       S=[].slice.call(document.scripts).map(function(s){ return s.text||''; }).join('\n');
       ['Fire','Shock','Cryo','Freeze','Acid'].forEach(function(n){ if(S.indexOf("type==='el"+n+"'")<0) bad.push('the sound el'+n+' is not in the mixer'); });
       g.ents=[cr]; cr.burnT=0; cr.chillT=0; cr.stunT=0; cr.frozenT=0; cr.corrT=0; g.arcs=[];
       c0=__gfxCount([wc],null,function(){ return drawElemFx(0.016); });
       if(c0.total!==0) bad.push('the body effects drew '+c0.total+' calls on a body with no status');
       cr.burnT=1;
       c1=__gfxCount([wc],null,function(){ return drawElemFx(0.016); });
       if(!(c1.total>8)) bad.push('the body effects drew '+c1.total+' calls on a burning body');
       cr.burnT=0;
       p.wep=WEAPONS.rifle;
       c0=__gfxCount([wc],null,function(){ return forgeGlow(p.x,p.y,p.face,p.wep,false); });
       p.wep=forgeApply(WEAPONS.rifle,2,'fire');
       c1=__gfxCount([wc],null,function(){ return forgeGlow(p.x,p.y,p.face,p.wep,false); });
       if(c0.total!==0) bad.push('a plain gun glows');
       if(!(c1.total>0)||c1.ret!==true) bad.push('a MK III gun does not glow');
       // the state word, both ways
       A={id:991,pc:null,dc:{readyState:'open',send:function(s){ try{ box.push(JSON.parse(s)); }catch(_j){} }},fc:null,state:'in',seat:1,pid:'zqxseat1',name:'ZQX MATE',timers:[]};
       NET.specG=null; NET.on=true; NET.role='host'; NET.seat=0; NET.upSeed=g.seed>>>0; NET.peers=[A]; NET.up=[];
       try{ NET.roster=netRosterBuild(); }catch(_r){}
       if(typeof netEntsInit==='function') netEntsInit(g);
       NET.upAcc=1; box.length=0;
       netUpTick(0.2);
       w=box.filter(function(x){ return x&&x.t==='st'; })[0];
       if(!w) bad.push('no state word was sent');
       else if(w.fk!==2||w.el!=='fire') bad.push('the state word carries fk '+w.fk+' el '+w.el);
       if(netSeatName(1)===null) bad.push('SKIP: staging: seat 1 has no name');
       else {
         nm=netOnState(A,{t:'st',k:'r',sd:g.seed>>>0,x:p.x+40,y:p.y,f:0,m:0,r:0,c:0,sp:0,dn:0,w:'rifle',fk:2,el:'cryo'});
         if(!NET.up[1]||NET.up[1].fk!==2||NET.up[1].el!=='cryo') bad.push('the receiver did not keep his forged gun ('+nm+')');
         netOnState(A,{t:'st',k:'r',sd:g.seed>>>0,x:p.x+40,y:p.y,f:0,m:0,r:0,c:0,sp:0,dn:0,w:'rifle',fk:2,el:'bogus'});
         if(NET.up[1]&&NET.up[1].el) bad.push('the receiver kept a bogus element');
       }
     }catch(ex){ bad.push('threw: '+(ex&&ex.message||ex)); }
     finally{
       sfx=oSfx;
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
       try{ var g2=__state(); if(g2){ if(all) g2.ents=all; g2.arcs=[]; if(g2.player) g2.player.wep=oW; if(!g2.over){ g2.player.downed=false; g2.player.hp=100; __endRaid('abandon'); } } }catch(_e){}
       __topClear();
     }
     var sk=bad.filter(function(b){ return b.indexOf('SKIP')===0; });
     return bad.length?(sk.length===bad.length?sk[0]:bad.join('; ')):null; }},
  {v:'25.48',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
