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

if ($s.Contains("  {v:'24.82',what:")) { throw "check 24.82 is in the fixture already" }

SubRx @'
  {v:'24.81',what:
'@ @'
  {v:'24.82',what:'his order (2026-10-12): the seal can be anywhere: 40 raids at 40 seeds put it in 25 or more places spread over the whole map, never near a spawn or a way out, never in a wall, a building or water, and the same seed puts it in the same place',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof FIXED_MAPS==='undefined') return 'SKIP: no raid here';
     var bad=[], def=FIXED_MAPS[0], SAFE=450, pts=[], i, j, g, s, a, d, B, k, ex={}, ne=0, cells={}, nc=0, cons=0, zs={}, nz=0,
         near=[], exn=[], wall=[], wet=[], inb=[], twice=[];
     function sd(n){ return n*7919; }
     try{
       __topClear(); __runPrep();
       for(s=1;s<=40;s++){
         __deploy({kit:[],safe:null,mapIx:0,seed:sd(s)});
         g=__state(); if(!g||!g.seal) return 'SKIP: no seal in the raid at seed '+sd(s);
         a={x:g.seal.x,y:g.seal.y}; pts.push(a);
         for(j=0;j<def.spawns.length;j++){ d=Math.hypot(def.spawns[j].x-a.x,def.spawns[j].y-a.y); if(d<SAFE){ near.push(sd(s)+' ('+Math.round(d)+' from a spawn)'); break; } }
         for(j=0;j<def.extracts.length;j++){ d=Math.hypot(def.extracts[j].x-a.x,def.extracts[j].y-a.y); if(d<400){ exn.push(sd(s)+' ('+Math.round(d)+')'); break; } }
         if(!spotFree(g.map,a.x,a.y,20)) wall.push(sd(s));
         if(inWaterMap(g.map,a.x,a.y)) wet.push(sd(s));
         B=(def.buildings||[]).concat(def.locked||[],(g.map.locked||[]));
         for(j=0;j<B.length;j++){ if(a.x>B[j].x&&a.x<B[j].x+B[j].w&&a.y>B[j].y&&a.y<B[j].y+B[j].h){ inb.push(sd(s)); break; } }
       }
       for(i=0;i<2;i++){
         s=(i===0)?1:40;
         __deploy({kit:[],safe:null,mapIx:0,seed:sd(s)});
         g=__state();
         if(!g||!g.seal||g.seal.x!==pts[s-1].x||g.seal.y!==pts[s-1].y) twice.push(sd(s)+': '+Math.round(pts[s-1].x)+','+Math.round(pts[s-1].y)+' then '+(g&&g.seal?Math.round(g.seal.x)+','+Math.round(g.seal.y):'none'));
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ var g2=__state(); if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){} __topClear(); }
     if(bad.length) return bad.join('; ');
     for(i=0;i<pts.length;i++){
       a=pts[i];
       k=a.x+','+a.y; if(!ex[k]){ ex[k]=1; ne++; }
       k=Math.floor(a.x/300)+','+Math.floor(a.y/300); if(!cells[k]){ cells[k]=1; nc++; }
       if(i>0&&Math.hypot(a.x-pts[i-1].x,a.y-pts[i-1].y)>300) cons++;
       for(j=0;j<(def.zones||[]).length;j++){ B=def.zones[j]; if(a.x>=B.x&&a.x<B.x+B.w&&a.y>=B.y&&a.y<B.y+B.h){ if(!zs[B.name]){ zs[B.name]=1; nz++; } break; } }
     }
     if(ne<25) bad.push('40 seeds put the seal in only '+ne+' different places');
     if(nc<22) bad.push('40 seeds put the seal in only '+nc+' different 300 unit squares of the map');
     if(cons<30) bad.push('only '+cons+' of 39 raids in a row moved the seal more than 300');
     if(nz<4) bad.push('the seal only ever stood in '+nz+' of the '+(def.zones||[]).length+' districts');
     if(near.length) bad.push('the seal stood closer than '+SAFE+' to a spawn at seed '+near.slice(0,4).join(', '));
     if(exn.length) bad.push('the seal stood beside a way out at seed '+exn.slice(0,4).join(', '));
     if(wall.length) bad.push('the seal stood in a wall at seed '+wall.slice(0,4).join(', '));
     if(wet.length) bad.push('the seal stood in water at seed '+wet.slice(0,4).join(', '));
     if(inb.length) bad.push('the seal stood inside a building or a locked room at seed '+inb.slice(0,4).join(', '));
     if(twice.length) bad.push('the same seed rolled two different doors: '+twice.join('; '));
     return bad.length?bad.join('; '):null; }},
  {v:'24.81',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
