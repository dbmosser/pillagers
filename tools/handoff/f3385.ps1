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

if ($s.Contains("  {v:'33.85',what:")) { throw "check 33.85 is in the fixture already" }

SubRx @'
  {v:'33.84',what:
'@ @'
  {v:'33.85',what:'cw-pixwild (86e) ship 6: live and dead deer and birds go through pixWrap as hard alpha scene sprites; the wing beat, peck, gait and head bob are whole steps; the drawn frames keep their old size',
   run:function(){
     if(typeof pixWrap!=='function'||typeof PIXW!=='object') return 'no adapter: pixWrap is not defined';
     var src=String(render2D), bad=[];
     ['pixWrap(\'cd:\'','pixWrap(\'bd:\'','pixWrap(\'dr:\''].forEach(function(k){ if(src.indexOf(k)<0) bad.push(k+' is not drawn through pixWrap'); });
     if(src.indexOf('Math.round(Math.sin(CT.f)*(run?5:1.2))')<0) bad.push('the deer gait is not a whole step');
     if(src.indexOf('Math.round(Math.sin(CT.f)*2)*2.5')<0) bad.push('the bird wing beat is not a step');
     if(typeof pixWrapBake!=='function') bad.push('no pixWrapBake');
     else {
       var T0=wc, s, e, px, j, aa=0, a1=0;
       try{
         e=pixWrapBake(48,26,PIX_ENV,14,function(){ wc.fillStyle='#5c2a1c'; wc.beginPath(); wc.ellipse(0,-3,14,5.5,0.18,0,6.2832); wc.fill(); },0,0);
         if(wc!==T0) bad.push('the bake left wc on the scratch');
         px=e.c.getContext('2d').getImageData(0,0,e.c.width,e.c.height).data;
         for(j=3;j<px.length;j+=4){ if(px[j]===255) a1++; else if(px[j]!==0) aa++; }
         if(aa) bad.push('a deer carcass bake has '+aa+' soft alpha pixels');
         if(!a1) bad.push('a deer carcass bake is empty');
         if(e.c.width*e.d<24) bad.push('a deer carcass bake is only '+e.c.width*e.d+' wide');
       } catch(err){ bad.push('bake threw: '+String(err&&err.message||err)); }
       finally { if(wc!==T0) wc=T0; }
     }
     return bad.length?bad.slice(0,8).join('; '):null;
   }},
  {v:'33.84',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
