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

if ($s.Contains("  {v:'34.00',what:")) { throw "check 34.00 is in the fixture already" }

SubRx @'
  {v:'33.99',what:
'@ @'
  {v:'34.00',what:'hub floor plates have cream station names and 16px side padding; title has a plate; toast clears hint chips and focused prompt at 1080p and 4K',
   run:function(){
     if(typeof hubSignPlate!=='function') return 'station plates still have cramped sides and no border';
     var oW=wc.fillText,oRect=wc.fillRect,oPanel=uiPanel,oC=ctx.fillText,wn=WNSEEN,near,legend;
     var toast=document.getElementById('hubtoast'),ts=toast.style.cssText,tc=toast.className,tt=toast.textContent;
     var signs=[],last=null,hints=null,heading=null,nearTop=null;
     function size(c){return parseFloat((/([\d.]+)px/.exec(c.font)||[0,0])[1]);}
     try{
       __runPrep();__topClear();__resetCfg();__pinDefaults(0);__cleanProfile();
       __forceSize(1920,1080);applyMenuZoom();__hubEnter();__topClear();
       document.getElementById('title').classList.remove('on');WNSEEN=1;
       near=HB.near;legend=HB.legend;HB.near=null;HB.legend=false;__loop(performance.now());HB.near=null;
       wc.fillRect=function(x,y,w,h){last={x:x,y:y,w:w,h:h};return oRect.apply(this,arguments);};
       wc.fillText=function(s,x,y){signs.push({s:String(s),x:x,y:y,w:wc.measureText(s).width,c:wc.fillStyle,plate:last});return oW.apply(this,arguments);};
       var S=hubScale(),R=Math.max(1,hudRes());
       wc.save();wc.setTransform(1,0,0,1,0,0);try{hubStationNames(S,0,0);}finally{wc.restore();}
       for(var i=0;i<HB.stations.length;i++){
         var st=HB.stations[i],a=signs.filter(function(s){return s.s===st.label;})[0];
         if(!a||!a.plate) return 'missing plate: '+st.id;
         if(st.id!=='lift'&&a.c!==UIC.tx_1) return 'station lacks cream contrast: '+st.id;
         if(a.plate.w-a.w<31.5*R/S) return 'station has less than 16px side padding: '+st.id;
       }
       uiPanel=function(c,x,y,w,h){if(c===ctx){if(Math.abs(h-44*Math.max(1,hudRes()))<.1) hints={x:x,y:y,w:w,h:h};if(h===72)heading={x:x,y:y,w:w,h:h};}return oPanel.apply(this,arguments);};
       ctx.fillText=function(s,x,y){if(HB.near&&String(s).indexOf('[')===0)nearTop=y-size(ctx);return oC.apply(this,arguments);};
       for(var k=0;k<2;k++){
         if(k){__forceSize(3840,2160);applyMenuZoom();__loop(performance.now()+17);}
         for(var n=0;n<2;n++){
           HB.near=n?HB.stations[0]:null;hints=null;heading=null;nearTop=null;
           toast.textContent='welcome pack';toast.classList.add('on');drawHubHUD(0,0);
           R=Math.max(1,hudRes());var cr=cv.getBoundingClientRect(),scale=cr.height/H,tr=toast.getBoundingClientRect();
           if(!hints||!heading) return 'missing hint row or title plate';
           if(tr.bottom>cr.top+hints.y*scale-8*R*scale+.5) return 'toast overlaps hints at '+W;
           if(n&&nearTop!==null&&tr.bottom>cr.top+nearTop*scale-8*R*scale+.5) return 'toast overlaps focused station at '+W;
           var top=H;(HUBBELT.cells||[]).forEach(function(c){top=Math.min(top,c.y);});
           if(hints.y+hints.h>top-8*R+.5) return 'hint plate overlaps belt at '+W;
         }
       }
       return null;
     }finally{
       wc.fillText=oW;wc.fillRect=oRect;uiPanel=oPanel;ctx.fillText=oC;WNSEEN=wn;
       if(HB){HB.near=near;HB.legend=legend;}
       try{__endRaid('abandon');}catch(e){}__topClear();__forceSize(1920,1080);applyMenuZoom();
       toast.style.cssText=ts;toast.className=tc;toast.textContent=tt;
     }
   }},
  {v:'33.99',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
