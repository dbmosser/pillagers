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

# THE STAMINA WORD IS INSIDE ITS BAR (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  var _stc=p.stamLock?'#ff5a4a':(p.stam<35?'#ffc04a':'#8fb5c8');
'@ @'
  var _stc=p.stamLock?'#c8452f':(p.stam<35?'#c98a1e':'#4f86a8');   // v28.xx (cw-stamlabel), the critic (2026-10-19): 'the stamina label sits outside its bar'. The fills are one step darker so the cream word reads inside the bar, the way the armour word does.
'@

SubRx @'
  ctx.font=FS(TYPE.micro); ctx.fillStyle=_stc;
  ctx.fillText(p.stamLock?'WINDED':'STAMINA',16+HBW+8,by-17);
'@ @'
  // v28.xx (cw-stamlabel), the critic (2026-10-19): 'stamina label outside its bar; three bar styles'. The word is inside the bar, left, in the armour word's face and colour, with a dark halo for the empty end.
  var _spf=FS(TYPE.label), _spx=parseFloat((/([\d.]+)px/.exec(_spf)||[0,13])[1]), _spm=16*1.08;
  if(_spx>_spm) _spf=_spf.replace(/[\d.]+px/,(Math.round(_spm*10)/10)+'px');
  ctx.save(); ctx.font=_spf; ctx.fillStyle='#FFF6DC'; ctx.shadowColor='rgba(0,0,0,.85)'; ctx.shadowBlur=3;
  ctx.fillText(p.stamLock?'WINDED':'STAMINA',24,(_spx>_spm)?Math.round(by-29+8+_spm*0.36):by-16);
  ctx.restore();
'@

SubRx @'
var VER='32.10';
'@ @'
var VER='32.11';
'@

$pat = "(?m)^  now:'v32\.10:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.11: The stamina word sits inside its bar like armour and health. Check 32.11 fails on v32.10',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
