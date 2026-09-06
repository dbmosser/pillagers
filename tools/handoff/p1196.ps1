$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# FIRST TEN MINUTES AUDIT, 2026-09-06: dying with the FREEBIE KIT deleted the
# Scav Pistol the player owns out of the armoury and billed him for it on the
# card, because the death splice went by gun id alone and the free kit's
# pistol is deliberately not flagged issued (an extraction keeps it). On a
# fresh profile that pistol is the only gun there is.
SubRx @'
    var _gunN=0,_gunVal=0;
    for(j=0;j<gone.length;j++){
      _gunN++;
      if(ITEMS['gun_'+gone[j].id]) _gunVal+=ival('gun_'+gone[j].id);
      var wi=P.weapons.indexOf(gone[j].id);
      if(wi>=0){ P.weapons.splice(wi,1);
'@ @'
    var _gunN=0,_gunVal=0;
    for(j=0;j<gone.length;j++){
      // v11.96: ONLY A GUN THAT CAME OUT OF THE ARMOURY COMES OFF THE LIST, and
      // the free kit's loaner is not a gun you lost. The splice went by id
      // alone, so dying with the free kit's Scav Pistol (not flagged issued,
      // because an extraction keeps it) deleted the pistol you own, the only
      // gun a fresh profile has, and the card billed you for it. Provenance is
      // on the slot, the flag the pickup path has read since the same fault
      // was fixed there; a field-found gun never touches the armoury either.
      var _egp=G.player, _egArm=!!((gone[j]===_egp.wep&&_egp.wepFromArmory)||(gone[j]===_egp.sec&&_egp.secFromArmory));
      var _egFree=!!(G.freeKit&&!_egArm&&gone[j].id===FREEKIT_GUN);
      if(_egFree) continue;   // out of the ledger entirely, as an issued loaner already is: no count, no price, no line
      _gunN++; if(ITEMS['gun_'+gone[j].id]) _gunVal+=ival('gun_'+gone[j].id);
      var wi=_egArm?P.weapons.indexOf(gone[j].id):-1;
      if(wi>=0){ P.weapons.splice(wi,1);
'@

# STAMPS.
SubRx @'
var VER='11.95';
'@ @'
var VER='11.96';
'@
SubRx @'
var WHATSNEW_VER='11.94';
'@ @'
var WHATSNEW_VER='11.96';
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'DYING WITH THE FREEBIE KIT NO LONGER DELETES THE SCAV PISTOL YOU OWN, and the loaner is not counted or billed as a gun you lost.',
'@
$cnt=([regex]::Matches($s,"now:'v11\.95:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v11.95 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v11\.95:[^']*'",{ param($m) "now:'v11.96: from the 2026-09-06 first-ten-minutes audit, dying with the freebie kit deleted the Scav Pistol you own and billed you for it, because the death splice went by gun id and the free pistol is not flagged issued (an extraction keeps it). The splice now asks the slot whether the gun came out of the armoury, and the loaner is neither counted nor priced. Check 11.96 deploys with the free kit on a profile that owns one pistol, dies, and requires the pistol still owned and no gun counted lost; fails on v11.95.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
