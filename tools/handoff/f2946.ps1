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

if ($s.Contains("  {v:'29.46',what:")) { throw "check 29.46 is in the fixture already" }

SubRx @'
  {v:'29.45',what:
'@ @'
  {v:'29.46',what:'the Heavy fuel can pack is drawn with a scheme colour stripe and bare steel chips, and the Heavy shin guards with steel chips',
   run:function(){
     if(typeof drawOp!=='function') return 'SKIP: no drawOp';
     var keepOut=P.cosOutfit, bad=[], kw=wc, SC=300;
     function mk(pk,bt){ return {hero:0,build:'lean',pack:pk,boots:bt,hair:'dark',cut:'crop',skin:'fair',fit:'slate',eyes:'eyebrown',hat:'none',scheme:'schember'}; }
     function paint(fn){
       var cv2=document.createElement('canvas'), x2;
       cv2.width=SC; cv2.height=SC; x2=cv2.getContext('2d'); wc=x2;
       try{ x2.translate(150,250); x2.scale(4,4); fn(); } finally { wc=kw; }
       return x2.getImageData(0,0,SC,SC).data;
     }
     function near(d,i,r,g,b,t){ return d[i+3]>200&&Math.abs(d[i]-r)<=t&&Math.abs(d[i+1]-g)<=t&&Math.abs(d[i+2]-b)<=t; }
     function cnt(d,r,g,b,t){ var n=0, i; for(i=0;i<d.length;i+=4) if(near(d,i,r,g,b,t)) n++; return n; }
     try{
       P.cosOutfit='outnone';
       var one=function(pk,bt){ return paint(function(){ drawOp(0,0,0,0,'#242832',0,0,'none',0,mk(pk,bt)); }); };
       var base=one('packbrown','bootblack'), fuel=one('packfuel','bootblack'), shin=one('packbrown','bootshin');
       var cf=cnt(fuel,223,230,236,12)-cnt(base,223,230,236,12), cs=cnt(shin,223,230,236,12)-cnt(base,223,230,236,12);
       var af=cnt(fuel,255,181,46,16)-cnt(base,255,181,46,16);
       if(cf<24) bad.push('the fuel can shows only '+cf+' bare steel chip pixels (want 24 or more)');
       if(af<90) bad.push('the fuel can shows only '+af+' more scheme accent pixels than a plain pack (want 90 or more, the stripe)');
       if(cs<24) bad.push('the shin guards show only '+cs+' bare steel chip pixels (want 24 or more)');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ wc=kw; if(keepOut===undefined) delete P.cosOutfit; else P.cosOutfit=keepOut; }
     return bad.length?bad.join('; '):null; }},
  {v:'29.45',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
