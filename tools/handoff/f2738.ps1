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

if ($s.Contains("  {v:'27.38',what:")) { throw "check 27.38 is in the fixture already" }

SubRx @'
  {v:'27.37',what:
'@ @'
  {v:'27.38',what:'partyp1, his verdict on the style medals (keep all of them, Halo style): each medal is a metal emblem of its own in a row at the left edge, the newest popping in large and settling, its name and figure on a plate under the newest only, clear of the HUD panels; the old text plates at the cursor are gone; a medal is one line in the feed',
   run:function(){
     if(!(window.__state&&window.__endRaid&&window.__runPrep)) return 'SKIP: no raid here';
     if(typeof arcadeDeploy!=='function'||typeof ARCADE!=='object'||typeof styleDraw!=='function') return 'SKIP: no arcade here';
     var bad=[], g=null, p, own=false, rs=say, proto, oFt, z, S, t1, t2, it, i, ks, seen={}, hb0=null, eb0=null, fb0=null, nt0, nL, r, a0, a1, t3, sc0, sc1, ok, s0, need;
     function snap(o){ var k, c={}; for(k in o) c[k]=o[k]; return c; }
     function wipe(o){ var k; for(k in o) delete o[k]; }
     function back(o,c){ var k; wipe(o); for(k in c) o[k]=c[k]; }
     function grab(fn){ var a=[]; proto.fillText=function(){ a.push(String(arguments[0])); return oFt.apply(this,arguments); }; try{ fn(); } finally { proto.fillText=oFt; } return a.join('|'); }
     function mk(){ return [{txt:'GRENADE'+' DOUBLE',pts:200,t:g.t-2.0},{txt:'MELEE'+' KILL',pts:120,t:g.t-1.2},{txt:'LONG'+' SHOT',pts:100,t:g.t-0.5}]; }
     try{
       __topClear(); __runPrep();
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       if(typeof styMedalDraw!=='function'||typeof STYBOX!=='object') return 'there is no medal row in this build';
       p=g.player; keys={}; say=function(){}; own=true; ARCADE.holdT=0; z=Math.max(1,hudRes());
       proto=CanvasRenderingContext2D.prototype; oFt=proto.fillText;
       hb0=snap(HUDBOX); eb0=(typeof EDGEBOX==='object')?snap(EDGEBOX):null; fb0={on:FEEDBOX.on,x:FEEDBOX.x,y:FEEDBOX.y,w:FEEDBOX.w,h:FEEDBOX.h};
       if(typeof NETTEAMBOX==='object'&&NETTEAMBOX){ nt0=NETTEAMBOX.n; NETTEAMBOX.n=0; }
       wipe(HUDBOX); if(eb0) wipe(EDGEBOX); FEEDBOX.on=0;
       s0=Math.round(25*z); need=2*s0+Math.round(34*z)+2*Math.round(6*z)+4;
       HUDBOX.raiders={x:Math.round(9*z),y:Math.round(H*0.14),w:Math.round(380*z),h:Math.round(H*0.55)-Math.round(H*0.14)};
       HUDBOX.legend={x:Math.round(9*z),y:Math.round(H*0.55)+need+2,w:Math.round(560*z),h:Math.round(H*0.12)};
       S=styS(); S.pops=mk();
       // ONE: the cursor carries no medal plate any more
       t1=grab(function(){ styleDraw(ctx,p,640,360); });
       if(t1.indexOf('GRENADE'+' DOUBLE')>=0||t1.indexOf('MELEE'+' KILL')>=0||t1.indexOf('LONG'+' SHOT')>=0) bad.push('ONE: a medal plate is still drawn at the cursor ('+t1+')');
       // TWO: the row draws one emblem a medal, and the name only for the newest
       t2=grab(function(){ nL=styMedalDraw(ctx,p); });
       if(nL!==3||STYBOX.n!==3||STYBOX.items.length!==3) bad.push('TWO: the row drew '+nL+' emblems for 3 medals');
       else {
         if(t2.indexOf('LONG'+' SHOT')<0) bad.push('TWO: the newest medal has no name plate ('+t2+')');
         if(t2.indexOf('GRENADE'+' DOUBLE')>=0||t2.indexOf('MELEE'+' KILL')>=0) bad.push('TWO: an older medal also drew its name');
         it=STYBOX.items;
         if(it[0].txt!=='LONG'+' SHOT'||!(it[0].x<it[1].x&&it[1].x<it[2].x)) bad.push('TWO: the newest medal is not first at the left, then the older ones along');
         for(i=0;i<3;i++){
           if(!(it[i].x-it[i].s>=0&&it[i].x+it[i].s<=W*0.3)) bad.push('TWO: emblem '+i+' is not at the left edge (x '+Math.round(it[i].x)+' of '+W+')');
           if(!(it[i].y>=H*0.08&&it[i].y<=H*0.92)) bad.push('TWO: emblem '+i+' is off the middle of the screen (y '+Math.round(it[i].y)+' of '+H+')');
           if(!(it[i].s*2>=36)) bad.push('TWO: emblem '+i+' is only '+Math.round(it[i].s*2)+' px across');
           if(i>0&&!(it[i].x-it[i-1].x>=2*it[i].s)) bad.push('TWO: emblems '+(i-1)+' and '+i+' overlap');
         }
         // THREE: clear of the pillager board and the controls list when there is room between them
         r={x:STYBOX.x,y:STYBOX.y,w:STYBOX.w,h:STYBOX.h};
         if(STYBOX.free!==1) bad.push('THREE: the row found no clear stretch though one stands between the board and the controls list');
         else {
           ok=function(b){ return !(r.x<b.x+b.w&&r.x+r.w>b.x&&r.y<b.y+b.h&&r.y+r.h>b.y); };
           if(!ok(HUDBOX.raiders)) bad.push('THREE: the row sits on the pillager board');
           if(!ok(HUDBOX.legend)) bad.push('THREE: the row sits on the controls list');
         }
       }
       // FOUR: a distinct emblem and a tier for each of the seven medals
       ks=['LONG'+' SHOT','MELEE'+' KILL','GRENADE'+' DOUBLE','MULTI'+'-KILL','UNTOUCHED','SCREEN'+' CLEAR','TEAM'+' COMBO'];
       for(i=0;i<ks.length;i++){
         if(!STY_ICON[ks[i]]) bad.push('FOUR: no emblem for '+ks[i]);
         else if(seen[STY_ICON[ks[i]]]) bad.push('FOUR: '+ks[i]+' shares the emblem of '+seen[STY_ICON[ks[i]]]);
         else seen[STY_ICON[ks[i]]]=ks[i];
         if(!(STY_TIER[ks[i]]>=1&&STY_TIER[ks[i]]<=3)) bad.push('FOUR: no tier for '+ks[i]);
       }
       if(styTierOf('TEAM'+' COMBO x3')!==STY_TIER['TEAM'+' COMBO']) bad.push('FOUR: a TEAM COMBO with its figure has no tier');
       // FIVE: the newest pops in large and settles
       S.pops=[{txt:'LONG'+' SHOT',pts:100,t:g.t-0.04}]; styMedalDraw(ctx,p); sc0=STYBOX.items.length?STYBOX.items[0].sc:0;
       S.pops=[{txt:'LONG'+' SHOT',pts:100,t:g.t-1.2}]; styMedalDraw(ctx,p); sc1=STYBOX.items.length?STYBOX.items[0].sc:0;
       if(!(sc0>=1.5)) bad.push('FIVE: a medal that has just popped is only '+sc0.toFixed(2)+' times its size');
       if(!(sc1>0&&sc1<=1.02)) bad.push('FIVE: a medal 1.2 s old is '+sc1.toFixed(2)+' times its size, not settled');
       // SIX: a spent medal is gone, and no medal means no row
       S.pops=[{txt:'MULTI'+'-KILL',pts:1,t:g.t}]; g.t+=5; styleTick(p,0.016);
       if(S.pops.length) bad.push('SIX: a spent medal was kept');
       t3=grab(function(){ nL=styMedalDraw(ctx,p); });
       if(nL!==0||STYBOX.n!==0||t3) bad.push('SIX: a row was drawn with no medal');
       // SEVEN: a medal is one line in the feed when the feed is there
       if(typeof feedMedal==='function'&&g.fd){
         a0=g.fd.lines.length; i=styMedal('LONG'+' SHOT',100,p.x,p.y); a1=g.fd.lines.length-a0;
         if(i>0&&a1!==1) bad.push('SEVEN: the medal made '+a1+' feed lines, not one');
       }
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       if(own) say=rs;
       try{ if(proto&&oFt) proto.fillText=oFt; }catch(_p){}
       try{ if(hb0) back(HUDBOX,hb0); if(eb0) back(EDGEBOX,eb0); }catch(_hb){}
       try{ if(fb0){ FEEDBOX.on=fb0.on; FEEDBOX.x=fb0.x; FEEDBOX.y=fb0.y; FEEDBOX.w=fb0.w; FEEDBOX.h=fb0.h; } }catch(_fb){}
       try{ if(typeof NETTEAMBOX==='object'&&NETTEAMBOX&&nt0!==undefined) NETTEAMBOX.n=nt0; }catch(_nt){}
       keys={};
       try{ if(g) g.sty=null; }catch(_gs){}
       try{ if(typeof ARCADE==='object'){ ARCADE.streak=null; if(ARCADE.on) arcadeLeave(); } }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ if(typeof ARCADE==='object'){ ARCADE.mine=0; ARCADE.waveT=0; ARCADE.holdT=0; } }catch(_h){}
       __topClear();
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'27.37',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
