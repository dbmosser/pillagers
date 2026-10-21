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

if ($s.Contains("  {v:'33.53',what:")) { throw "check 33.53 is in the fixture already" }

SubRx @'
  {v:'33.52',what:
'@ @'
  {v:'33.53',what:'cw-pixsmoke (86a): THE PIXEL SMOKE CHECK that every later pixel job extends. With the pixel look on, a career raid, the demo, the Undercroft floor and the title all draw at 1080p and 4K with no render fault and no pixel fault',
   run:function(){
     if(typeof pixFaults!=='function') return 'no pixel fault counter (pixFaults)';
     if(!(window.__deploy&&window.__state&&window.__frame&&window.__forceSize&&window.__runPrep&&window.__topClear&&window.__endRaid&&window.__hubEnter&&window.__hubFrame&&window.__showScreen)) return 'SKIP: this fixture cannot draw a raid, the floor and the title';
     var bad=[], sw=cv.style.width, sh=cv.style.height, hw=hcv.style.width, hh=hcv.style.height, sizes=[[1920,1080],[3840,2160]], si, i, g, f0, n=0;
     function frames(tag,k,fn){ var j; for(j=0;j<k;j++){ try{ fn(); }catch(e){ bad.push(tag+' threw: '+(e&&e.message||e)); return; } } g=__state(); if(g&&g.drawErr) bad.push(tag+' render fault: '+g.drawErr); n++; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       CFG.xfPix=1; f0=pixFaults();
       for(si=0;si<sizes.length;si++){
         __forceSize(sizes[si][0],sizes[si][1]);
         __deploy({kit:[],safe:null,mapIx:0,seed:4242}); keys={};
         frames('career '+sizes[si][0],12,function(){ __frame(0.016); });
         __endRaid('abandon'); __topClear();
         if(typeof arcadeDeploy==='function'&&typeof ARCADE==='object'&&ARCADE){
           if(arcadeDeploy({mapIx:0,seed:4242})){ ARCADE.holdT=0; frames('demo '+sizes[si][0],12,function(){ __frame(0.016); }); }
           else bad.push('staging: arcadeDeploy built no demo raid');
           try{ if(ARCADE.on) arcadeLeave(); }catch(_l){}
           try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
           __topClear();
         }
         __hubEnter(); frames('floor '+sizes[si][0],6,function(){ __hubFrame(0.016); });
         __showScreen('title'); __topClear();
       }
       if(pixFaults()>f0) bad.push('the pixel paths logged '+(pixFaults()-f0)+' fault(s)');
       if(n<6) bad.push('only '+n+' of 6 scenes drew');
       return bad.length?bad.join('; '):null;
     } catch(err){
       return 'pixel smoke check: '+String(err&&err.message||err);
     } finally {
       CFG.xfPix=0;
       try{ if(typeof ARCADE==='object'&&ARCADE&&ARCADE.on) arcadeLeave(); }catch(_a){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e2){}
       try{ cv.style.width=sw; cv.style.height=sh; hcv.style.width=hw; hcv.style.height=hh; resize(); }catch(_z){}
       keys={}; __resetCfg(); __topClear(); __cleanProfile();
     } }},
  {v:'33.52',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
