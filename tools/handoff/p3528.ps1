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

# WHEEL DROP HINT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  hk=padOn()?pbn(13):String(keyLabel('KeyQ','Q'));
'@ @'
  hk=padOn()?pbn(13):String(keyLabel('KeyQ','Q'));
  var _whd=!w.hub&&G.drag&&G.drag.fromWheel, _wht=w.hub?'RELEASE TO CLOSE':(_whd?'DROP ON A KEY':'RELEASE TO TAKE OUT');   // cw-wheeldrophint: an item held off the wheel (cw-beltwheel) drops on a belt key
  if(_whd) hk='LMB';
'@

SubRx @'
  ctx.font=FS(TYPE.label); tw=ctx.measureText(w.hub?'RELEASE TO CLOSE':'RELEASE TO TAKE OUT').width+LH(52);
'@ @'
  ctx.font=FS(TYPE.label); tw=ctx.measureText(_wht).width+LH(52);
'@

SubRx @'
  ctx.textAlign='left'; ctx.fillStyle=UIC.tx_1; hudText(w.hub?'RELEASE TO CLOSE':'RELEASE TO TAKE OUT',-tw/2+LH(46),LH(2));
'@ @'
  ctx.textAlign='left'; ctx.fillStyle=UIC.tx_1; hudText(_wht,-tw/2+LH(46),LH(2));
'@

SubRx @'
var VER='35.27';
'@ @'
var VER='35.28';
'@

$pat = "(?m)^  now:'v35\.27:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.28: while an item off the wheel is held the hint says lmb drop on a key Check 35.28 fails on v35.27',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
