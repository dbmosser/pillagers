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

# THE INJECTORS SOUND LIKE INJECTORS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function useStim(ix){
'@ @'
// v25.40 (usefoleyd), HIS ORDER 2026-10-12 (about 21:10): "add sounds for bandaging, applying armor, etc". THE INJECTORS SOUND LIKE
// INJECTORS. A Stim Injector and the self-revive played the menu chirp. Now a stim clicks its cap and hisses in (the v25.20 bank:
// the pin click and the injector), and the self-revive hisses its injector and rattles your gear as you get up, before the revive
// sting it already had. Yours is centred, your teammates hear it where you stand. Cosmetic only: no seeded draw, nothing under G.sim.
function injFoley(kind){
  if((G&&G.sim)||typeof foley!=='function') return false;
  if(kind==='revive'){ foley('injector',null,null,{rate:0.85,g:1.1}); foley('equip',null,null,{at:0.3,rate:0.9}); foley('rummage',null,null,{at:0.45,g:0.7}); return true; }
  foley('pinClick',null,null,{g:0.55,dur:0.1,rate:1.5}); foley('injector',null,null,{at:0.06,g:1.1});
  return true;
}
function useStim(ix){
'@

SubRx @'
  blip('pick'); say((((ITEMS.stim&&ITEMS.stim.name)||'Stim')+' active')
'@ @'
  if(!injFoley('stim')) blip('pick'); say((((ITEMS.stim&&ITEMS.stim.name)||'Stim')+' active')
'@

SubRx @'
  G.tel.revives++; blip('pick'); try{ sndRevLand(); }catch(_rl){}
'@ @'
  G.tel.revives++; if(!injFoley('revive')) blip('pick'); try{ sndRevLand(); }catch(_rl){}   // v25.40 (usefoleyd): the injector and the gear
'@

SubRx @'
var VER='25.39';
'@ @'
var VER='25.40';
'@

$pat = "(?m)^  now:'v25\.39:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v25.40: A stim now clicks and hisses in, and the self-revive hisses its injector and rattles your gear as you get up. Check 25.40 fails on v25.39',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
