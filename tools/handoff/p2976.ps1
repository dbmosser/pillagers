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

# Run over card: one solid button, one amber (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
body #attract[style*="block"]:has(.arcover[style*="block"]){ display:flex !important; flex-direction:column; align-items:center; justify-content:center; gap:calc(var(--sp-4) * var(--attz,1)); }
'@ @'
/* v28.xx (cw-party-over5), the critic on v29.74 (screen 55, score 2): "Press any button is a muddy ghost-amber box that looks disabled, the button is centred while the card text is left aligned, amber is spent twice". The column is a grid one card wide, so the button is exactly as wide as the card and lines up with its edges, it is the one solid primary (accent fill, dark ink, 56px high, no pulse), and the score goes light so the amber is spent once. */
body #attract[style*="block"]:has(.arcover[style*="block"]){ display:grid !important; grid-template-columns:max-content; justify-content:center; align-content:center; row-gap:calc(var(--sp-4) * var(--attz,1)); }
'@

SubRx @'
body #attract[style*="block"]:has(.arcover[style*="block"]) .attpress{ position:relative; left:auto; right:auto; bottom:auto; order:2; width:max-content; padding:calc(var(--sp-2) * var(--attz,1)) calc(var(--sp-5) * var(--attz,1)); border:1px solid var(--acc); border-radius:var(--rad); background:color-mix(in srgb, var(--acc) 14%, transparent); }
'@ @'
body #attract[style*="block"]:has(.arcover[style*="block"]) .attpress{ position:relative; left:auto; right:auto; bottom:auto; order:2; width:auto; box-sizing:border-box; min-height:calc(var(--sp-5) * 2.25 * var(--attz,1)); display:flex; align-items:center; justify-content:center; padding:0 calc(var(--sp-5) * var(--attz,1)); border:1px solid var(--acc); border-radius:var(--rad); background:var(--acc); color:var(--acc-ink); animation:none; opacity:1; }
body #attract[style*="block"]:has(.arcover[style*="block"]) .arcover .aos{ color:var(--tx-1); }
'@

SubRx @'
var VER='29.75';
'@ @'
var VER='29.76';
'@

$pat = "(?m)^  now:'v29\.75:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.76: The run over screen has a clear button. Check 29.76 fails on v29.75',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
