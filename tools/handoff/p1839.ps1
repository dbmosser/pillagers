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

# THE WEAPON PANEL NEVER COVERS THE BELT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  try{ var _wpw=Math.max(LH(230),ctx.measureText(_cornName).width+LH(30)); hudPanel(W-16-_wpw+LH(10),by-LH(90),_wpw,LH(100),0.62); ctx.textAlign='right'; }catch(_wp){}
'@ @'
  try{ var _wpw=Math.max(LH(230),ctx.measureText(_cornName).width+LH(30)), _wpx=W-16-_wpw+LH(10), _hcL=(G.hotCells&&G.hotCells.length)?G.hotCells[G.hotCells.length-1]:null;
       var _gz=(HUDZ.gear||1)*hudRes()*hudUserZ('gear'), _gdx=(typeof _boG==='object'&&_boG)?(_boG.dx||0):0, _lim=_hcL?(W+((_hcL.x+_hcL.w+LH(8))-_gdx-W)/_gz):-1e9;   // the belt edge, brought into this corner's scaled space
       if(_hcL&&_wpx<_lim){ _wpx=_lim; _wpw=W-16+LH(10)-_wpx; }   // v18.39: never over the belt (it covered key 9)
       if(_wpw>LH(60)) hudPanel(_wpx,by-LH(90),_wpw,LH(100),0.62); ctx.textAlign='right'; }catch(_wp){}
'@

SubRx @'
var VER='18.38';
'@ @'
var VER='18.39';
'@

$pat = "(?m)^  now:'v18\.38:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.39: The weapon readout panel no longer covers belt key 9. Check 18.39 fails on v18.38',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
