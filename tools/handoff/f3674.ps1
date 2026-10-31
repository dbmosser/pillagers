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

if ($s.Contains("  {v:'36.74',what:")) { throw "check 36.74 is in the fixture already" }

SubRx @'
  {v:'36.73',what:
'@ @'
  {v:'36.74',what:'cw-xcountplate: the extraction countdown stands on a plate once the ship has landed (inbound already did) and each fact draws once (countdown with the ring name, one action line, one distance); a damage number keeps clear of the name tags and a name tag keeps clear of a cache label',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__frame&&window.__endRaid&&window.__runPrep&&window.__resetCfg&&window.__pinDefaults&&window.__cleanProfile)) return 'SKIP: this fixture cannot deploy';
     if(typeof drawHUD!=='function'||typeof dmgNumLayout!=='function'||typeof WLTEXT==='undefined') return 'SKIP: no raid HUD here';
     var bad=[], g, p, z, rec=[], pan=[], CP=CanvasRenderingContext2D.prototype, oF=CP.fillText, oHP=hudPanel, oC=canSee, c0=(typeof CAREER_ON==='number')?CAREER_ON:0, a, b, ct, nums, i, j, q, bx, ca, na, r, f;
     function spy(){ rec=[]; pan=[];
       CP.fillText=function(s,x,y){ try{ var m=/([\d.]+)px/.exec(this.font), T=this.getTransform(); rec.push({s:String(s),px:m?+m[1]:0,x:T.a*x+T.c*y+T.e,y:T.b*x+T.d*y+T.f}); }catch(_e){} return oF.apply(this,arguments); };
       hudPanel=function(x,y,w,h){ try{ var T=ctx.getTransform(); pan.push({x:T.a*x+T.e,y:T.d*y+T.f,w:T.a*w,h:T.d*h}); }catch(_e){} return oHP.apply(this,arguments); }; }
     function unspy(){ CP.fillText=oF; hudPanel=oHP; }
     function hud(){ spy(); try{ drawHUD(); }catch(e){ bad.push('drawHUD threw '+(e&&e.message||e)); } unspy(); }
     function on(r){ return r.x>=0&&r.x<=W&&r.y>=0&&r.y<=H; }   // only what lands on the screen (an off-screen ring label is not drawn to the player)
     function count(re){ var n=0; for(var k=0;k<rec.length;k++) if(re.test(rec[k].s)&&on(rec[k])) n++; return n; }
     function first(re){ for(var k=0;k<rec.length;k++) if(re.test(rec[k].s)&&on(rec[k])) return rec[k]; return null; }
     function lst(re){ var o=[]; for(var k=0;k<rec.length;k++) if(re.test(rec[k].s)&&on(rec[k])) o.push(rec[k].s+'@'+Math.round(rec[k].x)+','+Math.round(rec[k].y)); return o.join('|'); }
     function plated(t){ if(!t) return false; for(var k=0;k<pan.length;k++){ var o=pan[k]; if(o.w>=150&&o.h<=140&&t.x>=o.x&&t.x<=o.x+o.w&&t.y>=o.y&&t.y<=o.y+o.h) return true; } return false; }
     function ov(A,B){ return A.x<B.x+B.w&&A.x+A.w>B.x&&A.y<B.y+B.h&&A.y+A.h>B.y; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       CAREER_ON=1; __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       p=g.player; keys={}; g.mapOpen=false; g.mapFirst=false; g.bagOpen=false; g.paused=false; p.hp=100; p.downed=false; p.iv=999; g.timeLeft=300; g.waypoint=null;
       z=(g.zones||[])[0]; if(!z) return 'SKIP: staging: no ring';
       z.open=true; z.beaconT=0; z.hold=30; z.holdMax=30; g.active=z; g.beaconT=0; g.shipHold=30;
       // ONE: landed ship, standing in the ring: the countdown is on a plate, said once, with the one action line and the one distance
       p.x=z.x; p.y=z.y; hud();
       if(count(/extract in progress/i)!==1) bad.push('in the ring the countdown draws '+count(/extract in progress/i)+' times');
       if(!plated(first(/extract in progress/i))) bad.push('in the ring the countdown has no plate behind it');
       if(count(/to extract/i)!==1) bad.push('in the ring the action line draws '+count(/to extract/i)+' times');
       if(count(/^extract(ion)? \d+m/i)!==1) bad.push('in the ring the pill distance draws '+count(/^extract(ion)? \d+m/i)+' times: '+lst(/\d+m\b/i));
       if(count(/^\d+m$/i)!==0) bad.push('in the ring the band draws its own metres: '+lst(/^\d+m$/i));
       // TWO: 200 m out, still on the band: the same plate, and the distance only once (the pill; the band had its own arrow and metres row)
       p.x=z.x+2000; p.y=z.y; hud();
       if(!plated(first(/extract in progress/i))) bad.push('200 m out the countdown has no plate behind it: '+lst(/extract in progress/i)+' panels '+pan.length);
       if(count(/^extract(ion)? \d+m/i)!==1) bad.push('200 m out the pill distance draws '+count(/^extract(ion)? \d+m/i)+' times: '+lst(/\d+m\b/i));
       if(count(/^\d+m$/i)!==0) bad.push('200 m out the band draws its own metres (the pill says it): '+lst(/^\d+m$/i));
       // THREE: names, a cache label on top of one, and a damage number
       z.beaconT=null; z.hold=null; g.beaconT=null; g.shipHold=null;
       p.x=WORLD_W/2; p.y=WORLD_H/2; g.anchX=p.x; g.anchY=p.y; g.leanSX=0; g.leanSY=0; g.shake=0; GFX.sx=0; GFX.sy=0;
       canSee=function(){ return true; };
       a=mkCrawler(p.x+125,p.y+70); b=mkCrawler(a.x+a.r*2,a.y); a.name='crawler c-73'; b.name='crawler c-74'; a.state=b.state='patrol'; a.hp=a.maxhp-1; b.hp=b.maxhp-1; g.ents=[a,b];
       ct=mkContainer(p.x+160,p.y+160,'cache'); ct.cache=1; ct.tag='the long dock cache'; g.containers=[ct];
       __frame(0); __frame(0);
       for(i=0;i<WLTEXT.boxes.length;i++){ q=WLTEXT.boxes[i]; if(q.k==='c'&&!ca) ca=q; if(q.k==='n'&&!na) na=q; }
       if(!ca||!na) bad.push('staging: no cache box or name box ('+WLTEXT.boxes.length+' boxes)');
       else {
         ct.x+=((na.x+na.w/2)-(ca.x+ca.w/2))/WTX.z; ct.y+=((na.y+na.h/2)-(ca.y+ca.h/2))/WTX.z;   // the cache label goes over the first name tag
         __frame(0); __frame(0);
         for(i=0;i<WLTEXT.boxes.length;i++) if(WLTEXT.boxes[i].k==='c') for(j=0;j<WLTEXT.boxes.length;j++) if(WLTEXT.boxes[j].k==='n'&&ov(WLTEXT.boxes[i],WLTEXT.boxes[j])) bad.push('a name tag overlaps a cache label');
       }
       dmgNum(a.x,a.y,12,'#FFF6DC',false,a); dmgNum(b.x,b.y,7,'#FFF6DC',false,b); __frame(0);
       nums=dmgNumLayout(); if(!nums.length) bad.push('staging: no damage numbers');
       for(i=0;i<nums.length;i++){ q=nums[i]; r={x:(q.x-q.w/2-WTX.ox)*WTX.z,y:(q.y-q.px*0.85-WTX.oy)*WTX.z,w:q.w*WTX.z,h:q.px*1.05*WTX.z};
         for(j=0;j<WLTEXT.boxes.length;j++){ bx=WLTEXT.boxes[j]; if(bx.k==='n'&&ov(r,bx)) bad.push('damage number '+q.txt+' sits on a name tag'); } }
       if(a.x!==p.x+125||a.hp!==a.maxhp-1) bad.push('drawing changed enemy simulation');
     }catch(e){ bad.push('threw: '+(e.message||e)); }
     finally{ unspy(); canSee=oC; CAREER_ON=c0; try{ __endRaid('abandon'); }catch(_e){} __topClear(); }
     return bad.length?bad.join('; '):null;
   }},
  {v:'36.73',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
