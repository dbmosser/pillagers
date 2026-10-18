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

# Run over card: one centred column with a button (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
body #attract .arcover .aor + .aor{ margin-top:calc(var(--sp-1) * var(--attz,1)); }
'@ @'
body #attract .arcover .aor + .aor{ margin-top:calc(var(--sp-1) * var(--attz,1)); }
/* v28.xx (cw-party-over3), his order 2026-10-18 (UI step 3, party screens 52 and 55): the critic scored the run over card 2 ("a small box floating in a black void,
   Press any button is plain text 400px under the card, no primary action"). While the run over card is up the screen is one centred column: the card (840px x scale, as it was),
   a 24px gap, then Press any button as a real button (1px accent line, accent at 14 percent, 8px radius, 16 and 48px padding). The prompt keeps its words and its
   32px size; only where it sits and its plate change. */
body #attract[style*="block"]:has(.arcover[style*="block"]){ display:flex !important; flex-direction:column; align-items:center; justify-content:center; gap:calc(var(--sp-4) * var(--attz,1)); }
body #attract[style*="block"]:has(.arcover[style*="block"]) .arcover{ position:relative; left:auto; top:auto; transform:none; order:1; }
body #attract[style*="block"]:has(.arcover[style*="block"]) .attpress{ position:relative; left:auto; right:auto; bottom:auto; order:2; width:max-content; padding:calc(var(--sp-2) * var(--attz,1)) calc(var(--sp-5) * var(--attz,1)); border:1px solid var(--acc); border-radius:var(--rad); background:color-mix(in srgb, var(--acc) 14%, transparent); }
'@

SubRx @'
var VER='29.72';
'@ @'
var VER='29.73';
'@

$pat = "(?m)^  now:'v29\.72:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.73: The run over screen is tidier and the prompt is a button. Check 29.73 fails on v29.72',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
