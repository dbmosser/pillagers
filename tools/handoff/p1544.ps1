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
      e.bag.splice(bestIx,1);
      if(old&&old.id!=='fists') e.bag.push('gun_'+old.id);
'@ @'
      // v15.44, bodies audit finding: A PILLAGER WHO SWITCHES GUNS NEVER LEAVES TWO COPIES OF HIS OLD GUN ON HIS BODY. mkRaider
      // pushes 'gun_'+wk, a copy of the gun in his hands, and the death path counts that copy as the held gun (v8.44). This swap
      // took the new gun out of the pack and pushed a fresh copy of the old one, so the old gun sat in the pack twice and the body
      // paid it twice: a Scav Pistol pillager whose pack rolled a Compact SMG swapped on his first frame and died with two pistols
      // and the SMG, and a looted gun did the same later. Nothing is taken out of the pack now: the new gun's copy stays and
      // stands for the gun in his hands, as the spawn copy did, so the death path pays it once and a man carrying two of the
      // better gun still pays both. The old gun goes into the pack only when it has no copy there (an elite's blessed gun, which
      // blessElite hands him after the spawn copy is pushed), so that pack is one longer after the swap; with a copy nothing
      // moves at all and the pack length is what it always was.
      if(old&&old.id!=='fists'&&e.bag.indexOf('gun_'+old.id)<0) e.bag.push('gun_'+old.id);
'@
SubRx @'
var VER='15.43';
'@ @'
var VER='15.44';
'@

$pat = "(?m)^  now:'v15\.43:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.44: A PILLAGER WHO SWITCHES GUNS NEVER LEAVES TWO COPIES OF HIS OLD GUN ON HIS BODY. A pillager who swapped to a better gun from his pack put a second copy of his old gun back in it, so his body paid the old gun twice. The swap now leaves the new gun copy in the pack to stand for the gun in his hands and adds the old gun only when it has no copy there, so every gun he carries pays once. Check 15.44 swaps five staged pillagers, kills them in one frame and counts every gun on each body; it fails on v15.43',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
