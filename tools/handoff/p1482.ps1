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
    if(P.weapons.indexOf(g.k)<0){ P.weapons.push(g.k); return WEAPONS[g.k].name+' to the armoury'; }
'@ @'
    // v14.82, gun audit finding 4: A CONTRACT GUN FILLS AN EMPTY HAND, the v14.29 rule the reward counter and the shop follow.
    if(P.weapons.indexOf(g.k)<0){ P.weapons.push(g.k); if(!P.equipped||P.equipped==='fists'||P.weapons.indexOf(P.equipped)<0) P.equipped=g.k; return WEAPONS[g.k].name+' to the armoury'; }
'@
SubRx @'
var VER='14.81';
'@ @'
var VER='14.82';
'@

$pat = "(?m)^  now:'v14\.81:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.82: A CONTRACT GUN FILLS AN EMPTY HAND. A contract paying a gun put it in the armoury and left gun 1 empty when he had no gun, so the next raid handed him a loaner, where a reward gun and a bought gun already go into an empty hand. Check 14.82 pays a gun with an empty hand and with a gun in hand; it fails on v14.81',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
