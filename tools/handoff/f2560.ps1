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

if ($s.Contains("  {v:'25.60',what:")) { throw "check 25.60 is in the fixture already" }

SubRx @'
  {v:'25.59',what:
'@ @'
  {v:'25.60',what:'his order: pillagers, hires and your teammate hold the same big guns, and a teammate Forge gun shows',
   run:function(){
     if(typeof drawOp!=='function'||typeof WEAPONS==='undefined'||!WEAPONS.rifle) return 'SKIP: no drawOp here';
     var Sc=5, OX=48, OY=56, CW=96, CH=72, bad=[], w0=wc, t0=(typeof G!=='undefined'&&G)?G.t:0;
     function paint(fn){
       var c=document.createElement('canvas'), x; c.width=CW*Sc; c.height=CH*Sc; x=c.getContext('2d');
       wc=x; x.setTransform(Sc,0,0,Sc,OX*Sc,OY*Sc);
       try{ fn(); } finally{ wc=w0; }
       return x.getImageData(0,0,c.width,c.height).data;
     }
     function raider(W,face){
       return paint(function(){ drawOp(0,0,face||0,0,'#8a2f2f',0,0,W?'':'none',0,{own:{kind:'raider',wep:W},team:'foe',moving:false,sprint:false,ads:false,hurt:0,bulk:0,build:'lean'}); });
     }
     function diffN(a,b,fn){
       var n=0, px, py, i;
       for(py=0;py<CH*Sc;py++) for(px=0;px<CW*Sc;px++){
         i=(py*CW*Sc+px)*4;
         if(Math.abs(a[i]-b[i])+Math.abs(a[i+1]-b[i+1])+Math.abs(a[i+2]-b[i+2])+Math.abs(a[i+3]-b[i+3])>60&&fn(px/Sc-OX,py/Sc-OY,i)) n++;
       }
       return n/(Sc*Sc);
     }
     var MIN={pistol:15,smg:18,rifle:28,shotgun:26,lmg:31,dmr:33,sniper:37}, id, none0, d, x1;
     try{
       if(typeof G!=='undefined'&&G) G.t=1.0;
       none0=raider(null,0);
       for(id in MIN){
         if(!WEAPONS[id]) continue;
         d=raider(Object.assign({},WEAPONS[id]),0); x1=-1e9;
         diffN(d,none0,function(wx){ if(wx>x1) x1=wx; return true; });
         if(!(x1>=MIN[id])) bad.push('a pillager '+id+' reaches '+x1.toFixed(1)+', wants '+MIN[id]);
       }
       if(typeof netUpDrawOne==='function'&&typeof forgeApply==='function'){
         var mk=function(fk,el){ return paint(function(){ netUpDrawOne({x:0,y:0,f:0,bob:0,mv:0,sp:0,lk:{fit:'slate',build:'lean'},w:'rifle',fk:fk,el:el}); }); };
         var plain=mk(0,''), gold=mk(1,''), acid=mk(2,'acid');
         var goldN=function(img){ return diffN(img,plain,function(wx,wy,i){ return wx>8.2&&wx<14&&wy>-23&&wy<-17&&img[i]>170&&img[i+1]>120&&img[i+2]<110&&img[i]-img[i+2]>90; }); };
         if(goldN(gold)<8) bad.push('a teammate MK II rifle shows no gold in this window ('+goldN(gold).toFixed(1)+')');
         if(diffN(acid,gold,function(){ return true; })<3) bad.push('a teammate MK III ACID draws the same as MK II');
       }
       var src=[].slice.call(document.scripts).map(function(s){ return s.text||''; }).join('\n');
       if(src.indexOf('g.fk=(m.'+'fk===1')<0) bad.push('the teammate message does not read the Forge mark');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ wc=w0; if(typeof G!=='undefined'&&G) G.t=t0; }
     return bad.length?bad.join('; '):null; }},
  {v:'25.59',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
