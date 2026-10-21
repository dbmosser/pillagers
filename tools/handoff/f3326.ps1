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

if ($s.Contains("  {v:'33.26',what:")) { throw "check 33.26 is in the fixture already" }

SubRx @'
  {v:'33.25',what:
'@ @'
  {v:'33.26',what:'every machine is drawn 1.33x bigger around its foot (name plate rides up, weak points follow) and a round at 1.2x the old radius now hits it (his order: enemies 33% larger)',
   run:function(){
     if(typeof machScaleBegin!=='function'||typeof machScaleEnd!=='function'||typeof machMul!=='function') return 'no machine size helpers: machines are still drawn at the old size';
     if(typeof __deploy!=='function'||typeof updateBullets!=='function') return 'SKIP: no raid helpers';
     var bad=[], kw=wc, g, p, i, K, cvs, ctx, hasShadow=(typeof shadowE!=='undefined'), ks=hasShadow?shadowE:undefined;
     var KINDS=[['sentry',mkSentry,drawSentryS],['crawler',mkCrawler,drawCrawlerS],['warden',mkWarden,drawWardenAt],['choir',mkChoir,drawChoirS],['snitch',mkSnitch,drawSnitchS],['listener',mkListener,drawListenerS],['howler',mkHowler,drawHowlerS],['bulwark',mkBulwark,drawBulwarkS]];
     function box(fn,e,scaled){
       ctx.setTransform(1,0,0,1,0,0); ctx.clearRect(0,0,900,900);
       wc=ctx; var n=0;
       try{ if(scaled) n=machScaleBegin(e); fn(e); }finally{ machScaleEnd(n); wc=kw; }
       var d=ctx.getImageData(0,0,900,900).data, x0=1e9,y0=1e9,x1=-1,y1=-1, x, y;
       for(y=0;y<900;y++) for(x=0;x<900;x++) if(d[(y*900+x)*4+3]>12){ if(x<x0)x0=x; if(x>x1)x1=x; if(y<y0)y0=y; if(y>y1)y1=y; }
       return x1<0?null:{w:x1-x0+1,h:y1-y0+1};
     }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player) return 'SKIP: no raid';
       p=g.player;
       cvs=document.createElement('canvas'); cvs.width=900; cvs.height=900; ctx=cvs.getContext('2d');
       for(i=0;i<KINDS.length;i++){
         K=KINDS[i];
         var e=K[1](450,600); e.face=0; e.hitT=0;
         if(machMul(e)!==1.33) bad.push(K[0]+' has size factor '+machMul(e));
         var b0=null,b1=null;
         try{ b0=box(K[2],e,false); b1=box(K[2],e,true); }catch(er){ bad.push(K[0]+' draw threw: '+(er&&er.message||er)); continue; }
         if(!b0||!b1){ bad.push(K[0]+' drew nothing on the test canvas'); continue; }
         var rw=b1.w/b0.w, rh=b1.h/b0.h;
         if(Math.abs(b1.w-1.33*b0.w)>0.0266*b0.w+1.5||Math.abs(b1.h-1.33*b0.h)>0.0266*b0.h+1.5) bad.push(K[0]+' drawn bounds '+b0.w+'x'+b0.h+' to '+b1.w+'x'+b1.h+' (x'+rw.toFixed(3)+' by x'+rh.toFixed(3)+', want 1.33)');
       }
       var human=mkSentry(0,0); human.kind='raider'; if(machMul(human)!==1) bad.push('a pillager bot is scaled');
       // a round at 1.2x the old radius hits the machine now, and one at 1.5x still misses
       [['sentry',mkSentry],['crawler',mkCrawler]].forEach(function(pair){
         [[1.2,true],[1.5,false]].forEach(function(t){
           var m=pair[1](p.x+300,p.y), hp0=m.hp, ar0=m.armor||0;
           g.ents=[m]; g.bullets.length=0;
           g.bullets.push({x:m.x+m.r*t[0]+3,y:m.y,vx:0.01,vy:0,dmg:20,life:0.5,player:true,owner:p,tint:'#ffffff',el:'',thru:0});
           updateBullets(0.001); g.bullets.length=0;
           var hit=(m.hp<hp0)||((m.armor||0)<ar0)||m.dead||m.hitT>0;
           if(hit!==t[1]) bad.push(pair[0]+' round at '+t[0]+'x radius '+(hit?'hit':'missed')+', wanted '+(t[1]?'hit':'miss'));
         });
       });
       var src=Array.prototype.map.call(document.scripts,function(s){return s.text;}).join('');
       if(src.indexOf('machScaleBegin(e2'+')')<0) bad.push('the world draw does not scale the machines');
       return bad.length?bad.join('; '):null;
     }catch(err){ return 'machine size check threw: '+String(err&&err.message||err); }
     finally{ wc=kw; if(hasShadow) shadowE=ks; try{ __endRaid('abandon'); }catch(_e){} __topClear(); }
   }},
  {v:'33.25',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
