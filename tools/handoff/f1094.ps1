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
  {v:'10.93',what:'the Undercroft station names are painted on top of the room darkness
'@ @'
  {v:'10.94',what:'nothing a face can wear is painted over the eye, across every look the Undercroft crowd can roll',
   run:function(){
     if(!(window.__opShot&&window.__canvases&&window.__crowdLook&&window.__cosOf))
       return 'SKIP: this fixture cannot draw one face at a time';
     if(!__vpAlive()) return 'SKIP: the pane has no layout, there are no pixels to read';
     var bad=[];
     __runPrep(); __resetCfg(); __pinDefaults(0); __forceSize(1920,1080);
     var CN=__canvases(), wx=CN.world.getContext('2d'), Wd=CN.world.width, Hd=CN.world.height;
     var BASE={faceMark:'faceplain',eyes:'eyeblue',skin:'skinfair',hat:'none',hair:'blonde',cut:'long',beard:'clean',tattoo:'tatnone'};
     // FIND THE EYE FROM THE DRAWING ITSELF rather than from the numbers in the
     // source, because a check that repeats the coordinates is a second copy of
     // them. The whites are the one flat colour on a lone figure.
     var r0=__opShot(BASE,0,9);
     if(!r0) return 'SKIP: this fixture cannot draw an operator';
     if(r0.thrown) return 'drawing one operator threw: '+r0.thrown;
     var A0=wx.getImageData(0,0,Wd,Hd).data, pts=[], x,y,q;
     for(y=0;y<Hd;y++) for(x=0;x<Wd;x++){ q=(y*Wd+x)*4;
       if(A0[q]===255&&A0[q+1]===246&&A0[q+2]===220) pts.push([x,y]); }
     if(pts.length<200) return 'SKIP: the eyes could not be found on the drawn face ('+pts.length+' pixels)';
     var mid=0, i;
     for(i=0;i<pts.length;i++) mid+=pts[i][0]; mid/=pts.length;
     function boxOf(left){ var a=1e9,b=1e9,c=-1,d=-1;
       for(var j=0;j<pts.length;j++){ if((pts[j][0]<mid)!==left) continue;
         if(pts[j][0]<a)a=pts[j][0]; if(pts[j][1]<b)b=pts[j][1];
         if(pts[j][0]>c)c=pts[j][0]; if(pts[j][1]>d)d=pts[j][1]; }
       return {x0:a,y0:b,x1:c,y1:d}; }
     var L=boxOf(true), R=boxOf(false);
     if(L.x1<L.x0||R.x1<R.x0) return 'SKIP: only one eye was found, so there is nothing to compare';
     function inEye(E,px,py){ var rx=(E.x1-E.x0)/2, ry=(E.y1-E.y0)/2;
       var dx=(px-(E.x0+rx))/Math.max(1,rx), dy=(py-(E.y0+ry))/Math.max(1,ry);
       return dx*dx+dy*dy<=1; }
     // Read a window around the eyes rather than the whole screen, so the whole
     // enumeration below is affordable.
     var RB={x:Math.max(0,L.x0-12),y:Math.max(0,Math.min(L.y0,R.y0)-12)};
     RB.w=Math.min(Wd-RB.x,(R.x1+12)-RB.x); RB.h=Math.min(Hd-RB.y,(Math.max(L.y1,R.y1)+12)-RB.y);
     if(RB.w<20||RB.h<12) return 'SKIP: the eye window came out empty';
     var cells=[];
     for(y=0;y<RB.h;y++) for(x=0;x<RB.w;x++)
       if(inEye(L,RB.x+x,RB.y+y)||inEye(R,RB.x+x,RB.y+y)) cells.push((y*RB.w+x)*4);
     if(cells.length<400) bad.push('control: the eye came out as '+cells.length+' pixels, too small to measure anything on');
     function win(){ return wx.getImageData(RB.x,RB.y,RB.w,RB.h).data; }
     function shot(look){ var r=__opShot(look,0,9); return r&&r.thrown?null:win(); }
     function cov(a,b){ var k=0;
       for(var j=0;j<cells.length;j++){ var c=cells[j];
         if(Math.abs(a[c]-b[c])+Math.abs(a[c+1]-b[c+1])+Math.abs(a[c+2]-b[c+2])>24) k++; }
       return k/cells.length*100; }
     function look(over){ var o={}, k; for(k in BASE) o[k]=BASE[k]; if(over) for(k in over) o[k]=over[k]; return o; }
     var plain=shot(look());
     if(!plain) return 'drawing the plain face threw';
     // CONTROL, FIRST, because a measurement that cannot see the defect reports
     // a clean face for a covered one. Paint a blot straight over both eyes and
     // require the instrument to shout about it.
     shot(look());
     wx.save(); wx.setTransform(1,0,0,1,0,0);
     wx.fillStyle='#ff00ff'; wx.fillRect(L.x0,L.y0,R.x1-L.x0+1,L.y1-L.y0+1);
     wx.restore();
     var blot=cov(plain,win());
     if(blot<80) bad.push('control: a blot painted straight over both eyes only measures '+blot.toFixed(1)+' percent, so this check cannot see a covered eye');
     // 1. EVERY FACE MARK ON THE RACK, one at a time. Measured on v10.93: four
     //    of the six were clean at 0, war paint covered 65.9 percent of the eye
     //    with two bars straight across both eyeballs, and the shiner 51.4,
     //    which is one whole eye.
     var faces=__cosOf('face');
     if(faces.length<4) bad.push('control: only '+faces.length+' face marks were found, so this is not enumerating the rack');
     for(i=0;i<faces.length;i++){
       var f1=shot(look({faceMark:faces[i]}));
       if(!f1){ bad.push('drawing '+faces[i]+' threw'); continue; }
       var c1=cov(plain,f1);
       if(c1>8) bad.push(faces[i]+' is painted over '+c1.toFixed(1)+' percent of the eye');
     }
     // 2. AND THE POPULATION HE ACTUALLY SEES. His words were "in some
     //    instances", so the crowd rolls are enumerated too, each measured
     //    against ITSELF with the mark removed, which isolates the mark from the
     //    skin and the hair that came with the roll.
     var rolls=28, worst=0, worstAt=null, marks={};
     for(i=0;i<rolls;i++){
       var lk=__crowdLook(); if(!lk) break;
       var withM={}, k2;
       for(k2 in BASE) withM[k2]=BASE[k2];
       for(k2 in lk) withM[k2]=lk[k2];
       withM.hero=0;
       var noM={}; for(k2 in withM) noM[k2]=withM[k2];
       noM.faceMark='faceplain'; noM.faceIx=0;
       var b1=shot(noM), b2=shot(withM);
       if(!b1||!b2){ bad.push('a crowd roll threw while drawing'); break; }
       var c2=cov(b1,b2);
       marks[lk.faceMark||('ix'+lk.faceIx)]=1;
       if(c2>worst){ worst=c2; worstAt=(lk.faceMark||('faceIx '+lk.faceIx)); }
     }
     if(worst>8) bad.push('a crowd face covers '+worst.toFixed(1)+' percent of its own eye, worst was '+worstAt);
     // CONTROL: the rolls have to have produced more than one kind of mark, or
     // twenty-eight draws of the same clean face proves nothing.
     var kinds=0, kk; for(kk in marks) kinds++;
     if(kinds<3) bad.push('control: '+rolls+' crowd rolls produced only '+kinds+' kind of face mark, so the enumeration is not covering the rack');
     return bad.length?bad.join('; '):null; }},
  {v:'10.93',what:'the Undercroft station names are painted on top of the room darkness
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
