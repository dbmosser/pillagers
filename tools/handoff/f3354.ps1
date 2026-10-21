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

if ($s.Contains("  {v:'33.54',what:")) { throw "check 33.54 is in the fixture already" }

SubRx @'
  {v:'33.53',what:
'@ @'
  {v:'33.54',what:'cw-cx-mapstart-clear: raid-start map keeps every cache location with compact icons, no loot words, 16px labels and clear 20px rewards; m map unchanged',
   run:function(){
     var g, ow=W, oh=H, os=MAPFIRST.skip, oldC=P.contracts, PR=CanvasRenderingContext2D.prototype, oa=PR.arc, ot=PR.fillText, arcs=[], texts=[], c, revealed, bad=[];
     function grab(){
       arcs=[]; texts=[];
       PR.arc=function(x,y,r){ arcs.push({x:x,y:y,r:r}); return oa.apply(this,arguments); };
       PR.fillText=function(s,x,y){ var m=this.getTransform();texts.push({s:String(s),font:this.font,col:this.fillStyle,x:x*m.a+m.e,y:y*m.d+m.f}); return ot.apply(this,arguments); };
       try{drawMapOverlay();}finally{PR.arc=oa;PR.fillText=ot;}
     }
     function size(t){return +((/([\d.]+)px/.exec(t.font)||[0,0])[1]);}
     function at(c,r){var m=mapProj();return arcs.some(function(a){return Math.abs(a.x-(m.ox+c.x*m.sc))<0.1&&Math.abs(a.y-(m.oy+c.y*m.sc))<0.1&&Math.abs(a.r-r)<0.1;});}
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile(); MAPFIRST.skip=1;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242}); g=__state(); if(!g||g.over) return 'SKIP: no raid';
       g.mapOpen=true; g.bagOpen=false; keys={}; mouse.down=false;
       c=g.containers.filter(function(c){return c.cache&&!c.strong&&!c.opened;})[0]; if(!c) return 'SKIP: no native cache';
       revealed=c.revealed; c.revealed=true;
       P.contracts=[{type:'kill',tgt:'crawler',n:5,prog:0,reward:450,desc:'x',tier:'std'}];
       [[1920,1080],[3840,2160]].forEach(function(wh){
         W=wh[0];H=wh[1];var z=Math.max(1,hudRes());g.mapFirst=1;grab();
         g.containers.filter(function(v){return v.cache&&!v.strong;}).forEach(function(v){if(!at(v,4*z))bad.push('cache has no compact ring at '+H);});
         g.containers.filter(function(v){return v.strong&&!v.opened;}).forEach(function(v){if(!at(v,10*z))bad.push('strongbox icon lost at '+H);});
         if(texts.some(function(t){return /^(cache|looted|strongbox)$/i.test(t.s);})) bad.push('loot word at '+H);
         if(texts.filter(function(t){return /^extract [abc]$/i.test(t.s);}).length!==3) bad.push('extract labels lost at '+H);
         var reward=texts.filter(function(t){return t.s==='$450';})[0];
         if(!reward||size(reward)<20*z-0.1||reward.col!==UIC.tx_1) bad.push('reward not 20px primary text at '+H);
         var box=mapProj();
         if(texts.some(function(t){return t.x>=box.ox&&t.x<=box.ox+WORLD_W*box.sc&&t.y>=box.oy&&t.y<=box.oy+WORLD_H*box.sc&&size(t)<16*z-0.1;})) bad.push('map text below 16px at '+H);
         g.mapFirst=0;grab();
         if(!texts.some(function(t){return /^(cache|strongbox)$/i.test(t.s);})) bad.push('m map lost loot words');
         if(!arcs.some(function(a){var m=mapProj();return Math.abs(a.x-(m.ox+c.x*m.sc))<0.1&&Math.abs(a.y-(m.oy+c.y*m.sc))<0.1&&a.r>=6.5*z&&a.r<=8*z;})) bad.push('m map cache ring changed');
       });
       return bad.length?bad.join('; '):null;
     }finally{
       PR.arc=oa;PR.fillText=ot;W=ow;H=oh;MAPFIRST.skip=os;P.contracts=oldC;if(c)c.revealed=revealed;
       try{if(g){g.mapFirst=0;g.mapOpen=false;}__endRaid('abandon');}catch(e){}__topClear();__resetCfg();__cleanProfile();
     }
   }},
  {v:'33.53',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
