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

# THE HP NUMBER FITS ITS BAR (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  ctx.font=FS(TYPE.title); ctx.fillStyle='#FFF6DC';
  ctx.fillText('HP  '+Math.round(p.hp),24,by+18);
'@ @'
  // v20.57, seen on the 4K screenshot (2026-10-08): THE HP NUMBER SITS INSIDE ITS BAR. The number grows with the text size (the
  // Settings choice and the screen) on top of the corner zoom the two share, while the bar grows with the zoom only, so at 4K
  // the number stood a third taller than its bar and stuck out over the top edge. It is now never taller than the bar holds,
  // and then centred in it; at 1080p with the usual text size nothing changes.
  var _hpf=FS(TYPE.title), _hpx=parseFloat((/([\d.]+)px/.exec(_hpf)||[0,26])[1]), _hpm=HBH*1.08;
  if(_hpx>_hpm) _hpf=_hpf.replace(/[\d.]+px/,(Math.round(_hpm*10)/10)+'px');
  ctx.font=_hpf; ctx.fillStyle='#FFF6DC';
  ctx.fillText('HP  '+Math.round(p.hp),24,(_hpx>_hpm)?Math.round(by+HBH/2+_hpm*0.36):by+18);
'@

SubRx @'
var VER='20.56';
'@ @'
var VER='20.57';
'@

$pat = "(?m)^  now:'v20\.56:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.57: At 4K the HP number sits inside its bar. Check 20.57 fails on v20.56',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
