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

# THE SHOP GREYS WHAT YOU CANNOT AFFORD (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  .vcell .vp{ position:absolute; right:7px; top:5px;
'@ @'
  /* v21.46, from the 4K visual pass (2026-10-09): a price you cannot pay reads grey, so the shop says at a glance what you can buy */
  .vcell.poor .vp{ color:#7d8894 !important; opacity:.8; }
  .vcell .vp{ position:absolute; right:7px; top:5px;
'@

SubRx @'
    cell.className='vcell'+(i===P._shopSel?' on':'')+(locked?' locked':'');
'@ @'
    cell.className='vcell'+(i===P._shopSel?' on':'')+(locked?' locked':'')+((o.price>(P.credits||0))?' poor':'');   // v21.46: a price you cannot pay reads grey
'@

SubRx @'
var VER='21.45';
'@ @'
var VER='21.46';
'@

$pat = "(?m)^  now:'v21\.45:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.46: The shop shows prices you cannot afford in grey. Check 21.46 fails on v21.45',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
