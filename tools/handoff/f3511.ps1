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

if ($s.Contains("  {v:'35.11',what:")) { throw "check 35.11 is in the fixture already" }

SubRx @'
  {v:'35.10',what:
'@ @'
  {v:'35.11',what:'RAID HUD FIXES: loot leaves the left feed, recovering only while health climbs, status icons clear of the feed',
   run:function(){
     var bad=[], p, i, rest=null, rec=[], oldFA=feedAdd, oldSP=statusPill, sv=null, fb=null, mb=null, top, hr, oy, base;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:['gun_carbine','medkit','bandage','plate'],mapIx:0,seed:4242});
       if(state!=='raid'||!G||!G.player) return 'no raid';
       p=G.player; G.mapOpen=false;
       var MP=mapPopupState(); MP.q.length=0; MP.wait=0; MP.open=false; G.msgDrain=0;
       // (1) a looted item makes no feed row; money still does; the right-side stack still gets it
       try{
         feedAdd=function(segs,fk){ rec.push(fk); return null; };
         feedSay('MEDKIT','pick',{item:'medkit',tag:'SLOT 2'});
         if(rec.indexOf('loot')>=0) bad.push('looted medkit made a left feed row');
         rec.length=0;
         feedSay('+$40','pick',{tag:'cash'});
         if(rec.indexOf('money')<0) bad.push('money row lost from the feed: '+rec.join(','));
       } finally { feedAdd=oldFA; }
       G.pick=[];
       say('MEDKIT','pick',{item:'medkit',tag:'SLOT 2'});
       var gotPick=false; for(i=0;i<(G.pick||[]).length;i++) if(G.pick[i]&&G.pick[i].item==='medkit') gotPick=true;
       if(!gotPick) bad.push('looted medkit missing from the right-side stack');
       for(i=0;i<STATUSL.length;i++) if(STATUSL[i].id==='rest'||STATUSL[i].k==='rest'||STATUSL[i].key==='rest') rest=STATUSL[i];
       if(!rest) for(i=0;i<STATUSL.length;i++) if(/RECOVER/i.test(String(STATUSL[i].t||STATUSL[i].name||STATUSL[i].label||''))) rest=STATUSL[i];
       if(!rest) bad.push('no rest entry in STATUSL');
       top=healCeil(ITEMS.bandage);
       // (2) 84.6 hp shows as 85 and gains nothing: no recovering icon
       if(rest){
         p.downed=false; p.stimT=0; p.hp=top-0.4; p.combatT=20; p.regenAcc=0; p.crAcc=0; delete p.regenUpT; delete p.regenUpW; delete p.regenUpHp;
         for(i=0;i<10;i++){ G.t+=0.1; tickRegen(0.1); }
         statusLive(p);
         if(rest.on) bad.push('recovering shown at hp '+p.hp.toFixed(1)+' with no health coming');
         // (3) real regen from 60: the icon shows once a point lands
         p.hp=60; p.combatT=20; p.regenAcc=0; delete p.regenUpT;
         for(i=0;i<36;i++){ G.t+=0.1; tickRegen(0.1); }
         statusLive(p);
         if(!(p.hp>60)) bad.push('no regen from 60 (hp '+p.hp+')');
         else if(!rest.on) bad.push('recovering hidden while health climbs (hp '+p.hp+')');
       }
       // (4) the status column never lands on the feed or the medal strip
       hr=hudRes(); oy=Math.round(H*0.40);
       sv={r:HUDBOX.raiders,l:HUDBOX.legend,b:HUDBOX.body};
       fb={on:FEEDBOX.on,x:FEEDBOX.x,y:FEEDBOX.y,w:FEEDBOX.w,h:FEEDBOX.h};
       mb={on:MEDALBOX.on,x:MEDALBOX.x,y:MEDALBOX.y,w:MEDALBOX.w,h:MEDALBOX.h};
       HUDBOX.raiders=null; HUDBOX.legend=null; HUDBOX.body=null;
       FEEDBOX.on=1; FEEDBOX.x=Math.round(9*hr); FEEDBOX.y=oy+4; FEEDBOX.w=Math.round(W*0.24); FEEDBOX.h=120;
       MEDALBOX.on=1; MEDALBOX.x=FEEDBOX.x; MEDALBOX.y=FEEDBOX.y+FEEDBOX.h+2; MEDALBOX.w=FEEDBOX.w; MEDALBOX.h=40;
       p.hp=100; p.stimT=5; G.mapOpen=false;
       var pills=[];
       ctx.save();
       try{
         base=ctx.getTransform();
         statusPill=function(x0,cy,x1,h){
           var M=base.inverse().multiply(ctx.getTransform()), a=M.transformPoint(new DOMPoint(x0,cy-h*0.6)), b=M.transformPoint(new DOMPoint(x1,cy+h*0.6));
           pills.push({x0:Math.min(a.x,b.x),y0:Math.min(a.y,b.y),x1:Math.max(a.x,b.x),y1:Math.max(a.y,b.y)});
         };
         drawStatusIcons();
       } finally { statusPill=oldSP; ctx.restore(); }
       if(!pills.length) bad.push('no status pill drawn');
       function hit(q,B){ return q.x0<B.x+B.w&&q.x1>B.x&&q.y0<B.y+B.h&&q.y1>B.y; }
       for(i=0;i<pills.length;i++){
         if(hit(pills[i],FEEDBOX)) bad.push('status pill on the feed at '+Math.round(pills[i].x0)+','+Math.round(pills[i].y0));
         if(hit(pills[i],MEDALBOX)) bad.push('status pill on the medal strip at '+Math.round(pills[i].x0)+','+Math.round(pills[i].y0));
       }
       // (5) a plate goes on any key (his armour report of 10-27)
       if(beltDropRefusal('plate',0)!=='') bad.push('plate refused on key 1: '+beltDropRefusal('plate',0));
       if(beltDropRefusal('plate',HOTBAR_N-1)!=='') bad.push('plate refused on the last key: '+beltDropRefusal('plate',HOTBAR_N-1));
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ feedAdd=oldFA; statusPill=oldSP; }catch(_r){}
       try{ if(sv){ HUDBOX.raiders=sv.r; HUDBOX.legend=sv.l; HUDBOX.body=sv.b; } }catch(_h){}
       try{ if(fb){ for(var f1 in fb) FEEDBOX[f1]=fb[f1]; } if(mb){ for(var m1 in mb) MEDALBOX[m1]=mb[m1]; } }catch(_b){}
       try{ var sm=document.getElementById('sectormodal'); if(sm) sm.classList.remove('on'); }catch(_s){}
       try{ if(pauseOpen) togglePauseBox(false); }catch(_p){}
       try{ var K2=__keys(); for(var q2 in K2) delete K2[q2]; }catch(_k){}
       try{ if(state==='raid'&&G&&!G.over) __endRaid('abandon'); }catch(_e){}
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'35.10',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
