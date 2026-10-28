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

if ($s.Contains("  {v:'35.64',what:")) { throw "check 35.64 is in the fixture already" }

SubRx @'
  {v:'35.63',what:
'@ @'
  {v:'35.64',what:'cw-cx-hudtvread: raid belt vacant keys have no full tile slabs, owned gold rings remain, key digits grow with tv, score labels clear 16px with a top inset in either seat',
   run:function(){
     var c0=JSON.stringify(CFG),a0={},g=null,ga,us=P.uiScale,hd=P.hud,of=ctx.fillRect,os=ctx.stroke,ot=hudText,rects=[],strokes=[],texts=[],bad=[],k;
     ['solo','role','mine','mate'].forEach(function(n){a0[n]=ARCADE[n];});
     function px(){return parseFloat((/([\d.]+)px/.exec(ctx.font)||[0,0])[1]);}
     try{
       __runPrep();__topClear();__resetCfg();__pinDefaults(0);__cleanProfile();P.uiScale=1.2;P.hud={};CFG.xfPix=0;
       __deploy({kit:['gun_carbine','gun_smg'],mapIx:0,seed:4242});g=__state();if(!g||g.over)return 'could not stage raid';ga=g.arcade;g.bagOpen=false;g.mapOpen=false;g.paused=false;keys={};mouse.down=false;
       ctx.fillRect=function(x,y,w,h){rects.push({x:x,y:y,w:w,h:h});return of.apply(this,arguments);};
       ctx.stroke=function(){strokes.push({c:ctx.strokeStyle,w:ctx.lineWidth});return os.apply(this,arguments);};
       hudText=function(t,x,y){texts.push({t:String(t),px:px(),y:y});return ot.apply(this,arguments);};
       for(var tv=0;tv<2;tv++){
         CFG.hudTv=tv;g.arcade=false;rects=[];strokes=[];texts=[];drawBelt();
         var cells=g.hotCells||[],slots=hotbarSlots(),vac=0,digits=texts.filter(function(t){return /^[0-9]$/.test(t.t);});
         if(digits.length<cells.length)bad.push('missing outlined key digits');
         digits.forEach(function(t){if(t.px<Math.round(18*hudRes()))bad.push('key digit too small: '+t.px);});
         for(var i=0;i<cells.length;i++)if((slots[i].vacant||slots[i].kind==='empty')&&i!==hotSel()){
           vac++;var q=cells[i];
           if(rects.some(function(r){return Math.abs(r.x-q.x)<.01&&Math.abs(r.y-q.y)<.01&&Math.abs(r.w-q.w)<.01&&Math.abs(r.h-q.h)<.01;}))bad.push('vacant key still has a slab');
         }
         if(!vac)bad.push('no vacant class keys staged');
         if(!strokes.some(function(s){return s.c==='#ffc04a'&&s.w===3;}))bad.push('owned gold ring missing');
         g.arcade=true;ARCADE.solo=0;ARCADE.mine=11;ARCADE.mate=22;
         for(var seat=0;seat<2;seat++){
           ARCADE.role=seat?'p2':'host';texts=[];arcadeScoreHud(30,hudRes());
           if(SCOREBOX.y<16)bad.push('score panel touches top edge');
           var labs=texts.filter(function(t){return /^(TEAM SCORE|YOU |P[12] )/.test(t.t);});
           if(labs.length!==3)bad.push('score labels missing');
           labs.forEach(function(t){if(t.px<16)bad.push('score label under 16px');});
         }
       }
       return bad.length?bad.join('; '):null;
     }finally{
       ctx.fillRect=of;ctx.stroke=os;hudText=ot;if(g)g.arcade=ga;
       for(k in a0)ARCADE[k]=a0[k];try{__endRaid('abandon');}catch(_e){}
       for(k in CFG)delete CFG[k];var old=JSON.parse(c0);for(k in old)CFG[k]=old[k];P.uiScale=us;P.hud=hd;keys={};mouse.down=false;__topClear();
     }
   }},
  {v:'35.63',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
