$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
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

# Menus ease open and the focus glides (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var SND_UI={move:{ty:'triangle',f1:2200,f2:2100,d:0.022,v:0.022},ok:{ty:'triangle',f1:660,f2:990,d:0.08,v:0.045},
  back:{ty:'triangle',f1:720,f2:440,d:0.08,v:0.04},deny:{ty:'square',f1:170,f2:140,d:0.12,v:0.03},

'@ @'
// v28.xx (cw-uimotion), UI STEP 2b (his words about Halo Reach, Halo 4, Diablo IV, ARC Raiders, Fortnite and Destiny 2 menus: "they are just reallly compelling and smooth"):
// ONE sound per event kind. The focus tick has four pitch variants (plus or minus 3 percent) and is capped at one per 40 ms; confirm is deeper,
// back lighter and shorter, deny a dull thud. uiSndPick decides which sound a kind makes, so it can be tested without audio.
var SND_UI_LOG=[], UI_TICK_P=[1,1.03,0.97,1.015];
var SND_UI={move:{ty:'triangle',f1:2200,f2:2100,d:0.022,v:0.022},ok:{ty:'triangle',f1:520,f2:780,d:0.09,v:0.05},
  back:{ty:'triangle',f1:600,f2:360,d:0.06,v:0.03},deny:{ty:'triangle',f1:150,f2:85,d:0.14,v:0.05},

'@

SubRx @'
function sndUi(kind){
  var K=SND_UI[kind], a, out, t, o, g;

'@ @'
function uiSndPick(kind,t,lastAt,n){
  var K=SND_UI[kind], gap, v, p;
  if(!K) return null;
  gap=(kind==='move')?0.04:0.03;
  if(t-lastAt<gap&&t>=lastAt) return null;   // the focus tick: at most one per 40 ms; any other sound: one action, one sound
  v=(kind==='move')?(n%4):0; p=(kind==='move')?UI_TICK_P[v]:1;
  return {kind:kind,ty:K.ty,f1:K.f1*p,f2:K.f2*p,d:K.d,v:K.v,variant:v,pitch:p};
}
function sndUi(kind){
  var K=SND_UI[kind], a, out, t, o, g;

'@

SubRx @'
  if(t-SND_UI_AT<0.03&&t>=SND_UI_AT) return false;   // one action, one sound: a press that also shuts a window plays once
  SND_UI_LAST=kind; SND_UI_AT=t; SND_UI_N++;

'@ @'
  K=uiSndPick(kind,t,SND_UI_AT,SND_UI_N); if(!K) return false;   // v28.xx (cw-uimotion): one action, one sound; a tick at most every 40 ms, four pitches
  SND_UI_LAST=kind; SND_UI_AT=t; SND_UI_N++;
  try{ SND_UI_LOG.push({kind:kind,t:t,pitch:K.pitch,variant:K.variant}); if(SND_UI_LOG.length>200) SND_UI_LOG.shift(); }catch(_ul){}

'@

SubRx @'
  if(el.disabled||(el.classList&&(el.classList.contains('locked')||el.classList.contains('dim')))){ sndUi('deny'); return; }

'@ @'
  if(el.disabled||(el.classList&&(el.classList.contains('locked')||el.classList.contains('dim')))){ try{ UIM.press(el,'deny'); }catch(_um){} sndUi('deny'); return; }   // v28.xx (cw-uimotion): a refused press shakes 6 px over 100 ms

'@

SubRx @'
  sndUi(/^(close|leave|back|cancel|not yet|keep my kit)/i.test(tx)?'back':'ok');

'@ @'
  try{ UIM.press(el,'ok'); }catch(_um){}   // v28.xx (cw-uimotion): a press pulses 6 percent over 120 ms
  sndUi(/^(close|leave|back|cancel|not yet|keep my kit)/i.test(tx)?'back':'ok');

'@

SubRx @'
  if(el!==old){ try{ sndUi('move'); }catch(_su){} }   // v24.49 (his #45): the highlight ticks as it moves

'@ @'
  if(el!==old){ try{ sndUi('move'); }catch(_su){} }   // v24.49 (his #45): the highlight ticks as it moves
  try{ UIM.focus(el,old); }catch(_um){}   // v28.xx (cw-uimotion): the focus ring eases to its target, the focused cell grows to 1.05

'@

SubRx @'
    a.ph=ph; pg.textContent='';

'@ @'
    a.ph=ph; try{ UIM.tabOut(pg,1); }catch(_um){} pg.textContent='';   // v28.xx (cw-uimotion): the old page slides out as the new one slides in

'@

SubRx @'
    pg.setAttribute('data-ph',ph);

'@ @'
    pg.setAttribute('data-ph',ph);
    try{ UIM.tab(pg,1); }catch(_um){}   // v28.xx (cw-uimotion): tab change, 200 ms cross-fade and a 24 px slide

'@

SubRx @'
  button:disabled.padfocus, .vcell.locked.padfocus{ opacity:.55 !important; }

'@ @'
  button:disabled.padfocus, .vcell.locked.padfocus{ opacity:.55 !important; }
  /* v28.xx (cw-uimotion): an element the UI motion layer is moving is driven by its clock, so a CSS transition never runs behind it */
  .uimx{ transition:none !important; }

'@

SubRx @'
})();
document.addEventListener('wheel',function(e){

'@ @'
})();
// v28.xx (cw-uimotion), UI STEP 2b: SMOOTH. His words about the menus of Halo Reach, Halo 4, Diablo IV, ARC Raiders, Fortnite and Destiny 2:
// "I cant exactly tell you why they are so good, they are just reallly compelling and smooth". ONE motion layer for menus, on a clock of its own
// (UIM.t, in ms, advanced by real frame time, or by UIM.step in a test, never by counting frames). Open 240 ms ease-out (alpha 0 to 1, 16 px rise),
// each item after it 35 ms apart (at most 8, so 485 ms in all), close 140 ms ease-in with no stagger, tab change 200 ms with a 24 px slide, focus
// ring x += (target-x)*(1-exp(-dt/40ms)) (95 percent in 120 ms), the focused cell grows to 1.05, a press pulses 1+.06*sin(pi*t) over 120 ms, a
// refused press shakes 6 px over 100 ms. A press or a close during a move RETARGETS from the value it has now (smoothstep, shorter for what is left),
// so nothing is ignored or restarted. Only the title menu and the party window are on it so far (UIM.scope); the values are written as the CSS
// properties opacity, translate and scale, which compose with every transform the menus already use. Menus only: no raid value is touched.
var UIM={manual:false,t:0,last:0,raf:0,logOn:false,log:[],st:[],scope:'#title,#partymodal',ring:null,rg:{on:0,x:0,y:0,w:0,h:0},fel:null};
UIM.E={out:function(u){ u=1-u; return 1-u*u*u; },inn:function(u){ return u*u; },sm:function(u){ return u*u*(3-2*u); }};
UIM.S=function(el){
  var s=el.__uim, b=1;
  if(!s){
    try{ b=parseFloat(getComputedStyle(el).opacity); }catch(_b){}
    s={el:el,a:1,x:0,y:0,s:1,sT:1,f:{},fx:null,w:'',kids:null,closing:0,base:(b>=0&&b<=1)?b:1};
    el.__uim=s; UIM.st.push(s);
  }
  return s;
};
UIM.go=function(el,fld,to,dur,ease,o){
  var s=UIM.S(el), cur=s[fld], f=s.f[fld], full=(o&&o.full)||0, dl=(o&&o.delay)||0, d=dur, k;
  if(f&&f.on&&!dl){ ease='sm'; if(full){ k=Math.min(1,Math.abs(to-cur)/Math.abs(full)); d=Math.max(80,dur*k); } }   // a press mid-move retargets from where it is
  s.f[fld]={on:1,from:cur,to:to,t0:UIM.t+dl,d:d,e:ease,cb:(o&&o.cb)||null};
  UIM.wake();
  return s;
};
UIM.clear=function(s){
  var el=s.el, i;
  try{ el.style.opacity=''; el.style.translate=''; el.style.scale=''; el.classList.remove('uimx'); }catch(_c){}
  el.__uim=null; i=UIM.st.indexOf(s); if(i>=0) UIM.st.splice(i,1);
};
UIM.paint=function(s){
  var el=s.el, p=0, sh=0, u, sc, w, fld, anim=false, tx;
  if(el.__uim!==s) return;
  if(s.fx){ u=(UIM.t-s.fx.t0)/s.fx.d; if(u>=1) s.fx=null; else if(u>0){ if(s.fx.k==='pulse') p=0.06*Math.sin(Math.PI*u); else sh=6*(1-u)*Math.sin(u*6*Math.PI); } }
  for(fld in s.f){ if(s.f[fld].on){ anim=true; break; } }
  if(!anim&&!s.fx&&s.a===1&&s.x===0&&s.y===0&&s.s===1&&s.sT===1){ UIM.clear(s); return; }
  sc=s.s*(1+p); tx=s.x+sh;
  w=s.a+'|'+tx+'|'+s.y+'|'+sc;
  if(w===s.w) return;
  s.w=w;
  if(!el.classList.contains('uimx')) el.classList.add('uimx');
  el.style.opacity=(s.a===1)?'':String(Math.round(s.a*s.base*1000)/1000);
  el.style.translate=(tx||s.y)?(tx.toFixed(2)+'px '+s.y.toFixed(2)+'px'):'';
  el.style.scale=(sc!==1)?sc.toFixed(4):'';
};
UIM.mkRing=function(){
  var r=UIM.ring;
  if(r&&r.isConnected) return r;
  r=document.createElement('div'); r.id='uimring';
  r.style.cssText='position:fixed;left:0;top:0;pointer-events:none;z-index:99999;box-sizing:border-box;border:2px solid #f5b73b;border-radius:6px;box-shadow:0 0 14px 2px rgba(245,183,59,.4);display:none;will-change:transform';
  document.body.appendChild(r); UIM.ring=r;
  return r;
};
UIM.ringHide=function(){ UIM.rg.on=0; if(UIM.ring) UIM.ring.style.display='none'; };
UIM.unfocus=function(){ var e=UIM.fel; if(e&&e.__uim) e.__uim.sT=1; UIM.fel=null; UIM.ringHide(); };
UIM.ringStep=function(dt){
  var el=UIM.fel, g=UIM.rg, rc, k, r;
  if(el&&(!el.isConnected||!el.classList.contains('padfocus'))){ UIM.unfocus(); el=null; }
  if(!el){ if(g.on) UIM.ringHide(); return; }
  rc=el.getBoundingClientRect();
  if(!(rc.width>0&&rc.height>0)){ UIM.ringHide(); return; }
  r=UIM.mkRing();
  if(!g.on){ g.x=rc.left; g.y=rc.top; g.w=rc.width; g.h=rc.height; g.on=1; r.style.display='block'; }
  else { k=1-Math.exp(-dt/40); g.x+=(rc.left-g.x)*k; g.y+=(rc.top-g.y)*k; g.w+=(rc.width-g.w)*k; g.h+=(rc.height-g.h)*k; }
  r.style.width=(g.w+12).toFixed(2)+'px'; r.style.height=(g.h+12).toFixed(2)+'px';
  r.style.transform='translate('+(g.x-6).toFixed(2)+'px,'+(g.y-6).toFixed(2)+'px)';
};
UIM.step=function(dt){
  var i, s, fld, f, u, c, k, e;
  if(!(dt>0)) dt=0;
  UIM.t+=dt;
  k=1-Math.exp(-dt/40);
  for(i=UIM.st.length-1;i>=0;i--){
    s=UIM.st[i]; if(!s) continue;
    for(fld in s.f){
      f=s.f[fld]; if(!f.on) continue;
      u=(UIM.t-f.t0)/f.d;
      if(u<=0) s[fld]=f.from;
      else if(u>=1){ s[fld]=f.to; f.on=0; if(f.cb){ c=f.cb; f.cb=null; try{ c(s); }catch(_cb){} } }
      else s[fld]=f.from+(f.to-f.from)*UIM.E[f.e](u);
    }
    s.s+=(s.sT-s.s)*k; if(Math.abs(s.sT-s.s)<0.0005) s.s=s.sT;
    UIM.paint(s);
  }
  UIM.ringStep(dt);
  if(UIM.logOn){
    for(i=0;i<UIM.st.length;i++){ s=UIM.st[i]; e=s.el; UIM.log.push({t:UIM.t,id:e.id||String(e.className||e.tagName),a:s.a,x:s.x,y:s.y,s:s.s}); }
    if(UIM.log.length>4000) UIM.log.splice(0,UIM.log.length-4000);
  }
  return UIM.t;
};
UIM.busy=function(){ return UIM.st.length>0||!!UIM.fel; };
UIM.loop=function(ts){
  var dt;
  UIM.raf=0; if(UIM.manual) return;
  dt=UIM.last?Math.min(100,ts-UIM.last):16.7; UIM.last=ts;
  UIM.step(dt);
  if(UIM.busy()) UIM.raf=requestAnimationFrame(UIM.loop); else UIM.last=0;
};
UIM.wake=function(){ if(UIM.manual||UIM.raf) return; UIM.last=0; UIM.raf=requestAnimationFrame(UIM.loop); };
UIM.inScope=function(el){ try{ return !!(el&&el.closest&&el.closest(UIM.scope)); }catch(_i){ return false; } };
UIM.kids=function(el){
  var q=(el.id==='title')?el.querySelectorAll('#modemenu > *'):el.children, r=[], i;
  for(i=0;i<q.length;i++){ if(getComputedStyle(q[i]).display!=='none') r.push(q[i]); }
  return r;
};
UIM.open=function(el){
  var s=el.__uim, busy=!!(s&&((s.f.a&&s.f.a.on)||(s.f.y&&s.f.y.on))), kids, i, q;
  if(!s) s=UIM.S(el);
  if(s.closing){ s.closing=0; el.style.display=''; el.style.pointerEvents=''; }
  if(!busy){ s.a=0; s.y=16; }
  UIM.go(el,'a',1,240,'out',{full:1}); UIM.go(el,'y',0,240,'out',{full:16});
  if(!busy){
    kids=UIM.kids(el); s.kids=kids;
    for(i=0;i<kids.length&&i<8;i++){ q=UIM.S(kids[i]); q.a=0; q.y=12; UIM.go(kids[i],'a',1,240,'out',{delay:i*35}); UIM.go(kids[i],'y',0,240,'out',{delay:i*35}); UIM.paint(q); }
  }
  UIM.paint(s);
};
UIM.close=function(el){
  var s=UIM.S(el);
  s.closing=1; el.style.display='flex'; el.style.pointerEvents='none';
  UIM.go(el,'a',0,140,'inn',{full:1,cb:function(q){ q.closing=0; el.style.display=''; el.style.pointerEvents=''; UIM.clear(q); }});
  UIM.go(el,'y',8,140,'inn',{full:8});
  UIM.paint(s);
};
UIM.reset=function(el){
  var s=el.__uim, i, k;
  if(!s) return;
  if(s.kids){ for(i=0;i<s.kids.length;i++){ k=s.kids[i].__uim; if(k) UIM.clear(k); } }
  if(s.closing){ s.closing=0; el.style.display=''; el.style.pointerEvents=''; }
  UIM.clear(s);
};
UIM.clearAll=function(){
  var i, s;
  for(i=UIM.st.length-1;i>=0;i--){ s=UIM.st[i]; if(s){ if(s.closing){ s.closing=0; s.el.style.display=''; s.el.style.pointerEvents=''; } UIM.clear(s); } }
  UIM.unfocus();
};
UIM.chg=function(el){
  var on=el.classList.contains('on'), modal=(el.id!=='title');
  if(on===!!el.__uimOn) return;
  el.__uimOn=on;
  if(on){ UIM.open(el); if(modal){ try{ sndUi('open'); }catch(_s){} } }
  else if(modal){ UIM.close(el); try{ sndUi('close'); }catch(_s){} }
  else UIM.reset(el);
};
UIM.watch=function(el){
  if(!el) return;
  el.__uimOn=el.classList.contains('on');
  try{ new MutationObserver(function(){ UIM.chg(el); }).observe(el,{attributes:true,attributeFilter:['class']}); }catch(_w){}
};
UIM.tab=function(pg,dir){
  var s=pg.__uim, busy=!!(s&&((s.f.a&&s.f.a.on)||(s.f.x&&s.f.x.on)));
  s=UIM.S(pg);
  if(!busy){ s.a=0; s.x=24*dir; }
  UIM.go(pg,'a',1,200,'out',{full:1}); UIM.go(pg,'x',0,200,'out',{full:24});
  UIM.paint(s);
};
UIM.tabOut=function(pg,dir){
  var g, s;
  if(!pg||!pg.parentNode||pg.style.display==='none'||!pg.firstChild) return;
  g=pg.cloneNode(true); g.removeAttribute('id'); g.classList.add('uimghost');
  g.style.pointerEvents='none'; g.style.opacity=''; g.style.translate=''; g.style.scale='';
  pg.parentNode.appendChild(g);
  s=UIM.S(g); s.base=1;
  UIM.go(g,'a',0,200,'out',{full:1,cb:function(q){ try{ if(g.parentNode) g.parentNode.removeChild(g); }catch(_r){} UIM.clear(q); }});
  UIM.go(g,'x',-24*dir,200,'out',{full:24});
  UIM.paint(s);
};
UIM.press=function(el,kind){
  var s;
  if(!el||!UIM.inScope(el)) return;
  s=UIM.S(el); s.fx={k:(kind==='deny')?'shake':'pulse',t0:UIM.t,d:(kind==='deny')?100:120};
  UIM.wake();
};
UIM.focus=function(el,old){
  if(old&&old!==el&&old.__uim){ old.__uim.sT=1; UIM.wake(); }
  if(el&&UIM.inScope(el)){ UIM.S(el).sT=1.05; UIM.fel=el; UIM.wake(); }
  else if(UIM.fel) UIM.unfocus();
};
UIM.watch(document.getElementById('title')); UIM.watch(document.getElementById('partymodal'));document.addEventListener('wheel',function(e){

'@

SubRx @'
var VER='29.59';
'@ @'
var VER='29.60';
'@

$pat = "(?m)^  now:'v29\.59:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.60: Menus now ease open, the focus glides to each button, and every press has its own small sound. Check 29.60 fails on v29.59',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
