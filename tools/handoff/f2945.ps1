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

if ($s.Contains("  {v:'29.45',what:")) { throw "check 29.45 is in the fixture already" }

SubRx @'
  {v:'29.44',what:
'@ @'
  {v:'29.45',what:'the Raider Tactical Helmet is drawn with a scheme colour stripe across the dome and bare steel paint chips, and the Raider bandolier strap with steel flecks',
   run:function(){
     if(typeof drawOp!=='function'||typeof drawVest!=='function') return 'SKIP: no drawOp';
     var keepOut=P.cosOutfit, bad=[], kw=wc, SC=300;
     function mk(h,sc){ return {hero:0,build:'lean',pack:'packbrown',boots:'bootblack',hair:'dark',cut:'crop',skin:'fair',fit:'slate',eyes:'eyebrown',hat:h,scheme:sc}; }
     function paint(fn){
       var cv2=document.createElement('canvas'), x2;
       cv2.width=SC; cv2.height=SC; x2=cv2.getContext('2d'); wc=x2;
       try{ x2.translate(150,250); x2.scale(4,4); fn(); } finally { wc=kw; }
       return x2.getImageData(0,0,SC,SC).data;
     }
     function near(d,i,r,g,b,t){ return d[i+3]>200&&Math.abs(d[i]-r)<=t&&Math.abs(d[i+1]-g)<=t&&Math.abs(d[i+2]-b)<=t; }
     function chips(d){ var n=0, i; for(i=0;i<d.length;i+=4) if(near(d,i,223,230,236,12)) n++; return n; }
     function run(d,r,g,b,t){ var best=0, cur, x, y; for(y=0;y<SC;y++){ cur=0; for(x=0;x<SC;x++){ if(near(d,(y*SC+x)*4,r,g,b,t)){ cur++; if(cur>best) best=cur; } else cur=0; } } return best/4; }
     try{
       P.cosOutfit='outnone';
       var none=paint(function(){ drawOp(0,0,0,0,'#242832',0,0,'none',0,mk('none','schember')); });
       var tac=paint(function(){ drawOp(0,0,0,0,'#242832',0,0,'none',0,mk('tachelm','schember')); });
       var cn=chips(tac)-chips(none), st=run(tac,255,181,46,16);
       if(cn<30) bad.push('the Tactical Helmet shows only '+cn+' bare steel chip pixels (want 30 or more)');
       if(st<10) bad.push('the Tactical Helmet has no colour stripe across the dome (longest accent run '+st.toFixed(1)+' px, want 10 or more)');
       var vb=paint(function(){ drawVest('vestband','lean',0,30,'#4a5a6a',{a:'#c8a24a'},1); });
       var cv=chips(vb);
       if(cv<20) bad.push('the Bandolier shows only '+cv+' bare steel fleck pixels (want 20 or more)');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ wc=kw; if(keepOut===undefined) delete P.cosOutfit; else P.cosOutfit=keepOut; }
     return bad.length?bad.join('; '):null; }},
  {v:'29.44',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
