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

if ($s.Contains("  {v:'22.91',what:")) { throw "check 22.91 is in the fixture already" }

SubRx @'
  {v:'22.90',what:
'@ @'
  {v:'22.91',what:'the offer line and the use bar caption grow at 4K: at 3840x2160 the offer line and APPLYING BANDAGE are drawn at least 1.9 times their 1080p font size, and HUDGIFTB is the bottom of the grown offer plate',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__textTrace)||typeof drawGiftLine!=='function'||typeof drawUseBar!=='function'||typeof hudRes!=='function') return 'SKIP: no offer line or use bar here';
     var bad=[], g=null, p=null, W0=W, H0=H, own=Object.prototype.hasOwnProperty.call(ctx,'fillRect'), oFR=ctx.fillRect, a, b, r4;
     function grab(w,h){
       var out={offer:0,use:0,gb:0,plate:null}, last=null, tr, i, s;
       W=w; H=h;
       g.giftIn={id:'zq40',k:'bandage',from:1,t:g.t}; g.giftOut=null;
       p.prep={t:0.5,max:1.5,kind:'heal',key:'bandage'}; p.prepA=null;
       ctx.fillRect=function(x,y,ww,hh){ var m=ctx.getTransform(); last=m.b*x+m.d*(y+hh)+m.f; return oFR.apply(this,arguments); };
       try{
         tr=__textTrace(function(){ ctx.save(); ctx.setTransform(1,0,0,1,0,0); try{ last=null; drawGiftLine(); out.gb=HUDGIFTB; out.plate=last; drawUseBar(); } finally { ctx.restore(); } });
       } finally { if(own) ctx.fillRect=oFR; else delete ctx.fillRect; }
       for(i=0;i<tr.length;i++){ s=tr[i].t; if(s.indexOf(' offers you ')>0&&!out.offer) out.offer=tr[i].px; if(s.indexOf('APPLYING ')===0&&!out.use) out.use=tr[i].px; }
       return out;
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       p=g.player; g.bagOpen=false; g.mapOpen=false; g.emoteBar=null;
       a=grab(1920,1080);
       b=grab(3840,2160); r4=hudRes();
       if(!(r4>1.5)) return 'SKIP: staging: the screen factor did not rise';
       if(!a.offer||!b.offer) return 'SKIP: staging: the offer line was not drawn';
       if(!a.use||!b.use) return 'SKIP: staging: the use bar caption was not drawn';
       if(b.offer<a.offer*1.9) bad.push('at 4K the offer line is '+b.offer.toFixed(1)+' px against '+a.offer.toFixed(1)+' px at 1080p');
       if(b.use<a.use*1.9) bad.push('at 4K the use bar caption is '+b.use.toFixed(1)+' px against '+a.use.toFixed(1)+' px at 1080p');
       if(typeof b.plate!=='number'||Math.abs(b.gb-b.plate)>1.5) bad.push('at 4K HUDGIFTB is '+b.gb+' while the offer plate ends at '+(typeof b.plate==='number'?Math.round(b.plate):'nothing'));
       if(typeof a.plate!=='number'||Math.abs(a.gb-a.plate)>1.5) bad.push('control: at 1080p HUDGIFTB is '+a.gb+' while the offer plate ends at '+(typeof a.plate==='number'?Math.round(a.plate):'nothing'));
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       W=W0; H=H0;
       if(own) ctx.fillRect=oFR; else delete ctx.fillRect;
       try{ var g2=__state(); if(g2){ g2.giftIn=null; g2.giftOut=null; if(g2.player){ g2.player.prep=null; g2.player.prepA=null; } if(!g2.over){ g2.player.downed=false; __endRaid('abandon'); } } }catch(_e){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'22.90',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
