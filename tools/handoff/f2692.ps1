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

if ($s.Contains("  {v:'26.92',what:")) { throw "check 26.92 is in the fixture already" }

SubRx @'
  {v:'26.91',what:
'@ @'
  {v:'26.92',what:'flow12, his answer that the golden enemy appears every raid: every raid gilds one machine or hostile pillager at least 700 from the drop (the same one for the same seed), it has three times the health, is drawn gold, and leaves a golden hoard of five when it dies, once',
   run:function(){
     if(!(window.__state&&window.__endRaid&&window.__runPrep&&window.__frame)) return 'SKIP: no raid or frame here';
     if(typeof arcadeDeploy!=='function'||typeof ARCADE!=='object') return 'SKIP: no arcade here';
     var bad=[], g=null, p, rs=say, own=false, lines=[], S, e, i, j, sd, ix1, ix2, n, c, cap=[], proto, oArc, s, hit, nH, saw, tagH='GOLDEN '+'HOARD', needD='GOLDEN ENEMY '+'DOWN', gl, hp0, seeds=[4242,4243,4244], miss=[];
     function raid(sdv){
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_a){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_b){}
       __topClear(); __runPrep();
       if(!arcadeDeploy({mapIx:0,seed:sdv})) return null;
       g=__state(); if(!g||g.over||!g.player) return null;
       p=g.player; keys={}; ARCADE.mine=0; ARCADE.holdT=0; g.t=5;
       return g;
     }
     try{
       __topClear(); __runPrep();
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(typeof goldTick!=='function'||typeof flowTick!=='function') return 'there is no golden enemy in this build';
       say=function(m,kd,o){ lines.push(String(m)+'|'+((o&&o.sub)||'')); }; own=true;
       // ONE: every one of three raids gilds one body, at least 700 from the drop, with three times the health
       for(j=0;j<seeds.length;j++){
         if(!raid(seeds[j])) return 'SKIP: arcadeDeploy built no arcade raid';
         flowTick(0.1); S=g.flow.gold;
         if(!S||!S.ref){ miss.push(seeds[j]); continue; }
         e=S.ref; n=0; for(i=0;i<g.ents.length;i++) if(g.ents[i]&&g.ents[i].golden) n++;
         if(n!==1) bad.push('ONE: seed '+seeds[j]+' has '+n+' golden bodies');
         if(Math.hypot(e.x-p.x,e.y-p.y)<699) bad.push('ONE: seed '+seeds[j]+' gilds a body '+Math.round(Math.hypot(e.x-p.x,e.y-p.y))+' from the drop');
         if(e.maxhp!==Math.round(S.hp0*3)||e.hp!==e.maxhp) bad.push('ONE: seed '+seeds[j]+' golden health is '+e.hp+'/'+e.maxhp+' from '+S.hp0);
         if(e.boss||e.merc) bad.push('ONE: the golden body is the Overseer or a hire');
         if(j===0){ ix1=g.ents.indexOf(e); sd=seeds[0]; }
       }
       if(miss.length) bad.push('ONE: no golden body in the raids of seeds '+miss.join(','));
       // TWO: the same seed gilds the same body again
       if(!raid(seeds[0])) return 'SKIP: no second raid';
       flowTick(0.1); S=g.flow.gold; ix2=S&&S.ref?g.ents.indexOf(S.ref):-2;
       if(ix1!==ix2) bad.push('TWO: the same seed gilded body '+ix2+' after body '+ix1);
       if(goldPickIx()!==ix2) bad.push('TWO: the pick is not stable once the body is gilded');
       e=S.ref; hp0=e.maxhp;
       // THREE: drawn gold on the HUD
       p.x=e.x-90; p.y=e.y; render2D(0); cap.length=0; proto=CanvasRenderingContext2D.prototype; oArc=proto.arc;
       proto.arc=function(){ cap.push([].slice.call(arguments)); return oArc.apply(this,arguments); };
       try{ flowDraw(ctx,p); } finally { proto.arc=oArc; }
       s=w2s(e.x,0,e.y); hit=0; for(i=0;i<cap.length;i++) if(cap[i].length>=5&&Math.abs(cap[i][0]-s.x)<2&&Math.abs(cap[i][1]-s.y)<2&&cap[i][2]>=e.r*ZOOM()*2.5) hit++;
       if(!hit) bad.push('THREE: no golden glow was drawn on the golden body ('+cap.length+' arcs)');
       // FOUR: it dies, by anyone: one hoard of five where it fell, a callout, a mark; and only once
       lines.length=0; nH=0; for(i=0;i<g.containers.length;i++) if(g.containers[i]&&g.containers[i].tag===tagH) nH++;
       e.hp=0; flowTick(0.1);
       c=null; for(i=0;i<g.containers.length;i++) if(g.containers[i]&&g.containers[i].tag===tagH) c=g.containers[i];
       if(!c) bad.push('FOUR: no GOLDEN HOARD when it died');
       else {
         if(c.loot.length<5) bad.push('FOUR: the hoard holds '+c.loot.length);
         if(Math.hypot(c.x-e.x,c.y-e.y)>40) bad.push('FOUR: the hoard is '+Math.round(Math.hypot(c.x-e.x,c.y-e.y))+' from where it fell');
       }
       saw=0; for(i=0;i<lines.length;i++) if(lines[i].indexOf(needD)>=0) saw=1;
       if(!saw) bad.push('FOUR: no GOLDEN ENEMY DOWN callout');
       i=flowMarks(); n=0; for(j=0;j<i.length;j++) if(i[j].kind==='loot'&&String(i[j].txt)===tagH) n++;
       if(n!==1) bad.push('FOUR: '+n+' hoard marks');
       flowTick(0.1); flowTick(0.1);
       n=0; for(i=0;i<g.containers.length;i++) if(g.containers[i]&&g.containers[i].tag===tagH) n++;
       if(n!==1) bad.push('FOUR: '+n+' hoards after two more ticks');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       if(own) say=rs;
       keys={};
       try{ if(proto&&oArc) proto.arc=oArc; }catch(_p){}
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ if(typeof ARCADE==='object'){ ARCADE.mine=0; ARCADE.waveT=0; ARCADE.holdT=0; } }catch(_h){}
       __topClear();
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'26.91',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
