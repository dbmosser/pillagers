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

# NO REPEATING CALLED LINE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(z&&z.beaconT!==null&&wantCall&&(z.hold===undefined||z.hold===null)){
    // Already called and still inbound. Saying so stops the second press
    // reading as the first one having failed.
    G.extSay=(G.extSay||0)-dt;
    if(G.extSay<=0){ G.extSay=2.5; say('Called. Inbound '+Math.ceil(z.beaconT)+'s. Stay alive.'); }
  }
'@ @'
  // v22.40, the raid text rewrite (R14): NO REPEATING CALLED LINE. E held in a ring already called and still inbound said Called,
  // Inbound and Stay alive again every 2.5 s, a third line on screen for a fact two others already show: the band above the belt
  // (EXTRACT A INBOUND and its seconds) and the EXTRACTION CALLED alert. A second press is answered by those, so this line is gone.
'@

SubRx @'
var VER='22.39';
'@ @'
var VER='22.40';
'@

$pat = "(?m)^  now:'v22\.39:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.40: Holding E in a ring already called no longer repeats a Called line every few seconds. Check 22.40 fails on v22.39',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
