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

# ============ THE DEATH SCREEN DID NOT COUNT THE GUN IT SAID YOU LOST.
# ============
# ============ The KIA ledger lists what you were carrying, one line at a time,
# ============ each marked LOST, and then sums it up. The guns are listed and
# ============ then left out of the sum, so the last line contradicts the list
# ============ directly above it and understates what dying cost you.
# ============
# ============ REPRODUCED on v10.71: die carrying a Medkit, a Bandage and your
# ============ own Scav Pistol. Three lines say LOST. The line under them says
# ============ "2 items lost, $270 gone". The pistol is worth 300, so the number
# ============ is not far off half of what he actually lost, and the count is
# ============ one short of the list he just read.
# ============
# ============ It matters more than the arithmetic. A gun is the most valuable
# ============ thing you carry: 300 for the Scav Pistol, 900 for the Compact SMG,
# ============ 1,100 for the Burst Carbine, 1,500 for the Auto Rifle, against
# ============ items at 60 to 340. A friend who dies with the welcome pack in his
# ============ hands loses 2,000 credits of guns and reads a number with none of
# ============ it in. The death screen is where you learn what dying costs.
# ============
# ============ The loaner is untouched and stays out of both, which is right and
# ============ was already right: carriedGuns skips issued kit, and measured on
# ============ v10.71 a death holding an issued Sputter lists no gun at all.
SubRx @'
    var gone=carriedGuns(G.player);
    for(j=0;j<gone.length;j++){
      var wi=P.weapons.indexOf(gone[j].id);
'@ @'
    var gone=carriedGuns(G.player);
    // v10.72: and they go in the count and in the money. Both branches below
    // print LOST, so both are counted here, once, before the branch.
    var _gunN=0,_gunVal=0;
    for(j=0;j<gone.length;j++){
      _gunN++;
      if(ITEMS['gun_'+gone[j].id]) _gunVal+=ival('gun_'+gone[j].id);
      var wi=P.weapons.indexOf(gone[j].id);
'@

SubRx @'
    lines.push(lostIdx.length+' items lost, '+'$'+(haul-savedVal).toLocaleString()+' gone');
'@ @'
    // v10.72: the guns are in this line now. It listed them as LOST above and
    // then summed the bag only, so it printed a smaller count than the list it
    // sat under and a number missing the most expensive thing he was carrying.
    // An issued loaner is in neither, because carriedGuns leaves it out and you
    // never owned it.
    var _lostN=lostIdx.length;
    var _lostWhat=_lostN+' item'+(_lostN===1?'':'s');
    if(_gunN) _lostWhat+=' and '+_gunN+' gun'+(_gunN===1?'':'s');
    lines.push(_lostWhat+' lost, '+'$'+((haul-savedVal)+_gunVal).toLocaleString()+' gone');
'@

SubRx @'
var VER='10.71';
'@ @'
var VER='10.72';
'@
SubRx @'
  now:'v10.71: the safe pocket tells you the truth. It read 1/1 even when the item it names is still in the stash, where it protects nothing, and the ascent check never mentioned it at all. This also corrects my own v10.70, which counted the pocket as an extra item being carried.',
'@ @'
  now:'v10.72: the death screen counts the gun it says you lost. It listed your gun as LOST and then left it out of the total underneath, so the number missed the most expensive thing you were carrying. An issued loaner is still in neither, because you never owned it.',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
