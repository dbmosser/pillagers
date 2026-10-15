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

if ($s.Contains("  {v:'28.13',what:")) { throw "check 28.13 is in the fixture already" }

SubRx @'
  {v:'28.12',what:
'@ @'
  {v:'28.13',what:'the body layer: a vest rack and a shoulder rack that change the chest and shoulders of the silhouette, in the scheme colours, across the link and in looks',
   run:function(){
     var vests=['vestband','vestharn','vestutil','vestheavy'], pads=['padsround','padsspike','padsbig'], bad=[], i, j, c, keep={}, ks=['cosScheme','cosOutfit','cosAll','cosVest','cosPads'];
     for(i=0;i<vests.length;i++){ c=cosFind(vests[i]); if(!c||c.kind!=='vest') bad.push(vests[i]+' is not on the vest rack'); }
     for(i=0;i<pads.length;i++){ c=cosFind(pads[i]); if(!c||c.kind!=='pads') bad.push(pads[i]+' is not on the shoulder rack'); }
     if(!cosFind('vestplate')||!cosFind('padsnone')) bad.push('the default vest and pads are missing');
     if(bad.length) return bad.join('; ');
     if(COSDEF.vest!=='vestplate'||COSDEF.pads!=='padsnone') bad.push('the defaults are '+COSDEF.vest+' and '+COSDEF.pads);
     function paint(st){
       var cv2=document.createElement('canvas'), x2, kw=wc;
       cv2.width=240; cv2.height=240; x2=cv2.getContext('2d'); wc=x2;
       try{ x2.translate(120,200); x2.scale(3,3); drawOp(0,0,0,0,'#242832',0,0,'none',0,st); } finally { wc=kw; }
       return x2.getImageData(0,0,240,240).data;
     }
     function ext(d,y0,y1){ var l=999, r=-1, j2, y, x; for(j2=0;j2<d.length;j2+=4){ if(d[j2+3]>60){ y=Math.floor(j2/4/240); if(y<y0||y>=y1) continue; x=(j2/4)%240; if(x<l) l=x; if(x>r) r=x; } } return {r:(r-120)/3,l:(120-l)/3}; }
     function near(d,hex,tol,y0,y1){ var rr0=parseInt(hex.slice(1,3),16), gg=parseInt(hex.slice(3,5),16), bb=parseInt(hex.slice(5,7),16), n=0, j2, y; for(j2=0;j2<d.length;j2+=4){ y=Math.floor(j2/4/240); if(y<y0||y>=y1) continue; if(d[j2+3]>200&&Math.abs(d[j2]-rr0)<=tol&&Math.abs(d[j2+1]-gg)<=tol&&Math.abs(d[j2+2]-bb)<=tol) n++; } return n; }
     function diff(a,b){ var n=0, j2; for(j2=0;j2<a.length;j2+=4) if(a[j2]!==b[j2]||a[j2+1]!==b[j2+1]||a[j2+2]!==b[j2+2]) n++; return n; }
     var base={hero:0,build:'lean',pack:'packbrown',boots:'bootblack',hair:'dark',cut:'crop',hat:'none',skin:'fair',fit:'slate',eyes:'eyebrown',scheme:'schember',team:'ally'};
     var mk=function(o){ var q={}, k2; for(k2 in base) q[k2]=base[k2]; for(k2 in o) q[k2]=o[k2]; return q; };
     var shot={}, chestY0=200-17*3, chestY1=200-13*3;
     try{
       for(i=0;i<ks.length;i++) keep[ks[i]]=P[ks[i]];
       P.cosOutfit='outnone';
       shot.base=paint(mk({}));
       for(i=0;i<vests.length;i++){ shot[vests[i]]=paint(mk({vest:vests[i]})); if(diff(shot[vests[i]],shot.base)<150) bad.push(vests[i]+' differs from the plate carrier in only '+diff(shot[vests[i]],shot.base)+' pixels'); }
       for(i=0;i<pads.length;i++){ shot[pads[i]]=paint(mk({pads:pads[i]})); if(diff(shot[pads[i]],shot.base)<150) bad.push(pads[i]+' differs from no pads in only '+diff(shot[pads[i]],shot.base)+' pixels'); }
       var all=vests.concat(pads);
       for(i=0;i<all.length;i++) for(j=i+1;j<all.length;j++) if(diff(shot[all[i]],shot[all[j]])<150) bad.push(all[i]+' and '+all[j]+' draw alike');
       // the silhouette: heavy plates and the utility vest stand wider than the carrier; every pad is wider at the shoulder and the spiked one is taller
       var e0=ext(shot.base,chestY0,chestY1), eh=ext(shot.vestheavy,chestY0,chestY1), eu=ext(shot.vestutil,chestY0,chestY1);
       if(eh.r<e0.r+1.2) bad.push('heavy plates are not wider than the carrier ('+eh.r.toFixed(1)+' against '+e0.r.toFixed(1)+')');
       if(eu.r<e0.r+1.2) bad.push('the utility vest is not wider than the carrier ('+eu.r.toFixed(1)+' against '+e0.r.toFixed(1)+')');
       var s0=ext(shot.base,200-27*3,200-20*3);
       ['padsround','padsspike'].forEach(function(id){ var sp=ext(shot[id],200-27*3,200-20*3); if(sp.r<s0.r+2.5) bad.push(id+' do not stand out at the shoulder ('+sp.r.toFixed(1)+' against '+s0.r.toFixed(1)+')'); });
       var sb=ext(shot.padsbig,200-27*3,200-20*3); if(Math.max(sb.r,sb.l)<Math.max(s0.r,s0.l)+2.5) bad.push('the big pauldron does not stand out at the shoulder');
       var topSp=ext(shot.padsspike,200-34*3,200-28*3), top0=ext(shot.base,200-34*3,200-28*3); if(topSp.r<=top0.r||!(topSp.r>0)) bad.push('the spiked pads have no spike above the shoulder');
       // brass cartridges and the accent
       if(near(shot.vestband,'#d8b04a',14,chestY0-12,chestY1+12)<10) bad.push('the bandolier shows no brass');
       if(near(shot.vestharn,'#ffb52e',16,chestY0,chestY1)<10) bad.push('the harness buckle does not take the scheme accent');
       if(near(shot.padsround,'#ffb52e',16,200-27*3,200-18*3)<6) bad.push('the pads do not take the scheme accent');
       // armour 2 keeps its steel: a body with armour 2 wears no cosmetic pads
       var arm=paint(mk({pads:'padsround',bulk:2})), arm0=paint(mk({bulk:2}));
       if(diff(arm,arm0)>0) bad.push('cosmetic pads are drawn over armour 2');
       // the hero reads the racks, a suit hides them
       P.cosAll=true; P.cosScheme='schember'; P.cosVest='vestband'; P.cosPads='padsround';
       var hd=paint({hero:1,own:{wep:null}}); if(diff(hd,paint(mk({vest:'vestband',pads:'padsround',hero:0,team:undefined})))>900) bad.push('the hero draws the racks differently from a body that carries them ('+diff(hd,paint(mk({vest:'vestband',pads:'padsround',team:undefined})))+')');
       P.cosOutfit='outrobot'; if(diff(paint({hero:1,own:{wep:null}}),paint({hero:1,own:{wep:null}}))!==0) bad.push('non repeatable');
       P.cosOutfit='outnone';
       // across the link and in a look
       if(NET_LOOK.indexOf('vest')<0||NET_LOOK.indexOf('pads')<0) bad.push('vest and pads are not in NET_LOOK');
       if(netLook().vest!=='vestband'||netLook().pads!=='padsround') bad.push('netLook sends '+netLook().vest+' and '+netLook().pads);
       if(netLookClean({vest:'vestband',pads:'padsspike'}).pads!=='padsspike') bad.push('a pads word is dropped on the way in');
       if(netLookClean({vest:'padsround'}).vest!==undefined) bad.push('a pads id is taken as a vest');
       if(lookSnap().vest!=='vestband'||lookSnap().pads!=='padsround') bad.push('a saved look drops the vest or the pads');
       var peer={x:0,y:0,f:0,mv:0,sp:0,roll:0,cr:0,dn:0,bob:0,sh:0,lk:{vest:'vestheavy',pads:'padsbig',scheme:'schember',fit:'slate',hat:'none',hair:'dark',cut:'crop',skin:'fair',build:'lean',pack:'packbrown',boots:'bootblack'}}, kw3=wc, pc=document.createElement('canvas'), px, pd;
       pc.width=240; pc.height=240; px=pc.getContext('2d'); wc=px;
       try{ px.translate(120,200); px.scale(3,3); netUpDrawOne(peer); } finally { wc=kw3; }
       pd=px.getImageData(0,0,240,240).data;
       if(ext(pd,chestY0,chestY1).r<e0.r+1.2) bad.push('a body over the link does not wear the vest in its look');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ for(i=0;i<ks.length;i++){ var k3=ks[i]; if(keep[k3]===undefined) delete P[k3]; else P[k3]=keep[k3]; } try{ saveProfile(); }catch(_sp){} }
     return bad.length?bad.join('; '):null; }},
  {v:'28.12',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
