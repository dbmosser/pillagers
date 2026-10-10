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

if ($s.Contains("  {v:'22.16',what:")) { throw "check 22.16 is in the fixture already" }

SubRx @'
  {v:'22.15',what:
'@ @'
  {v:'22.16',what:'the lift sector map draws each extraction ring where the raid puts it, and the world size left by the last raid does not move them',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof sectorPreviewDraw!=='function'||typeof FIXED_MAPS==='undefined'||!FIXED_MAPS[0]) return 'SKIP: no raid or sector map here';
     if(CFG.extOutside===0) return 'SKIP: rings are not moved out of buildings under these dials';
     var bad=[], g, M=FIXED_MAPS[0], live=[], moved=0, i, arcs, sc, ox, oy, oW=WORLD_W, oH=WORLD_H, miss;
     function draw(){
       var a=[], cvx=document.createElement('canvas'), ctx;
       cvx.width=420; cvx.height=340; ctx=cvx.getContext('2d');
       ctx.arc=function(x,y,r,s,e2){ a.push({x:x,y:y}); return CanvasRenderingContext2D.prototype.arc.call(this,x,y,r,s,e2); };
       try{ sectorPreviewDraw(cvx,M); } finally { delete ctx.arc; }
       return a;
     }
     function missing(a){
       var n=0, k, q, ok;
       for(k=0;k<live.length;k++){ ok=false; for(q=0;q<a.length;q++) if(Math.abs(a[q].x-(ox+live[k].x*sc))<0.6&&Math.abs(a[q].y-(oy+live[k].y*sc))<0.6){ ok=true; break; } if(!ok) n++; }
       return n;
     }
     try{
       __topClear(); __runPrep(); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.map||!g.map.extracts) return 'SKIP: staging: no raid';
       if(g.map.fixed!==M.id) return 'SKIP: staging: the raid is not on '+M.name;
       for(i=0;i<g.map.extracts.length;i++){
         live.push({x:g.map.extracts[i].x,y:g.map.extracts[i].y});
         if(M.extracts[i]&&Math.hypot(M.extracts[i].x-live[i].x,M.extracts[i].y-live[i].y)>20) moved++;
       }
       g.player.downed=false; __endRaid('abandon');
       if(!moved) return 'SKIP: staging: no ring on '+M.name+' was moved out of a building';
       sc=Math.min(420/M.w,340/M.h); ox=(420-M.w*sc)/2; oy=(340-M.h*sc)/2;
       arcs=draw();
       if(arcs.length!==live.length) bad.push('the lift map drew '+arcs.length+' rings for the '+live.length+' in the raid');
       miss=missing(arcs);
       if(miss) bad.push(miss+' of '+live.length+' rings on the lift map are not where the raid puts them ('+moved+' were moved out of buildings)');
       WORLD_W=600; WORLD_H=600;
       arcs=draw();
       WORLD_W=oW; WORLD_H=oH;
       miss=missing(arcs);
       if(miss) bad.push('with another world size left over, '+miss+' rings on the lift map moved');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       WORLD_W=oW; WORLD_H=oH;
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'22.15',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
