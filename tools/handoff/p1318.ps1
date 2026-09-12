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

# HIS NOTE, 2026-09-12: "if you buy the limited time offer it shouldnt show up in
# the gamble."
#
# IT IS CALLED LIMITED AND IT IS NOT. Buying the lot pays, banks the items, logs
# it and then calls renderGamble, which draws the SAME lot again with a live Buy
# button, because nothing anywhere records that this one was sold. The window is
# five minutes long, so a man with credits can stand at the counter and buy the
# same Limited Time Offer over and over until the clock turns.
#
# KEYED TO THE LOT'S OWN CLOCK, NOT A FLAG. A plain boolean would have to be
# cleared by something, and whatever cleared it would be a second clock that
# could disagree with the first. Storing WHICH window was bought means the next
# lot is unsold by definition and there is nothing to reset.
#
# NO MIGRATION NEEDED, AND NONE WRITTEN. The field is absent on every existing
# profile, absent is not equal to the current window, and an absent field
# therefore reads as not bought, which is the correct answer for a save made
# before this build.
SubRx @'
      P.gambleLog=P.gambleLog||[]; P.gambleLog.push(lot2[0]);
'@ @'
      // v13.18, HIS NOTE: the offer is spent. Keyed to the window it belongs to
      // rather than a flag, so the next lot is unsold by definition and there is
      // nothing anywhere that has to remember to clear it.
      P.wirtLotBought=wirtLotHour();
      P.gambleLog=P.gambleLog||[]; P.gambleLog.push(lot2[0]);
'@

SubRx @'
  var left=wirtLotLeft(), mins=Math.ceil(left/60);
'@ @'
  var left=wirtLotLeft(), mins=Math.ceil(left/60);
  // v13.18, HIS NOTE: bought means gone. The counter still says when the next one
  // lands, because an empty space with no explanation reads as a broken panel.
  if(P.wirtLotBought===wirtLotHour()){
    el.innerHTML='<span style="flex:1;line-height:1.5">'+
      '<span style="color:var(--ash);font-weight:700;font-size:16px;display:block">Limited Time Offer</span>'+
      '<span style="color:var(--ash);display:block">Bought. New item in '+mins+' minute'+(mins===1?'':'s')+'</span>'+
    '</span>';
    return;
  }
'@

SubRx @'
var VER='13.17';
'@ @'
var VER='13.18';
'@

$pat = "(?m)^  now:'v13\.17:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.18: HIS NOTE of 2026-09-12, if you buy the limited time offer it should not show up in the gamble. IT IS CALLED LIMITED AND IT WAS NOT: buying the lot paid, banked the items, logged it and then redrew the SAME lot with a live Buy button, because nothing anywhere recorded that this one was sold, and the window is five minutes long, so a man with credits could stand at the counter and buy the same Limited Time Offer over and over until the clock turned. KEYED TO THE LOT OWN CLOCK RATHER THAN A FLAG: a plain boolean would have to be cleared by something, and whatever cleared it would be a second clock that could disagree with the first, while storing WHICH window was bought means the next lot is unsold by definition and there is nothing to reset. NO MIGRATION NEEDED AND NONE WRITTEN, because the field is absent on every existing profile, absent is not equal to the current window, and an absent field therefore reads as not bought, which is the right answer for a save made before this build. The counter still says when the next one lands, because an empty space with no explanation reads as a broken panel. Check 13.18 buys the real lot through the real button and requires the credits to be taken once, the items to be banked once, and a second press of the same button to take nothing more; the control fails on v13.17, where the second press charges him again',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
