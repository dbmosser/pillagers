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

# A LATE OUT WORD BELONGS TO ITS OWN RAID (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function netUpEnd(how){
  if(!NET.on) return false;
'@ @'
function netUpEnd(how){
  if(!NET.on) return false;
  var _sd=NET.upSeed>>>0;   // v18.53: the raid this out word is about, read before it is let go below
'@

SubRx @'
  netBroadcast({t:'up',st:'out',how:netClean(how,12)});
'@ @'
  netBroadcast({t:'up',st:'out',how:netClean(how,12),sd:_sd});   // v18.53: names its raid (sd), so a late word never marks the next one
'@

SubRx @'
  if(s<0||s>=NET.max||s===NET.seat) return 'ignored';
  if(st!=='in') NET.up[s]=null;
'@ @'
  if(s<0||s>=NET.max||s===NET.seat) return 'ignored';
  // v18.53, FROM THE CODE COMB (2026-10-07): A LATE OUT WORD BELONGS TO ITS OWN RAID. The out word named no raid and was filed on
  // whatever raid was in hand when it landed, so one that arrived after the host had started the next raid marked player 2 out
  // of it (lateOut, v17.66) and refused them a raid they had never played. The word now names its raid (sd, from netUpEnd), and a
  // word about another raid than the one in hand is dropped here. A word that names none (an older build) is taken as before.
  if(st!=='in'&&typeof m.sd==='number'&&(m.sd>>>0)&&(NET.upSeed>>>0)&&(m.sd>>>0)!==(NET.upSeed>>>0)) return 'stale';
  if(st!=='in') NET.up[s]=null;
'@

SubRx @'
out={t:'up',s:s,st:st};
'@ @'
out={t:'up',s:s,st:st}; if(typeof m.sd==='number') out.sd=m.sd>>>0;
'@

SubRx @'
var VER='18.52';
'@ @'
var VER='18.53';
'@

$pat = "(?m)^  now:'v18\.52:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.53: Player 2 is never shut out of a fresh raid by a message left over from the last one. Check 18.53 fails on v18.52',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
