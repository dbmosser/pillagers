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

if ($s.Contains("  {v:'35.43',what:")) { throw "check 35.43 is in the fixture already" }

SubRx @'
  {v:'35.42',what:
'@ @'
  {v:'35.43',what:'solo and party ping labels are 16px bone on a padded plate clear of the target, with 18px map glyphs at 1080p and doubled at 4k',
   run:function(){
     if(typeof netPingLabel!=='function')return 'ping label remains tiny bare orange text';
     var g,p,pk=NET.pings,wk=NET.wps,on=NET.on,seat=NET.seat,ow=W,oh=H,wp=w2s,hp=hudPanel,ft=ctx.fillText,cg=colourCueGlyph,panels=[],texts=[],glyphs=[],pos,r,i,j,n;
     try{
       __runPrep();__topClear();__resetCfg();__pinDefaults(0);__cleanProfile();
       __deploy({kit:['gun_rifle'],safe:null,mapIx:0,seed:4242});g=__state();p=g.player;g.mapFirst=false;g.mapOpen=false;g.bagOpen=false;g.paused=false;CFG.xfPix=0;
       NET.wps={};NET.seat=0;
       hudPanel=function(x,y,w,h,a,plain){panels.push({x:x,y:y,w:w,h:h,a:a,plain:plain});return hp.apply(this,arguments);};
       ctx.fillText=function(s,x,y){texts.push({s:String(s),x:x,y:y,font:this.font,c:this.fillStyle});return ft.apply(this,arguments);};
       colourCueGlyph=function(c,k,x,y,s){glyphs.push({k:k,s:s});return cg.apply(this,arguments);};
       w2s=function(){return pos;};
       for(i=0;i<2;i++){
         __forceSize(i?3840:1920,i?2160:1080);r=hudRes();
         for(j=0;j<3;j++){
           NET.on=!!(j%2);pos=j===0?{x:2,y:2}:j===1?{x:W-2,y:H-2}:{x:W/2,y:H/2};
           NET.pings=[{s:0,x:p.x+60,y:p.y,w:'sentry',at:Date.now()}];panels=[];texts=[];
           n=netPingDraw();if(n!==1||panels.length!==1||texts.length!==1)return 'ping did not draw exactly one label plate';
           var b=panels[0],t=texts[0];
           if(Math.abs(parseFloat(t.font.match(/([\d.]+)px/)[1])-16*r)>.1)return 'ping label is not 16px scaled';
           if(t.c!==UIC.tx_1||t.s!==t.s.toLowerCase()||!/sentry/.test(t.s))return 'ping label lost its readable colour or specific target';
           if(b.a!==.85||b.plain!==1||b.h!==32*r||b.x<0||b.y<0||b.x+b.w>W||b.y+b.h>H)return 'ping plate is missing, clipped or not padded';
           if(t.x<=b.x||t.x>=b.x+b.w||t.y<=b.y||t.y>=b.y+b.h)return 'label escaped its plate';
           if(j===2&&b.y+b.h>pos.y-64*r)return 'ping label still overlaps the target';
         }
         glyphs=[];mmMarks({x:100,y:100,w:400,h:400},.3,1);
         if(!glyphs.some(function(v){return v.k==='target'&&v.s>=1.5;}))return 'minimap ping remains smaller than 18px';
         glyphs=[];netWpMapDraw(0,0,.1);
         if(!glyphs.some(function(v){return v.k==='target'&&v.s>=1.5*r;}))return 'full-map ping remains smaller than 18px scaled';
       }
       return null;
     }finally{
       w2s=wp;hudPanel=hp;ctx.fillText=ft;colourCueGlyph=cg;
       NET.on=false;try{__endRaid('abandon');}catch(e){}__topClear();__forceSize(ow,oh);NET.pings=pk;NET.wps=wk;NET.on=on;NET.seat=seat;
     }
   }},
  {v:'35.42',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
