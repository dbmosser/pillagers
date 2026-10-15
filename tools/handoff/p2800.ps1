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

# DEMO PLAYERS GET A RANDOM CHARACTER (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function arcadeDeploy(o){
'@ @'
// v27.xx (randchar), HIS ANSWER 15 (2026-10-13): DEMO players get "random character" each run. Every run builds a new look on the sandbox copy of the profile
// (the one the arcade plays on and puts back at leave): a build, a skin, hair, a cut, a beard, eyes, a face, an outfit colour, a hat, boots, gloves, a pack, a patch and
// a tattoo, each picked from the whole rack with Math.random (never the raid stream), the Own Clothes outfit most of the time so the rest shows. The rack is open in
// the sandbox only (cosAll), so nothing is bought or unlocked on his real save. A second window plays its own sandbox, so the two players differ. A run keeps its look
// through a respawn. Cosmetic only.
function arcadeLook(){
  var k, a, i;
  if(typeof ARCADE!=='object'||!ARCADE.on||typeof P==='undefined'||!P) return false;
  P.cosAll=1;
  for(k in COSKEY){
    if(!Object.prototype.hasOwnProperty.call(COSKEY,k)) continue;
    a=[]; for(i=0;i<COSMETICS.length;i++) if(COSMETICS[i].kind===k) a.push(COSMETICS[i].id);
    if(!a.length) continue;
    if(k==='outfit'&&Math.random()<0.6){ P[COSKEY[k]]='outnone'; continue; }
    P[COSKEY[k]]=a[Math.floor(Math.random()*a.length)];
  }
  return true;
}
function arcadeDeploy(o){
'@

SubRx @'
  startRaid();
  return !!(G&&G.arcade);
'@ @'
  try{ arcadeLook(); }catch(_alk){}   // v27.xx (randchar): a new character every run
  startRaid();
  return !!(G&&G.arcade);
'@

SubRx @'
var VER='27.99';
'@ @'
var VER='28.00';
'@

$pat = "(?m)^  now:'v27\.99:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.00: Each DEMO run now gives you a random character. Check 28.00 fails on v27.99',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
