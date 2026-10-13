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

# A BELT-STOCKED HEAL STAYS IN THE BACKPACK GRID (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function bagStacks(){
'@ @'
// v25.xx (belt3b): does the pin on key ix hide a copy of its item from the backpack grid and from the peddler's sale? The ones he bound do, and so does
// a gun on a gun key; the pin the game makes by itself for a heal, a stim, a grenade or a plate does not (those were never pinned before the class keys,
// and the grid is where a lone Bandage is selected, dropped or offered to a teammate).
function beltClaimsPin(ix,k){
  if(!beltClaimsBag(k)) return false;
  var cls=(typeof beltClassOf==='function')?beltClassOf(k):'';
  if(cls&&cls!=='gun'&&G&&G.hotAuto&&G.hotAuto[ix]) return false;
  return true;
}
function bagStacks(){
'@

SubRx @'
if(hk&&beltClaimsBag(hk)) cl[hk]
'@ @'
if(hk&&beltClaimsPin(a,hk)) cl[hk]
'@

SubRx @'
if(_hk&&beltClaimsBag(_hk)) _hbClaim[_hk]
'@ @'
if(_hk&&beltClaimsPin(_ha,_hk)) _hbClaim[_hk]
'@

SubRx @'
if(_cv&&beltClaimsBag(_cv)) _clm[_cv]
'@ @'
if(_cv&&beltClaimsPin(_ck,_cv)) _clm[_cv]
'@

SubRx @'
var VER='26.00';
'@ @'
var VER='26.01';
'@

$pat = "(?m)^  now:'v26\.00:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.01: Heals, grenades and plates the belt stocks by itself stay listed in the backpack grid again. Check 26.01 fails on v26.00',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
