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

if ($s.Contains("  {v:'26.66',what:")) { throw "check 26.66 is in the fixture already" }

SubRx @'
  {v:'26.65',what:
'@ @'
  {v:'26.66',what:'feel18, his order: a round the player fires that meets a metal wall at a glancing angle bounces once (turned about the face, 60 percent damage, one bounce), while a head-on round, a round on a concrete wall and a round an enemy fires still stop',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: no raid here';
     var bad=[], g, p, all, X0, Y0, k, ux, uy, cx, cy, horiz, R, W=null, n, t, F, nW0, b, d0, d1, dvn, dvt0, dvt1;
     function freeRect(x,y,w,h){ for(var i=0;i<g.map.walls.length;i++){ var q=g.map.walls[i]; if(x<q.x+q.w&&x+w>q.x&&y<q.y+q.h&&y+h>q.y) return false; } return x>20&&y>20&&x+w<WORLD_W-20&&y+h<WORLD_H-20; }
     function fire(deg,o){
       var S={x:F.x+n.x*30+t.x*30*Math.tan(deg*0.0174533),y:F.y+n.y*30+t.y*30*Math.tan(deg*0.0174533)}, l=Math.sqrt((F.x-S.x)*(F.x-S.x)+(F.y-S.y)*(F.y-S.y));
       g.bullets.length=0;
       g.bullets.push({x:S.x,y:S.y,vx:(F.x-S.x)/l*1180,vy:(F.y-S.y)/l*1180,dmg:30,life:0.6,player:!(o&&o.enemy),owner:(o&&o.enemy)?all[0]:p,tint:'#ffffff',thru:0,_pen:PEN_MAX,_rico:(o&&o.rico)?1:0});
       updateBullets(0.1);
       return g.bullets[0]||null;
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       if(g.sim) return 'SKIP: the fixture raid is a sim raid';
       p=g.player; all=g.ents.slice(); g.ents=[]; X0=p.x; Y0=p.y; nW0=g.map.walls.length;
       for(k=0;k<8&&!W;k++){
         ux=Math.cos(k*0.7854); uy=Math.sin(k*0.7854); cx=X0+ux*130; cy=Y0+uy*130; horiz=Math.abs(uy)>=Math.abs(ux)-1e-6;
         R=horiz?{x:cx-100,y:cy-10,w:200,h:20}:{x:cx-10,y:cy-100,w:20,h:200};
         if(!freeRect(R.x-60,R.y-60,R.w+120,R.h+120)) continue;
         W={x:R.x,y:R.y,w:R.w,h:R.h,lockWall:true,noDes:true};
         n=horiz?{x:0,y:(uy>0?-1:1)}:{x:(ux>0?-1:1),y:0}; t=horiz?{x:1,y:0}:{x:0,y:1};
         F={x:cx+n.x*10,y:cy+n.y*10};
       }
       if(!W) return 'SKIP: staging: no free ground for a test wall near the drop point';
       g.map.walls.push(W); rebuildGeometry();
       // ONE: a glancing round on steel bounces
       b=fire(40);
       if(!b) bad.push('ONE: a round at 40 degrees on a steel wall was stopped');
       else {
         dvn=b.vx*n.x+b.vy*n.y; dvt1=b.vx*t.x+b.vy*t.y;
         if(!(dvn>500)) bad.push('ONE: the bounced round is not leaving the face (normal speed '+dvn.toFixed(0)+')');
         if(!(b._rico)) bad.push('ONE: the bounce is not marked');
         if(Math.abs(b.dmg-18)>0.01) bad.push('ONE: the bounced round carries '+b.dmg+', not 18');
         d0=Math.abs((b.x-F.x)*n.x+(b.y-F.y)*n.y); updateBullets(0.05); b=g.bullets[0];
         if(!b) bad.push('ONE: the bounced round died in the next 0.05 s');
         else { d1=Math.abs((b.x-F.x)*n.x+(b.y-F.y)*n.y); if(!(d1>d0+20)) bad.push('ONE: the bounced round did not fly on ('+d0.toFixed(1)+' to '+d1.toFixed(1)+')'); }
       }
       // TWO: head-on stops
       if(fire(0)) bad.push('TWO: a head-on round on steel bounced');
       // THREE: concrete stops
       W.lockWall=false; W.noDes=false;
       if(fire(40)) bad.push('THREE: a round on a concrete wall bounced');
       W.lockWall=true; W.noDes=true;
       // FOUR: an enemy round stops
       if(fire(40,{enemy:1})) bad.push('FOUR: a round an enemy fired bounced off steel');
       // FIVE: a round that has bounced once does not bounce again
       if(fire(40,{rico:1})) bad.push('FIVE: a round that had bounced already bounced again');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(g){ if(W){ var wi=g.map.walls.indexOf(W); if(wi>=0) g.map.walls.splice(wi,1); rebuildGeometry(); } if(all) g.ents=all.slice(); g.bullets.length=0; } }catch(_h){}
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'26.65',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
