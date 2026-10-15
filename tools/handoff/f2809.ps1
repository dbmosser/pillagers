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

if ($s.Contains("  {v:'28.09',what:")) { throw "check 28.09 is in the fixture already" }

SubRx @'
  {v:'28.08',what:
'@ @'
  {v:'28.09',what:'two players never look alike: a seat ring and marker on every human body in a party, and the same scheme at two seats goes to the next free preset in every window',
   run:function(){
     if(typeof seatHere!=='function'||typeof seatScheme!=='function'||typeof drawSeatRing!=='function') return 'there is no seat mark in this build';
     var bad=[], NK={}, nks=['on','role','seat','mode','peers','up','floor','roster'], PK={}, pks=['cosScheme','cosFit','cosAll','cosOutfit'], i, k, d, hero={hero:1,own:{wep:null}};
     function paint(st,fn){
       var cv2=document.createElement('canvas'), x2, kw=wc;
       cv2.width=220; cv2.height=220; x2=cv2.getContext('2d'); wc=x2;
       try{ x2.translate(110,190); x2.scale(2.2,2.2); if(fn) fn(); else drawOp(0,0,0,0,'#242832',0,0,'none',0,st); } finally { wc=kw; }
       return x2.getImageData(0,0,220,220).data;
     }
     function near(dd,hex,tol,y0,y1){ var r=parseInt(hex.slice(1,3),16), g=parseInt(hex.slice(3,5),16), b=parseInt(hex.slice(5,7),16), n=0, j, yy; for(j=0;j<dd.length;j+=4){ yy=Math.floor(j/4/220); if(y0!==undefined&&(yy<y0||yy>=y1)) continue; if(dd[j+3]>200&&Math.abs(dd[j]-r)<=tol&&Math.abs(dd[j+1]-g)<=tol&&Math.abs(dd[j+2]-b)<=tol) n++; } return n; }
     function diff(a,b){ var n=0, j; for(j=0;j<a.length;j+=4) if(a[j]!==b[j]||a[j+1]!==b[j+1]||a[j+2]!==b[j+2]||a[j+3]!==b[j+3]) n++; return n; }
     function party(seat,mode,others){ var s; NET.on=true; NET.mode=mode||'coop'; NET.seat=seat; NET.peers=[{state:'in'}]; NET.up=[]; NET.floor=[]; for(s in others) NET.up[+s]={seat:+s,lk:{scheme:others[s],fit:'slate'}}; }
     try{
       for(i=0;i<nks.length;i++) NK[nks[i]]=NET[nks[i]];
       for(i=0;i<pks.length;i++) PK[pks[i]]=P[pks[i]];
       P.cosAll=false; P.cosOutfit='outnone'; P.cosFit='slate'; P.cosScheme='schstd';
       // nobody linked: nothing is marked and nothing is recoloured
       NET.on=false; NET.peers=[]; NET.seat=-1; NET.mode=''; NET.up=[]; NET.floor=[];
       if(seatHere()!==-1) bad.push('a solo window reads seat '+seatHere());
       if(near(paint(hero),'#ffb02e',10)>2) bad.push('a solo body wears a seat ring');
       if(schemeOf(hero)) bad.push('a solo Standard Issue body wears a scheme');
       // a party: two fresh profiles
       party(0,'coop',{1:'schstd'});
       if(seatHere()!==0) bad.push('seat 0 reads '+seatHere());
       d=paint(hero);
       if(near(d,'#ffb02e',10,160,205)<30) bad.push('seat 0 has no amber ring at its feet ('+near(d,'#ffb02e',10,160,205)+')');
       if(near(d,'#ffb02e',10,209,220)<30) bad.push('seat 0 has no amber number badge at the front of its ring ('+near(d,'#ffb02e',10,209,220)+')');
       if(schemeOf(hero)) bad.push('seat 0 should keep its own Standard Issue look');
       party(1,'coop',{0:'schstd'});
       if(!schemeOf(hero)||schemeOf(hero).id!=='schfrost') bad.push('seat 1 with the same scheme as seat 0 wears '+(schemeOf(hero)?schemeOf(hero).id:'Standard Issue'));
       d=paint(hero);
       if(near(d,'#38d6ff',10,160,205)<30) bad.push('seat 1 has no cyan ring at its feet');
       if(near(d,'#c4f0ff',14)<10) bad.push('seat 1 does not wear the Frost preset');
       // both windows agree: seat 0 sees seat 1 as a peer drawn the same way
       party(0,'coop',{1:'schstd'});
       var peer={x:0,y:0,f:0,mv:0,sp:0,roll:0,cr:0,dn:0,bob:0,sh:0,seat:1,lk:{scheme:'schstd',fit:'slate',hat:'none',hair:'dark',cut:'crop',skin:'fair',build:'lean',pack:'packbrown',boots:'bootblack'}};
       var pd=paint(null,function(){ netUpDrawOne(peer); });
       if(near(pd,'#38d6ff',10,160,205)<30) bad.push('the peer at seat 1 has no cyan ring in the other window');
       if(near(pd,'#c4f0ff',14)<10) bad.push('the peer at seat 1 is not drawn in Frost beside a Standard Issue seat 0');
       // two seats, two different picks: both keep their own
       party(1,'coop',{0:'schember'});
       if(schemeOf(hero)) bad.push('seat 1 changed a scheme that did not collide');
       // the same pick twice: the second takes the next free preset
       P.cosAll=true; P.cosScheme='schfrost'; party(1,'coop',{0:'schfrost'});
       if(!schemeOf(hero)||schemeOf(hero).id!=='schember') bad.push('two Frost seats: seat 1 wears '+(schemeOf(hero)?schemeOf(hero).id:'none'));
       // four players, four different looks
       P.cosAll=false; P.cosScheme='schstd';
       var ids=[]; for(k=0;k<4;k++){ NET.on=true; NET.mode='coop'; NET.seat=k; NET.peers=[{state:'in'}]; NET.up=[]; NET.floor=[]; for(i=0;i<4;i++) if(i!==k) NET.up[i]={seat:i,lk:{scheme:'schstd',fit:'slate'}}; ids.push(schemeOf(hero)?schemeOf(hero).id:'std'); }
       if(ids.join(',')!=='std,schfrost,schember,schverdant') bad.push('four Standard Issue seats read '+ids.join(','));
       // the two bodies are really different pictures
       party(0,'coop',{1:'schstd'}); var a0=paint(hero); party(1,'coop',{0:'schstd'}); var a1=paint(hero);
       if(diff(a0,a1)<500) bad.push('seat 0 and seat 1 differ in only '+diff(a0,a1)+' pixels');
       // a PvP match keeps its own colours
       party(0,'pvp',{1:'schstd'});
       if(seatHere()!==-1) bad.push('a PvP match reads a seat');
       if(near(paint(hero),'#ffb02e',10)>2) bad.push('a PvP body wears a seat ring');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ for(i=0;i<nks.length;i++){ k=nks[i]; if(NK[k]===undefined) delete NET[k]; else NET[k]=NK[k]; } for(i=0;i<pks.length;i++){ k=pks[i]; if(PK[k]===undefined) delete P[k]; else P[k]=PK[k]; } try{ saveProfile(); }catch(_sp){} }
     return bad.length?bad.join('; '):null; }},
  {v:'28.08',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
