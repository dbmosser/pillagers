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

# PILLAGERS DROP BETTER GEAR (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
        var c=setLoot(mkContainer(e.x,e.y,'body'),_drop); G.containers.push(c);
'@ @'
        _drop=_drop.concat(bodyBonus(e));   // v21.67, his note: what a pillager drops is better
        var c=setLoot(mkContainer(e.x,e.y,'body'),_drop); G.containers.push(c);
'@

SubRx @'
function updateEnts(dt){
'@ @'
// v21.67, HIS NOTE (2026-10-09): "gear that drops from enemies dying needs to be better". A pillager's body held what he had looted (two
// to four rolls, mostly on the body and locker tables, which are bandages, ammo, wire and boards) and his own gun. Every body now also
// carries one roll on the safe table (cores, titanium, optics, plates, medkits and real guns), and a man in a medium or heavy rig a
// second, so the fight pays like the loot it guards. Rolled at the death, never at the map build, so the seeded build is unchanged.
function bodyBonus(e){
  var out=[], n, RT, i, k;
  if(!e||e.kind!=='raider'||e.merc||e.friendlyPC||!LOOT||!LOOT.safe) return out;
  RT={none:0,light:1,medium:2,heavy:3}[e.rig]||0;
  n=1+(RT>=2?1:0);
  for(i=0;i<n;i++){ k=rollLoot(LOOT.safe); if(k) out.push(k); }
  return out;
}
function updateEnts(dt){
'@

SubRx @'
var VER='21.66';
'@ @'
var VER='21.67';
'@

$pat = "(?m)^  now:'v21\.66:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.67: Dead pillagers now drop better gear: an extra high value item, two from a man in medium or heavy armour. Check 21.67 fails on v21.66',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
