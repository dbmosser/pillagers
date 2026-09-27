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

if ($s.Contains("  {v:'16.28',what:")) { throw "check 16.28 is in the fixture already" }

SubRx @'
  {v:'16.27',what:
'@ @'
  {v:'16.28',what:'the HP bar is always there and the belt never covers it: the vitals block does not fold; with the vitals block made twice as big the belt slots start right of it and end left of the gear readout',
   run:function(){
     if(!(window.__resetCfg&&window.__pinDefaults&&window.__startRaid&&window.__cleanProfile)||typeof drawHUD!=='function'||typeof hudOff!=='function') return 'SKIP: this fixture cannot draw the HUD';
     var bad=[], keepHud=P.hud?JSON.parse(JSON.stringify(P.hud)):undefined, c, z, bR, gL, last;
     try{
       __resetCfg(); __pinDefaults(0); __startRaid({mapIx:0,seed:4242}); G.sim=0; G.over=false;
       P.hud={body:{c:true}}; if(hudOff('body').c) bad.push('the vitals block (health) can still be folded away');
       P.hud={body:{z:2},gear:{z:1}};
       try{ drawHUD(); }catch(e){ bad.push('drawHUD threw: '+e); }
       c=G.hotCells||[]; if(!c.length) return 'SKIP: no belt cells drawn';
       z=hudRes(); bR=390*(HUDZ.body||1)*z*2; gL=W-252*(HUDZ.gear||1)*z;
       last=c[c.length-1];
       if(c[0].x<bR) bad.push('with the vitals block twice as big the first belt slot starts at '+Math.round(c[0].x)+', under the vitals block (which reaches '+Math.round(bR)+')');
       if(last.x+last.w>gL+1) bad.push('the last belt slot ends at '+Math.round(last.x+last.w)+', under the gear readout (from '+Math.round(gL)+')');
     }
     finally{
       try{ if(keepHud===undefined) delete P.hud; else P.hud=keepHud; }catch(_h){}
       try{ G=null; }catch(_g){}
       try{ __resetCfg(); }catch(_rc){}
       try{ __cleanProfile(); }catch(_cp){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'16.27',what:
'@


$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
