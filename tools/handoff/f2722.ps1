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

if ($s.Contains("  {v:'27.22',what:")) { throw "check 27.22 is in the fixture already" }

SubRx @'
  {v:'27.21',what:
'@ @'
  {v:'27.22',what:'his order: a gun key with no gun draws a translucent flat silhouette of its class (about 27 percent, one grey, no rarity), a key with a gun draws it opaque, and a gun dragged to another key empties the old key back to its ghost',
   run:function(){
     if(!window.__deploy||!window.__endRaid||!window.__state||typeof drawBelt!=='function'||typeof hotbarSlots!=='function') return 'SKIP: no belt here';
     var bad=[], g=null, proto, oDI, rec=[], sl, i, k, vac=[], car=[], imgs={}, nImg=0, a, ghA=[], carA=[], gh, d, px, seenCol={}, nCol=0, ci=-1, vi=-1, id0, sl2, rs=say;
     function cellOf(x,y){ var q, c, hc=G.hotCells||[]; for(q=0;q<hc.length;q++){ c=hc[q]; if(x>=c.x&&x<=c.x+c.w&&y>=c.y&&y<=c.y+c.h) return q; } return -1; }
     function draw(){
       rec=[];
       proto.drawImage=function(im){ rec.push({im:im,a:this.globalAlpha,x:arguments[1],y:arguments[2]}); return oDI.apply(this,arguments); };
       try{ drawBelt(); } finally { proto.drawImage=oDI; }
       return rec.slice();
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0);
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       say=function(){}; g.ents.length=0;
       proto=CanvasRenderingContext2D.prototype; oDI=proto.drawImage;
       if(typeof WEAPONS==='object'&&WEAPONS.rifle&&typeof gunKeysSettle==='function'){ var wc0={}, kw; for(kw in WEAPONS.rifle) wc0[kw]=WEAPONS.rifle[kw]; g.player.wep=wc0; g.player.ammo=wc0.mag; g.hotAssign={}; g.hotAuto={}; gunKeysSettle({deploy:1}); try{ g.hot=gunCell(); }catch(_gh){} }
       sl=hotbarSlots();
       for(i=0;i<GUNKEYS&&i<sl.length;i++){ if(sl[i].kind==='gun'&&sl[i].vacant) vac.push(i); else if(sl[i].kind==='gun'&&sl[i].icon&&sl[i].icon!=='fists') car.push(i); }
       if(vac.length<3) return 'SKIP: staging: fewer than three empty gun keys ('+vac.length+')';
       if(!car.length) return 'SKIP: staging: no carried gun';
       draw();
       for(k=0;k<rec.length;k++){ i=cellOf(rec[k].x,rec[k].y); if(i<0) continue; if(vac.indexOf(i)>=0){ ghA.push(rec[k]); if(!imgs[i]){ imgs[i]=rec[k].im; nImg++; } } else if(car.indexOf(i)>=0) carA.push(rec[k]); }
       for(i=0;i<vac.length;i++) if(!imgs[vac[i]]) bad.push('the empty key '+(vac[i]+1)+' draws no silhouette');
       for(k=0;k<ghA.length;k++) if(!(ghA[k].a>=0.2&&ghA[k].a<=0.35)){ bad.push('a silhouette is drawn at alpha '+ghA[k].a+', not 0.2 to 0.35'); break; }
       if(!carA.length) bad.push('the carried gun key draws no gun image');
       for(k=0;k<carA.length;k++) if(!(carA[k].a>=0.95)){ bad.push('a carried gun is drawn at alpha '+carA[k].a+', not opaque'); break; }
       // each class its own picture
       var u={}, nu=0; for(i in imgs) if(Object.prototype.hasOwnProperty.call(imgs,i)){ var im=imgs[i], f=0, q2; for(q2 in u) if(u[q2]===im) f=1; if(!f){ u[i]=im; nu++; } }
       if(nu!==vac.length) bad.push('the '+vac.length+' empty keys draw '+nu+' different silhouettes');
       // one flat colour, no rarity
       gh=imgs[vac[0]];
       if(gh&&gh.getContext){ try{ d=gh.getContext('2d').getImageData(0,0,gh.width,gh.height).data; var c0=null; for(px=0;px<d.length;px+=28){ if(d[px+3]>200){ if(!c0) c0=[d[px],d[px+1],d[px+2]]; else if(Math.abs(d[px]-c0[0])+Math.abs(d[px+1]-c0[1])+Math.abs(d[px+2]-c0[2])>12) nCol++; } } if(!c0) nCol=-1; }catch(_gd){ nCol=0; }
         if(nCol!==0) bad.push('the silhouette is not one flat colour ('+nCol+' samples off)'); }
       // drag a carried gun to an empty key for the raid: the new key is opaque, the old key is a ghost again
       ci=car[0]; vi=vac[vac.length-1]; id0=sl[ci].icon;
       g.hotAssign=g.hotAssign||{}; g.hotAuto=g.hotAuto||{};
       delete g.hotAssign[ci]; delete g.hotAuto[ci]; g.hotAssign[vi]='gun_'+id0; g.hotAuto[vi]=0;
       sl2=hotbarSlots();
       if(sl2[vi]&&sl2[vi].kind==='gun'&&!sl2[vi].vacant&&sl2[vi].icon===id0&&sl2[ci]&&sl2[ci].vacant){
         draw(); ghA=[]; carA=[];
         for(k=0;k<rec.length;k++){ i=cellOf(rec[k].x,rec[k].y); if(i===vi) carA.push(rec[k]); else if(i===ci) ghA.push(rec[k]); }
         if(!carA.length||!(carA[0].a>=0.95)) bad.push('the key the gun was dragged to does not draw it opaque');
         if(!ghA.length||!(ghA[0].a>=0.2&&ghA[0].a<=0.35)) bad.push('the key the gun was dragged off did not go back to its ghost');
       }
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       try{ if(proto&&oDI) proto.drawImage=oDI; }catch(_p){}
       say=rs;
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.iv=0; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.slice(0,6).join('; '):null; }},
  {v:'27.21',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
