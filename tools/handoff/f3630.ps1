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

if ($s.Contains("  {v:'36.30',what:")) { throw "check 36.30 is in the fixture already" }

SubRx @'
  {v:'36.29',what:
'@ @'
  {v:'36.30',what:'forge and seal world labels keep their whole shared panel inside the viewport through ADS zoom at 1080p and 4K',
   run:function(){
     var g,p,station0=null,pad0=PAD.curOwn,bad=[],PR=CanvasRenderingContext2D.prototype,of=PR.fillText,op=uiPanel,rec={},pan=[],ow=W,oh=H,oz=ZC,ot=ZT;
     function name(t){ t=String(t).toLowerCase();return t==='the forge'?'forge':(/^the seal\s+\d+%$/.test(t)?'seal':''); }
     PR.fillText=function(t,x,y){
       var id=name(t);
       if(id&&/_wtA/.test(String(new Error().stack))){
         var m=this.getTransform(),a=this.measureText(t),left=x-(this.textAlign==='center'?a.width/2:0);
         rec[id]={x:(m.e+left*m.a)/DPRH,w:a.width*m.a/DPRH,y:(m.f+y*m.d)/DPRH};
       }
       return of.apply(this,arguments);
     };
     uiPanel=function(c,x,y,w,h){
       if(/_wtA/.test(String(new Error().stack))){var m=c.getTransform();pan.push({x:(m.e+x*m.a)/DPRH,w:w*m.a/DPRH,y:(m.f+y*m.d)/DPRH,h:h*m.d/DPRH});}
       return op.apply(this,arguments);
     };
     try{
       __runPrep();__topClear();__resetCfg();__pinDefaults(0);__cleanProfile();__pinDPR(1);
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});g=__state();p=g.player;
       if(!g.forge||!g.seal) return 'staging: missing forge or seal';
       station0={fx:g.forge.x,fy:g.forge.y,name:g.forge.name,sx:g.seal.x,sy:g.seal.y,done:g.seal.done};PAD.curOwn=0;
       g.ents=[];g.containers=[];g.zones=[];g.wild=[];g.map.story=null;g.mapOpen=false;g.bagOpen=false;g.paused=false;g.legendOn=0;
       p.x=WORLD_W/2;p.y=WORLD_H/2;p.ads=false;p.iv=0;p.roll=0;g.anchX=p.x;g.anchY=p.y;g.leanSX=0;g.leanSY=0;g.shake=0;g.adsCam=null;
       ZC=1;ZT=1;keys={};mouse.down=false;
       for(var r=0;r<2;r++)for(var a=0;a<2;a++)for(var side=0;side<2;side++){
         __forceSize(r?3840:1920,r?2160:1080);mouse.x=W/2;mouse.y=H/2;g.adsZ=a?2.3:1;__frame(0);
         var z=WTX.z,margin=24*Math.max(1,hudRes());
         g.forge.name='the forge';g.forge.x=WTX.ox+(side?W-3:3)/z;g.forge.y=WTX.oy+H*.48/z+84;
         g.seal.done=false;g.seal.x=WTX.ox+(side?3:W-3)/z;g.seal.y=WTX.oy+H*.48/z+60;
         g.nearForge=null;rec={};pan=[];__frame(0);
         for(var i=0;i<2;i++){
           var id=i?'seal':'forge',t=rec[id],q=null;
           if(!t){bad.push(id+' text missing at '+W+'/'+a+'/'+side);continue;}
           for(var j=0;j<pan.length;j++)if(t.x>=pan[j].x-1&&t.x+t.w<=pan[j].x+pan[j].w+1&&t.y>=pan[j].y&&t.y<=pan[j].y+pan[j].h)q=pan[j];
           if(!q)bad.push(id+' shared plate missing');
           else if(q.x<margin-.1||q.x+q.w>W-margin+.1)bad.push(id+' plate clipped at '+W+'/'+a+'/'+side);
           if(t.x<margin-.1||t.x+t.w>W-margin+.1)bad.push(id+' text clipped at '+W+'/'+a+'/'+side);
         }
       }
       g.forge.x=WTX.ox+(W+500)/WTX.z;g.seal.x=g.forge.x;rec={};__frame(0);
       if(rec.forge||rec.seal)bad.push('a wholly offscreen station name was pulled into view');
       return bad.length?bad.join('; '):null;
     }catch(e){return 'station label check: '+(e.message||e);}
     finally{
       PR.fillText=of;uiPanel=op;ZC=oz;ZT=ot;PAD.curOwn=pad0;
       if(station0&&g){g.forge.x=station0.fx;g.forge.y=station0.fy;g.forge.name=station0.name;g.seal.x=station0.sx;g.seal.y=station0.sy;g.seal.done=station0.done;}
       try{__endRaid('abandon');}catch(_e){}__forceSize(ow,oh);__topClear();
     }
   }},
  {v:'36.29',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
