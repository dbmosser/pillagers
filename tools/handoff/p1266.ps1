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

# FROM THE 2026-09-08 READ-ONLY AUDIT, confirmed by a skeptic against the source.
# THIS IS MY OWN WORDING, AND I RENAMED A TRUE LABEL INTO A FALSE ONE.
#
# The only progress readout the contract board has says "Contracts completed N".
# N is not a count of contracts. It is a weighted number: a STANDARD card counts
# one, a HARD two, an ELITE three. Claim your first ever HARD card and the board
# says you have completed two contracts.
#
# The gate under it is miscounted from his side for the same reason. "ELITE work
# at 6 more" means six more of that weight, which is two ELITE claims or three
# HARD ones, not six contracts. He plans against a ledger that can be wrong by
# three times per card.
#
# The changelog entry for that line is mine and it records a deliberate
# vocabulary swap with no look at the number behind it: the line used to say
# "Contract standing", which was true, and standing is a banned word, so I
# renamed it to "completed", which is false. Renaming is not the same as
# reading.
SubRx @'
    var cs=cstand(),nx=cs<3?('HARD work at '+(3-cs)+' more'):(cs<8?('ELITE work at '+(8-cs)+' more'):'all work open');
'@ @'
    // v12.66, 2026-09-08 audit: THE COUNT AND THE GATE ARE TWO DIFFERENT
    // NUMBERS, and this line printed one of them under the other one's name. The
    // gate is weighted, because harder work is worth more of it; the count is a
    // count. Both are said now, each called what it is.
    var cs=cstand(), cdn=(P.cdone||0);
    var nx=cs<3?('HARD work needs '+(3-cs)+' more credit'+(((3-cs)===1)?'':'s'))
              :(cs<8?('ELITE work needs '+(8-cs)+' more credit'+(((8-cs)===1)?'':'s')):'all work open');
    if(cs<8) nx+=' (a HARD card is worth 2, an ELITE 3)';
'@

SubRx @'
    h.innerHTML='Contracts completed <b>'+cs+'</b> &middot; '+nx;
'@ @'
    h.innerHTML='Contracts completed <b>'+cdn+'</b> &middot; '+nx;   // v12.66: the count, not the credit
'@

SubRx @'
  P.cstand=cstand()+TT2.w;
'@ @'
  P.cstand=cstand()+TT2.w;
  P.cdone=(P.cdone||0)+1;   // v12.66: and one contract, which is what the board says it counts
'@

# NEW IN.
SubRx @'
  'A HAUL CONTRACT COUNTS WHAT YOU CAME BACK WITH, not what you took up. Staging one expensive gun out of your own stash and walking straight to an extraction point used to finish the best-paying card on the board, and the gun went back in the stash afterwards.',
'@ @'
  'A HAUL CONTRACT COUNTS WHAT YOU CAME BACK WITH, not what you took up. Staging one expensive gun out of your own stash and walking straight to an extraction point used to finish the best-paying card on the board, and the gun went back in the stash afterwards.',
  'THE CONTRACT BOARD COUNTS CONTRACTS. Its one progress line said Contracts completed and printed a weighted number instead, so your first ever HARD card made it read two, and the line under it asked for credits while sounding like cards.',
'@

# STAMPS.
SubRx @'
var VER='12.65';
'@ @'
var VER='12.66';
'@
SubRx @'
var WHATSNEW_VER='12.65';
'@ @'
var WHATSNEW_VER='12.66';
'@
$cnt=([regex]::Matches($s,"now:'v12\.65:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.65 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.65:[^']*'",{ param($m) "now:'v12.66: from the 2026-09-08 read-only audit, and this is my own wording. The only progress readout the contract board has says Contracts completed N, and N is not a count of contracts: it is a weighted number, a STANDARD card counting one, a HARD two and an ELITE three. Claim a first ever HARD card and the board says two contracts completed. The gate under it is miscounted from his side for the same reason, because ELITE work at 6 more means six more of that weight, which is two ELITE claims or three HARD ones and not six contracts, so he plans against a ledger that can be wrong by three times per card. The changelog entry for that line is mine and records a deliberate vocabulary swap with no look at the number behind it: the line used to say Contract standing, which was true, and standing is a banned word, so I renamed it to completed, which is false. Renaming is not the same as reading. The count and the gate are two different numbers and both are said now, each called what it is: a true count of contracts claimed, and a gate that asks for credits and says what a harder card is worth. Check 12.66 claims one HARD card on a clean profile and requires the board to read one contract completed with the gate still naming what it needs, and a control requires the gate itself to be unchanged, since the credit is what opens harder work and this build must not move it; fails on v12.65.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
