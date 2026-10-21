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

# THE PIXEL UNDERCROFT CROWD (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(!figOn()) return drawOp0(x,y,face,ph,coat,pk,muzzle,mode,iv,st);
'@ @'
  if(!figOn()){
    if(pixOn()&&typeof hcv!=='undefined'&&wc&&wc.canvas===hcv&&pixBodyTry(x,y,face,ph,coat,pk,muzzle,mode,iv,st)) return;   // v33.60 (cw-pixcrowd), his pixel pass (10-20): the Undercroft crowd, you and the party on the hub canvas are pixel pillagers too; the small preview canvases stay vector until the wardrobe job
    return drawOp0(x,y,face,ph,coat,pk,muzzle,mode,iv,st);
  }
'@

SubRx @'
var VER='33.64';
'@ @'
var VER='33.65';
'@

$pat = "(?m)^  now:'v33\.64:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v33.65: With the pixel look on (the default), the Undercroft crowd, you and your mates are pixel pillagers. With the look off, nothing changes. Check 33.65 fails on v33.64',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
