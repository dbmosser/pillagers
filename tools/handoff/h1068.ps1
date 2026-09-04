$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# ==== TWO CHECK BUGS, BOTH MINE, both of which read as a broken build.
# ==== v10.50 and v9.25 failed the corpus on v10.68 and had failed it once on
# ==== v10.67 as well. Neither is a regression: v10.50 fails identically on a
# ==== v10.67 fixture, run as the first check on a fresh page, so the build is
# ==== not what changed.
# ====
# ==== WHAT CHANGED WAS THE PROFILE. Driving a friend's first session rewrote
# ==== the saved profile on this origin to a young character, and both checks
# ==== silently depend on an old one.
# ====
# ==== v10.50: cosmetics are EARNED. cosWorn refuses any rack the profile does
# ==== not own and falls back to the default, so writing P.cosBeard='fullbeard'
# ==== on a profile with 8 extractions paints Clean Shaven, and the check reads
# ==== that as "the fullbeard paints nothing". The Full Beard needs ten. Stubble
# ==== and the Goatee are gated on runs, which the profile had, which is why one
# ==== of the three beards failed and the other two did not. P.cosAll is his own
# ==== v10.53 flag that unlocks every rack, and it is what this check should
# ==== have been using since the day the racks were gated.
# ====
# ==== v9.25: its notoriety control reads the ABSOLUTE value on the profile and
# ==== passes if it is 1 or more. On a profile with 12 already banked that is
# ==== true before the check fires a single round, so the control was green for
# ==== the wrong reason for as long as the profile was old, and red as soon as
# ==== an earlier check zeroed it. It now starts from zero and measures the rise,
# ==== which is what it always claimed to measure.
SubRx @'
     var keep={face:P2.cosFace,beard:P2.cosBeard,boots:P2.cosBoots,hat:P2.cosHat,eyes:P2.cosEyes,tattoo:P2.cosTattoo};
'@ @'
     var keep={face:P2.cosFace,beard:P2.cosBeard,boots:P2.cosBoots,hat:P2.cosHat,eyes:P2.cosEyes,tattoo:P2.cosTattoo,all:P2.cosAll};
     // v10.68: cosmetics are EARNED and cosWorn silently falls back to the
     // default for any rack the profile does not own, so this check could only
     // ever see the racks the saved profile happened to have unlocked. The Full
     // Beard needs ten extractions. His own v10.53 flag unlocks every rack.
     P2.cosAll=1;
'@

SubRx @'
       P2.cosFace=keep.face; P2.cosBeard=keep.beard; P2.cosBoots=keep.boots; P2.cosHat=keep.hat; P2.cosEyes=keep.eyes; P2.cosTattoo=keep.tattoo;
'@ @'
       P2.cosFace=keep.face; P2.cosBeard=keep.beard; P2.cosBoots=keep.boots; P2.cosHat=keep.hat; P2.cosEyes=keep.eyes; P2.cosTattoo=keep.tattoo; P2.cosAll=keep.all;
'@

SubRx @'
     function shoot(mode){
       __resetCfg(); __pinDefaults(0); __startRaid({mapIx:0,seed:4242});
'@ @'
     function shoot(mode){
       __resetCfg(); __pinDefaults(0); __startRaid({mapIx:0,seed:4242});
       // v10.68: from zero, so the control below measures the CHARGE for shooting
       // a peaceful man rather than whatever this profile has banked already. It
       // read the absolute value, so on an old profile it was green before a
       // round was fired and on a fresh one it was red for no reason.
       try{ __P().notoriety=0; }catch(_nz){}
'@

SubRx @'
     if(a.noto<1) bad.push('control: shooting a peaceful pillager no longer costs notoriety');
'@ @'
     if(a.noto<1) bad.push('control: shooting a peaceful pillager cost no notoriety, starting from zero');
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
