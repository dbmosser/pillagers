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
  {v:'10.92',what:'your own marker on the map is far bigger
'@ @'
  {v:'10.93',what:'the Undercroft station names are painted on top of the room darkness rather than under it, they are no longer see-through, and the racks are called FASHION',
   run:function(){
     if(!(window.__hubEnter&&window.__hubFrame&&window.__hubStep&&window.__canvases&&window.__hub))
       return 'SKIP: this fixture cannot draw the Undercroft';
     if(!__vpAlive()) return 'SKIP: the pane has no layout, there are no pixels to read';
     var bad=[];
     __runPrep(); __resetCfg(); __pinDefaults(0); __forceSize(1920,1080);
     __hubEnter(); for(var f=0;f<12;f++) __hubStep(0.016);
     var CN=__canvases(), wx=CN.world.getContext('2d'), HB=__hub();
     if(!HB||!HB.stations||HB.stations.length<4) return 'SKIP: the Undercroft has no stations to read';
     var names={}, i;
     for(i=0;i<HB.stations.length;i++) names[HB.stations[i].label]=HB.stations[i].id;
     // HIS NOTE ASKS ABOUT WHAT HE SEES, so measure what he sees: draw the same
     // frame twice, once with the station names not painted, and difference the
     // two. What is left in each name's rectangle is exactly the ink that name
     // contributes to the FINISHED picture, after every layer over it. Both
     // draws go through __hubFrame, which draws and advances nothing, so the
     // lamps flicker identically and the only difference is the text.
     function ink(){
       var proto=CanvasRenderingContext2D.prototype, orig=proto.fillText, box=[];
       proto.fillText=function(t,x,y){
         if(names[String(t)]){ var T=this.getTransform();
           box.push({id:names[String(t)],x:T.a*x+T.c*y+T.e,y:T.b*x+T.d*y+T.f,
                     w:this.measureText(String(t)).width*T.a,align:this.textAlign,
                     px:(function(g){ var m=/([\d.]+)px/.exec(g); return m?+m[1]*T.a:0; })(this.font)}); }
         return orig.apply(this,arguments);
       };
       try{ __hubFrame(0.016); } finally { proto.fillText=orig; }
       var A=wx.getImageData(0,0,CN.world.width,CN.world.height).data;
       proto.fillText=function(t){ if(names[String(t)]) return; return orig.apply(this,arguments); };
       try{ __hubFrame(0.016); } finally { proto.fillText=orig; }
       var B=wx.getImageData(0,0,CN.world.width,CN.world.height).data;
       var Wd=CN.world.width, out=[], lum=0;
       for(var q2=0;q2<B.length;q2+=4) lum+=B[q2]+B[q2+1]+B[q2+2];
       for(var k=0;k<box.length;k++){
         var e=box[k];
         var x0=Math.max(0,Math.round(e.align==='center'?e.x-e.w/2:e.x)), y0=Math.max(0,Math.round(e.y-e.px));
         var w=Math.min(Wd-x0,Math.round(e.w)), h=Math.min(CN.world.height-y0,Math.round(e.px*1.4));
         if(w<3||h<3) continue;
         var nn=0,sum=0;
         for(var y=0;y<h;y++) for(var x=0;x<w;x++){
           var q=((y0+y)*Wd+(x0+x))*4;
           var d=Math.max(Math.abs(A[q]-B[q]),Math.abs(A[q+1]-B[q+1]),Math.abs(A[q+2]-B[q+2]));
           if(d>6){ nn++; sum+=d; }
         }
         out.push({id:e.id,px:nn,mean:nn?Math.round(sum/nn):0});
       }
       return {rows:out,room:lum/(B.length/4)/3};
     }
     function avg(a){ var s2=0,c2=0; for(var j=0;j<a.length;j++){ if(a[j].px>50){ s2+=a[j].mean; c2++; } } return c2?(s2/c2):0; }
     var lit=ink();
     // CONTROL FIRST: the instrument has to have found the names at all. If
     // suppressing them changed nothing, every number below is furniture.
     if(lit.rows.length<4) bad.push('control: only '+lit.rows.length+' station names were found on the drawn frame, so this is not measuring the Undercroft');
     var thin=[];
     for(i=0;i<lit.rows.length;i++) if(lit.rows[i].px<50) thin.push(lit.rows[i].id);
     if(thin.length) bad.push('control: '+thin.join(', ')+' painted almost no ink either way, so the instrument cannot see them');
     // 1. THE NAMES ARE NOT SEE-THROUGH. Measured on v10.92 they averaged 78 of
     //    a possible 152 and the dimmest was 64; the floor sits well above that
     //    and above anything a partial fix would reach.
     var la=avg(lit.rows);
     if(la<130) bad.push('the station names put only '+Math.round(la)+' of ink into the picture, which is the see-through look he reported');
     for(i=0;i<lit.rows.length;i++)
       if(lit.rows[i].px>50&&lit.rows[i].mean<120)
         bad.push(lit.rows[i].id+' reads at '+lit.rows[i].mean+', still faint even if the others are not');
     // 2. AND THEY ARE ON TOP OF THE ROOM DARKNESS, NOT UNDER IT, which is the
     //    half of the defect the note does not mention and the bigger half. The
     //    room's darkness is a full-screen sheet whose weight is .40 over the
     //    brightness dial. Wind that dial down and the sheet more than doubles.
     //    A name UNDER it loses most of what is left: v10.92 fell from 78 to 49,
     //    a ratio of 0.63. A name over it does not care.
     __cfg({bright:0.4});
     for(f=0;f<3;f++) __hubStep(0.016);
     var dark=ink();
     __cfg({bright:1.7});
     for(f=0;f<3;f++) __hubStep(0.016);
     // CONTROL: the dial has to have actually darkened the room, or a ratio of
     //   1.00 means the test did nothing rather than that the fix works.
     if(!(dark.room<lit.room*0.85))
       bad.push('control: the room only went from '+lit.room.toFixed(1)+' to '+dark.room.toFixed(1)+' brightness, so the darkness test proves nothing');
     else {
       var da=avg(dark.rows), ratio=da/Math.max(1,la);
       if(ratio<0.9) bad.push('the station names dim to '+Math.round(ratio*100)+' percent of themselves when the room goes dark, so they are still painted under the darkness rather than on top of it');
     }
     // 3. HIS SECOND HALF: THE NAME. The needle is assembled rather than written,
     //    because a check that writes the phrase it is looking for finds itself.
     var oldName=['DISCOUNT','FASHION','DEPOT'].join(String.fromCharCode(32));
     var mir=null;
     for(i=0;i<HB.stations.length;i++) if(HB.stations[i].id==='mirror') mir=HB.stations[i];
     if(!mir) bad.push('control: there is no racks station in the Undercroft to name');
     else if(String(mir.label).toUpperCase().indexOf(oldName)>=0) bad.push('the racks station is still called by its old three word name on the Undercroft floor');
     else if(String(mir.label).toUpperCase().indexOf('FASHION')<0) bad.push('the racks station is called '+mir.label+', which is neither of the names he has used');
     if(typeof WHATSNEW!=='undefined'){
       var hits=0;
       for(i=0;i<WHATSNEW.length;i++) if(String(WHATSNEW[i]).toUpperCase().indexOf(oldName)>=0) hits++;
       if(hits) bad.push(hits+' lines of the new-in card still carry the old three word name');
     }
     var h3=document.querySelector('#appearmodal h3');
     if(h3&&h3.textContent.toUpperCase().indexOf(oldName)>=0) bad.push('the racks window is still titled with the old three word name');
     return bad.length?bad.join('; '):null; }},
  {v:'10.92',what:'your own marker on the map is far bigger
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
