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

if ($s.Contains("  {v:'33.55',what:")) { throw "check 33.55 is in the fixture already" }

SubRx @'
  {v:'33.54',what:
'@ @'
  {v:'33.55',what:'cw-cx-mapstart-plates: raid-start labels have real dark plates, readable contract hierarchy and a holding mark; ordinary m map remains unchanged',
   run:function(){
     var g, ow=W, oh=H, os=MAPFIRST.skip, oldC=P.contracts, PR=CanvasRenderingContext2D.prototype, ot=PR.fillText, or=PR.fillRect, texts=[], rects=[], bad=[];
     function grab(){
       texts=[];rects=[];
       PR.fillText=function(s,x,y){var m=this.getTransform();texts.push({s:String(s),x:x*m.a+m.e,y:y*m.d+m.f,col:this.fillStyle,font:this.font});return ot.apply(this,arguments);};
       PR.fillRect=function(x,y,w,h){var m=this.getTransform();rects.push({x:x*m.a+m.e,y:y*m.d+m.f,w:w*m.a,h:h*m.d,col:this.fillStyle});return or.apply(this,arguments);};
       try{drawMapOverlay();}finally{PR.fillText=ot;PR.fillRect=or;}
     }
     function size(t){return +((/([\d.]+)px/.exec(t.font)||[0,0])[1]);}
     function plates(){return rects.filter(function(r){return /^rgba\(11,\s*12,\s*13,\s*0\.8\)$/.test(r.col);});}
     try{
       __runPrep();__topClear();__resetCfg();__pinDefaults(0);__cleanProfile();MAPFIRST.skip=1;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});g=__state();if(!g||g.over)return 'SKIP: no raid';
       P.contracts=[{type:'conduct',ck:'clean',n:1,prog:0,reward:900,desc:'x',tier:'std'},{type:'kill',tgt:'crawler',n:5,prog:0,reward:450,desc:'x',tier:'std'}];
       g.mapOpen=true;g.bagOpen=false;keys={};mouse.down=false;
       [[1920,1080],[3840,2160]].forEach(function(wh){
         W=wh[0];H=wh[1];var z=Math.max(1,hudRes());g.mapFirst=1;grab();var ps=plates();
         ['hot ground','extract a','extract b','extract c','peddler'].forEach(function(s){
           var t=texts.filter(function(t){return t.s.toLowerCase()===s||(s==='peddler'&&/^peddler\b/i.test(t.s));})[0];
           if(!t||!ps.some(function(p){return t.x>=p.x&&t.x<=p.x+p.w&&t.y>=p.y&&t.y<=p.y+p.h;}))bad.push(s+' has no painted plate at '+H);
         });
         var head=texts.filter(function(t){return t.s.toLowerCase()==='contracts';})[0];
         if(!head||size(head)<31.9*z)bad.push('contract heading below 32px at '+H);
         var rows=mapContractRows();rows.forEach(function(row){var t=texts.filter(function(t){return t.s.toLowerCase()===String(row.name).toLowerCase();})[0];if(!t||t.col!==UIC.tx_1)bad.push('contract name is not primary text at '+H);});
         if(!rects.some(function(r){return r.col===UIC.ok&&Math.abs(r.w-3*z)<0.1&&r.h>20*z;}))bad.push('holding status has no 3px mark at '+H);
         if(texts.some(function(t){return /^(cache|looted|strongbox)$/i.test(t.s);}))bad.push('loot word returned');
         g.mapFirst=0;grab();if(plates().length)bad.push('m map gained label plates');
         if(!texts.some(function(t){return /^(cache|strongbox)$/i.test(t.s);}))bad.push('m map lost loot labels');
       });
       return bad.length?bad.join('; '):null;
     }finally{
       PR.fillText=ot;PR.fillRect=or;W=ow;H=oh;MAPFIRST.skip=os;P.contracts=oldC;
       try{if(g){g.mapFirst=0;g.mapOpen=false;}__endRaid('abandon');}catch(e){}__topClear();__resetCfg();__cleanProfile();
     }
   }},
  {v:'33.54',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
