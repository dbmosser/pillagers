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

if ($s.Contains("  {v:'35.03',what:")) { throw "check 35.03 is in the fixture already" }

SubRx @'
  {v:'35.02',what:
'@ @'
  {v:'35.03',what:'cw-fsbtnspot, the raid screen go fullscreen button of his 2026-10-27 order sits in the top left corner, clear of the raid clock, the extract pill and the score plate with or without the plate, and its text grows with the HUD scale',
   run:function(){
     if(typeof fsRaidBtnSync!=='function'||typeof FSG!=='object') return 'no raid go fullscreen button here';
     var bad=[], ff0=fsFull, fsg0={ok:FSG.ok,force:FSG.force,why:FSG.why,was:FSG.was}, sb0={g:SCOREBOX.g,x:SCOREBOX.x,y:SCOREBOX.y,w:SCOREBOX.w,h:SCOREBOX.h};
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(state!=='raid'||!G||G.over) throw new Error('no live raid to test on');
       G.mapFirst=0; G.mapOpen=false; if(pauseOpen) togglePauseBox(false); syncPause();
       FSG.force=1; FSG.ok=1; FSG.was=0; fsFull=function(){ return false; };
       [0,1].forEach(function(plate){
         if(plate){ SCOREBOX.g=G; SCOREBOX.x=W/2-120; SCOREBOX.y=0; SCOREBOX.w=240; SCOREBOX.h=90; } else SCOREBOX.g=null;
         var nm=plate?'with the score plate':'without the score plate';
         if(!fsRaidBtnSync()){ bad.push(nm+': the button did not show in a windowed raid'); return; }
         var b=document.getElementById('raidfsbtn'), br=b.getBoundingClientRect(), r=cv.getBoundingClientRect(), z=Math.max(0.75,Math.min(2.2,r.height/1080));
         var midL=r.left+r.width/2-150*z;
         if(br.right>midL) bad.push(nm+': the button reaches the top middle (raid clock, extract pill): right edge '+Math.round(br.right)+' past '+Math.round(midL));
         if(br.left>r.left+r.width*0.25) bad.push(nm+': the button is not in the left part of the top edge (left '+Math.round(br.left)+')');
         if(br.top>r.top+60*z) bad.push(nm+': the button is not at the top edge (top '+Math.round(br.top)+')');
         var fs=parseFloat(getComputedStyle(b).fontSize)||0;
         if(Math.abs(fs-Math.round(15*z))>0.6) bad.push(nm+': the button text is '+fs+'px, the HUD scale wants '+Math.round(15*z)+'px');
       });
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ fsFull=ff0; }catch(_r){}
       try{ for(var q in fsg0) FSG[q]=fsg0[q]; }catch(_q){}
       try{ for(var s in sb0) SCOREBOX[s]=sb0[s]; }catch(_s){}
       try{ var rb=document.getElementById('raidfsbtn'); if(rb) rb.style.display='none'; }catch(_b){}
       try{ if(pauseOpen) togglePauseBox(false); }catch(_p){}
       try{ var K2=__keys(); for(var q2 in K2) delete K2[q2]; }catch(_k){}
       try{ if(state==='raid'&&G&&!G.over) __endRaid('abandon'); }catch(_e){}
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'35.02',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
