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

# THE CRAFT PANEL SHOWS WHAT ITEMS DO (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
       (outN>1?(' Makes '+outN+'.'):'')+'</div>'+
       '<div class="crlab">REQUIRED RESOURCES</div>';
'@ @'
       (outN>1?(' Makes '+outN+'.'):'')+'</div>'+
       (oit?itemStatsHTML(outKey):'')+   // v19.67: what it does in numbers, as the BUY panel shows (v19.23)
       '<div class="crlab">REQUIRED RESOURCES</div>';
'@

SubRx @'
var VER='19.66';
'@ @'
var VER='19.67';
'@

$pat = "(?m)^  now:'v19\.66:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.67: Crafting shows what the Medkit, plate, frag and the rest do in numbers. Check 19.67 fails on v19.66',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
