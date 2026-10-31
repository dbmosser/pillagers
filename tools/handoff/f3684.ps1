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

if ($s.Contains("  {v:'36.84',what:")) { throw "check 36.84 is in the fixture already" }

SubRx @'
  {v:'36.83',what:
'@ @'
  {v:'36.84',what:'the undercroft hub reads cleanly: the welcome toast keeps 24px clear of the station prompt and the stash sign, every $ in the corner readout is one size and weight, the experimental caption sits on the bar sign plate',
   run:function(){
     var oW=W,oH=H,oWN=WNSEEN,oOn=NET.on,oSame=NET.same,oKeys=keys;
     var oHF=ctx.fillText,ownHF=Object.prototype.hasOwnProperty.call(ctx,'fillText');
     var oWF=wc.fillText,ownWF=Object.prototype.hasOwnProperty.call(wc,'fillText');
     var oRR=wc.roundRect,ownRR=Object.prototype.hasOwnProperty.call(wc,'roundRect');
     var bad=[],plates=[],texts=[],hud=[],toast,lift=null,stash=null,bar=null,j,z,k,st,R,cr,sc,tr,tb,i,pr,sg,hit,sizes={},w0,n0,cs,dbg=[];
     function inside(t,p){ return t.x>=p.x&&t.x<=p.x+p.w&&t.y>=p.y&&t.y<=p.y+p.h; }
     function gapOf(a,b){ var dx=Math.max(a.x-(b.x+b.w),b.x-(a.x+a.w),0), dy=Math.max(a.y-(b.y+b.h),b.y-(a.y+a.h),0); return Math.sqrt(dx*dx+dy*dy); }
     function frame(){ plates=[]; texts=[]; hud=[]; drawHubWorld(0.016); }
     function plateOf(re){ var a,b; for(a=0;a<texts.length;a++) if(re.test(texts[a].t)) for(b=0;b<plates.length;b++) if(inside(texts[a],plates[b])) return b; return -1; }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       NET.on=false; NET.same=0; keys={};
       if(!__hubEnter()||!HB) return 'no Undercroft';
       __topClear(); document.getElementById('title').classList.remove('on'); WNSEEN=1; HB.legend=false;
       toast=document.getElementById('hubtoast');
       for(j=0;j<HB.stations.length;j++){ if(HB.stations[j].id==='lift') lift=HB.stations[j]; if(HB.stations[j].id==='term') stash=HB.stations[j]; if(HB.stations[j].id==='bar') bar=HB.stations[j]; }
       if(!lift||!stash||!bar||!toast) return 'no lift, stash, bar or toast';
       wc.roundRect=function(x,y,w,h){ var m=wc.getTransform(); plates.push({x:m.a*x+m.e,y:m.d*y+m.f,w:m.a*w,h:m.d*h}); return oRR.apply(this,arguments); };
       wc.fillText=function(t,x,y){ var m=wc.getTransform(); texts.push({t:String(t).toLowerCase(),x:m.a*x+m.e,y:m.d*y+m.f}); return oWF.apply(this,arguments); };
       ctx.fillText=function(t,x,y){ var s=String(t), m=ctx.getTransform(), fs=parseFloat((/([0-9.]+)px/.exec(ctx.font)||[0,16])[1]); hud.push({t:s,x:m.a*x+m.e,y:m.d*y+m.f,w:ctx.measureText(s).width*m.a,fs:fs*m.a}); return oHF.apply(this,arguments); };
       hubToast('the welcome pack is in your stash.',120);
       for(z=0;z<2;z++){
         W=z?3840:1920; H=z?2160:1080; R=Math.max(1,hudRes());
         for(k=0;k<2;k++){
           st=k?stash:lift; HB.player.x=st.x; HB.player.y=st.y+25; HB.near=st;
           frame();
           cr=cv.getBoundingClientRect(); sc=cr.height/H; tr=toast.getBoundingClientRect();
           tb={x:(tr.left-cr.left)/sc,y:(tr.top-cr.top)/sc,w:tr.width/sc,h:tr.height/sc};
           if(!(tr.width>0)) { bad.push('toast has no box'); continue; }
           pr=null; for(i=0;i<hud.length;i++) if(hud[i].t.indexOf(st.label)>=0&&hud[i].t.charAt(0)==='[') pr={x:hud[i].x-hud[i].w/2,y:hud[i].y-hud[i].fs,w:hud[i].w,h:hud[i].fs*1.3};
           if(!pr) bad.push('no station prompt at '+st.id+' '+W);
           else if(gapOf(tb,pr)<24*R) bad.push('toast within '+Math.round(gapOf(tb,pr))+'px of the prompt at '+st.id+' '+W);
           i=plateOf(new RegExp('^'+stash.label.toLowerCase().replace(/[^a-z ]/g,'')+'$'));
           if(i<0) bad.push('no stash sign at '+st.id+' '+W);
           else if(gapOf(tb,plates[i])<24*R) bad.push('toast within '+Math.round(gapOf(tb,plates[i]))+'px of the stash sign at '+st.id+' '+W);
         }
       }
       W=oW; H=oH; R=Math.max(1,hudRes()); HB.player.x=bar.x; HB.player.y=bar.y+25; HB.near=bar; frame();
       i=plateOf(/^the last pour$/); j=plateOf(/experimental/);
       if(i<0||j<0||i!==j) bad.push('the experimental caption is not on the bar sign plate ('+i+','+j+')');
       _trLast=''; syncTopRight();
       w0=document.createTreeWalker(document.getElementById('topright'),NodeFilter.SHOW_TEXT,null,false);
       while((n0=w0.nextNode())){ if(n0.nodeValue.indexOf('$')<0) continue; cs=getComputedStyle(n0.parentNode); sizes[cs.fontSize+' '+cs.fontWeight]=1; }
       if(Object.keys(sizes).length!==1) bad.push('the $ values in the corner readout differ: '+Object.keys(sizes).join(' vs '));
       return bad.length?bad.join('; '):null;
     }finally{
       if(ownHF) ctx.fillText=oHF; else delete ctx.fillText;
       if(ownWF) wc.fillText=oWF; else delete wc.fillText;
       if(ownRR) wc.roundRect=oRR; else delete wc.roundRect;
       W=oW; H=oH; keys={}; WNSEEN=oWN; try{ HB.near=null; }catch(e){}
       try{ var tt=document.getElementById('hubtoast'); tt.classList.remove('on'); tt.classList.remove('hubslot'); }catch(e2){}
       __topClear(); NET.on=oOn; NET.same=oSame; keys=oKeys;
     }
   }},
  {v:'36.83',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
