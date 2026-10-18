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

if ($s.Contains("  {v:'30.31',what:")) { throw "check 30.31 is in the fixture already" }

SubRx @'
  {v:'30.30',what:
'@ @'
  {v:'30.31',what:'the small art touches are drawn: the default pack has a seam, strap and steel buckle, the boots have lace dots, and the jersey 23 has a soft shadow',
   run:function(){
     if(typeof drawOp!=='function'||typeof darkHex!=='function'||typeof PACKCOL==='undefined') return 'SKIP: no drawOp';
     var keepOut=P.cosOutfit, bad=[], kw=wc, SC=300;
     function mk(o){ var s={hero:0,build:'lean',pack:'packbrown',boots:'bootblack',hair:'dark',cut:'crop',skin:'fair',fit:'slate',eyes:'eyebrown',hat:'none'}, k; for(k in o) s[k]=o[k]; return s; }
     function paint(fn){
       var cv2=document.createElement('canvas'), x2;
       cv2.width=SC; cv2.height=SC; x2=cv2.getContext('2d'); wc=x2;
       try{ x2.translate(150,250); x2.scale(4,4); fn(); } finally { wc=kw; }
       return x2.getImageData(0,0,SC,SC).data;
     }
     function cnt(d,r,g,b,t){ var n=0, i; for(i=0;i<d.length;i+=4) if(d[i+3]>200&&Math.abs(d[i]-r)<=t&&Math.abs(d[i+1]-g)<=t&&Math.abs(d[i+2]-b)<=t) n++; return n; }
     function hx(h){ return [parseInt(h.slice(1,3),16),parseInt(h.slice(3,5),16),parseInt(h.slice(5,7),16)]; }
     try{
       P.cosOutfit='outnone';
       var d=paint(function(){ drawOp(0,0,0,0,'#242832',0,0,'none',0,mk({})); });
       var sm=hx(darkHex(PACKCOL.packbrown,.35));
       var nb=cnt(d,207,213,219,14), ns=cnt(d,sm[0],sm[1],sm[2],5), nl=cnt(d,216,212,196,16);
       if(nb<20) bad.push('the pack buckle shows only '+nb+' steel pixels (want 20 or more)');
       if(ns<30) bad.push('the pack seam and strap show only '+ns+' pixels (want 30 or more)');
       if(nl<12) bad.push('the boot laces show only '+nl+' pale pixels (want 12 or more)');
       var j=paint(function(){ drawOp(0,0,0,0,'#c41e1e',0,0,'none',0,mk({outfit:'outballer'})); }), n=0, i, x, y;
       for(i=0;i<SC*SC;i++){ x=i%SC; y=(i-x)/SC; if(x<150-4.5*4||x>150+4.9*4||y<250-21*4||y>250-14*4) continue; if(j[i*4+3]>200&&j[i*4]>=70&&j[i*4]<=105&&j[i*4+1]>=10&&j[i*4+1]<=45&&j[i*4+2]>=10&&j[i*4+2]<=45) n++; }
       if(n<30) bad.push('the jersey 23 shows only '+n+' shadow pixels (want 30 or more)');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ wc=kw; if(keepOut===undefined) delete P.cosOutfit; else P.cosOutfit=keepOut; }
     return bad.length?bad.join('; '):null; }},
  {v:'30.30',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
