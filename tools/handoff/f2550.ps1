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

if ($s.Contains("  {v:'25.50',what:")) { throw "check 25.50 is in the fixture already" }

SubRx @'
  {v:'25.49',what:
'@ @'
  {v:'25.50',what:'forge11: a MK III acid rifle dropped from the backpack makes a pile that remembers it and comes back out as a MK III acid rifle, a plain gun still comes back at field grade, and on a linked window the pile word carries the MK and the element to the host',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof dropItem!=='function'||typeof grantLoot!=='function'||typeof forgeApply!=='function'||typeof gunQPush!=='function') return 'SKIP: no raid or forge model here';
     var NK={}, k, bad=[], g, p, oW, oS, oA, oSA, ct, i, got, n0, oSend=netSend, cap=[], m, pa={state:'in',seat:1}, r, c2;
     for(k in NET) NK[k]=NET[k];
     function findGun(id){
       var L=[p.wep,p.sec,(typeof gunQPeek==='function')?gunQPeek(id):null], j;
       if(G.stowQ&&G.stowQ[id]) L=L.concat(G.stowQ[id]);
       for(j=0;j<L.length;j++) if(L[j]&&L[j].id===id) return L[j];
       return null;
     }
     function clearGun(id){ var j; for(j=G.bag.length-1;j>=0;j--) if(G.bag[j]==='gun_'+id) G.bag.splice(j,1); if(G.stowQ) G.stowQ[id]=[]; }
     try{
       NET.on=false; NET.role=null; NET.peers=[];
       __topClear(); __runPrep(); __resetCfg(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g.player; if(!g||g.over) return 'SKIP: no live raid';
       oW=p.wep; oS=p.sec; oA=p.ammo; oSA=p.secAmmo;
       if((p.wep&&p.wep.id==='rifle')||(p.sec&&p.sec.id==='rifle')) return 'SKIP: staging: a rifle is already in hand';
       clearGun('rifle');
       G.bag.push('gun_rifle'); gunQPush(forgeApply(WEAPONS.rifle,2,'acid'));
       n0=G.containers.length;
       dropItem(G.bag.lastIndexOf('gun_rifle'));
       ct=G.containers[G.containers.length-1];
       if(G.containers.length!==n0+1||!ct||!ct.dropped) bad.push('the drop made no pile');
       else {
         if(!ct.fw||ct.fw.fk!==2||ct.fw.el!=='acid') bad.push('the pile does not remember the MK III acid rifle ('+JSON.stringify(ct.fw||null)+')');
         clearGun('rifle');
         grantLoot(ct,['gun_rifle']);
         got=findGun('rifle');
         if(!got) bad.push('the rifle did not come back out of the pile');
         else if(got.fk!==2||got.el!=='acid'||got.name!=='Auto Rifle MK III') bad.push('the rifle came back as '+got.name+' fk '+got.fk+' el '+got.el);
       }
       p.wep=oW; p.sec=oS; p.ammo=oA; p.secAmmo=oSA; clearGun('rifle');
       G.bag.push('gun_rifle'); gunQPush(rollFieldGun('rifle'));
       dropItem(G.bag.lastIndexOf('gun_rifle'));
       ct=G.containers[G.containers.length-1];
       if(ct&&ct.fw) bad.push('a plain dropped gun made a forged pile');
       clearGun('rifle'); grantLoot(ct,['gun_rifle']);
       got=findGun('rifle');
       if(!got) bad.push('the plain rifle did not come back');
       else if(got.fk||got.q!=='field') bad.push('a plain dropped rifle came back as '+got.q+' fk '+got.fk+', not field grade');
       p.wep=oW; p.sec=oS; p.ammo=oA; p.secAmmo=oSA; clearGun('rifle');
       // the linked window: the pile word
       NET.specG=null; NET.on=true; NET.role='join'; NET.seat=1; NET.upSeed=g.seed>>>0; NET.peers=[{state:'in',seat:0}]; NET.up=[];
       netSend=function(q,w){ cap.push(w); return true; };
       G.bag.push('gun_rifle'); gunQPush(forgeApply(WEAPONS.rifle,2,'acid'));
       dropItem(G.bag.lastIndexOf('gun_rifle'));
       m=cap.filter(function(w){ return w&&w.t==='pile'; })[0];
       if(!m) bad.push('the linked window sent no pile word');
       else if(m.fk!==2||m.el!=='acid') bad.push('the pile word carries fk '+m.fk+' el '+m.el);
       netSend=oSend; clearGun('rifle');
       // the host builds the pile from the word
       NET.on=true; NET.role='host'; NET.seat=0; NET.peers=[pa]; NET.up=[];
       if(!netEntsHost()) bad.push('SKIP: staging: not the host');
       else {
         n0=G.containers.length;
         r=netPileTake(pa,{t:'pile',k:'gun_rifle',x:p.x,y:p.y,fk:2,el:'acid'});
         c2=G.containers[G.containers.length-1];
         if(r!=='pile'||G.containers.length!==n0+1) bad.push('the host made no pile from the word ('+r+')');
         else if(!c2.fw||c2.fw.fk!==2||c2.fw.el!=='acid') bad.push('the host pile lost the forge');
         r=netPileTake(pa,{t:'pile',k:'gun_rifle',x:p.x,y:p.y,fk:7,el:'bogus'});
         c2=G.containers[G.containers.length-1];
         if(c2&&c2.fw) bad.push('a bogus forge in the pile word was kept');
       }
     }catch(ex){ bad.push('threw: '+(ex&&ex.message||ex)); }
     finally{
       netSend=oSend;
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
       try{ var g2=__state(); if(g2&&g2.player){ g2.player.wep=oW; g2.player.sec=oS; g2.player.ammo=oA; g2.player.secAmmo=oSA; if(!g2.over){ g2.player.downed=false; g2.player.hp=100; __endRaid('abandon'); } } }catch(_e){}
       __topClear();
     }
     var sk=bad.filter(function(b){ return b.indexOf('SKIP')===0; });
     return bad.length?(sk.length===bad.length?sk[0]:bad.join('; ')):null; }},
  {v:'25.49',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
