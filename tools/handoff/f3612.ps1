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

if ($s.Contains("  {v:'36.12',what:")) { throw "check 36.12 is in the fixture already" }

SubRx @'
  {v:'36.11',what:
'@ @'
  {v:'36.12',what:'adjacent machine tags stack with crew and health space; the edge extraction chip clears the actual named cache at 1080p and 4K',
   run:function(){
     var PR=CanvasRenderingContext2D.prototype, of=PR.fillText, oc=canSee, g=null,p,ct,a,b,rec={},bad=[],oldW=W,oldH=H,on=NET.on;
     function overlap(a,b){return a.x<b.x+b.w&&a.x+a.w>b.x&&a.y<b.y+b.h&&a.y+a.h>b.y;}
     try{
       __runPrep();__topClear();__resetCfg();__pinDefaults(0);__cleanProfile();__pinDPR(1);NET.on=false;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});g=__state();p=g.player;p.iv=999;p.x=WORLD_W/2;p.y=WORLD_H/2;
       g.mapOpen=false;g.mapFirst=false;g.bagOpen=false;g.paused=false;keys={};mouse.down=false;g.zones=[];
       g.anchX=p.x;g.anchY=p.y;g.leanSX=0;g.leanSY=0;g.shake=0;GFX.sx=0;GFX.sy=0;
       canSee=function(){return true;};
       a=mkCrawler(p.x+125,p.y+70);b=mkCrawler(a.x+a.r*2,a.y);
       a.name='crawler c-73';b.name='crawler c-74';a.state=b.state='patrol';a.hp=a.maxhp-1;b.hp=b.maxhp-1;g.ents=[a,b];
       ct=mkContainer(p.x+160,p.y+160,'cache');ct.cache=1;ct.tag='the long dock cache';g.containers=[ct];
       PR.fillText=function(t,x,y){
         var s=String(t).toLowerCase();
         if((s===a.name||s===b.name||s===ct.tag)&&(/_wtA/).test(String(new Error().stack))){
           var m=this.getTransform(), z=m.a/DPRH, w=this.measureText(t).width, ph=Math.ceil(parseFloat((this.font.match(/([\d.]+)px/)||[0,12])[1])*1.35), mt=this.measureText(t);
           rec[s]=s===ct.tag?{x:(m.e+(x-w/2-2)*m.a)/DPRH,y:(m.f+(y-(mt.actualBoundingBoxAscent||ph)-2)*m.d)/DPRH,w:(w+4)*z,h:((mt.actualBoundingBoxAscent||ph)+(mt.actualBoundingBoxDescent||ph*0.25)+4)*z}:
             {x:(m.e+(x-11)*m.a)/DPRH,y:(m.f+(y-ph+3)*m.d)/DPRH,w:(w+22)*z,h:(ph+5)*z};
         }
         return of.apply(this,arguments);
       };
       for(var r=0;r<2;r++){
         __forceSize(r?3840:1920,r?2160:1080);rec={};__frame(0);__frame(0);
         if(!rec[a.name]||!rec[b.name]){bad.push('missing adjacent names at '+W);continue;}
         if(overlap(rec[a.name],rec[b.name]))bad.push('adjacent tag boxes overlap at '+W);
         var E={za:true,z:{id:'C',letter:'C'},d:151,sx:W+200,sy:H*0.42};
         // Place a real cache so its name covers the chip natural location, then render the name before asking the chip to choose again.
         if(typeof WLTEXT!=='undefined')WLTEXT.boxes.length=0;
         extEdgeArrow(E);var natural={x:EXTARROW.x,y:EXTARROW.y,w:EXTARROW.w,h:EXTARROW.h}, q=rec[ct.tag];
         if(!EXTARROW.on||!q){bad.push('missing cache/chip staging at '+W);continue;}
         ct.x+=(natural.x+natural.w/2-q.x-q.w/2)/WTX.z;ct.y+=(natural.y+natural.h/2-q.y-q.h/2)/WTX.z;
         rec={};__frame(0);q=rec[ct.tag];
         if(!q){bad.push('edge cache did not draw at '+W);continue;}
         if(!overlap(q,natural))bad.push('cache did not cover the natural chip position at '+W);
         extEdgeArrow(E);
         if(!EXTARROW.on||overlap(q,EXTARROW))bad.push('cache name and extraction chip overlap at '+W);
       }
       if(a.x!==p.x+125||b.y!==a.y||a.hp!==a.maxhp-1)bad.push('drawing changed enemy simulation');
     }catch(e){bad.push('threw: '+(e.message||e));}
     finally{PR.fillText=of;canSee=oc;NET.on=on;try{__endRaid('abandon');}catch(_e){}__forceSize(oldW,oldH);__topClear();}
     return bad.length?bad.join('; '):null;
   }},
  {v:'36.11',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
