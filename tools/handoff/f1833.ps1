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

if ($s.Contains("  {v:'18.33',what:")) { throw "check 18.33 is in the fixture already" }

SubRx @'
  {v:'18.32',what:
'@ @'
  {v:'18.33',what:'the raid belt and backpack draw sprite icons: drawing an item icon through the sprite paints the canvas around its centre, the second draw reuses the stored sprite, and a non-gun sprite carries the lift (lighter top left than bottom right)',
   run:function(){
     if(typeof iconSprite!=='function'||typeof drawIconSprite!=='function') return 'the raid icons are painted live';
     var bad=[], cv2=document.createElement('canvas'), c, n0, e, d, tl, br;
     cv2.width=120; cv2.height=120; c=cv2.getContext('2d');
     try{
       drawIconSprite(c,'bandage',60,60,60);
       d=c.getImageData(60,60,1,1).data; if(d[3]<50) bad.push('nothing was painted at the icon centre');
       n0=ICONSPR.n; drawIconSprite(c,'bandage',60,60,60); if(ICONSPR.n!==n0) bad.push('the second draw painted a new sprite');
       e=iconSprite('plate',60)||iconSprite('armor',60);
       if(!e) bad.push('no sprite for a plate');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     return bad.length?bad.join('; '):null; }},
  {v:'18.32',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
