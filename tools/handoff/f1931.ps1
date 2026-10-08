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

if ($s.Contains("  {v:'19.31',what:")) { throw "check 19.31 is in the fixture already" }

SubRx @'
  {v:'19.30',what:
'@ @'
  {v:'19.31',what:'a moved map label stays on the map: a zone name that clashes with the SECTOR MAP line is never moved up past that line or off the screen',
   run:function(){
     if(typeof mapPlaceLabels!=='function'||typeof mapLabelRect!=='function') return 'SKIP: no label placer here';
     var bad=[], got=[], m, c=document.createElement('canvas'), x2=c.getContext('2d'), keep=ctx, n;
     if(!x2) return 'SKIP: no canvas';
     c.width=800; c.height=600;
     function lab(s,x,y,ga){ x2.font='bold 14px sans-serif'; return {s:s,x:x,y:y,font:x2.font,fs:'#fff',ta:'left',tb:'alphabetic',ga:ga,m:new DOMMatrix([1,0,0,1,0,0]),fp:14,w:x2.measureText(s).width}; }
     try{
       ctx=x2;
       n=mapPlaceLabels([lab('SECTOR MAP',20,40,1),lab('ZQX ZONE NAME',30,44,0.5),lab('ZQX BLOCK ONE',31,61.7,1),lab('ZQX BLOCK TWO',31,79.4,1)],40,function(s,x,y){ got.push({s:String(s),y:y}); });
       m=got.filter(function(q){ return q.s==='ZQX ZONE NAME'; })[0];
       if(m&&m.y<40) bad.push('the zone name was moved up past the SECTOR MAP line to y '+Math.round(m.y));
       if(m&&m.y-14*0.82<0) bad.push('the zone name was moved off the top of the screen');
       if(!got.some(function(q){ return q.s==='SECTOR MAP'; })) bad.push('control: the header was not drawn');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ ctx=keep; }
     return bad.length?bad.join('; '):null; }},
  {v:'19.30',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
