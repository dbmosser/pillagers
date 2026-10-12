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

if ($s.Contains("  {v:'24.16',what:")) { throw "check 24.16 is in the fixture already" }

SubRx @'
  {v:'24.15',what:
'@ @'
  {v:'24.16',what:'spr16: three bodies that read: Lean slimmer, Broad on wider legs and boots',
   run:function(){
     if(typeof drawOp!=='function'||typeof wc==='undefined') return 'SKIP: no drawOp here';
     var c=document.createElement('canvas'); c.width=240; c.height=300; var x=c.getContext('2d'), w0=wc, bad=[];
     function body(b){
       x.setTransform(1,0,0,1,0,0); x.clearRect(0,0,240,300); x.setTransform(6,0,0,6,120,270); wc=x;
       try{ drawOp(0,0,Math.PI/2,0,'#4a5b7d',0,0,'none',0,{moving:false,sprint:false,ads:false,hurt:0,rl:0,bulk:0,build:b,hair:'dark',cut:'crop',skin:'skinfair',pack:'packbrown',boots:'bootblack'}); }
       finally{ wc=w0; }
       return x.getImageData(0,0,240,300).data;
     }
     // the half width of one row on the side away from the pack: the body centre to its rightmost solid pixel, in world units
     function wid(d,u){ var py=Math.round(270-6*u), b2=-1, px; for(px=120;px<240;px++){ if(d[(py*240+px)*4+3]>200) b2=px; } return b2<0?0:(b2-120+1)/6; }
     try{
       var L0=body('lean'), B0=body('broad');
       var lt=wid(L0,14.5), bt=wid(B0,14.5), lb=wid(L0,1.5), bb=wid(B0,1.5);
       if(lt>7.1) bad.push('the Lean torso half width is '+lt.toFixed(1)+' (want 7.1 or less: slimmer than the old 7.5)');
       if(bt-lt<1.5) bad.push('Broad ('+bt.toFixed(1)+') is not 1.5 wider than Lean ('+lt.toFixed(1)+') at the waist');
       if(bb-lb<1.0) bad.push('the Broad boots ('+bb.toFixed(1)+') are not 1.0 wider than the Lean boots ('+lb.toFixed(1)+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ wc=w0; }
     return bad.length?bad.join('; '):null; }},
  {v:'24.15',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
