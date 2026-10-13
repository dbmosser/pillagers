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

if ($s.Contains("  {v:'25.59',what:")) { throw "check 25.59 is in the fixture already" }

SubRx @'
  {v:'25.58',what:
'@ @'
  {v:'25.59',what:'his order: the mouse resting on any other item of the tactical belt shows its info card above the key: the name in its rarity colour, held, what it does in numbers, its value and its keys, on screen and readable at 1080p and 4K, gone when the mouse leaves, and the trigger still fires with the mouse over the belt',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof drawHUD!=='function'||typeof hotbarSlots!=='function'||typeof ival!=='function') return 'SKIP: no raid here';
     var bad=[], g, p, W0=W, H0=H, proto=CanvasRenderingContext2D.prototype, oT=proto.fillText, rec=[], mx0=mouse.x, my0=mouse.y, RES=[[1920,1080],[3840,2160]];
     var ri, sl, i, iF=-1, iM=-1, iG=-1, c, a0, tg, fv='$'+ival('frag').toLocaleString(), hot0;
     function rec0(){ rec=[]; proto.fillText=function(s,x,y){ var m=this.getTransform(), d=(typeof DPRH==='number'&&DPRH>0)?DPRH:1, fm=/([\d.]+)px/.exec(this.font||''); rec.push({s:String(s),x:(m.a*x+m.c*y+m.e)/d,y:(m.b*x+m.d*y+m.f)/d,px:(fm?+fm[1]:0)*Math.abs(m.d||1)/d}); return oT.apply(this,arguments); }; }
     function hud(){ rec0(); try{ drawHUD(); } finally { proto.fillText=oT; } }
     function spin(ms){ var t0=performance.now(); while(performance.now()-t0<ms){} }
     function cellOf(C,ix){ var k; C=C||[]; for(k=0;k<C.length;k++) if(C[k]&&C[k].i===ix) return C[k]; return null; }
     function near(c,t){ return t.y<c.y+1&&t.y>c.y-H*0.5&&t.x>c.x+c.w/2-W*0.2&&t.x<c.x+c.w/2+W*0.2; }
     function find(re,c){ var k; for(k=0;k<rec.length;k++) if(re.test(rec[k].s)&&near(c,rec[k])) return rec[k]; return null; }
     function rest(c){ mouse.x=c.x+c.w/2; mouse.y=c.y+c.h/2; hud(); spin(220); hud(); }
     function inBox(re){ var b=(typeof BELTHOV!=='undefined')?BELTHOV.box:null, k, t; if(!b) return null; for(k=0;k<rec.length;k++){ t=rec[k]; if(re.test(t.s)&&t.x>=b.x-1&&t.x<=b.x+b.w+1&&t.y>=b.y-1&&t.y<=b.y+b.h+1) return t; } return null; }
     function judge(tg,c){
       var b=(typeof BELTHOV!=='undefined')?BELTHOV.box:null, k, t, small=null, out=null;
       if(!b){ bad.push(tg+'the card left no box'); return; }
       if(b.x<0||b.y<0||b.x+b.w>W||b.y+b.h>H) bad.push(tg+'the card is off the screen ('+[b.x,b.y,b.w,b.h].map(Math.round).join(',')+' on '+W+'x'+H+')');
       if(b.y+b.h>c.y) bad.push(tg+'the card is not above the key');
       if(b.x>c.x+c.w||b.x+b.w<c.x) bad.push(tg+'the card is not over its key');
       for(k=0;k<rec.length;k++){ t=rec[k]; if(!near(c,t)) continue; if(t.y<b.y-1||t.y>b.y+b.h+1) continue; if(t.x<b.x-1||t.x>b.x+b.w+1){ if(!out&&t.y<c.y-c.h*0.2) out=t.s; continue; } if(t.px*1080/H<12.9&&!small) small=t.s+' '+(t.px*1080/H).toFixed(1)+'px'; }
       if(small) bad.push(tg+'card text under 13px at 1080p terms: '+small);
     }
     try{
       __topClear(); __runPrep(); __deploy({kit:['frag','frag','bandage','bandage','medkit','smoke'],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g&&g.player; if(!g||g.over||!p) return 'SKIP: no live raid';
       hot0=g.hot;
       sl=hotbarSlots();
       for(i=0;i<sl.length;i++){ if(sl[i].kind==='throw'&&sl[i].icon==='frag'&&iF<0) iF=i; if(sl[i].kind==='heal'&&iM<0) iM=i; if(sl[i].kind==='gun'&&sl[i].inHand&&iG<0) iG=i; }
       if(iF<0||iM<0) return 'SKIP: staging: no Frag Charge or Medical key on the belt ('+iF+','+iM+')';
       if(!((sl[iF].count|0)>=2)) return 'SKIP: staging: the Frag key holds '+sl[iF].count;
       for(ri=0;ri<RES.length;ri++){
         W=RES[ri][0]; H=RES[ri][1]; tg=(ri?'4K':'1080p')+': ';
         mouse.down=false; g.drag=null; mouse.x=-500; mouse.y=-500; hud();
         c=cellOf(g.hotCells,iF); if(!c){ bad.push(tg+'the belt drew no key '+(iF+1)); continue; }
         mouse.x=c.x+c.w/2; mouse.y=c.y+c.h/2; hud();
         if(find(/^FRAG CHARGE$/,c)) bad.push(tg+'the card shows the frame the mouse arrives, so sweeping the belt flashes cards');
         spin(220); hud();
         if(!find(/^FRAG CHARGE$/,c)){ bad.push(tg+'no info card for the Frag Charge after the mouse rested on key '+(iF+1)); continue; }
         if(!find(/^UNCOMMON$/,c)) bad.push(tg+'the Frag card does not name its rarity');
         if(!find(new RegExp('^HELD '+sl[iF].count+'$'),c)) bad.push(tg+'the Frag card does not say how many are held ('+sl[iF].count+')');
         if(!find(/^DAMAGE$/,c)||!find(/^140$/,c)) bad.push(tg+'the Frag card has no damage number');
         if(!find(/^FUSE$/,c)||!find(new RegExp('^'+(Math.round(FRAG_FUSE*10)/10)+'S$'),c)) bad.push(tg+'the Frag card has no fuse');
         if(!find(/^BLAST$/,c)) bad.push(tg+'the Frag card has no blast');
         if(!inBox(/^VALUE$/)||!inBox(new RegExp('^\\'+fv+'$'))) bad.push(tg+'the Frag card does not show its value '+fv);
         if(!inBox(new RegExp('^'+(iF+1)+'$'))||!inBox(/^FIRE$/)||!inBox(/^USE$/)) bad.push(tg+'the Frag card does not show its keys');
         judge(tg,c);
         mouse.x=c.x+c.w/2; mouse.y=c.y-c.h*2; hud();
         if(find(/^FRAG CHARGE$/,c)) bad.push(tg+'the card stays up after the mouse leaves the key');
         c=cellOf(g.hotCells,iM); if(!c){ bad.push(tg+'the belt drew no key '+(iM+1)); continue; }
         rest(c);
         if(!find(/^HEALS$/,c)) bad.push(tg+'no info card with HEALS over the Medical key');
         else { if(!find(/^UP TO$/,c)) bad.push(tg+'the Medical card does not say what it heals up to'); judge(tg+'Medical: ',c); }
       }
       W=1920; H=1080; mouse.down=false; g.drag=null; mouse.x=-500; mouse.y=-500; hud();
       c=cellOf(g.hotCells,iF);
       if(c&&iG>=0){
         rest(c);
         a0=p.ammo; p.lastShot=-1e9; p.reloading=0; p.jam=0; p.fired=false; p.trigYield=false; p.cooking=false; g.hot=iG; mouse.down=true;
         for(i=0;i<6;i++) __sim(0.05);
         hud(); mouse.down=false;
         if(!(p.ammo<a0)) bad.push('holding the trigger with the mouse over the belt fired nothing (ammo '+a0+' to '+p.ammo+')');
         if(find(/^FRAG CHARGE$/,c)) bad.push('the card shows while the trigger is held');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       W=W0; H=H0; proto.fillText=oT; mouse.x=mx0; mouse.y=my0; mouse.down=false;
       try{ var g2=__state(); if(g2&&!g2.over){ g2.hot=hot0; g2.drag=null; g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'25.58',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
