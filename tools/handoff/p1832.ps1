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

# THE STYLING PASS, STAGE E: THE STASH AND THE SHOP (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
</style>
'@ @'
  /* v18.32, THE STYLING PASS, STAGE E: THE STASH AND THE SHOP. Item cells and shop cells as rounded tiles with a light from the
     top and a lift on hover; the tabs as rounded chips. The rarity border colours, sizes and every id are unchanged. */
  #root .cell, #root .vcell{ border-radius:8px; background:linear-gradient(180deg,rgba(127,146,216,.07) 0%,rgba(0,0,0,.34) 100%);
    box-shadow:inset 0 1px 0 rgba(255,255,255,.05); }
  #root .cell:hover, #root .vcell:hover{ background:linear-gradient(180deg,rgba(255,192,74,.14) 0%,rgba(0,0,0,.30) 100%); transform:translateY(-2px);
    box-shadow:0 6px 16px rgba(0,0,0,.35), inset 0 1px 0 rgba(255,255,255,.07); }
  #root .vcell.on{ background:linear-gradient(180deg,rgba(255,192,74,.22) 0%,rgba(255,192,74,.08) 100%); }
  #root .invtab{ border-radius:8px; }
  #root .vendgrid{ border-radius:10px; }
  #root .vdet{ border-radius:12px; box-shadow:0 16px 40px rgba(0,0,0,.40); }
</style>
'@

SubRx @'
var VER='18.31';
'@ @'
var VER='18.32';
'@

$pat = "(?m)^  now:'v18\.31:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.32: The stash and shop cells and tabs have the new rounded, shaded look. Check 18.32 fails on v18.31',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
