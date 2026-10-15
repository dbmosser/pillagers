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

# THE SMG STARTS ON ITS OWN KEY (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    at=gunKeyFor(w.id,hotbarSlots(),A,false);   // v26.xx (gunkeys1): a gun in his hands takes its class key, else the lowest free gun key
'@ @'
    at=gunKeyFor(w.id,hotbarSlots(),A,false);   // v26.xx (gunkeys1): a gun in his hands takes its class key, else the lowest free gun key
    var _dck=gunClassKey(gunClassOf(w.id)); if(_dck>=0&&_dck<GUNKEYS&&A[_dck]===undefined) at=_dck;   // v28.41 (cloud-coop-smg-on-its-key), CLOUD HUNT 2026-10-15: at the raid start a gun in his hands takes its own class key whenever no key of his holds it, even when the unpinned belt shows his stowed gun there (with no gun plan the SMG went to key 1 and key 2 stayed empty)
'@

SubRx @'
var VER='28.40';
'@ @'
var VER='28.41';
'@

$pat = "(?m)^  now:'v28\.40:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.41: With an SMG in your hands and a second gun stowed, the raid now starts with the SMG on its own key 2, as the Undercroft shows it. Check 28.41 fails on v28.40',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
