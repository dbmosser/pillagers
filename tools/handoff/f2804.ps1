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

if ($s.Contains("  {v:'28.04',what:")) { throw "check 28.04 is in the fixture already" }

SubRx @'
  {v:'28.03',what:
'@ @'
  {v:'28.04',what:'the colour scheme: a rack of presets (primary, secondary, accent) drawn on the body, carried over the link, kept in looks, and an old clothing colour maps to its scheme',
   run:function(){
     if(typeof SCHEMES==='undefined'||typeof schemeOf!=='function') return 'there is no colour scheme in this build';
     var bad=[], keep={}, ks=['cosScheme','cosFit','cosAll','cosOutfit'], i, k, list, box, el, d1, d2, n1, n2;
     function paint(st,mode,sc){
       var cv2=document.createElement('canvas'), x2, kw=wc, d;
       cv2.width=170; cv2.height=170; x2=cv2.getContext('2d'); wc=x2;
       try{ x2.translate(85,135); x2.scale(sc||2.6,sc||2.6); drawOp(0,0,0,0,'#242832',0,0,mode||'none',0,st); } finally { wc=kw; }
       return x2.getImageData(0,0,170,170).data;
     }
     function near(d,hex,tol){ var r=parseInt(hex.slice(1,3),16), g=parseInt(hex.slice(3,5),16), b=parseInt(hex.slice(5,7),16), n=0, j; for(j=0;j<d.length;j+=4) if(d[j+3]>200&&Math.abs(d[j]-r)<=tol&&Math.abs(d[j+1]-g)<=tol&&Math.abs(d[j+2]-b)<=tol) n++; return n; }
     function diff(a,b){ var n=0, j; for(j=0;j<a.length;j+=4) if(a[j]!==b[j]||a[j+1]!==b[j+1]||a[j+2]!==b[j+2]||a[j+3]!==b[j+3]) n++; return n; }
     try{
       for(i=0;i<ks.length;i++) keep[ks[i]]=P[ks[i]];
       // the rack
       list=COSMETICS.filter(function(c){ return c.kind==='scheme'; });
       if(list.length<14) bad.push('only '+list.length+' schemes on the rack');
       list.forEach(function(c){
         var S=SCHEMES[c.id];
         if(c.id==='schstd'){ if(S) bad.push('Standard Issue must be the old look, not a preset'); return; }
         if(!S||!/^#[0-9a-f]{6}$/i.test(S.p)||!/^#[0-9a-f]{6}$/i.test(S.s)||!/^#[0-9a-f]{6}$/i.test(S.a)) bad.push(c.id+' has no three colours');
       });
       P.cosAll=false;
       if(!cosOwned(cosFind('schstd'))||!cosOwned(cosFind('schmoss'))||!cosOwned(cosFind('schbone'))) bad.push('Standard Issue and the old clothing colours must be owned from the start');
       // an old save: no scheme, the clothing colour it wore
       delete P.cosScheme; P.cosFit='moss'; P.cosOutfit='outnone';
       if(cosWorn('scheme')!=='schmoss') bad.push('an old Moss clothing colour reads as '+cosWorn('scheme'));
       P.cosFit='slate'; if(cosWorn('scheme')!=='schstd') bad.push('an old Slate save reads as '+cosWorn('scheme'));
       P.cosFit='jersey'; if(cosWorn('scheme')!=='schstd') bad.push('the jersey reads as scheme '+cosWorn('scheme'));
       P.cosFit='slate';
       P.cosAll=true; P.cosScheme='schember';
       if(cosWorn('scheme')!=='schember') bad.push('a worn scheme reads as '+cosWorn('scheme'));
       P.cosAll=false; P.cosScheme='schgilded';
       if(cosOwned(cosFind('schgilded'))) { /* the board is finished on this profile: nothing to prove */ } else if(cosWorn('scheme')!=='schstd') bad.push('a locked scheme is worn: '+cosWorn('scheme'));
       P.cosAll=true;
       // the body
       var base={hero:0,build:'lean',pack:'packbrown',boots:'bootblack',hair:'dark',cut:'crop',hat:'none',skin:'fair',fit:'slate'};
       var mk=function(sc){ var o={}, q; for(q in base) o[q]=base[q]; if(sc) o.scheme=sc; return o; };
       d1=paint(mk(null)); d2=paint(mk('schember'));
       n1=near(d1,'#ffb52e',16); n2=near(d2,'#ffb52e',16);
       if(n2<14) bad.push('the Ember accent shows in only '+n2+' pixels of the body');
       if(n1>2) bad.push('a body with no scheme shows the Ember accent in '+n1+' pixels');
       if(diff(d1,d2)<150) bad.push('the scheme changed only '+diff(d1,d2)+' pixels');
       if(diff(paint(mk('schfrost')),d2)<150) bad.push('two schemes draw alike');
       d1=paint(mk('schfrost')); if(near(d1,'#c4f0ff',14)<14) bad.push('the Frost accent does not show');
       // an item you chose wins: a chosen sneaker and pack are not repainted
       var ch=mk('schember'); ch.boots='bootox'; ch.pack='packrust';
       if(near(paint(ch),'#2a2224',6)>=near(d2,'#2a2224',6)) bad.push('a chosen pack and boots still took the secondary');
       // a suit and the jersey step the scheme aside
       if(schemeOf({hero:0,scheme:'schember',outfit:'outrobot'})) bad.push('a suit still wears a scheme');
       // the hero reads its own rack
       P.cosScheme='schember'; P.cosFit='slate';
       if(near(paint({hero:1,own:{wep:null}}),'#ffb52e',16)<14) bad.push('the hero does not wear the scheme it has on');
       P.cosScheme='schstd';
       if(near(paint({hero:1,own:{wep:null}}),'#ffb52e',16)>2) bad.push('Standard Issue draws the Ember accent');
       P.cosFit='jersey'; P.cosScheme='schember';
       if(schemeOf({hero:1,own:{wep:null}})) bad.push('the jersey wears a scheme over it');
       P.cosFit='slate';
       // across the link and in a saved look
       if(NET_LOOK.indexOf('scheme')<0) bad.push('the scheme is not in NET_LOOK');
       P.cosScheme='schfrost';
       if(netLook().scheme!=='schfrost') bad.push('netLook sends scheme '+netLook().scheme);
       if(netLookClean({scheme:'schember'}).scheme!=='schember') bad.push('a scheme word is dropped on the way in');
       if(netLookClean({scheme:'schbogus'}).scheme!==undefined) bad.push('a scheme id no rack knows is let through');
       if(netLookClean({scheme:'band'}).scheme!==undefined) bad.push('an id of another kind is taken as a scheme');
       if(lookSnap().scheme!=='schfrost') bad.push('a saved look drops the scheme');
       if(LOOK_KINDS.indexOf('scheme')<0) bad.push('LOOK_KINDS has no scheme');
       var peer={x:0,y:0,f:0,mv:0,sp:0,roll:0,cr:0,dn:0,bob:0,sh:0,lk:{scheme:'schember',fit:'slate',hat:'none',hair:'dark',cut:'crop',skin:'fair',build:'lean',pack:'packbrown',boots:'bootblack'}}, kw2=wc, pc=document.createElement('canvas'), px, pd;
       pc.width=170; pc.height=170; px=pc.getContext('2d'); wc=px;
       try{ px.translate(85,135); px.scale(2.6,2.6); netUpDrawOne(peer); } finally { wc=kw2; }
       pd=px.getImageData(0,0,170,170).data;
       if(near(pd,'#ffb52e',16)<14) bad.push('a body over the link does not wear the scheme in its look');
       // the rack on screen
       box=document.createElement('div');
       renderCosmetics(box,'scheme');
       if(box.querySelectorAll('.costile').length!==list.length) bad.push('the scheme rack shows '+box.querySelectorAll('.costile').length+' tiles for '+list.length+' schemes');
       if(!box.querySelector('.costile.on')) bad.push('no scheme tile says it is worn');
       P.cosFit='moss';
       el=box.querySelector('.costile[data-id="schember"]'); if(el) el.click(); else bad.push('no Ember tile');
       if(P.cosScheme!=='schember') bad.push('clicking a scheme tile left '+P.cosScheme);
       if(P.cosFit!=='slate') bad.push('a scheme tile left the old clothing colour on ('+P.cosFit+')');
       renderCosmetics(box,'fit');
       if(box.querySelectorAll('.costile').length!==1) bad.push('CLOTHING still shows '+box.querySelectorAll('.costile').length+' tiles beside the schemes');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ for(i=0;i<ks.length;i++){ k=ks[i]; if(keep[k]===undefined) delete P[k]; else P[k]=keep[k]; } try{ saveProfile(); }catch(_sp){} }
     return bad.length?bad.join('; '):null; }},
  {v:'28.03',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
