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

if ($s.Contains("  {v:'20.16',what:")) { throw "check 20.16 is in the fixture already" }

SubRx @'
  {v:'20.15',what:
'@ @'
  {v:'20.16',what:'long hair leaves a Curved chest showing: on a teammate, a pillager or the crowd, a Curved body with long hair shows the same chest as one with short hair',
   run:function(){
     if(typeof drawOp!=='function') return 'SKIP: no painter here';
     var w0=wc, cv=document.createElement('canvas'), x2, bad=[], a, b;
     cv.width=240; cv.height=220; x2=cv.getContext('2d'); if(!x2) return 'SKIP: no canvas';
     function px(cut){ x2.setTransform(1,0,0,1,0,0); x2.clearRect(0,0,240,220); x2.setTransform(4,0,0,4,120,190); wc=x2; drawOp(0,0,0,0,'#5a6a7a',0,0,'none',0,{hero:0,build:'curved',cut:cut,hair:'blonde',hat:'none',moving:false,sprint:false,ads:false,hurt:0,rl:0,own:{wep:null}}); wc=w0; x2.setTransform(1,0,0,1,0,0); var d=x2.getImageData(Math.round(120-2.8*4),Math.round(190-19.4*4),1,1).data; return [d[0],d[1],d[2]]; }
     try{ a=px('crop'); b=px('long'); }catch(e){ wc=w0; return 'threw: '+(e&&e.message||e); }
     finally{ wc=w0; }
     if(Math.abs(a[0]-b[0])+Math.abs(a[1]-b[1])+Math.abs(a[2]-b[2])>30) bad.push('long hair covers the Curved chest (short '+a.join(',')+', long '+b.join(',')+')');
     return bad.length?bad.join('; '):null; }},
  {v:'20.15',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
