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

if ($s.Contains("  {v:'28.16',what:")) { throw "check 28.16 is in the fixture already" }

SubRx @'
  {v:'28.15',what:
'@ @'
  {v:'28.16',what:'the head layer: six new headgears that change the head shape at raid size, in the scheme accent, yours alone',
   run:function(){
     var ids=['boonie','tachelm','hardhat','goggles','gasmask','heavyhelm'], bad=[], i, j, c, pk={}, keepAll=P.cosAll, keepOut=P.cosOutfit, keepSch=P.cosScheme;
     for(i=0;i<ids.length;i++){ c=cosFind(ids[i]); if(!c||c.kind!=='hat'){ bad.push(ids[i]+' is not on the headgear rack'); } else { if(c.crowd!==0) bad.push(ids[i]+' can be worn by the crowd'); if(!/^(runs|extracts|level|warden|board):\d+$/.test(c.how)) bad.push(ids[i]+' has no way to earn it: '+c.how); } }
     if(bad.length) return bad.join('; ');
     function paint(st){
       var cv2=document.createElement('canvas'), x2, kw=wc;
       cv2.width=240; cv2.height=240; x2=cv2.getContext('2d'); wc=x2;
       try{ x2.translate(120,200); x2.scale(3,3); drawOp(0,0,0,0,'#242832',0,0,'none',0,st); } finally { wc=kw; }
       return x2.getImageData(0,0,240,240).data;
     }
     function box(d){ var top=999, l=999, r=-1, j2, y, x; for(j2=0;j2<d.length;j2+=4){ if(d[j2+3]>60){ y=Math.floor(j2/4/240); x=(j2/4)%240; if(y<top) top=y; if(x<l) l=x; if(x>r) r=x; } } return {top:(200-top)/3, w:(r-l+1)/3}; }
     function near(d,hex,tol,y0,y1){ var rr0=parseInt(hex.slice(1,3),16), gg=parseInt(hex.slice(3,5),16), bb=parseInt(hex.slice(5,7),16), n=0, j2, y; for(j2=0;j2<d.length;j2+=4){ y=Math.floor(j2/4/240); if(y<y0||y>=y1) continue; if(d[j2+3]>200&&Math.abs(d[j2]-rr0)<=tol&&Math.abs(d[j2+1]-gg)<=tol&&Math.abs(d[j2+2]-bb)<=tol) n++; } return n; }
     function diff(a,b){ var n=0, j2; for(j2=0;j2<a.length;j2+=4) if(a[j2]!==b[j2]||a[j2+1]!==b[j2+1]||a[j2+2]!==b[j2+2]) n++; return n; }
     var base={hero:0,build:'lean',pack:'packbrown',boots:'bootblack',hair:'dark',cut:'crop',skin:'fair',fit:'slate',eyes:'eyebrown'};
     var mk=function(h,sc){ var o={}, k; for(k in base) o[k]=base[k]; o.hat=h; if(sc) o.scheme=sc; return o; };
     var shots={}, b0;
     try{
       P.cosOutfit='outnone';
       shots.none=paint(mk('none')); b0=box(shots.none);
       for(i=0;i<ids.length;i++){
         shots[ids[i]]=paint(mk(ids[i],'schember'));
         c=box(shots[ids[i]]);
         if(!(c.top>=b0.top+3||c.w>=b0.w+5)) bad.push(ids[i]+' does not change the head shape (top '+c.top.toFixed(1)+' width '+c.w.toFixed(1)+' against the bare '+b0.top.toFixed(1)+' and '+b0.w.toFixed(1)+')');
         if(diff(shots[ids[i]],shots.none)<250) bad.push(ids[i]+' differs from the bare head in only '+diff(shots[ids[i]],shots.none)+' pixels');
       }
       for(i=0;i<ids.length;i++) for(j=i+1;j<ids.length;j++) if(diff(shots[ids[i]],shots[ids[j]])<250) bad.push(ids[i]+' and '+ids[j]+' draw alike');
       // the accent shows on the head: the trim on all but the hard hat, which is safety yellow whatever the scheme
       var accN={boonie:1,tachelm:1,goggles:1,gasmask:1,heavyhelm:1}, a0, a1;
       for(var id in accN){ a1=near(shots[id],'#ffb52e',16,0,132); a0=near(paint(mk(id,'schfrost')),'#ffb52e',16,0,132); if(a1<6) bad.push(id+' shows only '+a1+' pixels of the scheme accent'); if(a0>=a1) bad.push(id+' does not follow the scheme accent'); }
       // the hat on the figure the player wears: the hero path takes it from the rack
       P.cosAll=true; P.cosHat='heavyhelm'; P.cosScheme='schember';
       var hd=paint({hero:1,own:{wep:null}}); if(diff(hd,shots.heavyhelm)>600) bad.push('the hero wearing the Heavy Helmet draws differently from the same helmet on a body ('+diff(hd,shots.heavyhelm)+' pixels)');
       // the mouth: nothing is drawn over a respirator
       var gm=mk('gasmask'); gm.build='curved'; var gd=paint(gm), sk=near(gd,'#c25a6c',10,0,240); if(sk>0) bad.push('a rose mouth is drawn over the gas mask');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ if(keepAll===undefined) delete P.cosAll; else P.cosAll=keepAll; if(keepOut===undefined) delete P.cosOutfit; else P.cosOutfit=keepOut; if(keepSch===undefined) delete P.cosScheme; else P.cosScheme=keepSch; try{ if(P.cosHat==='heavyhelm') P.cosHat='none'; }catch(_h){} try{ saveProfile(); }catch(_sp){} }
     return bad.length?bad.join('; '):null; }},
  {v:'28.15',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
