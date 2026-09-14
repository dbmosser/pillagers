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
      var kk=ha[sk]; if(!kk) continue;
      var at=K.indexOf(kk); if(at>=0) K.splice(at,1);
'@ @'
      var kk=ha[sk]; if(!kk) continue;
      // v14.97, copies audit finding 1: A KEY ON THE GUN IN HIS HANDS CLAIMS NO PACKED COPY, the raid's rule since v14.63
      // (beltClaimsBag). With the SMG in gun 1, key 5 on it and a field SMG packed, this backpack read 0 packed and hid the
      // SMG, while the raid's backpack showed it.
      if(kk.indexOf('gun_')===0&&(P.equipped===kk.slice(4)||P.equippedSec===kk.slice(4))) continue;
      var at=K.indexOf(kk); if(at>=0) K.splice(at,1);
'@
SubRx @'
var VER='14.96';
'@ @'
var VER='14.97';
'@

$pat = "(?m)^  now:'v14\.96:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.97: THE UNDERCROFT BACKPACK SHOWS A PACKED GUN THE RAID SHOWS. A belt key on the gun in his hands hid a packed copy of that gun from the Undercroft backpack, while since v14.63 the raid backpack shows it. The Undercroft now follows the raid rule. Check 14.97 packs a field SMG with a key on the SMG, with the pistol and with the SMG in hand; it fails on v14.96',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
