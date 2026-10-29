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

if ($s.Contains("  {v:'36.14',what:")) { throw "check 36.14 is in the fixture already" }

SubRx @'
  {v:'36.13',what:
'@ @'
  {v:'36.14',what:'cache and extraction chip use the same 16px cream labels and 32px chip height at 1080p and 4K',
   run:function(){
     var g,p,ct,PR=CanvasRenderingContext2D.prototype,of=PR.fillText,oldW=W,oldH=H,rec={},bad=[];
     try{
       __runPrep();__topClear();__resetCfg();__pinDefaults(0);__cleanProfile();__pinDPR(1);
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});g=__state();p=g.player;p.x=WORLD_W/2;p.y=WORLD_H/2;
       g.anchX=p.x;g.anchY=p.y;g.leanSX=0;g.leanSY=0;g.ents=[];g.zones=[];g.mapOpen=false;g.mapFirst=false;g.bagOpen=false;
       ct=mkContainer(p.x+180,p.y+100,'cache');ct.cache=1;ct.tag='the long dock cache';g.containers=[ct];
       PR.fillText=function(t){var s=String(t).toLowerCase();if(s===ct.tag||(/^\? \d+m$/).test(s)){var m=this.getTransform(),px=parseFloat((this.font.match(/([\d.]+)px/)||[0,0])[1]);rec[s===ct.tag?'cache':'exit']={px:px*m.a/DPRH,c:this.fillStyle};}return of.apply(this,arguments);};
       for(var r=0;r<2;r++){
         __forceSize(r?3840:1920,r?2160:1080);rec={};__frame(0);extEdgeArrow({za:true,z:{},d:151,sx:W+200,sy:H*0.42});
         var hr=Math.max(1,hudRes());
         for(var k in {cache:1,exit:1})if(!rec[k])bad.push('missing '+k+' label at '+W);else{if(Math.abs(rec[k].px-16*hr)>0.15)bad.push(k+' text is '+rec[k].px+'px at '+W);if(rec[k].c!==UIC.tx_1)bad.push(k+' text is not cream');}
         if(!EXTARROW.on||Math.abs(EXTARROW.h-32*hr)>0.1)bad.push('exit chip is not 32px high at '+W);
       }
     }catch(e){bad.push('threw: '+(e.message||e));}
     finally{PR.fillText=of;try{__endRaid('abandon');}catch(_e){}__forceSize(oldW,oldH);__topClear();}
     return bad.length?bad.join('; '):null;
   }},
  {v:'36.13',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
