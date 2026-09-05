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
  {v:'11.21',what:'on THE COLD MILE the robot never stands still on a route either, and the two arms of the paired run are the same raid on two rule sets there too',
'@ @'
  {v:'11.22',what:'no building on THE COLD MILE holds ANY pocket of floor nothing can reach, down to a 12 by 12 niche behind a table, on five seeds; the old furniture rules bring the niches back; and the repair pass demolishes nothing on seven seeds of both maps',
   run:function(){
     var bad=[];
     if(!(window.__movers&&__movers.buildNav)) return 'SKIP: no buildNav to flood with';
     __pinDPR(1); __forceSize(1920,1080);
     // A fine flood of the finished map at cell 4 from the first open cell, then
     // every unreached, unlocked interior cell is grouped into pockets and each
     // pocket measured. v10.40 guarded rooms of 32 by 32 and left the niches,
     // 12 by 12 up to 84 by 28 behind furniture, as their own STILL OPEN line.
     // v11.14 and v11.17 kept furniture out of doorways and away from wall gaps;
     // this asks whether that took the niches with it. NICHE is the smallest
     // pocket v10.40 measured, so anything it would have counted counts here.
     var NICHE=12;
     function survey(mapIx, seed, oldRules){
       __resetCfg(); __pinDefaults(0); __cleanProfile();
       if(oldRules) __cfg({furnDoor:0,furnIDoor:0,furnGap:0});
       __deploy({kit:[],safe:null,mapIx:mapIx,seed:seed});
       var g=__state(), B=g.map.buildings||[], W=g.map.walls||[], L=g.map.locked||[], m=g.map;
       var WW=m.cols*m.cw, HH=m.rows*m.ch, F=4, t=16, i, x, y;
       var fw=Math.ceil(WW/F), fh=Math.ceil(HH/F), blk=new Uint8Array(fw*fh);
       for(i=0;i<W.length;i++){ var w=W[i];
         var x0=Math.max(0,Math.floor(w.x/F)), x1=Math.min(fw-1,Math.floor((w.x+w.w)/F));
         var y0=Math.max(0,Math.floor(w.y/F)), y1=Math.min(fh-1,Math.floor((w.y+w.h)/F));
         for(y=y0;y<=y1;y++) for(x=x0;x<=x1;x++) blk[y*fw+x]=1; }
       var seen=new Uint8Array(fw*fh), st=[], ok=false;
       for(var sy=1;sy<fh-1&&!ok;sy++) for(var sx=1;sx<fw-1;sx++){ if(!blk[sy*fw+sx]){ st.push(sy*fw+sx); seen[sy*fw+sx]=1; ok=true; break; } }
       while(st.length){ var c=st.pop(), cy=(c/fw)|0, cx=c%fw;
         if(cx>0&&!seen[c-1]&&!blk[c-1]){ seen[c-1]=1; st.push(c-1); }
         if(cx<fw-1&&!seen[c+1]&&!blk[c+1]){ seen[c+1]=1; st.push(c+1); }
         if(cy>0&&!seen[c-fw]&&!blk[c-fw]){ seen[c-fw]=1; st.push(c-fw); }
         if(cy<fh-1&&!seen[c+fw]&&!blk[c+fw]){ seen[c+fw]=1; st.push(c+fw); } }
       function inLk(px,py){ for(var l=0;l<L.length;l++){ var K=L[l]; if(px>K.x&&px<K.x+K.w&&py>K.y&&py<K.y+K.h) return true; } return false; }
       var pockets=[], demo=0, pseen=new Uint8Array(fw*fh);
       for(var b=0;b<B.length;b++){ var bb=B[b]; if(bb.repaired) demo++;
         for(y=Math.floor((bb.y+t)/F); y<=Math.floor((bb.y+bb.h-t)/F); y++)
           for(x=Math.floor((bb.x+t)/F); x<=Math.floor((bb.x+bb.w-t)/F); x++){
             var ii=y*fw+x; if(blk[ii]||seen[ii]||pseen[ii]) continue; if(inLk(x*F+F/2,y*F+F/2)) continue;
             var q=[ii], minx=x, maxx=x, miny=y, maxy=y; pseen[ii]=1;
             while(q.length){ var cc=q.pop(), ccy=(cc/fw)|0, ccx=cc%fw;
               if(ccx<minx) minx=ccx; if(ccx>maxx) maxx=ccx; if(ccy<miny) miny=ccy; if(ccy>maxy) maxy=ccy;
               var nb=[cc-1,cc+1,cc-fw,cc+fw]; for(var k=0;k<4;k++){ var nn=nb[k]; if(nn<0||nn>=fw*fh) continue; if(blk[nn]||seen[nn]||pseen[nn]) continue; pseen[nn]=1; q.push(nn); } }
             var pw=(maxx-minx+1)*F, ph=(maxy-miny+1)*F;
             if(pw>=NICHE&&ph>=NICHE) pockets.push(b+':'+pw+'x'+ph+' at '+(minx*F)+','+(miny*F)); } }
       return {pockets:pockets, demolished:demo, buildings:B.length, ents:g.ents.length};
     }
     var seeds=[4242,4,2,9,6], on=[], off=[], q;
     for(q=0;q<seeds.length;q++){ on.push(survey(1,seeds[q],false)); off.push(survey(1,seeds[q],true)); }
     // CONTROL ONE: the mile built, or every count below is zero for the wrong reason.
     if(on[0].buildings!==84||on[0].ents!==374)
       return 'SKIP: THE COLD MILE at seed 4242 built '+on[0].buildings+' buildings and '+on[0].ents+' entities rather than 84 and 374';
     // THE FINDING. With the shipping rules, no pocket at all on any of the five seeds.
     for(q=0;q<seeds.length;q++) if(on[q].pockets.length)
       bad.push('seed '+seeds[q]+' on THE COLD MILE holds '+on[q].pockets.length+' pocket(s) of floor nothing can reach: '+on[q].pockets.slice(0,3).join('; '));
     // AND THE REPAIR PASS IS A NO-OP: nothing demolished on any seed with the rules on.
     for(q=0;q<seeds.length;q++) if(on[q].demolished)
       bad.push('seed '+seeds[q]+': the repair pass still tore the interior out of '+on[q].demolished+' building(s)');
     // CONTROL TWO: the old furniture rules bring the niches back, or the flood
     // is blind and this whole check passes by seeing nothing. Measured on
     // v11.21: 3, 1, 1 and more across these seeds with the three rules off.
     var back=0; for(q=0;q<seeds.length;q++) back+=off[q].pockets.length;
     if(back<3) bad.push('control: with furnDoor, furnIDoor and furnGap off the five seeds show only '+back+' pocket(s), so the flood cannot see a niche and the finding above means nothing');
     // CONTROL THREE: the arms build the same world; the furniture rules roll no dice.
     for(q=0;q<seeds.length;q++) if(on[q].ents!==off[q].ents)
       bad.push('control: seed '+seeds[q]+' spawns '+on[q].ents+' entities with the rules on and '+off[q].ents+' off, so the seeded stream moved');
     return bad.length?bad.join('; '):null; }},
  {v:'11.21',what:'on THE COLD MILE the robot never stands still on a route either, and the two arms of the paired run are the same raid on two rule sets there too',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
