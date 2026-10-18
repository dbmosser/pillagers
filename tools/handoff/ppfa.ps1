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

# The run over card is centred at 720px (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
body #attract .arcover .aor + .aor{ margin-top:calc(var(--sp-1) * var(--attz,1)); }
'@ @'
body #attract .arcover .aor + .aor{ margin-top:calc(var(--sp-1) * var(--attz,1)); }
/* v28.xx (cw-party-over3): the critic (screen 55, 2 of 5) wanted "a centred card with centred content and a hero that carries it": the content is centred, the accent tab sits centred on the top edge,
   the card is 720px x scale (the guide end card width) and the haul rows are in tx-1 so they read from the couch. */
body #attract .arcover{ text-align:center; min-width:calc(720px * var(--attz,1)); }
body #attract .arcover::before{ left:50%; transform:translateX(-50%); }
body #attract .arcover .aor{ color:var(--tx-1); }
body #attract .arcover .aobm{ justify-content:center !important; }
body #attract .arcover .aobmt{ text-align:center !important; }
'@

SubRx @'
var VER='29.50';
'@ @'
var VER='29.51';
'@

$pat = "(?m)^  now:'v29\.50:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.51: The run over card is centred and easier to read. Check 29.51 fails on v29.50',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
