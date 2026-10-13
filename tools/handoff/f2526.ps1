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

if ($s.Contains("  {v:'25.26',what:")) { throw "check 25.26 is in the fixture already" }

SubRx @'
  {v:'25.25',what:
'@ @'
  {v:'25.26',what:'his order: the guns in your hands are bigger, every class reads, the magazine stays under a left-facing gun, the Forge shows',
   run:function(){
     if(typeof drawOp!=='function'||typeof WEAPONS==='undefined'||!WEAPONS.rifle) return 'SKIP: no drawOp here';
     var Sc=5, OX=48, OY=56, CW=96, CH=72, bad=[], w0=wc, t0=(typeof G!=='undefined'&&G)?G.t:0;
     function draw(W,face){
       var c=document.createElement('canvas'), x; c.width=CW*Sc; c.height=CH*Sc; x=c.getContext('2d');
       wc=x; x.setTransform(Sc,0,0,Sc,OX*Sc,OY*Sc);
       try{ drawOp(0,0,face||0,0,'#4a5b7d',0,0,W?'':'none',0,{hero:1,moving:false,sprint:false,ads:false,hurt:0,rl:0,bulk:0,own:{wep:W}}); }
       finally{ wc=w0; }
       return x.getImageData(0,0,c.width,c.height).data;
     }
     function diffN(a,b,fn){
       var n=0, px, py, i;
       for(py=0;py<CH*Sc;py++) for(px=0;px<CW*Sc;px++){
         i=(py*CW*Sc+px)*4;
         if(Math.abs(a[i]-b[i])+Math.abs(a[i+1]-b[i+1])+Math.abs(a[i+2]-b[i+2])+Math.abs(a[i+3]-b[i+3])>60&&fn(px/Sc-OX,py/Sc-OY,i)) n++;
       }
       return n/(Sc*Sc);
     }
     function tipOf(d,none){
       var x1=-1e9;
       diffN(d,none,function(wx){ if(wx>x1) x1=wx; return true; });
       return x1;
     }
     var MIN={tacker:15,pistol:15,magnum:18,sputter:18,smg:18,chatter:24,carbine:24,rifle:28,whisper:27,scuttle:20,shotgun:26,lmg:31,dmr:33,sniper:37,lance:37};
     var tips={}, id, none0, d, dl, noneL, D={}, gold;
     try{
       if(typeof G!=='undefined'&&G) G.t=1.0;
       none0=draw(null,0);
       for(id in MIN){
         if(!WEAPONS[id]) continue;
         d=draw(Object.assign({},WEAPONS[id]),0); D[id]=d;
         tips[id]=tipOf(d,none0);
         if(!(tips[id]>=MIN[id])) bad.push(id+' reaches '+tips[id].toFixed(1)+' from the shoulder, wants '+MIN[id]);
       }
       if(D.rifle&&D.shotgun&&diffN(D.rifle,D.shotgun,function(){ return true; })<25) bad.push('rifle and Scattergun draw the same');
       if(D.rifle&&D.lmg&&diffN(D.rifle,D.lmg,function(){ return true; })<25) bad.push('rifle and Support MG draw the same');
       if(tips.lmg-tips.rifle<2) bad.push('the Support MG is not longer than the rifle');
       if(tips.sniper-tips.dmr<2) bad.push('the Longshot is not longer than the Marksman');
       if(tips.rifle-tips.smg<5) bad.push('the rifle is not clearly longer than the SMG');
       // facing left: the magazine (rifle well near x 11 to 14) hangs BELOW the barrel line (y -20), not above it
       noneL=draw(null,Math.PI); dl=draw(Object.assign({},WEAPONS.rifle),Math.PI);
       var below=diffN(dl,noneL,function(wx,wy){ return wx>-14.5&&wx<-12.6&&wy>-16&&wy<-11; });
       var above=diffN(dl,noneL,function(wx,wy){ return wx>-14.5&&wx<-12.6&&wy>-29&&wy<-24; });
       if(below<1.5) bad.push('facing left, nothing hangs under the rifle at the magazine well ('+below.toFixed(1)+')');
       if(above>below) bad.push('facing left, the magazine is drawn above the barrel');
       // the Forge: MK II is gold on the receiver, MK III differs by element
       if(typeof forgeApply==='function'){
         var mk2=draw(forgeApply(Object.assign({},WEAPONS.rifle),1),0);
         var goldN=function(img){ return diffN(img,none0,function(wx,wy,i){ return wx>8.2&&wx<14&&wy>-23&&wy<-17&&img[i]>170&&img[i+1]>120&&img[i+2]<110&&img[i]-img[i+2]>90; }); };
         gold=goldN(mk2);
         if(gold<8) bad.push('MK II rifle shows no gold finish on the receiver ('+gold.toFixed(1)+')');
         if(goldN(D.rifle)>2) bad.push('a plain rifle already reads gold');
         var fire=draw(forgeApply(Object.assign({},WEAPONS.rifle),2,'fire'),0), cryo=draw(forgeApply(Object.assign({},WEAPONS.rifle),2,'cryo'),0);
         if(diffN(fire,cryo,function(){ return true; })<3) bad.push('MK III FIRE and MK III CRYO draw the same');
         if(diffN(fire,mk2,function(){ return true; })<3) bad.push('MK III draws the same as MK II');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ wc=w0; if(typeof G!=='undefined'&&G) G.t=t0; }
     return bad.length?bad.join('; '):null; }},
  {v:'25.25',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
