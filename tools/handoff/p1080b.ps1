$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# ==== MY OWN PLACEMENT, CAUGHT BY THE CHECK I WROTE FOR IT. I put the mile's
# ==== square on SUMP YARD because it was the squarest of the three cargo yards
# ==== and kept all nine pieces. It is also standing in a pond: the landmark
# ==== centre is inside the water rectangle at 700,5900 900x700, and all eight
# ==== ways round the monument are water. The new check refused it, which is
# ==== exactly what it is for.
# ====
# ==== MEASURED, all twelve mile landmarks, how many of the eight ways round the
# ==== centre are dry and clear: FROST YARD 8, BLAST FREEZER LINE 7, PUMPWORKS 7,
# ==== MANIFEST 6, BREAKER LINE 6, OUTRAIL 6, GANTRY STACKS 3 (its own gantry
# ==== rows cross the centre), COLD BLOCKS 2, COLD NINE 1, SUMP 0.
# ==== Of the ones that also keep their monument, THE FROST YARD is the only one
# ==== that is open, dry AND one of the three repeated cargo yards, so it does
# ==== both jobs at once.
SubRx @'
{"id":"cm_sump_market","name":"SUMP MARKET","x":280,"y":5320,"w":2000,"h":1700,"loot":"rare","dens":0.8,"arch":"townsq"}
'@ @'
{"id":"cm_sump_yard","name":"SUMP YARD","x":280,"y":5320,"w":2000,"h":1700,"loot":"rare","dens":0.8,"arch":"yard"}
'@
SubRx @'
{"id":"cm_frost_yard","name":"THE FROST YARD","x":6560,"y":700,"w":1020,"h":2100,"loot":"bulk","dens":0.8,"arch":"yard"}
'@ @'
{"id":"cm_frost_market","name":"THE FROST MARKET","x":6560,"y":700,"w":1020,"h":2100,"loot":"bulk","dens":0.8,"arch":"townsq"}
'@
SubRx @'
the mile turns one of its three identical cargo yards into SUMP MARKET.',
'@ @'
the mile turns one of its three identical cargo yards into THE FROST MARKET.',
'@
SubRx @'
on THE COLD MILE the old sump yard is now SUMP MARKET.
'@ @'
on THE COLD MILE the old frost yard is now THE FROST MARKET.
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
