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

if ($s.Contains("  {v:'23.74',what:")) { throw "check 23.74 is in the fixture already" }

SubRx @'
  {v:'23.73',what:
'@ @'
  {v:'23.74',what:'gfx2, his order 2026-10-12 (the graphics program): the hook scaffold, eight render hooks each called once a frame, GFX.bypass leaving the frame pixel for pixel, the CLASSIC light wrap, sim-side stubs (gfxShot, wallMark, boomFx, gfxOnDeath with the kind kept, scarStamp, gfxEmit) live in a raid and off in a bot raid, and the store registry emptied by a context restore',
   run:function(){
     var bad=[], g=null, i, k, d, n0, hk=['cam','ground','shadow','body','light','prefog','postfog','screen'], byp0=0, sim0=false, simSet=false;
     var A, B, C, s1, s2, dropped=0, dr0, last, da0, nd, src, live, off, nm, sk=['shot','wall','boom','scar','emit'];
     if(typeof GFX==='undefined'||typeof GFXSTORES==='undefined'||typeof gfxStore!=='function') return 'hooks missing: no GFX scaffold or store registry';
     var hash=function(){ var w=cv.width, h=cv.height, dd=wc.getImageData(0,0,w,h).data, j, s=0; for(j=0;j<dd.length;j+=4*37){ s=(s*31+dd[j]+dd[j+1]*7+dd[j+2]*13)|0; } return s+':'+w+'x'+h; };
     try{
       if(!(window.__gfxStage&&window.__frame&&window.__state&&window.__endRaid)) return 'SKIP: this fixture has no gfx stage';
       byp0=GFX.bypass; GFX.bypass=0;
       g=__gfxStage({frames:3});
       if(!g) return 'SKIP: __gfxStage built no raid';
       if(g.sim) return 'SKIP: the staged raid is a sim raid';
       G.shake=0;
       // 1. each render hook once a frame
       n0={}; for(k in GFX.n) n0[k]=GFX.n[k];
       __frame(0);
       for(i=0;i<hk.length;i++){ d=(GFX.n[hk[i]]||0)-(n0[hk[i]]||0); if(d!==1) bad.push('render hook '+hk[i]+' ran '+d+' times in one frame'); }
       // 2. the bypass leaves the world frame pixel for pixel (only judged when two plain frames agree)
       __frame(0); A=hash(); GFX.bypass=1; __frame(0); B=hash(); GFX.bypass=0; __frame(0); C=hash();
       if(A===C&&A!==B) bad.push('the frame drawn with GFX.bypass differs from the one without');
       // 3. the sim-side hooks are wired where the design puts them
       nm='gfx'+'Shot('; if(String(fireWeapon).indexOf(nm)<0) bad.push('fireWeapon calls no gfxShot');
       nm='wall'+'Mark('; if(String(updateBullets).indexOf(nm)<0) bad.push('updateBullets calls no wallMark');
       nm='boom'+'Fx('; if(String(explodeFrag).indexOf(nm)<0) bad.push('explodeFrag calls no boomFx');
       if(String(howlerImpact).indexOf(nm)<0) bad.push('howlerImpact calls no boomFx');
       // updateThrowables is wrapped by the fixture timer, so its own text is read from the page source
       src=[].slice.call(document.scripts).map(function(s){ return s.text||''; }).join('\n');
       i=src.indexOf('function update'+'Throwables(');
       if(i<0) bad.push('no updateThrowables in the page source');
       else { src=src.slice(i); k=src.indexOf('\nfunction ',10); if(k>0) src=src.slice(0,k); if(src.split(nm).length-1<2) bad.push('the linked-window frag and shell copies call no boomFx'); }
       src=null;
       nm='gfx'+'OnDeath('; if(String(deathAnimAdd).indexOf(nm)<0) bad.push('deathAnimAdd calls no gfxOnDeath');
       nm='gfx'+'StoresDrop('; if(String(onCtxRestored).indexOf(nm)<0) bad.push('onCtxRestored does not empty the store registry');
       // 4. live in a raid, off in a bot raid
       n0={}; for(k in GFX.n) n0[k]=GFX.n[k];
       live=[gfxShot(G.player,{id:'zqx'},0,true), wallMark(null,G.player.x,G.player.y,1,0), boomFx(G.player.x,G.player.y,1,'frag'), scarStamp('scorch',G.player.x,G.player.y,{}), gfxEmit(G.player.x,G.player.y,20,'#ffffff',1)];
       for(i=0;i<sk.length;i++){ if(live[i]!==true) bad.push('the '+sk[i]+' hook did not take a live event'); d=(GFX.n[sk[i]]||0)-(n0[sk[i]]||0); if(d!==1) bad.push('the '+sk[i]+' hook counted '+d+' calls for one'); }
       if(typeof gfxWet()!=='number') bad.push('gfxWet gives no number');
       sim0=G.sim; G.sim=true; simSet=true;
       off=[gfxShot(G.player,{id:'zqx'},0,true), wallMark(null,G.player.x,G.player.y,1,0), boomFx(G.player.x,G.player.y,1,'frag'), scarStamp('scorch',G.player.x,G.player.y,{}), gfxEmit(G.player.x,G.player.y,20,'#ffffff',1)];
       G.sim=sim0; simSet=false;
       for(i=0;i<sk.length;i++) if(off[i]!==false) bad.push('the '+sk[i]+' hook acts in a bot raid');
       // 5. a death keeps its kind and calls the death hook
       da0=GFX.n.death||0;
       nd=deathAnimAdd({x:G.player.x+40,y:G.player.y,r:14,face:0,kind:'crawler'});
       last=(G.deathAnims&&nd)?G.deathAnims[G.deathAnims.length-1]:null;
       if(!last||last.kind!=='crawler') bad.push('the death record does not keep the kind');
       if((GFX.n.death||0)-da0!==1) bad.push('deathAnimAdd ran the death hook '+((GFX.n.death||0)-da0)+' times');
       if(last&&G.deathAnims[G.deathAnims.length-1]===last) G.deathAnims.pop();
       // 6. the registry
       s1=gfxStore('zqxA'); s1.m.k=1; s1.n=1;
       s2=gfxStore('zqxB',function(){ dropped++; });
       if(gfxStore('zqxA')!==s1) bad.push('gfxStore gives a new store for the same name');
       dr0=GFX.drops;
       onCtxRestored();
       if(s1.m.k!==undefined||s1.n!==0) bad.push('a context restore left a registered store full');
       if(dropped!==1) bad.push('a store drop function ran '+dropped+' times on one restore');
       if(GFX.drops!==dr0+1) bad.push('the registry drop count moved by '+(GFX.drops-dr0));
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ delete GFXSTORES.zqxA; delete GFXSTORES.zqxB; }catch(_dz){}
       try{ if(simSet) G.sim=sim0; }catch(_ss){}
       GFX.bypass=byp0; keys={};
       try{ var g2=__state(); if(g2&&!g2.over&&!g2.sim) __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'23.73',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
