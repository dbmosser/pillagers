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

# CONTRACT REWARDS SHOW THE GUN (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(g.k&&ITEMS[g.k]) return [g.k];
'@ @'
  // v20.46, from the whole-game bug hunt of 2026-10-08 (H28): THE REWARDS STRIP SHOWS THE GUN OR THE KEY A CARD PAYS. A contract gun is
  // {kind:'wep',k:'rifle'} while its item row is gun_rifle, and a key is {kind:'key'} with no item named at all, so both came back
  // empty and every gun and key card on the Mainframe showed only its Credits. A gun now draws its own item, and a key draws the key
  // to the first sealed room of the map he is set for: which room the claim pays is rolled at the claim (resolveKey), never here.
  if(g.kind==='wep') return (g.k&&ITEMS['gun_'+g.k])?['gun_'+g.k]:[];
  if(g.kind==='key'){ var _kl=((FIXED_MAPS[clamp(P.mapIx===undefined?0:P.mapIx,0,FIXED_MAPS.length-1)]||{}).locked)||[], _kk=_kl.length?('key_'+_kl[0].id):''; return (_kk&&ITEMS[_kk])?[_kk]:[]; }
  if(g.k&&ITEMS[g.k]) return [g.k];
'@

SubRx @'
    cell.title=ITEMS[gkey].name+(seen[gkey]>1?('  x'+seen[gkey]):'');
'@ @'
    cell.title=((c.gear&&(c.gear.kind==='wep'||c.gear.kind==='key'))?gearLabel(c.gear):ITEMS[gkey].name)+(seen[gkey]>1?('  x'+seen[gkey]):'');   // v20.46 (H28): the gun goes to the armoury, not as the field item, and the key is the room the claim rolls
'@

SubRx @'
var VER='20.45';
'@ @'
var VER='20.46';
'@

$pat = "(?m)^  now:'v20\.45:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.46: The contract REWARDS strip now shows the gun or key a contract pays, next to the Credits. Check 20.46 fails on v20.45',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
