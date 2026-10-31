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

if ($s.Contains("  {v:'36.73',what:")) { throw "check 36.73 is in the fixture already" }

SubRx @'
  {v:'36.72',what:
'@ @'
  {v:'36.73',what:'the raid HUD panels share one inset (within 2 px: pillager board, feed, vitals bars, ammo card, run info) and the clock, its extract line and the arrow draw inside one card (his critic, o-120d: ragged margins, four floating timer pieces)',
   run:function(){
     if(!(window.__deploy&&window.__endRaid&&window.__frame)) return 'SKIP: no raid here';
     var bad=[], g, i, L=[], lo, hi, PR=CanvasRenderingContext2D.prototype, of=PR.fillText, clk=null, pill=null, C, ins=[];
     function add(n,v){ if(typeof v==='number'&&v===v) L.push({n:n,v:v}); }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __pinDPR(1); }catch(_d){}
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       g.bagOpen=false; g.mapOpen=false; g.ents.length=0; keys={}; g.legendOn=1;
       for(i=0;i<4;i++) say('inset test line '+i,'info',{reach:'e'});
       for(i=0;i<8;i++) __frame(0.016);
       PR.fillText=function(s,x,y){ var t=String(s); if(/^\d+:\d\d$/.test(t)) clk={x:x,y:y}; else if(/^extract \d+m/i.test(t)) pill={x:x,y:y}; return of.apply(this,arguments); };
       __frame(0.016); __frame(0.016);
       PR.fillText=of;
       add('pillager board',HUDBOX.raiders?HUDBOX.raiders.x:null);
       add('feed',(FEEDBOX&&FEEDBOX.on)?FEEDBOX.x:null);
       add('vitals',(typeof VITBOX==='object'&&VITBOX)?VITBOX.x:null);
       add('ammo card',(GUNCARD&&GUNCARD.g===g&&GUNCARD.w>0)?(W-(GUNCARD.x+GUNCARD.w)):null);
       add('run info',HUDBOX.cond?(W-(HUDBOX.cond.x+HUDBOX.cond.w)):null);
       if(L.length<4) bad.push('only '+L.length+' corner panels were laid out ('+L.map(function(q){return q.n;}).join(', ')+')');
       lo=1e9; hi=-1e9; for(i=0;i<L.length;i++){ if(L[i].v<lo) lo=L[i].v; if(L[i].v>hi) hi=L[i].v; ins.push(L[i].n+' '+Math.round(L[i].v*10)/10); }
       if(hi-lo>2) bad.push('panel insets differ by '+(Math.round((hi-lo)*10)/10)+' px (want within 2): '+ins.join(', '));
       C=(typeof CLKCARD==='object')?CLKCARD:null;
       if(!C||C.g!==g||!(C.w>0)) bad.push('no top centre card was drawn around the clock and the extract line');
       else if(!clk||!pill) bad.push('the clock or the extract line was not drawn (clock '+(clk?'yes':'no')+', extract '+(pill?'yes':'no')+')');
       else {
         if(C.k!=='one'&&!(g.arcade||g.career)) bad.push('the card is not the clock card');
         if(C.k==='one'&&!(clk.x>C.x&&clk.x<C.x+C.w&&clk.y>C.y&&clk.y<C.y+C.h)) bad.push('the clock is outside its card');
         if(!(pill.x>C.x&&pill.x<C.x+C.w&&pill.y>C.y&&pill.y<C.y+C.h)) bad.push('the extract line is outside its card');
         if(!(C.ay<=C.y+C.h)) bad.push('the arrow hangs below its card');
       }
     }catch(e){bad.push('threw: '+(e&&e.message||e));}
     finally{
       PR.fillText=of;
       try{var g2=__state(); if(g2&&!g2.over){g2.player.downed=false; __endRaid('abandon');}}catch(_e){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null;
   }},
  {v:'36.72',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
