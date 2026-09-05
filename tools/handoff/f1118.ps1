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

# v11.16's OLD ARM MUST KEEP THE OLD PARTITIONS. Its control drives building
# 20 with the old carve and expects the crawler to stand at the partition that
# ran into the door next door; with that partition trimmed there is nothing to
# stand against, so the old arm turns partDoor off as well.
SubRx @'
     function drive(mi,bIx,doorClear,frames,rectWant){
       __runPrep(); __resetCfg(); __pinDefaults(0); __cfg({doorClear:doorClear});
'@ @'
     function drive(mi,bIx,doorClear,frames,rectWant){
       __runPrep(); __resetCfg(); __pinDefaults(0); __cfg({doorClear:doorClear,partDoor:doorClear});
'@

SubRx @'
  {v:'11.17',what:'the doorways inside buildings are recorded and kept clear of furniture, so every building interior has a route in from its own front door',
'@ @'
  {v:'11.18',what:'no interior wall ends inside a doorway, so every front door opens onto floor a body can stand on',
   run:function(){
     if(!(window.__deploy&&window.__state)) return 'SKIP: this fixture cannot build a map';
     var bad=[], NM=['COLD STORAGE','THE COLD MILE'];
     // A door is DEAD when a partition reaches into its opening and leaves under
     // 30 units on both sides of itself; TOUCHED when a partition reaches in at
     // all. The zone is the gap grown 40 through the wall.
     function survey(mi,dial){
       __runPrep(); __resetCfg(); __pinDefaults(0); __cfg({partDoor:dial});
       __deploy({kit:[],safe:null,mapIx:mi,seed:4242});
       var g=__state(),W=g.map.walls,Ds=g.map.doors,dead=[],touched=0,i,j;
       for(i=0;i<Ds.length;i++){ var d=Ds[i],h=d.w>=d.h;
         var zx=h?d.x:d.x-40, zy=h?d.y-40:d.y, zw=h?d.w:d.w+80, zh=h?d.h+80:d.h, worst=null;
         for(j=0;j<W.length;j++){ var w=W[j]; if(w.furn||w.ib===undefined) continue;
           if(w.x<zx+zw&&w.x+w.w>zx&&w.y<zy+zh&&w.y+w.h>zy){
             touched++;
             var lo=h?d.x:d.y, hi=h?d.x+d.w:d.y+d.h, a=h?w.x:w.y, b=h?w.x+w.w:w.y+w.h;
             var room=Math.max(a-lo,hi-b);
             if(worst===null||room<worst) worst=room; } }
         if(worst!==null&&worst<30) dead.push(i); }
       return {doors:Ds.length,touched:touched,dead:dead,ents:g.ents.length,cont:(g.containers||[]).length};
     }
     var on=[survey(0,1),survey(1,1)], off=[survey(0,0),survey(1,0)], mi;
     for(mi=0;mi<2;mi++){
       // THE FINDING. Measured on v11.17: 0 dead of 37 and 4 dead of 151, and
       // 3 and 19 touched.
       if(on[mi].dead.length) bad.push(NM[mi]+': '+on[mi].dead.length+' of '+on[mi].doors+' front doors open onto the end of an interior wall with under 30 units either side ['+on[mi].dead.join(',')+']');
       if(on[mi].touched) bad.push(NM[mi]+': '+on[mi].touched+' partitions still reach into a doorway zone');
       // CONTROL: the world did not move. The cut draws no random number.
       if(on[mi].ents!==off[mi].ents||on[mi].cont!==off[mi].cont) bad.push(NM[mi]+': entities or containers moved between the arms, '+off[mi].ents+'/'+off[mi].cont+' to '+on[mi].ents+'/'+on[mi].cont+', so the cut drew a random number');
     }
     // CONTROL TWO: the old partitions must still show the fault on the mile.
     if(off[1].dead.length<3) bad.push('control: with partDoor off THE COLD MILE has only '+off[1].dead.length+' dead doors against the 4 measured, so the dial does not restore the old partitions');
     if(off[1].touched<12) bad.push('control: with partDoor off only '+off[1].touched+' partitions reach into a doorway zone on the mile against the 19 measured');
     return bad.length?bad.join('; '):null; }},
  {v:'11.17',what:'the doorways inside buildings are recorded and kept clear of furniture, so every building interior has a route in from its own front door',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
