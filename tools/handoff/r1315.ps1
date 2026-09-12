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

# MY CHECK WAS WRONG, NOT THE BUILD. Check 13.15 read the death card six frames
# after the bleed-out finished and found nothing on it, then reported that the
# game never says the line. It does say it. Measured by hand:
#
#   KILLED BY YOUR OWN CHARGE, 141M FROM EXTRACTION . NEVER SPOTTED .
#   YOU DIED CARRYING MEDICAL YOU NEVER USED
#
# Dying is not one frame. killPlayer sets the flag immediately, and the raid does
# not reach over='dead' for well over a hundred frames after it, so six frames
# read a card belonging to the PREVIOUS check, which is how it came back holding
# the word ABANDONED.
#
# The fix is to wait for the outcome the check is about rather than for a frame
# count I guessed, so the arm now runs frames until the raid is actually over.
SubRx @'
       s1.player.downT=0.01;
       frames(6);
       return __state();
'@ @'
       s1.player.downT=0.01;
       // WAIT FOR THE OUTCOME, not for a frame count. The card is written when
       // the raid ends, and the end is more than a hundred frames after the
       // bleed-out finishes; six frames read the previous check card.
       for(var _dw=0;_dw<40;_dw++){
         var _st=__state();
         if(_st&&_st.over) break;
         frames(10);
       }
       return __state();
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
