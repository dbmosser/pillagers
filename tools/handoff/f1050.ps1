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
  {v:'10.49',what:'the run report carries his in-game text edits as JSON that reads back to the same maps, and nothing when there are none',
'@ @'
  {v:'10.50',what:'freckles, scar, mud and every beard sit clear of the eyes on the painted figure, and a boot colour paints the foot and collar, not the leg',
   run:function(){
     var bad=[];
     if(typeof drawOp!=='function'||typeof cosWorn!=='function') return 'SKIP: no painter or racks in this build';
     var P2=__P();
     var keep={face:P2.cosFace,beard:P2.cosBeard,boots:P2.cosBoots,hat:P2.cosHat,eyes:P2.cosEyes,tattoo:P2.cosTattoo};
     // The Depot's own way of painting the figure: the raid painter at 5.2 on
     // its own canvas. Face 0 is facing right, the gun arm away from the head.
     function paint(){
       var c=document.createElement('canvas'); c.width=200; c.height=320;
       var g=c.getContext('2d'); var keepWc=wc; wc=g;
       try{ g.save(); g.translate(100,304); g.scale(5.2,5.2);
            drawOp(0,0,0,0,'#242832',0,0,'none',0,{hero:1,moving:false,sprint:false,ads:false,hurt:0,rl:0,own:{wep:null}});
            g.restore(); }
       finally{ wc=keepWc; }
       return g.getImageData(0,0,200,320).data;
     }
     function changed(a,b){ var out=[]; for(var i=0;i<a.length;i+=4){ if(Math.abs(a[i]-b[i])+Math.abs(a[i+1]-b[i+1])+Math.abs(a[i+2]-b[i+2])+Math.abs(a[i+3]-b[i+3])>40) out.push({x:(i/4)%200,y:Math.floor(i/4/200)}); } return out; }
     function box(px){ var b={x0:1e9,x1:-1,y0:1e9,y1:-1}; px.forEach(function(q){ if(q.x<b.x0)b.x0=q.x; if(q.x>b.x1)b.x1=q.x; if(q.y<b.y0)b.y0=q.y; if(q.y>b.y1)b.y1=q.y; }); return b; }
     try{
       P2.cosFace='faceplain'; P2.cosBeard='clean'; P2.cosHat='none'; P2.cosTattoo='tatnone';
       var base=paint();
       // THE EYE BAND, read off the whites (255,246,220) in the head.
       var ey={x0:1e9,x1:-1,y0:1e9,y1:-1}, n=0;
       for(var i=0;i<base.length;i+=4){ if(base[i]>245&&base[i+1]>236&&base[i+2]>205&&base[i+2]<232&&base[i+3]>200){ var x=(i/4)%200,y=Math.floor(i/4/200); if(y<220){ n++; if(x<ey.x0)ey.x0=x; if(x>ey.x1)ey.x1=x; if(y<ey.y0)ey.y0=y; if(y>ey.y1)ey.y1=y; } } }
       if(n<20) return 'SKIP: could not find the eye whites on the painted figure ('+n+' pixels)';
       // FRECKLES below the band.
       P2.cosFace='facefreckles'; var fr=box(changed(base,paint()));
       if(fr.y1<0) bad.push('the freckles paint nothing');
       else if(fr.y0<=ey.y1) bad.push('the freckles start at row '+fr.y0+', inside the eye band that ends at row '+ey.y1);
       // THE SCAR beside the eye, not through it.
       P2.cosFace='facescar'; var sc=changed(base,paint());
       var through=sc.filter(function(q){ return q.y>=ey.y0&&q.y<=ey.y1&&q.x>=ey.x0&&q.x<=ey.x1; }).length;
       if(!sc.length) bad.push('the scar paints nothing');
       else if(through) bad.push('the scar puts '+through+' pixels inside the eye band');
       // MUD below the band.
       P2.cosFace='facemud'; var md=box(changed(base,paint()));
       if(md.y1>=0&&md.y0<=ey.y1) bad.push('the mud starts at row '+md.y0+', inside the eye band that ends at row '+ey.y1);
       P2.cosFace='faceplain';
       // THE BEARDS start under the band. The finding on v10.49: the stubble began 1.7 units in.
       ['stubble','goatee','fullbeard'].forEach(function(b){
         P2.cosBeard=b; var bb=box(changed(base,paint()));
         if(bb.y1<0) bad.push('the '+b+' paints nothing');
         else if(bb.y0<=ey.y1) bad.push('the '+b+' starts at row '+bb.y0+', inside the eye band that ends at row '+ey.y1);
       });
       P2.cosBeard='clean';
       // BOOTS ARE BOOTS: two boot colours differ on the foot and a collar, not the whole leg.
       var boots=(typeof COSMETICS!=='undefined')?COSMETICS.filter(function(c){ return c.kind==='boots'; }).map(function(c){ return c.id; }):[];
       if(boots.length>=2){
         P2.cosBoots=boots[0]; var b0=paint(); P2.cosBoots=boots[1]; var bx=box(changed(b0,paint()));
         var tall=bx.y1-bx.y0+1;
         if(bx.y1<0) bad.push('two boot colours paint the same figure');
         else if(tall>44) bad.push('a boot colour reaches '+tall+' rows up the leg, which is trousers, not boots (the leg is 57 rows)');
       } else bad.push('control: fewer than two boots on the rack');
       // CONTROL: the eyes are where the painter puts them, a band about 6 units tall at 5.2.
       if(ey.y1-ey.y0<20||ey.y1-ey.y0>45) bad.push('control: the eye band is '+(ey.y1-ey.y0)+' rows tall, not the 31 or so the painter draws');
     } finally {
       P2.cosFace=keep.face; P2.cosBeard=keep.beard; P2.cosBoots=keep.boots; P2.cosHat=keep.hat; P2.cosEyes=keep.eyes; P2.cosTattoo=keep.tattoo;
     }
     return bad.length?bad.join('; '):null; }},
  {v:'10.49',what:'the run report carries his in-game text edits as JSON that reads back to the same maps, and nothing when there are none',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
