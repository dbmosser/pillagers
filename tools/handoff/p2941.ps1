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

# The attract board card is one menu width and its empty line is the body size (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
body #attract .arcpage table{ width:100%; margin:0; }

'@ @'
body #attract .arcpage table{ width:100%; margin:0; }
/* v28.xx (cw-uishared-board3): the critic scored the board 2 of 5 ("845px card holding two short lines, empty right side, the 18px line is off the
   scale"). A page with no table (the board) is one menu width, like the title buttons; its empty line is the 20px body size. */
body #attract .arcpage:not(:has(table)){ min-width:calc(var(--menu-w) * var(--attz,1)); }

'@

SubRx @'
body #attract .arcpage .apn{ color:var(--tx-2); opacity:1; line-height:1.4; }

'@ @'
body #attract .arcpage .apn{ color:var(--tx-2); opacity:1; line-height:1.4; font-size:calc(var(--fs-body) * var(--attz,1)); }

'@

SubRx @'
var VER='29.40';
'@ @'
var VER='29.41';
'@

$pat = "(?m)^  now:'v29\.40:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.41: The score board card is narrower and its text is the standard size. Check 29.41 fails on v29.40',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
