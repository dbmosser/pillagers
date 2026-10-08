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

# THE CONTROLS LEGEND STEPS ASIDE FOR THE BACKPACK (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  var MONO=FS(TYPE.micro);   // audit: bypassed FS, sat below the floor
  delete HUDBOX.legend;
'@ @'
  var MONO=FS(TYPE.micro);   // audit: bypassed FS, sat below the floor
  delete HUDBOX.legend;
  // v18.86, seen on the 4K raid screenshot (2026-10-07): with the backpack open the controls legend ran under its left edge and its
  // second column showed through the panel (SHIFT, SPAC.., melee, backpack). The backpack carries its own key line, so the legend
  // steps aside while it is open and comes back when it closes.
  if(G&&G.bagOpen&&!G.over) return;
'@

SubRx @'
var VER='18.85';
'@ @'
var VER='18.86';
'@

$pat = "(?m)^  now:'v18\.85:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.86: Opening the backpack hides the controls legend until you close it. Check 18.86 fails on v18.85',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
