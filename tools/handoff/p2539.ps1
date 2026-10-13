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

# YOUR PLATES RING AND SHATTER (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function damagePlayer(amt,src,srcName,sx,sy){
'@ @'
// v25.39 (usefoleyc), HIS ORDER 2026-10-12 (about 21:10): "add sounds for bandaging, applying armor, etc". YOUR PLATES RING WHEN THEY
// ARE HIT AND SHATTER WHEN THEY BREAK. A round your armour soaked sounded exactly like one that went into you (the plain hit), and the
// plates running out made no sound at all, so you learned you were bare only from the bar. Now a round on the plates adds the metal
// ring the bulwark already has (impactMat armor) and a light recorded plate knock, and the round that takes the last of your armour
// plays the plate breaking once: a heavy low clack (the v25.20 bank), a shatter (impactMat glass) and the carrier tearing. Your
// teammates hear the break where you stand. Cosmetic only: no seeded draw, nothing under G.sim, no game state.
function armorHitFoley(broke){
  if(G&&G.sim) return;
  blip('hit',undefined,undefined,'armor');
  if(typeof foley!=='function') return;
  if(!broke){ foley('plateClack',null,null,{rate:1.4,g:0.4,dur:0.12,gap:0.07,local:1}); return; }
  blip('hit',undefined,undefined,'glass');
  foley('plateClack',null,null,{rate:0.72,g:1.15});
  foley('strapRip',null,null,{off:0.1,dur:0.12,g:0.5,rate:1.5,at:0.04,local:1});
}
function damagePlayer(amt,src,srcName,sx,sy){
'@

SubRx @'
    var ab=Math.min(p.armor,amt*soak); p.armor-=ab; amt-=ab;
  }
'@ @'
    var ab=Math.min(p.armor,amt*soak); p.armor-=ab; amt-=ab;
    if(ab>0) armorHitFoley(p.armor<=0);   // v25.39 (usefoleyc): the plates ring, and break when they run out
  }
'@

SubRx @'
var VER='25.38';
'@ @'
var VER='25.39';
'@

$pat = "(?m)^  now:'v25\.38:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v25.39: A round on your plates now rings them, and the plates breaking plays a heavy clack and a shatter. Check 25.39 fails on v25.38',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
