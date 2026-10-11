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

if ($s.Contains("  {v:'23.53',what:")) { throw "check 23.53 is in the fixture already" }

SubRx @'
  {v:'23.52',what:
'@ @'
  {v:'23.53',what:'arcade29, his yes 2026-10-11, found by the 3-hour arcade soak: the world stays light, one cull pass in an arcade raid takes off 10 idle wave bodies 3000 away and 10 old empty wrecks 2000 away, keeps a near body, a chasing body, a near wreck, a young wreck and a full one, and in a normal raid takes nothing',
   run:function(){
     var bad=[], g=null, sr, had=false, k, p, E=[], C=[], keepE=[], keepC=[], n;
     function ent(dx,dy,st){ var e=mkCrawler(p.x+dx,p.y+dy); e.arcWave=1; e.alert=0; e.state=st||'patrol'; e.arcFar=0; g.ents.push(e); return e; }
     function box(dx,dy,ty,old,full){ var c=mkContainer(p.x+dx,p.y+dy,ty); c.loot=full?['scrap']:[]; c.opened=!full; c.arcAt=(+g.t||0)-(old?301:10); g.containers.push(c); return c; }
     function stage(){
       E=[]; C=[]; keepE=[]; keepC=[];
       for(k=0;k<10;k++){ E.push(ent(Math.cos(k*0.6)*3000,Math.sin(k*0.6)*3000)); C.push(box(Math.cos(k*0.6+0.3)*2000,Math.sin(k*0.6+0.3)*2000,(k%2)?'botwreck':'body',true,false)); }
       keepE.push(ent(500,0)); keepE.push(ent(-3000,0,'chase'));
       keepC.push(box(0,500,'botwreck',true,false)); keepC.push(box(0,-2000,'botwreck',false,false)); keepC.push(box(2000,2000,'body',true,true));
     }
     function on(a,list){ var c=0, q; for(q=0;q<list.length;q++) if(a.indexOf(list[q])>=0) c++; return c; }
     function unstage(){ try{ if(g){ g.ents=g.ents.filter(function(e){ return E.indexOf(e)<0&&keepE.indexOf(e)<0; }); g.containers=g.containers.filter(function(c){ return C.indexOf(c)<0&&keepC.indexOf(c)<0; }); } }catch(_u){} }
     try{
       __topClear(); __runPrep();
       if(typeof arcadeDeploy!=='function'||typeof ARCADE!=='object') return 'no arcade in this build';
       if(typeof arcadeCullTick!=='function') return 'no arcade cull in this build: an arcade raid never takes off a far idle wave body or an old searched wreck';
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(__state()&&!__state().over) __endRaid('abandon');
       if(!arcadeDeploy({mapIx:0,seed:4242})||!__state()||!__state().arcade) return 'SKIP: arcadeDeploy built no arcade raid';
       try{ attStop(); }catch(_as){}
       g=__state(); p=g.player; keys={}; sr=ARCADE.role; had=true; ARCADE.role='host';
       if(netEntsPeer()) return 'SKIP: the fixture has a live co-op peer';
       if(!p||p.specOut) return 'SKIP: no playing player 1 in the arcade raid';
       stage();
       arcadeCullTick(61);
       n=on(g.ents,E); if(n) bad.push(n+' of 10 idle wave bodies 3000 away for 61 s stayed in the arcade raid');
       n=on(g.containers,C); if(n) bad.push(n+' of 10 old empty wrecks 2000 away stayed in the arcade raid');
       if(g.ents.indexOf(keepE[0])<0) bad.push('a wave body 500 away was taken');
       if(g.ents.indexOf(keepE[1])<0) bad.push('a far wave body that is chasing was taken');
       if(g.containers.indexOf(keepC[0])<0) bad.push('an old empty wreck 500 away was taken');
       if(g.containers.indexOf(keepC[1])<0) bad.push('a far empty wreck only 10 s old was taken');
       if(g.containers.indexOf(keepC[2])<0) bad.push('a far old body still holding loot was taken');
       unstage(); E=[]; C=[]; keepE=[]; keepC=[];
       ARCADE.role=sr; had=false;
       try{ arcadeLeave(); }catch(_l0){}
       if(__state()&&!__state().over) __endRaid('abandon');
       __topClear(); __runPrep();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g&&g.player;
       if(!g||g.arcade||!p) return bad.length?bad.join('; '):'SKIP: no normal raid for the second arm';
       stage();
       arcadeCullTick(61);
       if(on(g.ents,E)+on(g.ents,keepE)!==12) bad.push('a normal raid took staged wave bodies');
       if(on(g.containers,C)+on(g.containers,keepC)!==13) bad.push('a normal raid took staged wrecks');
       unstage();
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       unstage();
       try{ if(had&&typeof ARCADE==='object') ARCADE.role=sr; }catch(_r){}
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ if(typeof ARCADE==='object'){ ARCADE.over=null; ARCADE.mine=0; ARCADE.mate=0; ARCADE.pot=0; ARCADE.holdT=0; ARCADE.waveT=0; ARCADE.ownAt=0; ARCADE.idleSaid=0; ARCADE.wantIn=0; } }catch(_m){}
       try{ for(var kk in keys) keys[kk]=false; }catch(_k){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'23.52',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
