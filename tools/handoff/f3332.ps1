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

if ($s.Contains("  {v:'33.32',what:")) { throw "check 33.32 is in the fixture already" }

SubRx @'
  {v:'33.31',what:
'@ @'
  {v:'33.32',what:'one gunfire tail only: the v23.77 place tails (slaps indoors, a roll outside, soft in the woods, a ring in a vault, a hiss over water) are the space-aware gunfire; the second tail of v33.25 is gone',
   run:function(){
     var bad=[], src, L;
     if(typeof gunLayers!=='function'||typeof gunTail!=='function') return 'the v23.77 gun tails are missing (no gunLayers)';
     L=gunLayers(100,'inside'); if(L.tailKind!=='slap') bad.push('indoors is not a slap tail');
     if(gunLayers(100,'woods').tailKind!=='soft'||gunLayers(100,'vault').tailKind!=='ring'||gunLayers(100,'open').tailKind!=='roll') bad.push('the place tails changed');
     if(!(gunLayers(800,'open').thump>0)) bad.push('a far shot has lost its thump');
     if(typeof sndGunTail==='function'||typeof gunTailSpec==='function'||typeof gunTailMake==='function') bad.push('the second gun tail (sndGunTail) is still there on top of gunTail');
     src=String((typeof _realBlip==='function')?_realBlip:blip);
     if(src.indexOf('sndGun'+'Tail(')>=0) bad.push('blip still adds the second tail');
     return bad.length?bad.join('; '):null;
   }},
  {v:'33.31',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
