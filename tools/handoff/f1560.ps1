$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

SubRx @'
  {v:'15.59',what:
'@ @'
  {v:'15.60',what:'on a controller the Undercroft bottom line names the pad buttons: on the floor at the lift with no controller the line along the bottom reads WASD WALK, SHIFT JOG and E USE STATION, and with a faked controller connected, while the station prompt in the same frame reads [A], the same line reads L STICK WALK, LS JOG and A USE STATION and names no WASD, SHIFT or E, and with the controller gone again it is the keyboard line word for word (first run audit finding)',
   run:function(){
     if(!window.__hubEnter) return 'SKIP: this fixture cannot reach the Undercroft floor';
     if(typeof pollPad!=='function'||typeof drawHubHUD!=='function'||typeof padOn!=='function'||typeof keyLabel!=='function') return 'SKIP: no pad poll, pad labels or floor HUD draw in this build';
     if(typeof ctx==='undefined'||!ctx||typeof PAD==='undefined'||!PAD) return 'SKIP: no HUD canvas or pad state in this build';
     if(typeof G!=='undefined'&&G&&G.sim) return 'SKIP: a sim is running';
     var NG=navigator.getGamepads;
     if(typeof NG!=='function') return 'SKIP: this browser has no pad interface to fake';
     var bad=[], stubbed=false, got=[], realFill=null, ownFill=false, keep=null;
     var annWas=PAD.announced, wnWas=(typeof WNSEEN!=='undefined')?WNSEEN:null, curWas=(typeof _curNow!=='undefined')?_curNow:null, cursorWas=null;
     try{ cursorWas=cv.style.cursor; }catch(_cw){}
     // The keyboard line is text the check must find; the words the pad line must not draw are assembled from pieces.
     var DOT='  \u00b7  ', KBD=['WASD WALK','SHIFT JOG','E USE STATION'].join(DOT);
     var EN=['E',' USE',' STATION'].join(''), AN=['A',' USE',' STATION'].join(''), WN=['WA','SD'].join(''), SN=['SHI','FT'].join('');
     try{ navigator.getGamepads=function(){ return []; }; stubbed=(navigator.getGamepads!==NG); }catch(_s){}
     if(!stubbed){ try{ navigator.getGamepads=NG; }catch(_r0){} return 'SKIP: this browser will not let the pad be faked'; }
     function padIdle(){
       var bts=[],i;
       for(i=0;i<17;i++) bts.push({pressed:false,value:0,touched:false});
       var fake={connected:true,id:'probe pad',index:0,mapping:'standard',timestamp:1,axes:[0,0,0,0],buttons:bts};
       navigator.getGamepads=function(){ return [fake]; };
     }
     // One floor HUD frame: the words drawn along the bottom of the floor, and the station prompt above them.
     function frame(){
       got=[]; drawHubHUD(0,0);
       var r={foot:[],prompt:[]};
       for(var k=0;k<got.length;k++){
         if(got[k].y===H-16) r.foot.push(got[k].t);
         else if(got[k].y===H-58) r.prompt.push(got[k].t);
       }
       return r;
     }
     function any(list,w){ for(var k=0;k<list.length;k++) if(list[k].indexOf(w)>=0) return true; return false; }
     try{
       __topClear(); __cleanProfile(); __hubEnter();
       if(typeof state==='undefined'||state!=='hub'||!HB||!HB.player||!HB.stations||!HB.stations.length) return 'SKIP: the Undercroft floor did not open with its stations';
       [].forEach.call(document.querySelectorAll('.modal.on'),function(x){ x.classList.remove('on'); });   // a fresh profile opens the welcome window
       keep={near:HB.near,legend:HB.legend};
       var st=null;
       for(var i=0;i<HB.stations.length;i++) if(HB.stations[i]&&HB.stations[i].id==='lift'){ st=HB.stations[i]; break; }
       if(!st) st=HB.stations[0];
       // The lift in front of him, the H controls panel shut and the what is new card counted as seen, so only the prompt
       // and the bottom line are drawn where the check reads.
       HB.near=st; HB.legend=false;
       if(wnWas!==null) WNSEEN=1;
       ownFill=Object.prototype.hasOwnProperty.call(ctx,'fillText');
       realFill=ctx.fillText;
       ctx.fillText=function(t,x,y){ got.push({t:String(t),y:y}); return realFill.apply(this,arguments); };
       // CONTROL: no controller, and the bottom line is the keyboard line and the prompt says [E], on either build.
       navigator.getGamepads=function(){ return []; }; pollPad();
       if(padOn()) return 'SKIP: the pad still reads as connected with no controller faked here';
       var k0=frame();
       if(!k0.foot.length) return 'SKIP: the floor HUD drew nothing along the bottom of the floor here';
       if(k0.foot.indexOf(KBD)<0) return 'SKIP: with no controller the bottom of the floor read "'+k0.foot.join(' | ')+'" rather than the keyboard line, so the line cannot be found here';
       if(!k0.prompt.length||k0.prompt[0].indexOf('[E]')!==0) return 'SKIP: with no controller and the lift in front of him the station prompt read "'+k0.prompt.join(' | ')+'" rather than starting [E] here';
       // A faked controller, every button up and the sticks at rest, polled on the floor.
       padIdle(); pollPad();
       if(!padOn()) return 'SKIP: the faked controller did not register here';
       var p1=frame();
       // CONTROL: the station prompt in the same frame follows the controller, so the pad is seen and the floor button table is live.
       if(!p1.prompt.length||p1.prompt[0].indexOf('[A]')!==0) return 'SKIP: with the faked controller on, the station prompt read "'+p1.prompt.join(' | ')+'" rather than starting [A], so the floor button table is not live here';
       if(!p1.foot.length) bad.push('with a controller on the floor nothing was drawn along the bottom of the floor');
       else {
         var line=p1.foot.join(' | ');
         if(any(p1.foot,EN)||any(p1.foot,WN)||any(p1.foot,SN)) bad.push('with a controller on the floor and the station prompt reading [A], the bottom line still reads "'+line+'", keys a controller does not have');
         if(!any(p1.foot,AN)||!any(p1.foot,'L STICK')||!any(p1.foot,'LS JOG')) bad.push('with a controller on the floor the bottom line reads "'+line+'" rather than naming L STICK to walk, LS to jog and A to use a station');
       }
       // CONTROL: the controller gone again, and the keyboard line is back word for word.
       navigator.getGamepads=function(){ return []; }; pollPad();
       if(padOn()) bad.push('the pad still read as connected after the faked controller was taken away');
       else {
         var k1=frame();
         if(k1.foot.indexOf(KBD)<0) bad.push('with the controller taken away the bottom of the floor read "'+k1.foot.join(' | ')+'" rather than the keyboard line');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(realFill){ if(ownFill) ctx.fillText=realFill; else delete ctx.fillText; } }catch(_f){}
       try{ navigator.getGamepads=function(){ return []; }; pollPad(); }catch(_p0){}
       try{ navigator.getGamepads=NG; }catch(_p){}
       try{ PAD.announced=annWas; }catch(_a){}
       try{ if(keep&&HB){ HB.near=keep.near; HB.legend=keep.legend; } }catch(_h){}
       try{ if(wnWas!==null) WNSEEN=wnWas; }catch(_w){}
       try{ if(curWas!==null) _curNow=curWas; if(cursorWas!==null) cv.style.cursor=cursorWas; }catch(_cu){}
       try{ var K3=__keysRef(); for(var k3 in K3) K3[k3]=false; }catch(_k){}
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'15.59',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
