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

if ($s.Contains("  {v:'36.02',what:")) { throw "check 36.02 is in the fixture already" }

SubRx @'
  {v:'36.01',what:
'@ @'
  {v:'36.02',what:'closing the abandon question by Escape, direct close or the x cancels it and restores a drawn feed line; 9.37 then 35.53 and 35.44 pass in the same tab',
   run:function(){
     var bad=[], g=null, pb=document.getElementById('pausebox'), ab=document.getElementById('abandonbtn'), ca=document.getElementById('confirmabandon');
     function stage(how){
       togglePauseBox(true); ab.click();
       if(!pauseOpen||!pb.classList.contains('asking')||ca.style.display==='none') { bad.push(how+': control: abandon question did not arm'); return; }
       if(!feedWaits()) bad.push(how+': control: the open question did not hold the feed');
       if(how==='Escape'){
         if(document.activeElement&&document.activeElement.blur) document.activeElement.blur();
         document.body.dispatchEvent(new KeyboardEvent('keydown',{code:'Escape',key:'Escape',bubbles:true,cancelable:true}));
         document.body.dispatchEvent(new KeyboardEvent('keyup',{code:'Escape',key:'Escape',bubbles:true,cancelable:true}));
       }else if(how==='x') document.getElementById('pausex').click();
       else togglePauseBox(false);
       if(pauseOpen||pb.classList.contains('on')) bad.push(how+': pause box stayed open');
       if(pb.classList.contains('asking')||ca.style.display!=='none') bad.push(how+': abandon question survived closing');
       if(feedWaits()) bad.push(how+': feed still waits after closing');
       g.fd={t:0,seq:0,lines:[]};
       feedAdd([{t:'zq pickup restored',c:null}],'info',{});
       var tr=__textTrace(function(){ feedDraw(); }), found=false;
       for(var i=0;i<tr.length;i++) if(/zq pickup restored/i.test(String(tr[i].t))) found=true;
       if(!found||FEEDBOX.rows.length!==1) bad.push(how+': the pickup feed line did not draw');
     }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player||g.sim) return 'control: no live raid';
       if(!pb||!ab||!ca||!document.getElementById('pausex')) return 'control: missing pause controls';
       keys={}; mouse.down=false; g.mapOpen=false; g.bagOpen=false; g.trade=null; g.ents.length=0;
       g.player.downed=false; g.player.hp=g.player.maxhp; g.player.iv=99;
       render2D(0);
       stage('Escape'); stage('direct close'); stage('x');
       togglePauseBox(false); __endRaid('abandon'); __topClear();
       // v28.xx (cw-cx-abandonfeed): reproduce the corpus order without clearing asking between these checks.
       var versions=['9.37','35.53','35.44'];
       for(var j=0;j<versions.length;j++){
         var test=null;
         for(var k=0;k<__REGRESS.length;k++) if(__REGRESS[k].v===versions[j]) { test=__REGRESS[k]; break; }
         if(!test) { bad.push('missing check '+versions[j]); continue; }
         __topClear(); __ctxHeal();
         var result=test.run();
         if(result) bad.push('after 9.37, '+versions[j]+': '+result);
       }
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       keys={};
       try{ togglePauseBox(false); disarmAbandon(); }catch(_p){}
       try{ var last=__state(); if(last&&!last.over){ last.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null;
   }},
  {v:'36.01',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
