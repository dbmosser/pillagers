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

if ($s.Contains("  {v:'24.68',what:")) { throw "check 24.68 is in the fixture already" }

SubRx @'
  {v:'24.67',what:
'@ @'
  {v:'24.68',what:'feat4b, his order 2026-10-12 (32 more interiors): a DEMO raid seals two strongrooms into vaults with caches, on a side stream, the same every build',
   run:function(){
     var bad=[], g, V, r1, r2, fp1, fp2, real=null, own=false, drift=[], i, j, n, c, L, gun,
         vaults=function(gg){ return ((gg.map&&gg.map.locked)||[]).filter(function(R){ return R.arc; }); },
         rects=function(vs){ return JSON.stringify(vs.map(function(R){ return [R.id,R.name,Math.round(R.x),Math.round(R.y),Math.round(R.w),Math.round(R.h),Math.round(R.doorX),Math.round(R.doorY)]; })); },
         leave=function(){ keys={}; try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){} try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){} __topClear(); };
     try{
       __topClear(); __runPrep();
       if(typeof arcadeDeploy!=='function'||typeof ARCADE!=='object') return 'no arcadeDeploy in this build';
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(typeof arcadeVaults!=='function') return 'no arcadeVaults in this build';
       real=arcadeVaults; own=true;
       arcadeVaults=function(gg){ var r0=RNGS, out=real(gg); if(RNGS!==r0) drift.push(r0+' to '+RNGS); return out; };
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); V=vaults(g);
       if(V.length!==2) bad.push('the DEMO raid at seed 4242 has '+V.length+' vaults, not 2');
       r1=rects(V); fp1=(netUpFp(g)||{}).h;
       for(i=0;i<V.length;i++){
         L=V[i];
         if(L.open) bad.push(L.name+' starts open');
         if(!g.map.walls.some(function(w){ return w.door===L.id&&w.arc; })) bad.push(L.name+' has no door wall');
         if(!shutRoomAt(g.map,L.x+L.w/2,L.y+L.h/2)) bad.push('shutRoomAt is false in the middle of '+L.name);
         for(j=0;j<g.ents.length;j++){ c=g.ents[j]; if(c&&c.x>L.x&&c.x<L.x+L.w&&c.y>L.y&&c.y<L.y+L.h) bad.push('a '+c.kind+' stands inside '+L.name); }
         n=0; gun=false; var cs=[];
         for(j=0;j<g.containers.length;j++){ c=g.containers[j]; if(c.inLocked===L.id&&c.x>L.x&&c.x<L.x+L.w&&c.y>L.y&&c.y<L.y+L.h){ n++; cs.push(c); if(c.loot.some(function(k){ return ITEMS[k]&&ITEMS[k].use==='gun'&&ITEMS[k].r==='elite'||k==='gun_sniper'; })) gun=true; } }
         if(n<2) bad.push(L.name+' holds '+n+' caches, not 2');
         else if(dist(cs[0],cs[1])<30) bad.push('the two caches in '+L.name+' stand '+Math.round(dist(cs[0],cs[1]))+' apart, on top of each other');
         if(!gun) bad.push(L.name+' has no elite gun in its caches');
       }
       if(V.length&&ITEMS.keycard&&typeof keyFits==='function'){
         L=V[0]; g.player.x=L.doorX; g.player.y=L.doorY; g.player.downed=false; g.searching=null;
         if(typeof arcadeShieldOff==='function') arcadeShieldOff(); ARCADE.holdT=0;
         g.bag=g.bag.filter(function(b){ return !(ITEMS[b]&&ITEMS[b].use==='key'); }); g.bag.push('keycard');
         keys={}; keys.KeyE=true; __sim(0.05); keys={};
         if(!L.open) bad.push('a Vault Keycard at the '+L.name+' door did not open it');
         else if(g.map.walls.some(function(w){ return w.door===L.id; })) bad.push(L.name+' opened but its door wall stands');
       }
       leave(); __runPrep();
       if(!arcadeDeploy({mapIx:0,seed:4242})) return bad.concat(['SKIP: no second arcade raid']).join('; ');
       g=__state(); r2=rects(vaults(g)); fp2=(netUpFp(g)||{}).h;
       if(r1!==r2) bad.push('a second DEMO build at seed 4242 placed other vaults: '+r1+' then '+r2);
       if(fp1!==fp2) bad.push('the party fingerprint differs between two DEMO builds ('+fp1+' then '+fp2+')');
       if(drift.length) bad.push('arcadeVaults moved the main stream: '+drift.join(', '));
       arcadeVaults=real; own=false;
       leave(); __runPrep();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state();
       if(g&&!g.over){ if(vaults(g).length) bad.push('a plain raid has '+vaults(g).length+' vaults'); }
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       if(own&&real){ try{ arcadeVaults=real; }catch(_r){} }
       leave();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'24.67',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
