$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

SubRx @'
  if(p.downed||p.hp>=p.maxhp||p.combatT<CFG.regenDelay){ p.regenAcc=0; return; }
  p.regenAcc=(p.regenAcc||0)+dt;
  while(p.regenAcc>=CFG.regenSec&&p.hp<p.maxhp){
    p.regenAcc-=CFG.regenSec;
    p.hp=Math.min(p.maxhp,p.hp+1);
'@ @'
  // v15.23, his ruling of 2026-09-16: ONLY A MEDKIT GETS HIM BACK TO 100. "bandages should only let players heal to 85 HP -- only
  // medkit gets player back to 100". Out of combat this crept one point every three seconds all the way to 100, so a Bandage to
  // 85 and a minute of quiet did what only a Medkit may. Regen stops at the Bandage ceiling, and never takes health away above
  // it; with the heal ceilings dial off it runs to 100 as before.
  var _top=healCeil(ITEMS.bandage);
  if(p.downed||p.hp>=_top||p.combatT<CFG.regenDelay){ p.regenAcc=0; return; }
  p.regenAcc=(p.regenAcc||0)+dt;
  while(p.regenAcc>=CFG.regenSec&&p.hp<_top){
    p.regenAcc-=CFG.regenSec;
    p.hp=Math.min(_top,p.hp+1);
'@
SubRx @'
var VER='15.22';
'@ @'
var VER='15.23';
'@

$pat = "(?m)^  now:'v15\.22:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.23: ONLY A MEDKIT GETS HIM BACK TO 100, HIS RULING OF 2026-09-16. Out of combat health crept back one point every three seconds all the way to 100, so a Bandage to 85 and a minute of quiet did what only a Medkit may. Regen now stops at the Bandage ceiling of 85. Check 15.23 runs regen from 80 with ceilings on and off; it fails on v15.22',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
