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

if ($s.Contains("  {v:'34.48',what:")) { throw "check 34.48 is in the fixture already" }

SubRx @'
  {v:'34.47',what:
'@ @'
  {v:'34.48',what:'cw-pixdecal (86b): FOOTPRINTS AND DECALS SIT ON THE GROUND GRID. In the pixel look their draw position snaps to the 2 unit ground grid; with it off nothing moves; and the raid frame draws them through that snap',
   run:function(){
     if(typeof pixMarkSnap!=='function') return 'no mark snap (pixMarkSnap)';
     var bad=[], old=CFG.xfPix, src=String(render2D), a, b;
     try{
       CFG.xfPix=1; a=pixMarkSnap(101.3); b=pixMarkSnap(-7.9);
       if(a!==102||b!==-8) bad.push('the look on does not snap to the 2 unit grid: '+a+', '+b);
       CFG.xfPix=0; a=pixMarkSnap(101.3);
       if(a!==101.3) bad.push('the look off moved a mark: '+a);
       if((src.match(/pixMarkSnap\(/g)||[]).length<5) bad.push('the raid frame does not draw prints and decals through the snap');
       return bad.length?bad.join('; '):null;
     } catch(err){
       return 'pixel decal check: '+String(err&&err.message||err);
     } finally { CFG.xfPix=old; } }},
  {v:'34.47',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
