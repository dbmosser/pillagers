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

if ($s.Contains("  {v:'26.59',what:")) { throw "check 26.59 is in the fixture already" }

SubRx @'
  {v:'26.58',what:
'@ @'
  {v:'26.59',what:'his yes (suggestion 21): a pillager has a role from his gun and rig (rush, flank, supp, mark, shield), wears a coat tinted by it with one silhouette mark of its own, a rusher closes in nearer than a marksman holds, and crews mix roles',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__sim)||typeof render2D!=='function'||typeof mkRaider!=='function'||typeof WEAPONS==='undefined') return 'SKIP: no raid here';
     var bad=[], g=null, p=null, all=null, e=null, i, k, a, sx, sy, role, roles=['rush','flank','supp','mark','shield'], WI, wid, seen, got, OWN=Object.prototype.hasOwnProperty, hF, oF, hR, oR, nCol, col, dR=null, dM=null, oD, hasD, coats={}, hist={};
     try{
       if(typeof raiderRole!=='function') return 'a pillager has no role';
       WI={lmg:'supp',dmr:'mark',sniper:'mark',whisper:'mark',lance:'mark',magnum:'mark',shotgun:'rush',carbine:'flank'};
       for(wid in WI){ if(OWN.call(WI,wid)){ got=raiderRole({kind:'raider',ident:'beef',wep:WEAPONS[wid]||{id:wid},rig:'none'}); if(got!==WI[wid]) bad.push('a '+wid+' pillager is "'+got+'", not "'+WI[wid]+'"'); } }
       if(raiderRole({kind:'raider',ident:'beef',wep:WEAPONS.smg,rig:'heavy'})!=='shield') bad.push('a pillager in a heavy rig is not a shield carrier');
       if(raiderRole({kind:'raider',ident:'beef',wep:WEAPONS.smg,rig:'none',merc:true})!==null) bad.push('a hired man has a role');
       for(i=0;i<IDENTITIES.length;i++){ got=raiderRole({kind:'raider',ident:IDENTITIES[i].id,wep:WEAPONS.smg,rig:'light'}); hist[got]=(hist[got]||0)+1; }
       if(!(hist.rush>=IDENTITIES.length/8&&hist.flank>=IDENTITIES.length/8&&hist.supp>=IDENTITIES.length/8)) bad.push('the SMG pillagers of every identity do not mix rush, flank and supp ('+JSON.stringify(hist)+')');
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over) return bad.length?bad.join('; '):'SKIP: no live raid';
       p=g.player; p.iv=99; p.hp=100000; p.downed=false; all=g.ents.slice();
       for(k=0;k<24;k++){ a=k/24*6.2832; if(losClear(p.x,p.y,p.x+Math.cos(a)*90,p.y+Math.sin(a)*90,G.vseg)) break; }
       if(k>=24) return bad.length?bad.join('; '):'SKIP: no open ground beside the player';
       sx=p.x+Math.cos(a)*90; sy=p.y+Math.sin(a)*90; p.face=Math.atan2(sy-p.y,sx-p.x);
       hasD=OWN.call(window,'drawOp'); oD=drawOp;
       for(i=0;i<roles.length;i++){
         role=roles[i]; col=PROLE[role].c.toLowerCase();
         e=mkRaider(sx,sy,undefined,true); e.elite=0; e.prole=role; e.hostile=true; e.state='loot'; e.downed=0; e.hp=e.maxhp; e.face=Math.atan2(p.y-sy,p.x-sx);
         g.ents=[e]; nCol=0; seen=null;
         hF=OWN.call(wc,'fill'); oF=wc.fill; hR=OWN.call(wc,'fillRect'); oR=wc.fillRect;
         wc.fill=function(){ if(String(this.fillStyle).toLowerCase()===col) nCol++; return oF.apply(this,arguments); };
         wc.fillRect=function(){ if(String(this.fillStyle).toLowerCase()===col) nCol++; return oR.apply(this,arguments); };
         drawOp=function(){ var s=arguments[9]; if(s&&s.own===e&&seen===null) seen=arguments[4]; return oD.apply(this,arguments); };
         try{ render2D(0.016); } finally { if(hF) wc.fill=oF; else delete wc.fill; if(hR) wc.fillRect=oR; else delete wc.fillRect; drawOp=oD; }
         if(nCol<1) bad.push('a '+role+' pillager in view draws no mark in his role colour '+col);
         if(typeof seen!=='string') bad.push('a '+role+' pillager was not drawn');
         else { if(seen===e.coat) bad.push('a '+role+' pillager wears his plain identity coat'); coats[role]=seen; }
       }
       if(coats.rush&&coats.mark&&coats.rush===coats.mark) bad.push('a rusher and a marksman of one identity wear the same coat');
       g.ents=all.slice(); all=g.ents.slice();
       function stand(r){
         var q=mkRaider(sx,sy,undefined,true), d0, j;
         q.elite=0; q.prole=r; q.hostile=true; q.wep=WEAPONS.smg; q.dmg=WEAPONS.smg.dmg; q.rng=WEAPONS.smg.rng*.72; q.hp=q.maxhp; q.bag=[];
         q.x=p.x+Math.cos(a)*180; q.y=p.y+Math.sin(a)*180; q.face=Math.atan2(p.y-q.y,p.x-q.x); q.state='chase'; q.alert=3; q.tx=p.x; q.ty=p.y; q.cd=0; q.windup=null; q.flank=1;
         g.ents=[q]; for(j in keys) keys[j]=false;
         d0=dist(q,p);
         for(j=0;j<150;j++){ q.alert=3; p.hp=100000; __sim(1/60); }
         g.ents=[];
         return dist(q,p);
       }
       dR=stand('rush'); dM=stand('mark');
       if(!(dM-dR>=40)) bad.push('after 2.5 seconds a rusher stands '+Math.round(dR)+' from the player and a marksman '+Math.round(dM)+': the rusher should be at least 40 nearer');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       try{ if(typeof oD==='function') drawOp=oD; }catch(_e1){}
       try{ if(g&&all) g.ents=all; var g2=__state(); if(g2&&!g2.over){ g2.player.iv=0; g2.player.hp=100; g2.player.downed=false; __endRaid('abandon'); } }catch(_e3){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'26.58',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
