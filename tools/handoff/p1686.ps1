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

# A TEAMMATE WHO HAS LEFT IS NEVER WAITED FOR (stability pass, 2026-09-27; drafted by a review agent, reviewed by a second).

SubRx @'
  if(st!=='in') NET.up[s]=null;
'@ @'
  if(st!=='in') NET.up[s]=null;
  // v16.86, HIS REPORT (two players, one PC): the host could not extract while downed after player 2 had extracted. His
  // pull on the floor is the same pull as standing and nothing the out word does touches the rings; the one party test in
  // the host extraction is netSpecStart, which keeps the raid running for a teammate still up top. A last position word
  // from the window whose raid ended can land after its out word (the fast channel is unordered, v16.70 saw it) and files
  // that seat up top again for NET_HUB_STALE seconds, so a host extraction inside that window was parked spectating for a
  // party that had already left. The seat is marked out on this raid seed; netSpecStart waits for nobody so marked
  // (netUpGone) until he comes up again (in), and the end of the raid or of the party clears the marks.
  if(!NET.upOut) NET.upOut={};
  NET.upOut[s]=(st==='in')?0:(NET.upSeed>>>0);
'@

SubRx @'
function netUpShown(g){ return !!g&&g.n>0&&g.age<NET_HUB_STALE&&g.seat!==NET.seat&&netSeatName(g.seat)!==null&&!!NET.upSeed&&g.sd===(NET.upSeed>>>0); }
'@ @'
function netUpShown(g){ return !!g&&g.n>0&&g.age<NET_HUB_STALE&&g.seat!==NET.seat&&netSeatName(g.seat)!==null&&!!NET.upSeed&&g.sd===(NET.upSeed>>>0); }
// v16.86: a seat whose raid on this seed ended (its out word came) and that has not come up again since. A last position
// word of his landing after the out word still draws him for a moment (check 15.79 counts on that); he is nobody to wait for.
function netUpGone(g){ return !!g&&!!NET.upOut&&!!NET.upOut[g.seat]&&NET.upOut[g.seat]===(g.sd>>>0); }
'@

SubRx @'
  if(!n) return false;
'@ @'
  for(i=0;i<NET.up.length;i++) if(netUpShown(NET.up[i])&&netUpGone(NET.up[i])) n--;   // v16.86: a teammate whose out word came on this seed is not waited for, whatever his last position word filed
  if(!n) return false;
'@

SubRx @'
  netBroadcast({t:'up',st:'out',how:netClean(how,12)});
'@ @'
  NET.upOut={};   // v16.86: the raid is let go, and with it every seat marked out on it
  netBroadcast({t:'up',st:'out',how:netClean(how,12)});
'@

SubRx @'
  NET.up=[]; NET.upAcc=0; NET.upN=0; NET.upSeed=0; NET.upFp=null;   // v15.79: and nobody up top
'@ @'
  NET.up=[]; NET.upAcc=0; NET.upN=0; NET.upSeed=0; NET.upFp=null;   // v15.79: and nobody up top
  NET.upOut={};   // v16.86: and no seat is marked out
'@

SubRx @'
var VER='16.85';
'@ @'
var VER='16.86';
'@

$pat = "(?m)^  now:'v16\.85:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.86: A TEAMMATE WHO HAS LEFT IS NEVER WAITED FOR. From his report during his co-op session (player 1 could not get out after player 2 had extracted). After player 2 extracted, a last position word from his window could arrive after his extraction word and make the host think he was still up top, so the host was parked watching the raid for a teammate who had already gone. A teammate whose extraction word has arrived is now never waited for, and the host run ends outright. Check 16.86 fails on v16.85',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
