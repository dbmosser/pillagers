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

# FEWER BIG ROBOTS AT THE EXTRACTION (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  var siegeIv=(8-4.6*GR)/_sv85, siegeCap=Math.round((6+8*GR)*_sv85);
'@ @'
  var siegeIv=(8-4.6*GR)/_sv85, siegeCap=Math.round((5+7*GR)*_sv85);   // v18.06: his son, fewer at the ring (was 6+8*GR)
'@

SubRx @'
var nm=rr()<.5?mkSentry(ss2.x,ss2.y):mkCrawler(ss2.x,ss2.y);
'@ @'
var nm=rr()<.3?mkSentry(ss2.x,ss2.y):mkCrawler(ss2.x,ss2.y);   // v18.06: his son, fewer big robots: three in ten are sentries (was one in two)
'@

SubRx @'
var VER='18.05';
'@ @'
var VER='18.06';
'@

$pat = "(?m)^  now:'v18\.05:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.06: The extraction siege sends fewer machines and far fewer of the big ones. Check 18.06 fails on v18.05',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
