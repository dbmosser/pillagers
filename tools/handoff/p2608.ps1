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

# THE SMOKE CLOUD IS 1.3 TIMES BIGGER (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function smokeSegs(){
  var out=[],i,j;
'@ @'
// v26.xx (smokebig), HIS ORDER 2026-10-13: "smoke grenade should still cover bigger area -- make it like 1.3x its current sie". THE SMOKE CLOUD IS
// 1.3 TIMES AS WIDE. One place now sizes a cloud, smokeRad(): the dial smokeR (165, the old radius, kept as the base so a saved profile that holds
// 165 gets the new size too) times SMOKE_BIG. The cloud you throw, the cloud a pillager drops, the copy the host and the party take off the wire and
// the RADIUS on the hover card all read it, so the sight octagon smokeSegs builds (0.92 of the radius) and the puffs the air pass draws (sized from
// the same radius) stay one cloud. It still lasts 12 seconds. No rnd is drawn.
var SMOKE_BIG=1.3;
function smokeRad(){ return (CFG.smokeR===undefined?165:CFG.smokeR)*SMOKE_BIG; }
function smokeSegs(){
  var out=[],i,j;
'@

SubRx @'
G.smokes.push({x:th.tx,y:th.ty,r:(CFG.smokeR===undefined?165:CFG.smokeR),t:0,life:12});
'@ @'
G.smokes.push({x:th.tx,y:th.ty,r:smokeRad(),t:0,life:12});
'@

SubRx @'
R.push(['RADIUS',Math.round((CFG.smokeR===undefined?165:CFG.smokeR)/10)+'M']);
'@ @'
R.push(['RADIUS',Math.round(smokeRad()/10)+'M']);
'@

SubRx @'
G.smokes.push({x:e.x,y:e.y,r:(CFG.smokeR===undefined?165:CFG.smokeR),t:0,life:12});
    netThrSend('smoke',e.x,e.y);   // v21.98 (K8, K15): the party sees his cloud
'@ @'
G.smokes.push({x:e.x,y:e.y,r:smokeRad(),t:0,life:12});
    netThrSend('smoke',e.x,e.y);   // v21.98 (K8, K15): the party sees his cloud
'@

SubRx @'
G.smokes.push({x:e.x,y:e.y,r:(CFG.smokeR===undefined?165:CFG.smokeR),t:0,life:12});
          netThrSend('smoke',e.x,e.y);   // v21.98 (K8, K15): and the cloud he drops
'@ @'
G.smokes.push({x:e.x,y:e.y,r:smokeRad(),t:0,life:12});
          netThrSend('smoke',e.x,e.y);   // v21.98 (K8, K15): and the cloud he drops
'@

SubRx @'
if(k==='smoke') G.smokes.push({x:x,y:y,r:(CFG.smokeR===undefined?165:CFG.smokeR),t:0,life:12});
'@ @'
if(k==='smoke') G.smokes.push({x:x,y:y,r:smokeRad(),t:0,life:12});
'@

SubRx @'
var VER='26.07';
'@ @'
var VER='26.08';
'@

$pat = "(?m)^  now:'v26\.07:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.08: A Smoke Canister now covers 1.3 times the ground it did, so there is more cloud to hide in. Check 26.08 fails on v26.07',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
