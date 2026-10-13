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

if ($s.Contains("  {v:'25.34',what:")) { throw "check 25.34 is in the fixture already" }

SubRx @'
  {v:'25.33',what:
'@ @'
  {v:'25.34',what:'his order: the mouse resting on a gun key of the tactical belt shows that gun stat card above the key, on screen and readable at 1080p and 4K, after a short dwell, gone when the mouse leaves or a drag starts, in the Undercroft too, and the trigger still fires with the mouse over the belt',
   run:function(){
     if(!window.__deploy||!window.__endRaid||!window.__hubEnter||typeof drawHUD!=='function'||typeof drawHubBelt!=='function'||typeof hubBagState!=='function'||typeof hotbarSlots!=='function'||typeof forgeApply!=='function') return 'SKIP: no raid here';
     var bad=[], g, p, W0=W, H0=H, proto=CanvasRenderingContext2D.prototype, oT=proto.fillText, rec=[], keep=null, mx0=mouse.x, my0=mouse.y, RES=[[1920,1080],[3840,2160]];
     var ri, sl, i, iR=-1, iS=-1, iH=-1, c, r, q, a0, tg, pk=null, og, st;
     function rec0(){ rec=[]; proto.fillText=function(s,x,y){ var m=this.getTransform(), d=(typeof DPRH==='number'&&DPRH>0)?DPRH:1, fm=/([\d.]+)px/.exec(this.font||''); rec.push({s:String(s),x:(m.a*x+m.c*y+m.e)/d,y:(m.b*x+m.d*y+m.f)/d,px:(fm?+fm[1]:0)*Math.abs(m.d||1)/d}); return oT.apply(this,arguments); }; }
     function hud(){ rec0(); try{ drawHUD(); } finally { proto.fillText=oT; } }
     function floor(){ rec0(); try{ drawHubBelt(); } finally { proto.fillText=oT; } }
     function spin(ms){ var t0=performance.now(); while(performance.now()-t0<ms){} }
     function cellOf(C,ix){ var k; C=C||[]; for(k=0;k<C.length;k++) if(C[k]&&C[k].i===ix) return C[k]; return null; }
     function near(c,t){ return t.y<c.y+1&&t.y>c.y-H*0.45&&t.x>c.x+c.w/2-W*0.2&&t.x<c.x+c.w/2+W*0.2; }
     function find(re,c){ var k; for(k=0;k<rec.length;k++) if(re.test(rec[k].s)&&near(c,rec[k])) return rec[k]; return null; }
     function rest(c,draw){ mouse.x=c.x+c.w/2; mouse.y=c.y+c.h/2; draw(); spin(220); draw(); }
     function judge(tg,c,re){
       var b=(typeof BELTHOV!=='undefined')?BELTHOV.box:null, k, t, small=null;
       if(!b){ bad.push(tg+'the card left no box'); return; }
       if(b.x<0||b.y<0||b.x+b.w>W||b.y+b.h>H) bad.push(tg+'the card is off the screen ('+[b.x,b.y,b.w,b.h].map(Math.round).join(',')+' on '+W+'x'+H+')');
       if(b.y+b.h>c.y) bad.push(tg+'the card is not above the key (bottom '+Math.round(b.y+b.h)+', key top '+Math.round(c.y)+')');
       if(b.x>c.x+c.w||b.x+b.w<c.x) bad.push(tg+'the card is not over its key');
       for(k=0;k<rec.length;k++){ t=rec[k]; if(t.x<b.x-1||t.x>b.x+b.w+1||t.y<b.y-1||t.y>b.y+b.h+1) continue; if(t.px*1080/H<12.9&&!small) small=t.s+' '+(t.px*1080/H).toFixed(1)+'px'; }
       if(small) bad.push(tg+'card text under 13px at 1080p terms: '+small);
       t=find(re,c); if(t&&(t.x<b.x||t.x>b.x+b.w||t.y<b.y||t.y>b.y+b.h)) bad.push(tg+'the gun name is drawn outside the card');
     }
     try{
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g&&g.player; if(!g||g.over||!p) return 'SKIP: no live raid';
       keep={wep:p.wep,sec:p.sec,ammo:p.ammo,secAmmo:p.secAmmo,sw:p.swapped,hot:g.hot};
       p.wep=forgeApply(WEAPONS.rifle,2,'fire'); p.ammo=p.wep.mag; p.sec=forgeApply(WEAPONS.shotgun,0); p.secAmmo=p.sec.mag; p.swapped=false;
       sl=hotbarSlots();
       for(i=0;i<sl.length;i++){ if(sl[i].kind==='gun'&&sl[i].icon==='rifle'&&iR<0) iR=i; if(sl[i].kind==='gun'&&sl[i].icon==='shotgun'&&iS<0) iS=i; }
       if(iR<0||iS<0) return 'SKIP: staging: the two guns are not on the belt ('+iR+','+iS+')';
       g.hot=iR;
       for(ri=0;ri<RES.length;ri++){
         W=RES[ri][0]; H=RES[ri][1]; tg=(ri?'4K':'1080p')+': ';
         mouse.down=false; g.drag=null; mouse.x=-500; mouse.y=-500; hud();
         c=cellOf(g.hotCells,iS); if(!c){ bad.push(tg+'the belt drew no key '+(iS+1)); continue; }
         mouse.x=c.x+c.w/2; mouse.y=c.y+c.h/2; hud();
         if(find(/^RIOT SCATTERGUN$/,c)) bad.push(tg+'the card shows the frame the mouse arrives, so sweeping the belt flashes cards');
         spin(220); hud();
         if(!find(/^RIOT SCATTERGUN$/,c)){ bad.push(tg+'no stat card for the Riot Scattergun after the mouse rested on key '+(iS+1)); continue; }
         if(!find(/^DMG$/,c)||!find(/^HANDLING$/,c)) bad.push(tg+'the card over the belt has no stat rows');
         if(!find(/^VS AUTO RIFLE MK III$/,c)) bad.push(tg+'the card does not compare with the gun in hand');
         if(!find(/^OTHER GUN$/,c)) bad.push(tg+'the card does not say OTHER GUN');
         judge(tg,c,/^RIOT SCATTERGUN$/);
         mouse.x=c.x+c.w/2; mouse.y=c.y-c.h*2; hud();
         if(find(/^RIOT SCATTERGUN$/,c)) bad.push(tg+'the card stays up after the mouse leaves the key');
         c=cellOf(g.hotCells,iR); if(!c){ bad.push(tg+'the belt drew no key '+(iR+1)); continue; }
         rest(c,hud);
         if(!find(/^AUTO RIFLE MK III$/,c)) bad.push(tg+'no card naming the MK III Auto Rifle in hand');
         else {
           if(!find(/^IN HANDS$/,c)) bad.push(tg+'the card of the gun in hand does not say IN HANDS');
           if(!find(/^FIRE$/,c)) bad.push(tg+'the MK III card does not name its element FIRE');
           if(find(/^VS /,c)) bad.push(tg+'the card of the gun in hand compares it with itself');
           judge(tg,c,/^AUTO RIFLE MK III$/);
         }
         g.drag={key:'bandage',px:mouse.x,py:mouse.y}; hud(); g.drag=null;
         if(find(/^AUTO RIFLE MK III$/,c)) bad.push(tg+'the card stays up during a drag');
       }
       W=1920; H=1080; mouse.down=false; g.drag=null; mouse.x=-500; mouse.y=-500; hud();
       c=cellOf(g.hotCells,iS);
       if(c){
         rest(c,hud);
         a0=p.ammo; p.lastShot=-1e9; p.reloading=0; p.jam=0; p.fired=false; p.trigYield=false; p.cooking=false; g.hot=iR; mouse.down=true;
         for(i=0;i<6;i++) __sim(0.05);
         hud(); mouse.down=false;
         if(!(p.ammo<a0)) bad.push('holding the trigger with the mouse over the belt fired nothing (ammo '+a0+' to '+p.ammo+')');
         if(find(/^RIOT SCATTERGUN$/,c)) bad.push('the card shows while the trigger is held');
       }
       p.wep=keep.wep; p.sec=keep.sec; p.ammo=keep.ammo; p.secAmmo=keep.secAmmo; p.swapped=keep.sw; g.hot=keep.hot; keep=null;
       __endRaid('abandon'); __topClear();
       pk={eq:P.equipped,es:P.equippedSec,ha:P.hotAssign,kit:P.kit};
       G=null; keys={}; __showScreen('hub'); __hubEnter();
       P.equipped='rifle'; P.equippedSec='shotgun'; P.hotAssign={}; P.kit=[];
       st=hubBagState(); og=G; G=st; try{ sl=hotbarSlots(); } finally { G=og; }
       for(i=0;i<sl.length;i++) if(sl[i].kind==='gun'&&sl[i].icon==='shotgun'&&iH<0) iH=i;
       W=1920; H=1080; mouse.down=false; mouse.x=-500; mouse.y=-500; floor();
       c=cellOf(HUBBELT.cells,iH);
       if(iH<0||!c) bad.push('the Undercroft belt did not draw the Riot Scattergun key (staging)');
       else {
         rest(c,floor);
         if(!find(/^RIOT SCATTERGUN$/,c)) bad.push('no stat card on the Undercroft belt after the mouse rested on key '+(iH+1));
         else judge('Undercroft: ',c,/^RIOT SCATTERGUN$/);
         mouse.x=-500; mouse.y=-500; floor();
         if(find(/^RIOT SCATTERGUN$/,c)) bad.push('the Undercroft card stays up after the mouse leaves');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       W=W0; H=H0; proto.fillText=oT; mouse.x=mx0; mouse.y=my0; mouse.down=false;
       if(pk){ P.equipped=pk.eq; P.equippedSec=pk.es; P.hotAssign=pk.ha; P.kit=pk.kit; }
       try{ var g2=__state(); if(g2&&!g2.over){ if(keep){ g2.player.wep=keep.wep; g2.player.sec=keep.sec; g2.player.ammo=keep.ammo; g2.player.secAmmo=keep.secAmmo; g2.player.swapped=keep.sw; g2.hot=keep.hot; } g2.drag=null; g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'25.33',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
