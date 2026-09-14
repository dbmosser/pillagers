$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

SubRx @'
  {v:'14.33',what:
'@ @'
  {v:'14.34',what:'an opened wall opens the placement grids: with every wall of a live raid removed and the geometry rebuilt, the reachable area grows past what the drop reached before and the free-spot wall grid is dropped (weather audit finding 4)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof rebuildGeometry!=='function'||typeof navReach!=='function') return 'SKIP: no geometry rebuild or reach flood in this build';
     var bad=[], g0=null;
     var count=function(gr){ var c=0,i; if(!gr) return 0; if(typeof gr.length==='number'){ for(i=0;i<gr.length;i++) if(gr[i]) c++; } else { for(i in gr) if(gr[i]) c++; } return c; };
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(); if(!g||!g.player||!g.map) return 'SKIP: no live raid';
       g0=g;
       var before=g.map.reachGrid;
       if(!before) return 'SKIP: this raid was built without a reachable-area flood';
       var nBefore=count(before);
       // A stand-in free-spot grid, the kind that passes its identity test after an in-place splice.
       g.map._fsGrid={walls:g.map.walls};
       // Every wall comes down, in place, the way a door or a destroyed wall leaves the array.
       g.map.walls.splice(0,g.map.walls.length);
       rebuildGeometry();
       var after=g.map.reachGrid, nAfter=count(after);
       if(!after) bad.push('after the rebuild there is no reachable-area grid at all, so every spot reads reachable');
       else if(!(nAfter>nBefore)) bad.push('with every wall gone the reachable area still covers '+nAfter+' cells, the '+nBefore+' the drop reached before');
       if(g.map._fsGrid&&g.map._fsGrid.walls===g.map.walls) bad.push('the free-spot wall grid survived the rebuild and still counts the removed walls');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(g0&&!g0.over) __endRaid('abandon'); }catch(_e){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'14.33',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
