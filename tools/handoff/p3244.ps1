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

# AUTO RESOLUTION STOPS AT 75 PERCENT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
bounce:0,upAt:0,said:0,min:0.5,step:0.1,moves:0,q:0,qa:0};
'@ @'
bounce:0,upAt:0,said:0,min:0.75,step:0.05,moves:0,q:0,qa:0};   // v32.xx (cw-drsfloor), HIS ANSWER 2.44 b (round 2): the quality ladder may drop effects but never picture sharpness below 75 percent. Floor 0.5 to 0.75; step 0.1 to 0.05 so the auto step still has rungs to use
'@

SubRx @'
var VER='32.43';
'@ @'
var VER='32.44';
'@

$pat = "(?m)^  now:'v32\.43:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.44: Auto resolution never drops the picture under 75 percent. Check 32.44 fails on v32.43',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
