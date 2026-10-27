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

if ($s.Contains("  {v:'35.15',what:")) { throw "check 35.15 is in the fixture already" }

SubRx @'
  {v:'35.14',what:
'@ @'
  {v:'35.15',what:'fog of war hides airborne grenades, lingering smoke, both death falls, every body element, both lightning ends, machine damage smoke and sparks, and the pulsing extract shaft; off preserves each draw',
   run:function(){
     var bad=[], p, far=null, i, a, rr, x, y, kind='', count=0, smokes=0, sparks=0, body=null;
     var keep={fog:CFG.fogWar,pix:CFG.xfPix,fx:CFG.fxInt,shared:CFG.sharedSight,particles:GFXQ.particles,bypass:GFX.bypass};
     var oElem=drawElemFx, methods=['arc','fill','stroke','fillRect','drawImage'], proto=CanvasRenderingContext2D.prototype;
     var kinds=['grenade','smoke','fall','pillager fall','fire','shock','ice','chill','acid','bolt','bolt to unseen','bolt from unseen','machine','pixel machine','extract'];
     function near(v,w){ return Math.abs(v-w)<0.01; }
     function record(m,args){
       var st;
       if(kind==='grenade') { if(m==='arc'&&near(args[0],far.x)&&near(args[1],far.y-32)&&args[2]===3) count++; return; }
       if(kind==='smoke') { if(m==='arc'&&args[2]===41.5&&Math.abs(args[0]-far.x)<50&&Math.abs(args[1]-far.y)<25) count++; return; }
       if(kind==='extract') { if(m==='fillRect'&&near(args[0],far.x-7)&&near(args[1],far.y-150)&&args[2]===14&&args[3]===150) count++; return; }
       st=new Error().stack||'';
       if(kind==='fall'||kind==='pillager fall') { if(m!=='arc'&&/\bdrawDeathAnims\b/.test(st)) count++; }
       else if(kind==='machine'||kind==='pixel machine') {
         if(/\bgfxDamageFx\b/.test(st)) {
           if(m!=='arc') count++;
           if((m==='fill'||m==='fillRect')&&(wc.fillStyle==='#1c1917'||wc.fillStyle==='#2a2623')) smokes++;
           if(m==='fillRect'&&wc.fillStyle==='#ffb040') sparks++;
         }
       } else if(m!=='arc'&&/\bdrawElemFx\b/.test(st)) count++;
     }
     function stage(k){
       kind=k; count=0; smokes=0; sparks=0; body=null;
       G.ents=[]; G.throws=[]; G.smokes=[]; G.deathAnims=[]; G.arcs=[]; G.sparks=[]; G.puffs=[]; G.bullets=[]; G.fxBullets=[];
       CFG.xfPix=(k==='pixel machine')?1:0; CFG.fxInt=1; GFXQ.particles=1; GFX.bypass=0;
       G._fwlT=-1; G.beaconT=null;
       if(k==='grenade') G.throws=[{x:far.x,y:far.y,t:0.5,dur:1,kind:'frag'}];
       else if(k==='smoke') G.smokes=[{x:far.x,y:far.y,r:83,t:2,life:12}];
       else if(k==='fall'||k==='pillager fall') {
         var d={x:far.x,y:far.y,r:14,face:0,c:'#555c64',t0:G.t-0.25,kind:'raider'};
         if(k==='pillager fall') { var dead=mkRaider(far.x,far.y); dead.hostile=true; if(!raiderFallSnap(d,dead)) throw new Error('could not stage the pillager fall'); }
         G.deathAnims=[d];
       } else if(k.indexOf('bolt')===0) {
         var from=(k==='bolt to unseen')?p:far, to=(k==='bolt from unseen')?p:{x:far.x+2,y:far.y};
         G.arcs=[{x1:from.x,y1:from.y,x2:to.x,y2:to.y,t:0.03,life:0.14}];
       } else if(k==='extract') { G.active.x=far.x; G.active.y=far.y; }
       else {
         body=mkSentry(far.x,far.y); body.seen=true; body.hp=body.maxhp=100; body.nid=17;
         body.burnT=body.stunT=body.frozenT=body.chillT=body.corrT=0;
         if(k==='machine'||k==='pixel machine') {
           body.hp=15;
           var ph=grit((body.nid|0)*7+3,11)*6.2832;
           G.t=(60.1-ph*3)/11; // deterministic spark phase, independent of the cosmetic random stream
         } else body[{fire:'burnT',shock:'stunT',ice:'frozenT',chill:'chillT',acid:'corrT'}[k]]=5;
         G.ents=[body];
       }
     }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       CFG.fogWar=1; CFG.sharedSight=0;
       __deploy({kit:['gun_carbine'],safe:null,mapIx:0,seed:4242});
       if(state!=='raid'||!G||!G.player) return 'no raid';
       G.mapFirst=false; G.mapOpen=false; G.bagOpen=false; G.paused=false; p=G.player;
       if(!G.vseg) G.vseg=G.map.segs;
       G.ents=[];
       for(a=0;a<17&&!far;a++) for(rr=Math.max(280,AMBR()+80);rr<=760&&!far;rr+=60){
         x=p.x+Math.cos(p.face+Math.PI+(a-8)*0.1)*rr; y=p.y+Math.sin(p.face+Math.PI+(a-8)*0.1)*rr;
         if(x>30&&y>30&&x<WORLD_W-30&&y<WORLD_H-30&&!canSee(p.x,p.y,p.face,x,y,G.vseg)&&!fowLive(x,y)&&!fowLive(x+2,y)) far={x:x,y:y};
       }
       if(!far) return 'staging: no spot behind him out of sight';
       // Exercise the independent fog gate even when the pre-existing body sight flag is cached true.
       drawElemFx=function(dt){ if(body) body.seen=true; return oElem(dt); };
       for(i=0;i<methods.length;i++) (function(m){ wc[m]=function(){ record(m,arguments); return proto[m].apply(this,arguments); }; })(methods[i]);
       for(i=0;i<kinds.length;i++) {
         CFG.fogWar=1; stage(kinds[i]); __frame(0);
         if(count) bad.push(kind+' drew out of sight ('+count+' calls)');
         if(kind==='grenade'&&G.throws.length!==1) bad.push('hidden grenade removed from simulation');
         if(kind==='smoke'&&(G.smokes.length!==1||G.smokes[0].t!==2)) bad.push('hidden smoke changed');
         if((kind==='fall'||kind==='pillager fall')&&G.deathAnims.length!==1) bad.push('hidden fall removed before expiry');
         if(kind.indexOf('bolt')===0&&(G.arcs.length!==1||G.arcs[0].t!==0.03)) bad.push('hidden bolt changed at dt zero');
         if(body&&(body.hp!==(kind.indexOf('machine')>=0?15:100))) bad.push('drawing changed body health');
         CFG.fogWar=0; stage(kinds[i]); __frame(0);
         if(!count) bad.push('control: '+kind+' did not draw with fog off');
         if(kind==='machine'||kind==='pixel machine') {
           if(!smokes) bad.push('control: '+kind+' did not draw damage smoke');
           if(!sparks) bad.push('control: '+kind+' did not draw damage sparks');
         }
       }
       // Hidden effects still expire normally rather than building up until he looks back.
       CFG.fogWar=1; stage('fall'); G.deathAnims[0].t0=G.t-2; drawDeathAnims();
       if(G.deathAnims.length) bad.push('hidden expired fall was retained');
       stage('bolt'); drawElemFx(0.1); drawElemFx(0.1);
       if(G.arcs.length) bad.push('hidden expired bolt was retained');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       drawElemFx=oElem;
       for(i=0;i<methods.length;i++) try{ delete wc[methods[i]]; }catch(_w){}
       CFG.fogWar=keep.fog; CFG.xfPix=keep.pix; CFG.fxInt=keep.fx; CFG.sharedSight=keep.shared;
       GFXQ.particles=keep.particles; GFX.bypass=keep.bypass;
       try{ if(G){ G.ents=[]; G.throws=[]; G.smokes=[]; G.deathAnims=[]; G.arcs=[]; } }catch(_b){}
       try{ var sm=document.getElementById('sectormodal'); if(sm) sm.classList.remove('on'); }catch(_s){}
       try{ if(pauseOpen) togglePauseBox(false); }catch(_p){}
       try{ var K=__keys(); for(var q in K) delete K[q]; }catch(_k){}
       try{ if(state==='raid'&&G&&!G.over) __endRaid('abandon'); }catch(_e){}
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'35.14',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
