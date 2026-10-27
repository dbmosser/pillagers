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

if ($s.Contains("  {v:'35.06',what:")) { throw "check 35.06 is in the fixture already" }

SubRx @'
  {v:'35.05',what:
'@ @'
  {v:'35.06',what:'cw-fogwar (his order of 10-27): with fog of war on, ground not yet explored is black on the map screen; off keeps the map as it was',
   run:function(){
     if(typeof fowMark!=='function'||typeof fowMask!=='function') return 'no fog of war option in this build';
     var bad=[], fw0=CFG.fogWar, W0=W, H0=H, di0=CanvasRenderingContext2D.prototype.drawImage, hits=[];
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(state!=='raid'||!G||G.over) throw new Error('no live raid to test on');
       G.mapFirst=0; G.mapOpen=false; if(pauseOpen) togglePauseBox(false); syncPause();
       CFG.fogWar=1; G.fow=null; G._fowT=-1; fowMark();
       var p=G.player;
       if(!fowAt(p.x,p.y)) bad.push('the ground under the player is not explored after a look');
       var fx=(p.x<WORLD_W/2)?WORLD_W-10:10, fy=(p.y<WORLD_H/2)?WORLD_H-10:10;
       if(fowAt(fx,fy)) bad.push('the far corner '+fx+','+fy+' counts as explored at raid start');
       W=1920; H=1080; G.mapOpen=true; G.mapFirst=0;
       CanvasRenderingContext2D.prototype.drawImage=function(im){ if(im&&im===G._fowCv) hits.push([].slice.call(arguments,1)); return di0.apply(this,arguments); };
       drawMapOverlay();
       var M=mapProj(), want=G.seen.w*FOG_CELL*M.sc;
       var ok=hits.some(function(a){ var n=a.length; return Math.abs(a[n-4]-M.ox)<2&&Math.abs(a[n-3]-M.oy)<2&&Math.abs(a[n-2]-want)<2; });
       if(!ok) bad.push('fog on: the map screen did not lay the unexplored mask over the map ('+hits.length+' mask draws)');
       hits.length=0; CFG.fogWar=0; drawMapOverlay();
       if(hits.length) bad.push('fog off: the map screen still drew the mask');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ CanvasRenderingContext2D.prototype.drawImage=di0; }catch(_d){}
       try{ CFG.fogWar=fw0; W=W0; H=H0; if(G) G.mapOpen=false; }catch(_r){}
       try{ if(pauseOpen) togglePauseBox(false); }catch(_p){}
       try{ var K2=__keys(); for(var q2 in K2) delete K2[q2]; }catch(_k){}
       try{ if(state==='raid'&&G&&!G.over) __endRaid('abandon'); }catch(_e){}
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'35.05',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
