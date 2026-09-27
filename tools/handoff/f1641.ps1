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

if ($s.Contains("  {v:'16.41',what:")) { throw "check 16.41 is in the fixture already" }

SubRx @'
  {v:'16.40',what:
'@ @'
  {v:'16.41',what:'a teammate off screen gets an arrow at the screen edge pointing at him; one on screen gets none',
   run:function(){
     if(typeof netMateArrow!=='function') return 'this build draws no arrow to a teammate off screen';
     if(typeof w2s!=='function'||!(W>0&&H>0)) return 'SKIP: no screen to draw on';
     var oW=w2s, a, b, bad=[];
     try{
       w2s=function(x,h,z){ return {x:x,y:z}; };
       a=netMateArrow({seat:1,x:W*3,y:H/2,dn:0});
       b=netMateArrow({seat:1,x:W/2,y:H/2,dn:0});
     } finally { w2s=oW; }
     if(!a) bad.push('a teammate far off the right edge got no arrow');
     else { if(!(a.x>W*0.8&&a.x<=W)) bad.push('the arrow is not at the right edge (x '+Math.round(a.x)+' of '+W+')'); if(Math.abs(a.a)>0.05) bad.push('the arrow does not point right ('+a.a.toFixed(2)+')'); }
     if(b) bad.push('a teammate on screen got an arrow');
     return bad.length?bad.join('; '):null; }},
  {v:'16.40',what:
'@


$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
