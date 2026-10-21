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

# THE PIXEL COVER WRECKS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
      var LEN=vt?ch3:cw3, WID=vt?cw3:ch3;
'@ @'
      var cvPaint=function(){   // v33.72 (cw-pixcover): the car, skip, barrier, pipes or pallets, closed over so the pixel look can bake it once; the soft contact shadow above it stays on the world
      var LEN=vt?ch3:cw3, WID=vt?cw3:ch3;
'@

SubRx @'
      box(cabA+0.02,0.16,cabB-0.02,0.24,21,'rgba(255,252,244,.13)',1);
      }
    } else if(it.w&&it.w.furn){
'@ @'
      box(cabA+0.02,0.16,cabB-0.02,0.24,21,'rgba(255,252,244,.13)',1);
      }
      };
      // v33.72 (cw-pixcover), HIS ORDER (2026-10-20 22:45 to 23:05, the pixel pass): with the pixel look on a cover piece is one cached sprite at PIX_ENV (2 world units per art pixel), by kind, side, size, colour and rust.
      var cvE=null;
      if(pixOn()) cvE=pixWrap('cv:'+(CR.kind||'car')+(vt?'v':'h')+(CR.flip>0?'1':'0')+':'+Math.round(cw3)+'x'+Math.round(ch3)+':'+String(CR.hue)+':'+Math.round((+CR.rust||0)*3),Math.round(cw3)+44,Math.round(ch3)+46,PIX_ENV,cvPaint,cx3+cw3/2,cy3+ch3,{up:Math.round(ch3)+32});
      if(!cvE) cvPaint();
    } else if(it.w&&it.w.furn){
'@

SubRx @'
var VER='33.76';
'@ @'
var VER='33.77';
'@

$pat = "(?m)^  now:'v33\.76:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v33.77: With the pixel look on, wrecked cars, skips, barriers, pipe bundles and pallets draw as crisp pixel sprites. With the look off nothing changes. Check 33.77 fails on v33.76',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
