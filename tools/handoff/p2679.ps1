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

# THE WARDEN HAS AN ARMOURED FRONT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function feudFoe(a,b){
'@ @'
// v26.xx (ai28), HIS WORDS (2026-10-14, suggestion 28): "I thought we already had this". WHAT WE HAD: the BULWARK, since v3.98, soaks 88
// percent of any round that arrives inside its front arc (CFG.bulwarkArc 1.15 radians each side of its facing, CFG.bulwarkSoak 0.12), and
// everything is hit half again as hard from behind (the back shot bonus), so the Bulwark has always had an armoured front and soft sides
// and back, and a weak point (the spine) on its back. WHAT WAS MISSING: the plain WARDEN had no facing armour at all, only the weak
// points, so its front was no tougher than its flank. Now a plain Warden shrugs off 60 percent of a round that arrives inside the
// front arc of WARDEN_ARC (1.0 radian, 57 degrees, each side of where it faces), and takes the full round from the sides and half again
// from behind; a round into its optic (the weak point on its front) still pays, as the weak points are tested before the armour. The
// Bulwark keeps its own numbers. THE OVERSEER is left unarmoured on purpose (it has its phases now, ai24). Blasts, mines and fire come
// from no side, so they go past the armour: that is what flanking and a frag are for.
var WARDEN_ARC=1.0, WARDEN_SOAK=0.4;
function feudFoe(a,b){
'@

SubRx @'
} else if(en.kind==='bulwark'&&(function(){
'@ @'
} else if((en.kind==='bulwark'||(en.kind==='warden'&&!en.boss))&&(function(){   // v26.xx (ai28): and a plain Warden
'@

SubRx @'
return _bd<(CFG.bulwarkArc===undefined?1.15:CFG.bulwarkArc);
'@ @'
return _bd<((en.kind==='warden')?WARDEN_ARC:(CFG.bulwarkArc===undefined?1.15:CFG.bulwarkArc));
'@

SubRx @'
edmg*=(CFG.bulwarkSoak===undefined?0.12:CFG.bulwarkSoak);
'@ @'
edmg*=(en.kind==='warden')?WARDEN_SOAK:(CFG.bulwarkSoak===undefined?0.12:CFG.bulwarkSoak);
'@

SubRx @'
if(!en._shTold){ en._shTold=1; say('BULWARK SHIELD','info',{sub:'Flank it.'}); }
'@ @'
if(!en._shTold){ en._shTold=1; say((en.kind==='warden')?'WARDEN ARMOUR':'BULWARK SHIELD','info',{sub:(en.kind==='warden')?'Hit its back.':'Flank it.'}); }
'@

SubRx @'
var VER='26.78';
'@ @'
var VER='26.79';
'@

$pat = "(?m)^  now:'v26\.78:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.79: A plain Warden now shrugs off most fire from the front; hit it from the sides or the back. Check 26.79 fails on v26.78',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
