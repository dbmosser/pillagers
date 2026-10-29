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

if ($s.Contains("  {v:'36.13',what:")) { throw "check 36.13 is in the fixture already" }

SubRx @'
  {v:'36.12',what:
'@ @'
  {v:'36.13',what:'named cache text stays inside a shared panel and 24px screen margins at 1080p and 4K',
   run:function(){
     var g,p,ct,PR=CanvasRenderingContext2D.prototype,of=PR.fillText,op=uiPanel,oldW=W,oldH=H,rec=null,pan=[],bad=[];
     try{
       __runPrep();__topClear();__resetCfg();__pinDefaults(0);__cleanProfile();__pinDPR(1);
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});g=__state();p=g.player;p.x=WORLD_W/2;p.y=WORLD_H/2;
       g.anchX=p.x;g.anchY=p.y;g.leanSX=0;g.leanSY=0;g.ents=[];g.zones=[];g.mapOpen=false;g.mapFirst=false;g.bagOpen=false;
       ct=mkContainer(p.x+100,p.y+100,'cache');ct.cache=1;ct.tag='the long dock cache';g.containers=[ct];
       PR.fillText=function(t,x,y){if(String(t).toLowerCase()===ct.tag&&(/_wtA/).test(String(new Error().stack))){var m=this.getTransform(),mt=this.measureText(t);rec={x:(m.e+(x-mt.width/2)*m.a)/DPRH,y:(m.f+(y-mt.actualBoundingBoxAscent)*m.d)/DPRH,w:mt.width*m.a/DPRH,h:(mt.actualBoundingBoxAscent+mt.actualBoundingBoxDescent)*m.d/DPRH,c:this.fillStyle};}return of.apply(this,arguments);};
       uiPanel=function(c,x,y,w,h){if((/_wtA/).test(String(new Error().stack))){var m=c.getTransform();pan.push({x:(m.e+x*m.a)/DPRH,y:(m.f+y*m.d)/DPRH,w:w*m.a/DPRH,h:h*m.d/DPRH});}return op.apply(this,arguments);};
       for(var r=0;r<2;r++){
         __forceSize(r?3840:1920,r?2160:1080);__frame(0);ct.x=WTX.ox+(W-3)/WTX.z;ct.y=p.y+100;rec=null;pan=[];__frame(0);
         var q=pan[0],margin=24*Math.max(1,hudRes());
         if(!rec||!q){bad.push('cache name/shared panel missing at '+W);continue;}
         if(q.x<margin-0.1||q.x+q.w>W-margin+0.1)bad.push('cache panel touches screen edge at '+W);
         if(rec.x<q.x+2||rec.x+rec.w>q.x+q.w-2||rec.y<q.y+2||rec.y+rec.h>q.y+q.h-2)bad.push('name not inside panel at '+W);
         if(rec.c!==UIC.tx_1)bad.push('cache text not high contrast at '+W);
       }
     }catch(e){bad.push('threw: '+(e.message||e));}
     finally{PR.fillText=of;uiPanel=op;try{__endRaid('abandon');}catch(_e){}__forceSize(oldW,oldH);__topClear();}
     return bad.length?bad.join('; '):null;
   }},
  {v:'36.12',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
