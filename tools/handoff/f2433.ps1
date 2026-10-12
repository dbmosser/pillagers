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

if ($s.Contains("  {v:'24.33',what:")) { throw "check 24.33 is in the fixture already" }

SubRx @'
  {v:'24.32',what:
'@ @'
  {v:'24.33',what:'spr21: the Survivor wears civilian clothes with a head bandage, carries no pack or gun, and raises an open hand when you are near',
   run:function(){
     if(typeof drawOp!=='function'||typeof wc==='undefined') return 'SKIP: no drawOp here';
     var c=document.createElement('canvas'); c.width=300; c.height=320; var x=c.getContext('2d'), w0=wc, bad=[], d;
     var st0={moving:false,sprint:false,ads:false,hurt:0,bulk:0,wave:1,pack:'packbrown',skin:'fair'}; st0.outfit='outs'+'urvivor';
     try{ x.setTransform(6,0,0,6,150,290); wc=x;
       drawOp(0,0,0,0,'#7a8a6a',0,0,'crouchnone',0,st0);
       wc=w0; x.setTransform(1,0,0,1,0,0); d=x.getImageData(0,0,300,320).data; }
     catch(er){ bad.push('threw: '+(er&&er.message||er)); }
     finally{ wc=w0; }
     if(!d) return bad.join('; ');
     var pk=0, wh=0, hand=0, k, px, py, r, g, b, ux, uy;
     for(py=0;py<320;py++) for(px=0;px<300;px++){ k=(py*300+px)*4; if(d[k+3]<200) continue; r=d[k]; g=d[k+1]; b=d[k+2];
       if(Math.abs(r-92)<5&&Math.abs(g-74)<5&&Math.abs(b-52)<5) pk++;
       if(r>220&&g>212&&b>196&&r-b<30) wh++;
       ux=(px-150)/6; uy=(290-py)/6;
       if(Math.abs(ux)>9.5&&uy>28&&r>200&&g>165&&b>120&&r-b>40) hand++; }
     if(pk>0) bad.push(pk+' pack pixels (want none: he carries no pack)');
     if(wh<60) bad.push('no head bandage ('+wh+' bandage white pixels, want 60 or more)');
     if(hand<20) bad.push('no open hand raised beside his head ('+hand+' skin pixels up there, want 20 or more)');
     var src=[].slice.call(document.scripts).map(function(s){ return s.text; }).join('\n');
     if(src.indexOf("outfit:'outsur"+"vivor',wave:")<0) bad.push('the stray dispatch does not dress him in his outfit');
     if(src.indexOf("e2.helped?'none':'crouch"+"none'")<0) bad.push('he does not stand up once helped');
     return bad.length?bad.join('; '):null; }},
  {v:'24.32',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
