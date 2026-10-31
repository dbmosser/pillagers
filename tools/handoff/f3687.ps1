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

if ($s.Contains("  {v:'36.87',what:")) { throw "check 36.87 is in the fixture already" }

SubRx @'
  {v:'36.86',what:
'@ @'
  {v:'36.87',what:'the first demo pack comes early and near: a standing player meets the first machine about 15 to 20 s in (median over 12 seeds), the later packs and a career raid are as before (his 2.62 b)',
   run:function(){
     if(typeof ARCADE_FIRST!=='object'||typeof arcadeFirstOn!=='function') return 'the demo has no first pack rule (the first pack still comes at 22 s and lands 770 to 1060 away)';
     var res=[], s, g, f, t0, p, none=0, med, bad=[], rR=render2D, rH=drawHUD, oC;
     try{
       render2D=function(){}; drawHUD=function(){};
       for(s=1;s<=12;s++){
         __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
         if(!arcadeDeploy({mapIx:0,seed:s*7919+13})) return 'SKIP: arcadeDeploy built no demo raid';
         g=__state(); g.mapFirst=false; g.mapOpen=false; g.bagOpen=false; g.paused=false; ARCADE.holdT=0;
         try{ if(typeof easyLive==='function'&&easyLive()) easyAnswer(false); }catch(_ez){}
         if(s===1){
           if(!arcadeFirstOn(ARCADE)) bad.push('a fresh demo run is not on its first pack');
           ARCADE.waveN=1; if(arcadeFirstOn(ARCADE)) bad.push('the second pack still takes the first pack rule'); ARCADE.waveN=0;
           oC=g.career; g.career=true; if(arcadeFirstOn(ARCADE)) bad.push('a career raid takes the demo first pack rule'); g.career=oC;
         }
         t0=performance.now();
         for(f=0;f<1200&&g.tel.firstContact===null&&!g.over;f++) __loop(t0+(f+1)*50);
         if(g.tel.firstContact===null){ none++; res.push(101); } else res.push(Math.round(g.tel.firstContact*10)/10);
         try{ __endRaid('abandon'); }catch(_e){}
         try{ if(ARCADE.on) arcadeLeave(); }catch(_l){}
       }
       res.sort(function(a,b){ return a-b; }); med=(res[5]+res[6])/2;
       if(!(med>=14&&med<=22)) bad.push('the median first contact of a standing player is '+med+' s over 12 seeds, not 14 to 22 ('+res.join(',')+')');
       return bad.length?bad.join('; '):null;
     } finally {
       render2D=rR; drawHUD=rH;
       try{ if(ARCADE.on) arcadeLeave(); }catch(_a){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_r){}
       __topClear();
     } }},
  {v:'36.86',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
