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

# THE COLD MILE IS FROZEN (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function mapOffered(m){ return !BETA_ONE_MAP||m.beta===1; }
'@ @'
// v23.6x (feat0b), HIS ORDER (2026-10-12): "Freeze the bigger map, lets only focus on improving the smaller one for now, e.g. graphics.
// Disable the bigger map in the game for now." A map marked frozen is never offered: not on the sector page, not on the lift, not in the
// arcade. It is still built exactly as before when something asks for it by number (the tests and the bot), so nothing is lost.
function mapOffered(m){ return !(m&&m.frozen)&&(!BETA_ONE_MAP||m.beta===1); }
'@

SubRx @'
id:'mile', name:'THE COLD MILE', beta:1, w:9000, h:7600,
'@ @'
id:'mile', name:'THE COLD MILE', beta:1, frozen:1, w:9000, h:7600,   // v23.6x (feat0b): frozen on his order, kept in code
'@

SubRx @'
  for(var q=0;q<FIXED_MAPS.length;q++){
    var A=FIXED_MAPS[q].w*FIXED_MAPS[q].h;
'@ @'
  for(var q=0;q<FIXED_MAPS.length;q++){
    if(!mapOffered(FIXED_MAPS[q])) continue;   // v23.6x (feat0b): a frozen map is not measured, so the lone card carries no size tag
    var A=FIXED_MAPS[q].w*FIXED_MAPS[q].h;
'@

SubRx @'
    var M=FIXED_MAPS[i],R=sealRec(i),sel=(i===cur);
'@ @'
    var M=FIXED_MAPS[i],R=sealRec(i),sel=(i===cur);
    if(!mapOffered(M)) continue;   // v23.6x (feat0b): a frozen map gets no card on the sector page
'@

SubRx @'
    ARCADE.mapIx=clamp(mi|0,0,FIXED_MAPS.length-1);   // his last sector
'@ @'
    ARCADE.mapIx=clamp(mi|0,0,FIXED_MAPS.length-1);   // his last sector
    if(!mapOffered(FIXED_MAPS[ARCADE.mapIx])) ARCADE.mapIx=firstOfferedMap();   // v23.6x (feat0b): never a frozen one
'@

SubRx @'
    var R=sealRec(i);
    if(R.cut<=0&&R.tier<=0) continue;
'@ @'
    var R=sealRec(i);
    if(R.cut<=0&&R.tier<=0) continue;
    if(!mapOffered(FIXED_MAPS[i])) continue;   // v23.6x (feat0b): no seal line for a sector nobody can reach
'@

SubRx @'
var VER='23.61';
'@ @'
var VER='23.62';
'@

$pat = "(?m)^  now:'v23\.61:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.62: The bigger map is frozen: every raid goes to COLD STORAGE. Check 23.62 fails on v23.61',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
