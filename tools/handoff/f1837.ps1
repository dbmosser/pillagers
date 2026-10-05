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

if ($s.Contains("  {v:'18.37',what:")) { throw "check 18.37 is in the fixture already" }

SubRx @'
  {v:'18.36',what:
'@ @'
  {v:'18.37',what:'one bar for every meter: a full bar drawn on a test canvas is the fill colour at its centre, lighter at its top, and its outer corner is left clear (rounded)',
   run:function(){
     if(typeof bar!=='function') return 'SKIP: no bar painter';
     var bad=[], cv2=document.createElement('canvas'), oc=ctx, c, d0, dt, dc;
     cv2.width=200; cv2.height=60; c=cv2.getContext('2d');
     try{
       ctx=c; bar(10,10,180,30,1,'#5fae6f');
       dc=c.getImageData(100,25,1,1).data; dt=c.getImageData(100,12,1,1).data; d0=c.getImageData(10,10,1,1).data;
       if(Math.abs(dc[1]-0xae)>14) bad.push('the centre is not the fill colour ('+dc[0]+','+dc[1]+','+dc[2]+')');
       if(!(dt[0]+dt[1]+dt[2]>dc[0]+dc[1]+dc[2]+20)) bad.push('the top of the fill is not lit');
       if(d0[3]>120) bad.push('the corner is square (alpha '+d0[3]+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ ctx=oc; }
     return bad.length?bad.join('; '):null; }},
  {v:'18.36',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
