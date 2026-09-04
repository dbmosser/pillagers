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
  {v:'10.81',what:'some buildings on both maps are destroyed: whole runs of outer wall gone so you can walk in from any side, with their rooms still standing and nothing sealed behind them',
'@ @'
  {v:'10.82',what:'a destroyed building looks destroyed: its floor is burnt and covered in rubble, and the building next door is untouched',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__cfg)) return 'SKIP: this fixture cannot build a map with a dial';
     var bad=[];
     // MEASURED on COLD STORAGE at seed 4242 before the floors below were set:
     // the ruined building moved 99.47 percent of its floor pixels and its mean
     // brightness fell 124.76 to 114.30. The building next door moved 0.08
     // percent and did not change brightness at all. Floors at half the signal,
     // ceiling far above the noise, per the v10.79 rule.
     var HIT=45, DROP=4.0, QUIET=3;
     function arm(rate,mi){
       __runPrep(); __resetCfg(); __pinDefaults(0); __cfg({bldgRuin:rate});
       __deploy({kit:[],safe:null,mapIx:mi,seed:4242});
       var g=__state();
       if(!g.ground) return null;
       return {g:g,cx:g.ground.getContext('2d')};
     }
     function look(cx,r){
       var d=cx.getImageData(r.x,r.y,r.w,r.h).data,s=0;
       for(var i=0;i<d.length;i+=4) s+=(d[i]+d[i+1]+d[i+2])/3;
       return {d:d,mean:s/(d.length/4)};
     }
     function moved(a,b){
       var c=0; for(var i=0;i<a.d.length;i+=4)
         if(Math.abs(a.d[i]-b.d[i])+Math.abs(a.d[i+1]-b.d[i+1])+Math.abs(a.d[i+2]-b.d[i+2])>10) c++;
       return c/(a.d.length/4)*100;
     }
     var mi, ruinsSeen=0;
     for(mi=0;mi<2;mi++){
       var off=arm(0,mi), on=arm(0.09,mi);
       if(!off||!on) return 'SKIP: this build bakes no ground canvas';
       var nm=(mi===0?'COLD STORAGE':'THE COLD MILE'), B=on.g.map.buildings, q;
       // THE WORLD MUST NOT HAVE MOVED. Paint is paint; if this pass ever drew a
       // random number the whole seeded map would drift behind it.
       if(off.g.ents.length!==on.g.ents.length||off.g.containers.length!==on.g.containers.length)
         bad.push(nm+' moved its world when only the ground paint changed, '+
                  off.g.ents.length+'/'+off.g.containers.length+' against '+on.g.ents.length+'/'+on.g.containers.length);
       for(q=0;q<B.length;q++){
         var b=B[q];
         if(b.w<80||b.h<80) continue;
         var r={x:b.x+20,y:b.y+20,w:b.w-40,h:b.h-40};
         if(r.w<20||r.h<20) continue;
         var A=look(off.cx,r), C=look(on.cx,r), mv=moved(A,C);
         if(b.ruined){
           ruinsSeen++;
           if(mv<HIT) bad.push(nm+' building '+q+' is destroyed and only '+mv.toFixed(1)+' percent of its floor changed, under the '+HIT+' a burnt floor has to clear');
           if(A.mean-C.mean<DROP) bad.push(nm+' building '+q+' is destroyed and its floor went from '+A.mean.toFixed(1)+' to '+C.mean.toFixed(1)+', which is not a burn');
         } else {
           // AND ONLY THE ONES THAT FELL. Painting every floor would satisfy
           // every line above and tell a player nothing.
           if(mv>QUIET) bad.push(nm+' building '+q+' is standing and '+mv.toFixed(1)+' percent of its floor changed anyway');
         }
       }
       // CONTROL: open ground well away from any ruin is untouched, so the paint
       // is a mark on a building and not a wash over the map.
       var far=null, fx, fy, tries;
       for(tries=0;tries<400&&!far;tries++){
         fx=200+((tries*617)%(on.g.map.cw*on.g.map.cols-500));
         fy=200+((tries*971)%(on.g.map.ch*on.g.map.rows-500));
         var clear=true;
         for(q=0;q<B.length;q++){ var b2=B[q];
           if(fx<b2.x+b2.w+300&&fx+180>b2.x-300&&fy<b2.y+b2.h+300&&fy+180>b2.y-300){ clear=false; break; } }
         if(clear) far={x:fx,y:fy,w:180,h:180};
       }
       if(far){
         var F1=look(off.cx,far), F2=look(on.cx,far), fmv=moved(F1,F2);
         if(fmv>QUIET) bad.push('control: open ground on '+nm+' changed '+fmv.toFixed(1)+' percent, so this is a wash over the map rather than a mark on a building');
       }
     }
     if(ruinsSeen<2) bad.push('control: only '+ruinsSeen+' destroyed buildings were found to look at, so this check proved nothing');
     __resetCfg();
     return bad.length?bad.join('; '):null; }},
  {v:'10.81',what:'some buildings on both maps are destroyed: whole runs of outer wall gone so you can walk in from any side, with their rooms still standing and nothing sealed behind them',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
