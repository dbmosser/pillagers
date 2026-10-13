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

# A CLICK ON A GUN KEY STILL WORKS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
        if(_dit&&_dit.use==='gun'&&HC.i>=GUNKEYS){
'@ @'
        if(_dit&&_dit.use==='gun'&&HC.i>=GUNKEYS&&d.fromHot!==HC.i){   // v25.xx (belt2b): a press and release on the key it came from is a click, and a click still brings the gun up (v18.90)
'@

SubRx @'
var VER='25.89';
'@ @'
var VER='25.90';
'@

$pat = "(?m)^  now:'v25\.89:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v25.90: A click on a gun bound past key 4 brings it up again; dragging it to another such key stays refused. Check 25.90 fails on v25.89',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
