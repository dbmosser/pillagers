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

if ($s.Contains("  {v:'32.33',what:")) { throw "check 32.33 is in the fixture already" }

SubRx @'
  {v:'32.32',what:
'@ @'
  {v:'32.33',what:'cw-cx-mapquiet-o03: individual loot tags use muted medium type with 16px text clearance and 12px icon clearance, and contract tracks reach the common right edge below status',
   run:function(){
     var g, bad=[], ow=W, oh=H, os=MAPFIRST.skip, oldC=P.contracts, oldUS=P.uiScale, hadUS=Object.prototype.hasOwnProperty.call(P,'uiScale'), op=mapPlaceLabels, oi=mapIcon, PR=CanvasRenderingContext2D.prototype, of=PR.fillText, ofr=PR.fillRect,
         tags=[], all=[], icons=[], tracks=[], statuses=[], cd, z, pass, expected;
     function box(s,x,y){var fp=+((/([\d.]+)px/.exec(ctx.font)||[0,16])[1]);return mapLabelRect({x:x,y:y,w:ctx.measureText(typeof TX==='function'?TX(String(s)):String(s)).width,fp:fp,m:ctx.getTransform(),ta:ctx.textAlign,tb:ctx.textBaseline},0,0);}
     function gap(a,b){return Math.sqrt(Math.pow(Math.max(0,a.l-b.r,b.l-a.r),2)+Math.pow(Math.max(0,a.t-b.b,b.t-a.b),2));}
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile(); MAPFIRST.skip=1; __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state();if(!g||!g.player||g.over)return 'SKIP: no raid';g.mapOpen=true;g.mapFirst=0;g.paused=false;g.bagOpen=false;keys={};mouse.down=false;delete P.uiScale;
       P.contracts=[{type:'conduct',ck:'clean',n:1,prog:0,reward:450,desc:'x',tier:'std'},{type:'kill',tgt:'crawler',n:5,prog:3,reward:450,desc:'x',tier:'std'}];
       mapIcon=function(x,y,r){var m=ctx.getTransform();icons.push({l:(x-r)*m.a+m.e,t:(y-r)*m.d+m.f,r:(x+r)*m.a+m.e,b:(y+r)*m.d+m.f});return oi.apply(this,arguments);};
       mapPlaceLabels=function(Q,hdr,fn){return op(Q,hdr,function(s,x,y){var B=box(s,x,y);all.push(B);if(/^(cache|looted|strongbox)$/i.test(String(s)))tags.push({b:B,f:ctx.font,c:String(ctx.fillStyle).toLowerCase()});return (fn||of).call(ctx,s,x,y);});};
       PR.fillRect=function(x,y,w,h){if(cd&&cd.col&&String(this.fillStyle).toLowerCase()===String(UIC.ui_line_hi).toLowerCase()&&h>=2*z&&h<=8*z&&x>=cd.col.x-1&&y>=cd.col.y&&y<cd.col.y+cd.col.h)tracks.push({x:x,y:y,w:w,h:h});return ofr.apply(this,arguments);};
       PR.fillText=function(s,x,y){if(cd&&cd.col&&/^(holding|broken|ready|done|\d+\/\d+)$/i.test(String(s))&&Math.abs(x-(cd.col.x+cd.col.w-Math.round(20*cd.u)))<=z)statuses.push({b:box(s,x,y),x:x});return of.apply(this,arguments);};
       for(pass=0;pass<2;pass++){
         W=pass?3840:1920;H=pass?2160:1080;cd=mapCard();z=cd.z;tags=[];all=[];icons=[];tracks=[];statuses=[];__drawHUD();
         expected=g.containers.filter(function(c){return !!c.cache;}).length+g.containers.filter(function(c){return c.strong&&!c.opened;}).length;
         if(tags.length!==expected)bad.push('lost individual loot labels at '+H+'p');
         tags.forEach(function(T){
           if(T.c!==String(UIC.tx_2).toLowerCase()||!/^500 /.test(T.f))bad.push('loot tag is not medium tx-2');
           if(+((/([\d.]+)px/.exec(T.f)||[0,0])[1])<15.9*z)bad.push('loot tag below 16px floor');
           all.forEach(function(B){if(B!==T.b&&T.b.l<B.r+15.5*z&&B.l<T.b.r+15.5*z&&T.b.t<B.b+15.5*z&&B.t<T.b.b+15.5*z)bad.push('loot labels below 16px clearance at '+H+'p');});
           icons.forEach(function(I){if(gap(T.b,I)<11.5*z)bad.push('loot label crowds a map icon at '+H+'p');});
         });
         if(tracks.length!==mapContractRows().length||statuses.length!==tracks.length)bad.push('missing contract track or status');
         tracks.forEach(function(T,i){var S=statuses[i];if(S&&(Math.abs(T.x+T.w-S.x)>z||S.b.b>=T.y-2*z))bad.push('track does not align below contract status');});
       }
       return bad.length?bad.join('; '):null;
     }finally{
       mapPlaceLabels=op;mapIcon=oi;PR.fillText=of;PR.fillRect=ofr;W=ow;H=oh;MAPFIRST.skip=os;P.contracts=oldC;if(hadUS)P.uiScale=oldUS;else delete P.uiScale;keys={};mouse.down=false;
       try{if(g){g.mapOpen=false;g.mapFirst=0;}__endRaid('abandon');}catch(e){}__topClear();__resetCfg();__cleanProfile();
     }
   }},
  {v:'32.32',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
