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

if ($s.Contains("  {v:'28.12',what:")) { throw "check 28.12 is in the fixture already" }

SubRx @'
  {v:'28.11',what:
'@ @'
  {v:'28.12',what:'pack and boot shapes: four packs and two boots that change the outline, in the scheme colours, across the link',
   run:function(){
     var packs=['packroll','packradio','packfuel','packframe'], boots=['bootshin','bootgaiter'], bad=[], i, j, c, keep={}, ks=['cosScheme','cosOutfit','cosAll','cosPack','cosBoots'];
     for(i=0;i<packs.length;i++){ c=cosFind(packs[i]); if(!c||c.kind!=='pack') bad.push(packs[i]+' is not on the backpack rack'); else if(!/^(runs|extracts|level|warden):\d+$/.test(c.how)) bad.push(packs[i]+' cannot be earned: '+c.how); }
     for(i=0;i<boots.length;i++){ c=cosFind(boots[i]); if(!c||c.kind!=='boots') bad.push(boots[i]+' is not on the boots rack'); else if(!/^(runs|extracts|level|warden):\d+$/.test(c.how)) bad.push(boots[i]+' cannot be earned: '+c.how); }
     if(bad.length) return bad.join('; ');
     function paint(st,face){
       var cv2=document.createElement('canvas'), x2, kw=wc;
       cv2.width=240; cv2.height=240; x2=cv2.getContext('2d'); wc=x2;
       try{ x2.translate(120,200); x2.scale(3,3); drawOp(0,0,face||0,0,'#242832',0,0,'none',0,st); } finally { wc=kw; }
       return x2.getImageData(0,0,240,240).data;
     }
     function box(d,y0,y1){ var top=999, l=999, r=-999, j2, y, x; for(j2=0;j2<d.length;j2+=4){ if(d[j2+3]>60){ y=Math.floor(j2/4/240); if(y<y0||y>=y1) continue; x=(j2/4)%240; if(y<top) top=y; if(x<l) l=x; if(x>r) r=x; } } return {top:(200-top)/3,l:(120-l)/3,r:(r-120)/3}; }
     function near(d,hex,tol,y0,y1){ var rr0=parseInt(hex.slice(1,3),16), gg=parseInt(hex.slice(3,5),16), bb=parseInt(hex.slice(5,7),16), n=0, j2, y; for(j2=0;j2<d.length;j2+=4){ y=Math.floor(j2/4/240); if(y<y0||y>=y1) continue; if(d[j2+3]>200&&Math.abs(d[j2]-rr0)<=tol&&Math.abs(d[j2+1]-gg)<=tol&&Math.abs(d[j2+2]-bb)<=tol) n++; } return n; }
     function diff(a,b){ var n=0, j2; for(j2=0;j2<a.length;j2+=4) if(a[j2]!==b[j2]||a[j2+1]!==b[j2+1]||a[j2+2]!==b[j2+2]) n++; return n; }
     var base={hero:0,build:'lean',pack:'packbrown',boots:'bootblack',hair:'dark',cut:'crop',hat:'none',skin:'fair',fit:'slate',eyes:'eyebrown',scheme:'schember',team:'ally'};
     var mk=function(o){ var q={}, k2; for(k2 in base) q[k2]=base[k2]; for(k2 in o) q[k2]=o[k2]; return q; };
     var shot={}, b0, all=packs.concat(boots);
     try{
       for(i=0;i<ks.length;i++) keep[ks[i]]=P[ks[i]];
       P.cosOutfit='outnone';
       shot.base=paint(mk({})); b0=box(shot.base,0,240);
       for(i=0;i<packs.length;i++){ shot[packs[i]]=paint(mk({pack:packs[i]})); if(diff(shot[packs[i]],shot.base)<120) bad.push(packs[i]+' differs from the canvas pack in only '+diff(shot[packs[i]],shot.base)+' pixels'); }
       for(i=0;i<boots.length;i++){ shot[boots[i]]=paint(mk({boots:boots[i]})); if(diff(shot[boots[i]],shot.base)<120) bad.push(boots[i]+' differs from the black boots in only '+diff(shot[boots[i]],shot.base)+' pixels'); }
       for(i=0;i<all.length;i++) for(j=i+1;j<all.length;j++) if(diff(shot[all[i]],shot[all[j]])<120) bad.push(all[i]+' and '+all[j]+' draw alike');
       // the outline: the bedroll, the radio (with its antenna) and the frame pack stand taller; the fuel can and the frame pack stand wider on the back side
       var bb=function(id){ return box(shot[id],0,240); };
       if(bb('packroll').top<b0.top+0.5&&bb('packroll').l<b0.l+1.5) bad.push('the bedroll does not change the outline');
       if(bb('packradio').top<b0.top+2) bad.push('the radio antenna does not stand above the figure ('+bb('packradio').top.toFixed(1)+' against '+b0.top.toFixed(1)+')');
       if(bb('packfuel').l<b0.l+1.5&&bb('packfuel').r<b0.r+1.5) bad.push('the fuel can does not stand out');
       if(bb('packframe').l<b0.l+1.5&&bb('packframe').top<b0.top+1) bad.push('the frame pack does not change the outline');
       // the leg shapes are wider than the trousers
       var lgc=near(shot.bootgaiter,'#6a5c44',10,200-11*3,200-4*3), sgc=near(shot.bootshin,'#69747e',10,200-11*3,200-4*3);
       if(lgc<20) bad.push('the gaiters show only '+lgc+' pixels of leather'); if(sgc<20) bad.push('the shin guards show only '+sgc+' pixels of steel');
       // the scheme: the accent shows on every shape, the secondary paints a pack and boots left at the default
       for(i=0;i<all.length;i++){ if(near(shot[all[i]],'#ffb52e',16,0,240)<16) bad.push(all[i]+' does not carry the scheme accent'); }
       var fr=paint(mk({pack:'packframe',scheme:'schfrost'})); if(near(fr,'#ffb52e',16,0,240)>2) bad.push('the frame pack keeps the Ember accent under Frost');
       // the hero reads the racks, a suit hides them, the link carries them
       P.cosAll=true; P.cosScheme='schember'; P.cosPack='packradio'; P.cosBoots='bootshin';
       var hd=paint({hero:1,own:{wep:null}}), pk=paint(mk({pack:'packradio',boots:'bootshin'}));
       if(diff(hd,pk)>900) bad.push('the hero draws the racks differently from a body that carries them ('+diff(hd,pk)+')');
       if(netLook().pack!=='packradio'||netLook().boots!=='bootshin') bad.push('netLook sends '+netLook().pack+' and '+netLook().boots);
       var peer={x:0,y:0,f:0,mv:0,sp:0,roll:0,cr:0,dn:0,bob:0,sh:0,lk:{pack:'packroll',boots:'bootgaiter',scheme:'schember',fit:'slate',hat:'none',hair:'dark',cut:'crop',skin:'fair',build:'lean'}}, kw3=wc, pc=document.createElement('canvas'), px, pd;
       pc.width=240; pc.height=240; px=pc.getContext('2d'); wc=px;
       try{ px.translate(120,200); px.scale(3,3); netUpDrawOne(peer); } finally { wc=kw3; }
       pd=px.getImageData(0,0,240,240).data;
       if(diff(pd,shot.base)<200) bad.push('a body over the link does not wear the shapes in its look');
       // the rack tiles
       var box2=document.createElement('div'); renderCosmetics(box2,'pack'); if(box2.querySelectorAll('.costile').length!==COSMETICS.filter(function(q){ return q.kind==='pack'; }).length) bad.push('the backpack rack shows '+box2.querySelectorAll('.costile').length+' tiles');
       if(!box2.querySelector('.costile[data-id="packradio"] img')) bad.push('a pack tile has no picture of the pack on the figure');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ for(i=0;i<ks.length;i++){ var k3=ks[i]; if(keep[k3]===undefined) delete P[k3]; else P[k3]=keep[k3]; } try{ saveProfile(); }catch(_sp){} }
     return bad.length?bad.join('; '):null; }},
  {v:'28.11',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
