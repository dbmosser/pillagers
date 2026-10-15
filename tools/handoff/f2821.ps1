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

if ($s.Contains("  {v:'28.21',what:")) { throw "check 28.21 is in the fixture already" }

SubRx @'
  {v:'28.20',what:
'@ @'
  {v:'28.21',what:'partyp3, his words on the combo ring (i did not notice it at all): the ring is bolder, its multiplier is a big number on a plate, the ring flashes outward when the chain grows, and in the last stretch of the chain it shifts toward red and flickers',
   run:function(){
     if(!(window.__state&&window.__endRaid&&window.__runPrep)) return 'SKIP: no raid here';
     if(typeof arcadeDeploy!=='function'||typeof ARCADE!=='object'||typeof styleDraw!=='function') return 'SKIP: no arcade here';
     var bad=[], g=null, p, own=false, rs=say, proto, oArc, oFt, z, xs, st, fr, lt, a0, a1, i, al=[], al2=[], px, d0;
     function num(s,k){ var m=String(s).match(/rgba?\(([^)]*)\)/); return m?parseFloat(m[1].split(',')[k]):NaN; }
     function grab(sT){
       var arcs=[], txts=[];
       ARCADE.streak={n:3,t:g.t-sT};
       proto.arc=function(){ arcs.push({x:arguments[0],y:arguments[1],r:arguments[2],a0:arguments[3],a1:arguments[4],lw:this.lineWidth,st:String(this.strokeStyle)}); return oArc.apply(this,arguments); };
       proto.fillText=function(){ txts.push({t:String(arguments[0]),f:String(this.font)}); return oFt.apply(this,arguments); };
       try{ styleDraw(ctx,p,640,360); } finally { proto.arc=oArc; proto.fillText=oFt; }
       return {arcs:arcs,txts:txts};
     }
     function maxR(o){ var m=0, j; for(j=0;j<o.arcs.length;j++) m=Math.max(m,o.arcs[j].r); return m; }
     try{
       __topClear(); __runPrep();
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       if(typeof STYR==='undefined') return 'there is no bold combo ring in this build';
       p=g.player; keys={}; say=function(){}; own=true; ARCADE.holdT=0; z=Math.max(1,hudRes()); xs=xhSize(); ARCADE.team=null;
       proto=CanvasRenderingContext2D.prototype; oArc=proto.arc; oFt=proto.fillText;
       st=grab(1.0);
       fr=st.arcs[st.arcs.length-1];
       // ONE: bold, and the sweep is the last arc
       if(!fr||fr.lw<5*z) bad.push('ONE: the sweep is only '+(fr?fr.lw.toFixed(1):'none')+' px wide ('+(5*z)+' needed)');
       else if(Math.abs((fr.a1-fr.a0)/6.2832-0.75)>0.03) bad.push('ONE: the sweep a chain three quarters spent shows '+((fr.a1-fr.a0)/6.2832).toFixed(2)+' of the ring, not 0.75');
       // TWO: the multiplier is a big number
       for(i=0,px=0;i<st.txts.length;i++) if(st.txts[i].t==='x3'){ px=parseFloat((st.txts[i].f.match(/([\d.]+)px/)||[0,0])[1]); }
       if(!(px>=22*z)) bad.push('TWO: the multiplier is printed at '+px+' px (22 needed)');
       // THREE: a chain that has just grown flashes outward past the ring (the flash ring starts ON the ring and opens outward over STYR.pulse, so it is read 0.3 s in, when it has opened about 10 px)
       fr=grab(0.3); if(!(maxR(fr)>=maxR(st)+8*z)) bad.push('THREE: a chain that just grew has no flash outward ('+maxR(fr).toFixed(1)+' against '+maxR(st).toFixed(1)+')');
       // FOUR: the last stretch is redder and flickers
       lt=grab(3.4); a0=num(lt.arcs[lt.arcs.length-1].st,1); a1=num(st.arcs[st.arcs.length-1].st,1);
       if(!(a0<=a1-20)) bad.push('FOUR: the sweep of a chain about to run out is not redder (green '+a0+' against '+a1+')');
       d0=g.t;
       for(i=0;i<8;i++){ g.t=d0+i*0.045; al.push(num(grab(3.4).arcs.slice(-1)[0].st,3)); al2.push(num(grab(1.0).arcs.slice(-1)[0].st,3)); }
       g.t=d0;
       if(!(Math.max.apply(null,al)-Math.min.apply(null,al)>=0.12)) bad.push('FOUR: the sweep of a chain about to run out does not flicker');
       if(Math.max.apply(null,al2)-Math.min.apply(null,al2)>0.01) bad.push('FOUR: the sweep of a healthy chain flickers');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       if(own) say=rs;
       try{ if(proto&&oArc) proto.arc=oArc; if(proto&&oFt) proto.fillText=oFt; }catch(_p){}
       keys={};
       try{ if(typeof ARCADE==='object'){ ARCADE.streak=null; ARCADE.team=null; if(ARCADE.on) arcadeLeave(); } }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ if(typeof ARCADE==='object'){ ARCADE.mine=0; ARCADE.waveT=0; ARCADE.holdT=0; } }catch(_h){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'28.20',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
