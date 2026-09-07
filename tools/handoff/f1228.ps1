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

# v12.28 CHECK, inserted before the v12.27 entry. Seed 555 on THE COLD MILE
# seals five bodies under the old placement (the dial unseal 0 is the control
# arm, so the staging proves it can seal), and none under the new; the body
# and container counts must not move, every body that moved must sit outside
# its vault within 400 units of the door and clear of walls, and seed 4242 on
# COLD STORAGE must still count 85 bodies and 165 containers.
SubRx @'
  {v:'12.27',what:'a free-kit run that ends dead gives back the tactical belt plan and the gun slot with the packing, minus a key whose item did not come back; a clean extraction restores neither, as before (the v12.13 not-verified line)',
'@ @'
  {v:'12.28',what:'no machine or pillager is born inside a locked room: the old placement (dial unseal 0) seals bodies at seed 555 on THE COLD MILE and the new seals none, with the same body and container counts, each moved body outside its vault near its door and clear of walls, and the seed 4242 fingerprint 85 and 165 unchanged (his 2026-09-06 note that crawlers still get stuck chasing)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof wallsNear!=='function') return 'SKIP: no wall grid query in this build';
     var bad=[];
     function inside(e,R){ return e.x>R.x&&e.x<R.x+R.w&&e.y>R.y&&e.y<R.y+R.h; }
     function sealed(g){ var L=g.map.locked||[], n=0; for(var i=0;i<g.ents.length;i++) for(var j=0;j<L.length;j++) if(inside(g.ents[i],L[j])) n++; return n; }
     function endIt(){ try{ var g=__state(); if(g&&!g.over){ g.player.downed=false; __endRaid('extract'); } }catch(_x){} __topClear(); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       // CONTROL ARM: the old placement, by the dial.
       CFG.unseal=0;
       __deploy({kit:[],safe:null,mapIx:1,seed:555});
       var g0=__state(), L=g0.map.locked||[];
       if(!L.length) return 'SKIP: no locked rooms on this map';
       var n0=sealed(g0), e0=g0.ents.length, c0=g0.containers.length;
       var P0=g0.ents.map(function(e){ return {x:e.x,y:e.y,kind:e.kind}; });
       if(n0<1) bad.push('control: the old placement sealed nobody at this seed, so the sweep has nothing to prove here');
       endIt();
       // THE BUILD.
       CFG.unseal=1;
       __deploy({kit:[],safe:null,mapIx:1,seed:555});
       var g1=__state(), n1=sealed(g1);
       if(n1) bad.push(n1+' bodies are still born inside a locked room');
       if(g1.ents.length!==e0) bad.push('the sweep changed the body count ('+e0+' to '+g1.ents.length+')');
       if(g1.containers.length!==c0) bad.push('the sweep changed the container count ('+c0+' to '+g1.containers.length+')');
       var moved=0, i, j;
       for(i=0;i<Math.min(e0,g1.ents.length);i++){
         var a=P0[i], b=g1.ents[i];
         if(a.kind!==b.kind) { bad.push('the bodies came out in a different order at index '+i); break; }
         if(Math.abs(a.x-b.x)<0.01&&Math.abs(a.y-b.y)<0.01) continue;
         moved++;
         var nearDoor=false, inVault=false;
         for(j=0;j<L.length;j++){ var R=L[j]; if(inside(b,R)) inVault=true; var dx=b.x-R.doorX, dy=b.y-R.doorY; if(Math.sqrt(dx*dx+dy*dy)<400) nearDoor=true; }
         if(inVault) bad.push(b.kind+' at index '+i+' was moved but is still inside a vault');
         if(!nearDoor) bad.push(b.kind+' at index '+i+' was moved more than 400 units from any vault door');
         var pad=(b.r||14)+8, nw=wallsNear(G.wgrid,b.x,b.y,pad);
         for(var w=0;w<nw.length;w++){ var W=nw[w]; if(b.x>W.x-pad&&b.x<W.x+W.w+pad&&b.y>W.y-pad&&b.y<W.y+W.h+pad){ bad.push(b.kind+' at index '+i+' was moved into a wall'); break; } }
       }
       if(moved!==n0) bad.push('the old placement sealed '+n0+' bodies and the new one moved '+moved);
       endIt();
       // THE FINGERPRINT: seed 4242 on COLD STORAGE still counts 85 bodies and 165 containers, one of them the elite crawler walked out of the freezer.
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g2=__state();
       if(g2.ents.length!==85||g2.containers.length!==165) bad.push('seed 4242 counts '+g2.ents.length+' bodies and '+g2.containers.length+' containers, not 85 and 165');
       if(sealed(g2)) bad.push('seed 4242 still seals '+sealed(g2)+' body');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{ try{ __resetCfg(); }catch(_c){} endIt(); __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'12.27',what:'a free-kit run that ends dead gives back the tactical belt plan and the gun slot with the packing, minus a key whose item did not come back; a clean extraction restores neither, as before (the v12.13 not-verified line)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
