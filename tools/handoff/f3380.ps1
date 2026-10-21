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

if ($s.Contains("  {v:'33.80',what:")) { throw "check 33.80 is in the fixture already" }

SubRx @'
  {v:'33.79',what:
'@ @'
  {v:'33.80',what:'cw-pixdown (86g): with the pixel look on a downed player kneels in the crouch legs inside a pulsing ring with the gun on the floor, a dead player topples in 8 baked frames (the first upright, the last flat) and turns to light, a pillager bot falls as a red pixel body and fades by 0.7 s, none of it draws a vector ring and every baked pixel is solid or clear',
   run:function(){
     if(typeof pixDrawOp!=='function'||typeof pxToppleSpr!=='function'||typeof pxDeath!=='function'||typeof pxFallTry!=='function'||typeof pxKneelGround!=='function') return 'no pixel downed, death and fall (pxToppleSpr, pxDeath, pxFallTry, pxKneelGround)';
     if(!(window.__deploy&&window.__state&&window.__runPrep&&window.__topClear&&window.__endRaid&&window.__gfxCount)) return 'SKIP: this fixture cannot draw a raid';
     var bad=[], g, saved=false, hp0, dn0, db0, t0, i, M, r, rr, seen={}, nHash=0, a, al=[], ringN=0, gunN=0, crouchN=0, strokes, o, lk, spr, d, bb, w0, h0, w7, h7, bl=0, e, o2, b0;
     function px(c){ return c.getContext('2d').getImageData(0,0,c.width,c.height).data; }
     function fnv(data){ var q=2166136261, j; for(j=0;j<data.length;j++){ q^=data[j]; q=Math.imul(q,16777619)>>>0; } return q; }
     function maps(){
       var Mp=new Map();
       PIXSTORE.m.actors.forEach(function(en){ Mp.set(en.c,{p:en}); });
       return Mp;
     }
     function rec1(fn){
       var d0=wc.drawImage, out=[];
       wc.drawImage=function(src){ out.push({s:src,a:wc.globalAlpha}); return d0.apply(wc,arguments); };
       try{ fn(); } finally{ delete wc.drawImage; }
       return out;
     }
     function draw1(s,mode,face){ pixFrame(); drawOp(600,500,face||0,0,'#242832',0,0,mode,0,s); }
     function body(s,mode,face,tr){
       var j, before=PIX.bodies;
       for(j=0;j<(tr||14)&&PIX.bodies===before;j++) draw1(s,mode,face);
       return PIX.bodies>before;
     }
     function inStore(rec,Mp){ return rec.filter(function(q){ return Mp.get(q.s); }); }
     function solid(c){ var dd=px(c), j; for(j=3;j<dd.length;j+=4) if(dd[j]!==0&&dd[j]!==255) return false; return true; }
     function bbox(c){ var dd=px(c), x, y, x0=1e9, x1=-1, y0=1e9, y1=-1; for(y=0;y<c.height;y++) for(x=0;x<c.width;x++) if(dd[(y*c.width+x)*4+3]){ if(x<x0)x0=x; if(x>x1)x1=x; if(y<y0)y0=y; if(y>y1)y1=y; } return {w:x1-x0+1,h:y1-y0+1}; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       CFG.xfPix=1;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242}); keys={}; g=__state();
       if(!g||g.over) return 'SKIP: no raid';
       function base(q){ var s={hero:1,own:g.player,team:'ally',moving:false,sprint:false,ads:false,hurt:0,bulk:0,rl:0}, z; for(z in q) s[z]=q[z]; return s; }
       wc.save(); saved=true; wc.setTransform(1,0,0,1,0,0);
       hp0=g.player.hp; dn0=g.player.downed; db0=g.deathBeat; t0=g.t;
       // downed: the kneel in pixels, the crouch legs, the pulsing ring, the gun on the floor, no stroked vector ring
       g.player.downed=true;
       if(!body(base({}),'down',0,16)) bad.push('the downed player was not drawn in pixels');
       for(i=0;i<3;i++) draw1(base({}),'down',0);
       strokes=__gfxCount([wc],['stroke','arc'],function(){ draw1(base({}),'down',0); });
       if((strokes.calls.stroke||0)>0) bad.push('the downed body still strokes a vector ring ('+strokes.calls.stroke+' strokes)');
       for(i=0;i<11;i++){
         g.t=i*0.1;
         r=rec1(function(){ draw1(base({}),'down',0); }); M=maps();
         inStore(r,M).forEach(function(q){
           var en=M.get(q.s).p;
           if(en.ring){ al.push(q.a); ringN++; }
           if(en.fg) gunN++;
           if(String(en.fam).slice(-2)==='|c') crouchN++;
           if(!solid(q.s)) bl++;
         });
       }
       if(ringN<11) bad.push('the kneel drew its ring in '+ringN+' of 11 frames');
       if(al.length){ a=Math.max.apply(null,al)-Math.min.apply(null,al); if(a<0.3) bad.push('the kneel ring alpha only moved '+a.toFixed(2)+' over 1 s'); }
       if(g.player.wep&&g.player.wep.id&&g.player.wep.id!=='fists'&&gunN<11) bad.push('the gun lay on the floor in '+gunN+' of 11 frames');
       if(crouchN<11) bad.push('the kneel used the crouch legs in '+crouchN+' of 11 frames');
       if(bl) bad.push(bl+' downed layers hold a blended pixel');
       g.player.downed=dn0;
       // death: 8 frames, the first upright, the last flat; the fall, the hold, the light, then nothing
       lk={head:'short',skin:'fair',clothes:'scav',bot:0};
       for(i=0;i<8;i++){ pixFrame(); spr=pxToppleSpr(lk,0,1,i,1.5708); if(!spr){ bad.push('topple frame '+i+' did not bake'); continue; } seen[fnv(px(spr.c))]=1; if(!solid(spr.c)) bad.push('topple frame '+i+' holds a blended pixel'); if(i===0) bb=bbox(spr.c); if(i===7){ w7=bbox(spr.c); } }
       if(Object.keys(seen).length<8) bad.push('only '+Object.keys(seen).length+' different topple frames of 8');
       if(bb&&w7){ if(!(bb.h>bb.w)) bad.push('the first topple frame is not upright ('+bb.w+' by '+bb.h+')'); if(!(w7.w>w7.h)) bad.push('the last topple frame is not flat ('+w7.w+' by '+w7.h+')'); }
       g.player.hp=0; seen={};
       [0,0.11,0.16,0.2,0.22].forEach(function(t){
         var before=PIX.bodies, q;
         g.deathBeat=1.5-t;
         pixFrame(); r=rec1(function(){ drawOp(600,500,0,0,'#242832',0,0,'down',0,base({})); }); M=maps();
         if(PIX.bodies===before){ pixFrame(); r=rec1(function(){ drawOp(600,500,0,0,'#242832',0,0,'down',0,base({})); }); M=maps(); }
         q=inStore(r,M).filter(function(z){ return String(M.get(z.s).p.fam).charAt(0)==='t'; });
         if(!q.length) bad.push('death at '+t+' s drew no topple frame'); else seen[fnv(px(q[0].s))]=1;
       });
       if(Object.keys(seen).length<5) bad.push('the player death showed '+Object.keys(seen).length+' different frames, wanted 5');
       g.deathBeat=1.5-0.7; pixFrame(); r=rec1(function(){ draw1(base({}),'down',0); }); M=maps();
       r=inStore(r,M).filter(function(z){ return String(M.get(z.s).p.fam).charAt(0)==='t'; });
       if(!r.length||!(r[0].a<0.6)) bad.push('the dead player at 0.7 s is not fading ('+(r.length?r[0].a:'not drawn')+')');
       g.deathBeat=1.5-0.95; pixFrame(); r=rec1(function(){ draw1(base({}),'down',0); }); M=maps();
       if(inStore(r,M).filter(function(z){ return String(M.get(z.s).p.fam).charAt(0)==='t'; }).length) bad.push('the dead player is still drawn at 0.95 s');
       g.player.hp=hp0; g.deathBeat=db0;
       // a pillager bot falls: a red pixel body, then gone by 0.7 s
       o2=null; for(i=0;i<g.ents.length;i++) if(g.ents[i]&&g.ents[i].kind==='raider'){ o2=g.ents[i]; break; }
       o={}; if(o2){ for(e in o2) o[e]=o2[e]; } else { o={kind:'raider',face:0,bag:[],hp:1}; }
       o.merc=0; o.friendly=false; o.friendlyPC=false; o.hostile=true; o.face=0; o.x=600; o.y=500;
       [0.05,0.15,0.4].forEach(function(t){
         var before=PIX.bodies, q;
         for(i=0;i<3&&PIX.bodies===before;i++){ pixFrame(); r=rec1(function(){ raiderFallDraw({op:o,x:600,y:500,sg:1},t); }); }
         M=maps(); q=inStore(r,M).filter(function(z){ return String(M.get(z.s).p.fam).charAt(0)==='t'; });
         if(PIX.bodies===before||!q.length){ bad.push('the bot fall at '+t+' s was not drawn in pixels'); return; }
         if(String(M.get(q[0].s).p.fam).split('|')[4]!=='1') bad.push('the falling bot is not a red bot body');
         if(t===0.4&&!(q[0].a>0.4&&q[0].a<0.8)) bad.push('the bot fall at 0.4 s has alpha '+q[0].a+', wanted about 0.6');
       });
       pixFrame(); b0=PIX.bodies; r=rec1(function(){ raiderFallDraw({op:o,x:600,y:500,sg:1},0.72); }); M=maps();
       if(PIX.bodies!==b0||inStore(r,M).length) bad.push('the bot fall is still drawn at 0.72 s');
       return bad.length?bad.join('; '):null;
     } catch(err){
       return 'pixel down check: '+String(err&&err.message||err);
     } finally {
       try{ delete wc.drawImage; }catch(_d){}
       try{ if(g&&g.player){ if(hp0!==undefined) g.player.hp=hp0; g.player.downed=dn0; g.deathBeat=db0; if(t0!==undefined) g.t=t0; } }catch(_p){}
       if(saved){ try{ wc.restore(); }catch(_r){} }
       CFG.xfPix=0;
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e2){}
       keys={}; __resetCfg(); __topClear(); __cleanProfile();
     } }},
  {v:'33.79',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
