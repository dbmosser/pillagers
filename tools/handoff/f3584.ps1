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

if ($s.Contains("  {v:'35.84',what:")) { throw "check 35.84 is in the fixture already" }

SubRx @'
  {v:'35.83',what:
'@ @'
  {v:'35.84',what:'final rush HUD gives its banner 416px and 24px clearance, moves navigation beside the clock and keeps the clock above a quieter score in both seats',
   run:function(){
     var g,role0=ARCADE.role,solo0=ARCADE.solo,rec=[],plates=[],of=hudText,op=hudPlate,i,clock,score,nav,banner,z;
     function text(re){ for(var k=0;k<rec.length;k++) if(re.test(rec[k].s)) return rec[k]; return null; }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       if(!arcadeDeploy({mapIx:0,seed:4242})) throw Error('no demo');
       g=__state(); if(!g||!g.player||g.over) throw Error('no live raid');
       easyAnswer(false); ARCADE.solo=0; g.timeLeft=90; g.paused=false; g.mapOpen=false; g.bagOpen=false; keys={}; mouse.down=false;
       ARCADE.mine=105; ARCADE.mate=105; z=hudRes();
       hudText=function(s,x,y){ var t=ctx.getTransform(),m=/([\d.]+)px/.exec(ctx.font); rec.push({s:String(s),x:t.a*x+t.c*y+t.e,y:t.b*x+t.d*y+t.f,px:m?+m[1]:0}); return of.apply(this,arguments); };
       hudPlate=function(x,y,w,h,a,f){ var t=ctx.getTransform(); plates.push({x:t.a*x+t.c*y+t.e,y:t.b*x+t.d*y+t.f,w:w*t.a,h:h*t.d,a:a,f:f}); return op.apply(this,arguments); };
       for(i=0;i<2;i++){
         ARCADE.role=i?'p2':'host'; g.arcRushSaid=0; g.alert=null; g.alertQ=[]; arcadeRushTick(); g.t+=0.2;
         HUDTOPB=0; rec=[]; plates=[]; drawHUD();
         clock=text(/^1:30$/); score=text(/^210 sp$/i); nav=text(/^extract /i); banner=text(/^final rush$/i);
         if(!clock||!score||!nav||!banner) throw Error('seat '+i+' missing clock, score, navigation or rush');
         if(SCOREBOX.y-CLOCKBOX.y-CLOCKBOX.h<Math.round(16*z)) throw Error('clock and score gap is under 16px');
         if(!(clock.px>score.px&&clock.y<score.y)) throw Error('clock is not the larger read above score');
         if(!(nav.x<CLOCKBOX.x-16*z)) throw Error('navigation still crowds the centre column');
         var p=plates.filter(function(q){ return q.a===HUDC.danger&&q.f==='rgba(17,19,21,.96)'; })[0];
         if(!p||p.w<400*z) throw Error('rush panel is narrower than 400px');
         if(p.y-(SCOREBOX.y+SCOREBOX.h)<20*z) throw Error('rush panel lacks clear space below score');
         if(!ALERTL||ALERTL.a.key!=='finalrush'||ALERTL.bl[0]<LH(12)) throw Error('rush inset is missing');
         var wz=WTX.z||1;
         if(!wlUnder(WTX.ox+(p.x+p.w/2)/wz,WTX.oy+(p.y+p.h/2)/wz,16/wz,16/wz)) throw Error('world nameplates can cross the rush banner');
       }
       return null;
     }catch(e){ return String(e&&e.message||e); }
     finally{
       hudText=of; hudPlate=op;
       try{ if(ARCADE.on) arcadeLeave(); if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       ARCADE.role=role0; ARCADE.solo=solo0;
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     } }},
  {v:'35.83',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
