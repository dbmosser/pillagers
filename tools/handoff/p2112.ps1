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

# THE LOANER BANDAGES ARE NOT YOUR LOSS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    var lostIdx=idx.slice(nSafe),shown=lostIdx.slice(0,7);
'@ @'
    // v21.12, from the whole-game bug hunt of 2026-10-08 (H20): THE ISSUED LOANER BANDAGES ARE NOT LOST. The quartermaster issues
    // two Bandages to anyone who goes up without a heal, and they are his: the extraction card leaves them out of what was secured,
    // and this card leaves an issued loaner gun out because you never owned it. Here they were rows reading LOST, in the count and
    // in the money gone ($120 on every such death). The ones still carried come off the ledger now, as on the extraction card.
    var lostIdx=idx.slice(nSafe), _dIss=0, _dj;
    trackIssuedBandages();
    for(_dj=lostIdx.length-1;_dj>=0&&_dIss<(G.issuedBandages||0);_dj--) if(G.bag[lostIdx[_dj]]==='bandage'){ lostIdx.splice(_dj,1); _dIss++; }
    var shown=lostIdx.slice(0,7);
'@

SubRx @'
((haul-savedVal)+_gunVal)
'@ @'
((haul-savedVal-_dIss*ival('bandage'))+_gunVal)
'@

SubRx @'
var VER='21.11';
'@ @'
var VER='21.12';
'@

$pat = "(?m)^  now:'v21\.11:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.12: The death card no longer lists the two issued loaner Bandages as lost or counts their money as gone. Check 21.12 fails on v21.11',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
