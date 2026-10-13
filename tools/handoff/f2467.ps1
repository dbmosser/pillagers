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

if ($s.Contains("  {v:'24.67',what:")) { throw "check 24.67 is in the fixture already" }

SubRx @'
  {v:'24.66',what:
'@ @'
  {v:'24.67',what:'his #50 and #35 (UI redesign ui5q1k, from the AAA judge of the raid HUD shots): the HUD panel is the graphite menu plate: a neutral graphite fill of 85 percent or more by default (no navy), a cut top left corner, and an amber tick on its top edge',
   run:function(){
     if(typeof hudPanel!=='function') return 'SKIP: no HUD panel here';
     var bad=[], keep=ctx, oc=document.createElement('canvas'), c2, d, px;
     oc.width=240; oc.height=140; c2=oc.getContext('2d');
     function at(x,y){ return c2.getImageData(x,y,1,1).data; }
     try{
       ctx=c2; hudPanel(20,20,200,100);
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ ctx=keep; }
     d=at(120,90);
     if(d[3]<215) bad.push('the panel fill is only '+Math.round(d[3]/2.55)+' percent');
     if(d[2]-d[0]>8) bad.push('the panel fill is navy (rgb '+d[0]+','+d[1]+','+d[2]+')');
     px=at(21,21);
     if(px[3]>40) bad.push('the top left corner is not cut (alpha '+px[3]+')');
     d=at(20+10+4+6,20);
     if(!(d[0]>200&&d[1]>140&&d[2]<120&&d[3]>200)) bad.push('there is no amber tick on the top edge (rgba '+[d[0],d[1],d[2],d[3]].join(',')+')');
     return bad.length?bad.join('; '):null; }},
  {v:'24.66',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
