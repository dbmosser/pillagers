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

if ($s.Contains("  {v:'35.04',what:")) { throw "check 35.04 is in the fixture already" }

SubRx @'
  {v:'35.03',what:
'@ @'
  {v:'35.04',what:'cw-fsgatezoom, the fullscreen gate of his 2026-10-27 order takes the menu screen factor like the pause menu, so at 4K it is not half the size of every other window',
   run:function(){
     if(typeof fsGateShow!=='function'||typeof menuScale!=='function'||typeof FSG!=='object') return 'no fullscreen gate here';
     var bad=[], ms0=menuScale, ff0=fsFull, fsg0={ok:FSG.ok,force:FSG.force,why:FSG.why,was:FSG.was};
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       fsFull=function(){ return false; }; FSG.force=1; FSG.ok=0; FSG.why='start';
       menuScale=function(){ return 1; }; fsGateShow('start');
       var g=document.getElementById('fsgate'), c=g&&g.firstElementChild;
       if(!c) throw new Error('the gate has no card');
       var w1=c.getBoundingClientRect().width;
       fsGateHide();
       menuScale=function(){ return 2; }; fsGateShow('start');
       var w2=c.getBoundingClientRect().width;
       if(parseFloat(g.style.zoom||'1')!==2) bad.push('the gate zoom is '+(g.style.zoom||'none')+' while the menus are at 2');
       if(!(w2>w1+1)) bad.push('the gate card is '+Math.round(w2)+'px wide at a menu factor of 2, '+Math.round(w1)+'px at 1');
       menuScale=function(){ return 1.5; }; fsRaidBtnSync();
       if(parseFloat(g.style.zoom||'1')!==1.5) bad.push('the open gate did not follow a new menu factor (a window resize): zoom '+(g.style.zoom||'none'));
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ menuScale=ms0; }catch(_m){}
       try{ fsFull=ff0; }catch(_r){}
       try{ FSG.why='start'; fsGateHide(); }catch(_h){}
       try{ var g2=document.getElementById('fsgate'); if(g2) g2.style.zoom=''; }catch(_z){}
       try{ for(var q in fsg0) FSG[q]=fsg0[q]; }catch(_q){}
       try{ var rb=document.getElementById('raidfsbtn'); if(rb) rb.style.display='none'; }catch(_b){}
       try{ var K2=__keys(); for(var q2 in K2) delete K2[q2]; }catch(_k){}
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'35.03',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
