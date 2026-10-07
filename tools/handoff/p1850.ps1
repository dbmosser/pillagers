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

# A SEAL CUT PAST THE NEW NEED STILL OPENS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
      var have=SR.cut+G.seal.gained;
      if(have<need){
'@ @'
      var have=SR.cut+G.seal.gained;
      // v18.50, FROM THE CODE COMB (2026-10-07): A SEAL CUT PAST THE NEW NEED STILL OPENS. v17.97 made the cut quicker (34 + 21 per
      // stage), and a profile that had banked more than the new need (36 of the old 40, say) could never finish: this guard skipped
      // the cut, so the completion test inside it never ran and the door was stuck for good. The cut always runs now; one frame of E
      // on such a door completes it and pays out.
      if(have<need||!G.seal.done){
'@

SubRx @'
var VER='18.49';
'@ @'
var VER='18.50';
'@

$pat = "(?m)^  now:'v18\.49:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.50: A seal that was stuck full after the quicker-seal change now opens the moment you hold E at it. Check 18.50 fails on v18.49',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
