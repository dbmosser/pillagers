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

# A MERC WHO BOARDED AN EARLIER SHIP WAS NEVER PAID. endRaid settles the merc's
# ten percent by looking for his ROSTER row (v8.46: "the roster remembers the
# man and what he carried out"), and the boarding code stamps out and val onto
# the roster row whose ref is the boarding entity. But only ordinary raiders
# were ever pushed to the roster; the hired merc went to ents alone. So when he
# fled low and boarded before you, no row was there to stamp or to find, and the
# card said "was left out there": no cut, no standing. He gets a row now, and
# the pillager board skips it so your hire is not listed as a rival.
SubRx @'
      M2.merc=1; M2.hostile=false; M2.grudge=false; M2.friendly=1;
      ents.push(M2);
'@ @'
      M2.merc=1; M2.hostile=false; M2.grudge=false; M2.friendly=1;
      ents.push(M2);
      // v11.60: a roster row, so boarding stamps his haul and endRaid can pay
      // his cut when he went up before you. The board skips merc rows.
      roster.push({ref:M2,name:M2.name,crew:M2.crew,val:0,out:false,merc:1});
'@

SubRx @'
  for(i=0;i<R.length;i++){
    var r=R[i],e=r.ref,inEnts=(G.ents.indexOf(e)>=0);
'@ @'
  for(i=0;i<R.length;i++){
    var r=R[i],e=r.ref,inEnts=(G.ents.indexOf(e)>=0);
    if(r.merc||(e&&e.merc)) continue;   // v11.60: your hire is not a rival on the board
'@

# STAMPS.
SubRx @'
var VER='11.59';
'@ @'
var VER='11.60';
'@
SubRx @'
var WHATSNEW_VER='11.59';
'@ @'
var WHATSNEW_VER='11.60';
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'A MERC WHO GETS OUT BEFORE YOU NOW PAYS YOUR CUT. If the man you hired ran low, fled and boarded an earlier ship, the card used to say he was left out there and paid nothing. He is remembered now, and if you both get out you take your ten percent.',
'@
$cnt=([regex]::Matches($s,"now:'v11\.59:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v11.59 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v11\.59:[^']*'",{ param($m) "now:'v11.60: a merc who boarded an earlier ship was never paid. endRaid settles his cut by finding his roster row and boarding stamps out and val onto that row, but only ordinary raiders were pushed to the roster; the hired merc went to ents alone, so no row was stamped or found and the card said left out there. He gets a roster row at spawn now and the pillager board skips merc rows. From the v11.46 audit, P1.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
