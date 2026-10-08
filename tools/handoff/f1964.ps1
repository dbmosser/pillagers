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

if ($s.Contains("  {v:'19.64',what:")) { throw "check 19.64 is in the fixture already" }

SubRx @'
  {v:'19.63',what:
'@ @'
  {v:'19.64',what:'a map tag steps aside before it steps down: with the spot above taken and room to the side, a clashing CACHE tag moves sideways, not down onto its marker',
   run:function(){
     if(typeof mapPlaceLabels!=='function') return 'SKIP: no label placer here';
     var bad=[], got={}, c=document.createElement('canvas'), x2=c.getContext('2d'), keep=ctx, m;
     if(!x2) return 'SKIP: no canvas';
     c.width=1200; c.height=800;
     function lab(s,x,y){ x2.font='bold 14px sans-serif'; return {s:s,x:x,y:y,font:x2.font,fs:'#fff',ta:'center',tb:'alphabetic',ga:1,m:new DOMMatrix([1,0,0,1,0,0]),fp:14,w:x2.measureText(s).width}; }
     try{
       ctx=x2;
       mapPlaceLabels([lab('SECTOR MAP',100,30),lab('CACHE',400,304),lab('ZQX LOCKED',355,300),lab('ZQY LOCKED',355,282)],30,function(s,x,y){ got[String(s)]={x:x,y:y}; });
       m=got['CACHE'];
       if(!m) return 'SKIP: the CACHE tag was dropped';
       if(m.y>304+1) bad.push('the CACHE tag was moved down to y '+Math.round(m.y)+', onto its marker, with room beside it');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ ctx=keep; }
     return bad.length?bad.join('; '):null; }},
  {v:'19.63',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
