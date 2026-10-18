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

# THE TITLE SAYS CREATE A NEW SAVE, NOT CREATE A NEW SAVE WITH A CAPITAL A (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    var n=ncCand(w,o,s); if(!n) return w;

'@ @'
    // v28.xx (cw-menu-newsave), UI step 30: the one-letter article A between caps words stayed a capital ("Create A new save" on the title). It lowers with its line.
    if(w==='A'&&has3&&/\s/.test(s.charAt(o-1))&&/^\s+[A-Z]{3,}/.test(s.slice(o+1))) return 'a';
    var n=ncCand(w,o,s); if(!n) return w;

'@

SubRx @'
var VER='29.31';
'@ @'
var VER='29.32';
'@

$pat = "(?m)^  now:'v29\.31:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.32: The title button now reads Create a new save. Check 29.32 fails on v29.31',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
