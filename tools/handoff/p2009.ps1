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

# THE UNDERCROFT CROWD HAS BUILDS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    for(var i=0;i<COSMETICS.length;i++){ var c=COSMETICS[i]; if(c.id==='crown'||c.kind==='build'||c.crowd===0) continue;
'@ @'
    // v20.09: and the build now that it draws (v20.01), so the floor has Broad and Curved people in it too
    for(var i=0;i<COSMETICS.length;i++){ var c=COSMETICS[i]; if(c.id==='crown'||c.crowd===0) continue;
'@

SubRx @'
           own:_c});
'@ @'
           build:_lk.build,own:_c});
'@

SubRx @'
var VER='20.08';
'@ @'
var VER='20.09';
'@

$pat = "(?m)^  now:'v20\.08:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.09: Some of the people in the Undercroft are Broad or Curved now. Check 20.09 fails on v20.08',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
