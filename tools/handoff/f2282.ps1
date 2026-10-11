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

if ($s.Contains("  {v:'22.82',what:")) { throw "check 22.82 is in the fixture already" }

SubRx @'
  {v:'22.81',what:
'@ @'
  {v:'22.82',what:'the location tag: walking into another zone shows its authored name in caps in the free alert slot (G.loc, drawn on the HUD) and says no Crossing into sentence; the same name does not show again within 20 s; and a hostile chasing within 700 drops the tag',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__loop&&window.__keysRef&&window.__textTrace)) return 'SKIP: this fixture cannot deploy, step or trace';
     var bad=[], g, p, i, j, Z, A=null, B=null, t0, f=0, realSay=say, said=[], K, lm, cx, cy, ok, tr, hit, NA='Crossing '+'into', NB='Enter'+'ing the';
     function inLm(x,y){ var L=g.map.landmarks||[]; for(var q=0;q<L.length;q++) if(x>L[q].x-40&&x<L[q].x+L[q].w+40&&y>L[q].y-40&&y<L[q].y+L[q].h+40) return true; return false; }
     function step(n,x,y){ for(var q=0;q<n&&!g.over;q++){ p.x=x; p.y=y; g.ents.length=0; g.alert=null; g.alertQ=[]; __loop(t0+(++f)*16.7); } }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       if(!g.map||!g.map.zoneAt) return 'SKIP: this map has no zones';
       p=g.player; p.iv=99; p.maxhp=100000; p.hp=100000; g.ents.length=0; g.waveT=-1e9;
       for(var gx=1;gx<40&&!B;gx++) for(var gy=1;gy<40&&!B;gy++){
         cx=WORLD_W*gx/40; cy=WORLD_H*gy/40; Z=g.map.zoneAt(cx,cy);
         if(!Z||!Z.name||inLm(cx,cy)||(A&&A.n===Z.name)) continue;
         if(!A) A={x:cx,y:cy,n:Z.name}; else B={x:cx,y:cy,n:Z.name};
       }
       if(!A||!B) return 'SKIP: no two zone centres clear of landmarks on this map';
       say=function(m){ said.push(String(m)); return realSay.apply(this,arguments); };
       t0=Math.max(performance.now(),(typeof lastTs==='number'&&isFinite(lastTs))?lastTs:0);
       K=__keysRef(); for(var k0 in K) delete K[k0];
       step(6,A.x,A.y);
       if(g.over) return 'SKIP: staging: the raid ended';
       g.zoneCd=0; g.loc=null; g.locSeen={}; said.length=0;
       step(6,B.x,B.y);
       for(j=0;j<said.length;j++) if(said[j].indexOf(NA)>=0||said[j].indexOf(NB)>=0) bad.push('walking into '+B.n+' said a sentence: '+said[j]);
       if(!(g.loc&&g.loc.m===String(B.n).toUpperCase())) bad.push('walking into '+B.n+' showed no location tag with its name in caps (G.loc '+JSON.stringify(g.loc||null)+')');
       else {
         tr=__textTrace(function(){ try{ drawHUD(); }catch(_h){} });
         hit=null; for(j=0;j<tr.length;j++) if(tr[j].t===String(B.n).toUpperCase()) hit=tr[j];
         if(!hit) bad.push('the location tag '+B.n+' was not drawn on the HUD');
         else if(hit.y>H*0.4) bad.push('the location tag was drawn at y '+Math.round(hit.y)+', not in the alert slot at the top');
       }
       // AGAIN WITHIN 20 s: back to A (its first tag), then into B again: B does not show twice.
       g.zoneCd=0; g.loc=null; step(6,A.x,A.y);
       if(!(g.loc&&g.loc.m===String(A.n).toUpperCase())) bad.push('walking back into '+A.n+' showed no tag');
       g.zoneCd=0; g.loc=null; step(6,B.x,B.y);
       if(g.loc&&g.loc.m===String(B.n).toUpperCase()) bad.push('the tag '+B.n+' showed again within 20 s');
       // A HOSTILE CHASING WITHIN 700 DROPS IT, and one far off does not.
       if(typeof locSay==='function'){
         g.loc=null; g.locSeen={}; g.alert=null;
         g.ents.length=0; g.ents.push({kind:'crawler',state:'chase',x:p.x+300,y:p.y,hp:50});
         ok=locSay('ZQ YARD'); g.ents.length=0;
         if(ok||g.loc) bad.push('with a hostile chasing 300 away the location tag still showed');
         g.ents.push({kind:'crawler',state:'chase',x:p.x+2000,y:p.y,hp:50});
         ok=locSay('ZQ YARD'); g.ents.length=0;
         if(!ok||!g.loc) bad.push('with the only chase 2000 away the location tag did not show');
       }
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       say=realSay;
       try{ var K2=__keysRef(); for(var k3 in K2) delete K2[k3]; }catch(_k){}
       try{ var g2=__state(); if(g2){ g2.loc=null; g2.locSeen={}; g2.ents.length=0; g2.msgT=0; g2.msg=''; g2.feed=[]; g2.msgQ=[]; g2.msgQM=[]; g2.alert=null; g2.alertQ=[]; g2.pick=[]; } if(g2&&!g2.over){ g2.player.downed=false; g2.player.iv=0; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'22.81',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
