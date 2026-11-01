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

if ($s.Contains("  {v:'37.02',what:")) { throw "check 37.02 is in the fixture already" }

SubRx @'
  {v:'37.01',what:
'@ @'
  {v:'37.02',what:'the game keeps ONE running total of its off screen picture stores (count and estimated bytes) in the frame telemetry, the run record and the flight recorder line (research row 17, the 3 hour party)',
   run:function(){
     var bad=[], g=null, T=null, t0, t1, cv, pre=null, rec=null, ex='', want=0, nm;
     try{
       if(typeof picStoreTotal!=='function') return 'the game keeps no total of its picture stores (no picStoreTotal)';
       if(!(window.__gfxStage&&window.__endRaid)) return 'SKIP: this fixture has no gfx stage';
       g=__gfxStage({frames:90});
       if(!g||g.sim) return 'SKIP: no live raid staged';
       T=g.tel&&g.tel.gfx;
       if(!T||!T.pic) bad.push('the frame telemetry carries no pic row after 90 frames');
       else if(!(T.pic.n>0&&T.pic.b>0)) bad.push('the telemetry total reads '+T.pic.n+' pictures and '+T.pic.b+' bytes in a raid with walls drawn');
       t0=picStoreTotal(true);
       want=Object.keys(WALLSPR.m).length+Object.keys(VEGSPR.m).length+Object.keys(SHADSPR.m).length+Object.keys(ICONSPR.m).length+PIXSTORE.m.actors.size+PIXSTORE.m.scene.size;
       for(nm in GFXSTORES) want+=Object.keys(GFXSTORES[nm].m).length;
       if(t0.n-t0.by.big[0]!==want) bad.push('the total counts '+(t0.n-t0.by.big[0])+' stored pictures, the stores hold '+want);
       cv=document.createElement('canvas'); cv.width=10; cv.height=10;
       ICONSPR.m.__picprobe={c:cv,s:1};
       t1=picStoreTotal(true);
       delete ICONSPR.m.__picprobe;
       if(t1.n!==t0.n+1||t1.b!==t0.b+400) bad.push('one 10x10 picture added to a store moved the total from '+t0.n+'/'+t0.b+' to '+t1.n+'/'+t1.b+', not +1/+400');
       if(!(t1.pn>=t1.n&&t1.pb>=t1.b)) bad.push('the peak is below the total');
       pre=(typeof pendingRun!=='undefined')?pendingRun:null;
       __endRaid('abandon');
       rec=(typeof pendingRun!=='undefined')?pendingRun:null;
       if(rec&&rec!==pre){
         if(!rec.gfx||!rec.gfx.pic) bad.push('the run record carries no pic row');
         else {
           if(!(rec.gfx.pic.n>0)) bad.push('the run record total is empty');
           if(!/ pics:\d+\/[\d.]+mb peak:\d+\/[\d.]+mb by:wall \d+/.test(picLine(rec.gfx.pic))) bad.push('the run line reads: '+picLine(rec.gfx.pic).slice(0,120));
         }
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ delete ICONSPR.m.__picprobe; }catch(_pp){}
       try{ var g2=__state(); if(g2&&!g2.over&&!g2.sim) __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'37.01',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
