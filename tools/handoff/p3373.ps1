$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
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

# PIXEL FASHION TURNTABLE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    if(pixOn()&&typeof hcv!=='undefined'&&wc&&wc.canvas===hcv&&pixBodyTry(x,y,face,ph,coat,pk,muzzle,mode,iv,st)) return;   // v33.60 (cw-pixcrowd), his pixel pass (10-20): the Undercroft crowd, you and the party on the hub canvas are pixel pillagers too; the small preview canvases stay vector until the wardrobe job
'@ @'
    if(pixOn()&&wc&&((typeof hcv!=='undefined'&&wc.canvas===hcv)||wc.canvas.id==='avcv')&&pixBodyTry(x,y,face,ph,coat,pk,muzzle,mode,iv,st)) return; // v28.xx (cw-cx-pixpreview): the FASHION turntable uses the same plain pixel body as the raid and Undercroft
'@

SubRx @'
  var S=Math.max(5.2,c.height/62);   // v28.29 (cosm7): the figure fills the taller canvas
'@ @'
  var S=pixOn()?4:Math.max(5.2,c.height/62); // v28.xx (cw-cx-pixpreview): job 86c asks for whole 4x previews with smoothing off
  c.style.imageRendering=pixOn()?'pixelated':'';
  x2.imageSmoothingEnabled=!pixOn();
'@

SubRx @'
  x2.save(); x2.translate(c.width/2,c.height-16); x2.scale(S,S);
'@ @'
  var base=pixOn()?Math.round((c.height+PXB.TARGET*S)/2):c.height-16; // v28.xx (cw-cx-pixpreview): center the 4x figure in the existing turntable canvas
  x2.save(); x2.translate(c.width/2,base); x2.scale(S,S);
'@

SubRx @'
var VER='33.72';
'@ @'
var VER='33.73';
'@

$pat = "(?m)^  now:'v33\.72:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v33.73: The FASHION turntable shows the plain pixel pillager at 4x, centered in its existing canvas. The later wardrobe job still owns the rack tiles and full sets. Check 33.73 fails on v33.72',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
