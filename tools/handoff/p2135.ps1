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

# CLAIM ALL SITS CLEAR OF THE CONTRACTS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    <button class="deploy ghost" id="conclaimall" style="margin:8px 0 0;padding:8px 18px;width:100%">CLAIM ALL COMPLETED</button>
'@ @'
    <!-- v21.35, from the 4K visual pass of 2026-10-09 (W-C3): the CLAIM ALL bar sat flush on the contract list and the detail card, its
         rounded bottom edge on the list's top line with no gap, while the REWARDS tab keeps 8px under its own CLAIM ALL. It keeps 10px now. -->
    <button class="deploy ghost" id="conclaimall" style="margin:8px 0 10px;padding:8px 18px;width:100%">CLAIM ALL COMPLETED</button>
'@

SubRx @'
var VER='21.34';
'@ @'
var VER='21.35';
'@

$pat = "(?m)^  now:'v21\.34:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.35: On the Mainframe CONTRACTS tab the CLAIM ALL bar no longer sits flush on the contract list. Check 21.35 fails on v21.34',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
