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

if ($s.Contains("  {v:'35.26',what:")) { throw "check 35.26 is in the fixture already" }

SubRx @'
  {v:'35.25',what:
'@ @'
  {v:'35.26',what:'cw-ammoneed, his order 2026-10-27 (player should have higher chance of finding ammo boxes if player has no ammo): over four seeds a pillager with no ammo finds an ammo box in far more of the boxes he opens than a stocked one, nothing is taken out, a stocked one finds what the box always held, and in co-op the host decides it for player 2 from the word his window sends',
   run:function(){
     if(!(window.__state&&window.__startRaid&&window.__endRaid&&window.__resetCfg&&window.__pinDefaults&&window.__topClear)) return 'SKIP: no raid here';
     if(typeof updatePlayer!=='function'||typeof LOOT!=='object'||typeof bestRarity!=='function') return 'SKIP: no search path here';
     var bad=[], seeds=[4242,4243,4244,4245], si, g=null, p=null, i, c, keep=null, r, D, q, mm, oSay=say, NK={}, k, staged=false,
         oS=netSend, oSF=netSendFast, oB=netBroadcast, sent=[], h={seat:0,state:'in'}, hp={seat:1,state:'in'},
         st={n:0,a:0}, dr={n:0,a:0}, hs={n:0,a:0}, hd={n:0,a:0}, moved=0, taken=0, missed=0, m1=null, m0=null, a0, a1, b0, b1;
     function ammoIn(l){ for(var j=0;l&&j<l.length;j++){ var it=ITEMS[l[j]]; if(it&&it.use==='ammo') return true; } return false; }
     function can(ct){ var t=ct&&LOOT[ct.type], j; if(!ct||ct.opened||ct.mercSrc||ct.dropped||!ct.loot||!ct.loot.length||!(ct.time>0)||!t) return false; for(j=0;j<t.length;j++) if(t[j][0]==='ammobox') return true; return false; }
     function reset(ct){ ct.loot=keep.slice(); ct.best=bestRarity(ct.loot); ct.prog=0; ct.pulled=0; delete ct.ammoNeed; ct.netBy=-1; delete ct.netAskT; }
     function arm(dry){ p.reserve=dry?0:300; p.ammo=dry?0:((p.wep&&p.wep.mag)||30); g.bag=[]; }
     function same(a,b){ return a.slice().sort().join(',')===b.slice().sort().join(','); }
     function holds(a,b){ var n={}, j; for(j=0;j<a.length;j++) n[a[j]]=(n[a[j]]||0)+1; for(j=0;j<b.length;j++){ if(!n[b[j]]) return false; n[b[j]]--; } return true; }
     function solo(ct,dry){
       var off=[[18,0],[-18,0],[0,18],[0,-18]], j, ok=false;
       for(j=0;j<off.length&&!ok;j++){
         reset(ct); arm(dry); g.searching=null; g.searchT=0; p.x=ct.x+off[j][0]; p.y=ct.y+off[j][1];
         keys={}; keys['KeyE']=true; updatePlayer(0.016); keys={};
         ok=(g.searching===ct&&(ct.pulled|0)===0);
         g.searching=null; g.searchT=0;
       }
       return ok;
     }
     try{
       say=function(){};
       for(si=0;si<seeds.length;si++){
         __resetCfg(); __pinDefaults(0); __startRaid({mapIx:0,seed:seeds[si]});
         g=__state(); if(!g||g.over||!g.player){ bad.push('control: seed '+seeds[si]+' built no live raid'); continue; }
         p=g.player; g.ents.length=0; p.iv=99; p.downed=false;
         for(i=0;i<g.containers.length;i++){
           c=g.containers[i]; if(!can(c)) continue;
           keep=c.loot.slice();
           if(!solo(c,false)){ missed++; reset(c); continue; }
           st.n++; if(ammoIn(c.loot)) st.a++; if(!same(c.loot,keep)) moved++;
           if(!solo(c,true)){ missed++; reset(c); continue; }
           dr.n++; if(ammoIn(c.loot)) dr.a++; if(!holds(c.loot,keep)) taken++;
           reset(c);
         }
       }
       // CO-OP, on the last raid: the host rolls it for player 2 from the dry word, and the window of player 2 sends that word.
       g=__state();
       if(g&&!g.over&&g.player&&typeof netSrchTake==='function'&&typeof netContInit==='function'&&typeof netSrchHold==='function'&&typeof netSrchEnd==='function'){
         p=g.player;
         for(k in NET) NK[k]=NET[k]; staged=true;
         NET.on=true; NET.max=4; NET.specG=null; NET.entMap={}; NET.upSeed=g.seed>>>0;
         NET.role='host'; NET.seat=0; NET.peers=[hp]; NET.roster=[{seat:0,name:'ONE'},{seat:1,name:'TWO'}]; NET.up=[];
         netSendFast=function(x,m){ sent.push(JSON.parse(JSON.stringify(m))); return true; };
         netSend=function(x,m){ sent.push(JSON.parse(JSON.stringify(m))); return true; };
         netBroadcast=function(m){ sent.push(JSON.parse(JSON.stringify(m))); return 1; };
         netContInit(g);
         arm(false);   // the host himself is stocked, so only the word of player 2 can count
         for(i=0;i<g.containers.length;i++){
           c=g.containers[i]; if(!can(c)||typeof c.cid!=='number') continue;
           keep=c.loot.slice();
           for(D=0;D<2;D++){
             reset(c); r=netSrchTake(hp,{t:'srch',op:'start',cid:c.cid,slow:1,dry:D});
             if(r==='srch:ok'){ mm=D?hd:hs; mm.n++; if(ammoIn(c.loot)) mm.a++; }
             netSrchEnd(1);
           }
           reset(c);
         }
         NET.role='join'; NET.seat=1; NET.peers=[h]; NET.srch=null;
         c=null; for(i=0;i<g.containers.length&&!c;i++) if(can(g.containers[i])) c=g.containers[i];
         if(c){
           keep=c.loot.slice();
           for(D=0;D<2;D++){
             reset(c); arm(!!D); NET.srch=null; g.searching=null; sent.length=0;
             netSrchHold(c,0.016);
             mm=null; for(q=0;q<sent.length;q++) if(sent[q]&&sent[q].t==='srch'&&sent[q].op==='start') mm=sent[q];
             if(D) m1=mm; else m0=mm;
           }
           reset(c); NET.srch=null; g.searching=null;
         }
       }
       if(dr.n<150||st.n<150) bad.push('control: only '+dr.n+' boxes searched with no ammo and '+st.n+' stocked ('+missed+' missed), too few to measure');
       else {
         a0=st.a/st.n; a1=dr.a/dr.n;
         if(!(a1>=a0+0.25&&a1>=0.55)) bad.push('a pillager with no ammo found an ammo box in '+Math.round(a1*100)+' percent of '+dr.n+' boxes, a stocked one in '+Math.round(a0*100)+' percent of '+st.n+': no ammo does not raise the chance');
       }
       if(moved) bad.push('a stocked pillager found something other than what the box held in '+moved+' boxes');
       if(taken) bad.push('a pillager with no ammo lost loot out of '+taken+' boxes');
       if(!staged) bad.push('control: the co-op search path is not here');
       else if(hs.n<50||hd.n<50) bad.push('control: the host searched only '+hs.n+' and '+hd.n+' boxes for player 2');
       else {
         b0=hs.a/hs.n; b1=hd.a/hd.n;
         if(!(b1>=b0+0.25)) bad.push('in co-op player 2 with no ammo found an ammo box in '+Math.round(b1*100)+' percent of boxes, stocked '+Math.round(b0*100)+' percent: the host does not decide it for him');
       }
       if(staged){
         if(!m1||m1.dry!==1) bad.push('the window of player 2 with no ammo does not tell the host (start word '+JSON.stringify(m1)+')');
         if(m0&&m0.dry) bad.push('the window of player 2 with ammo still says dry');
       }
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       say=oSay; keys={}; netSend=oS; netSendFast=oSF; netBroadcast=oB;
       if(staged){ for(k in NET) if(!(k in NK)) delete NET[k]; for(k in NK) NET[k]=NK[k]; }
       try{ var g2=__state(); if(g2&&!g2.over){ g2.searching=null; g2.player.downed=false; g2.player.hp=100; __endRaid('abandon'); } }catch(_e){}
       __topClear(); try{ __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'35.25',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
