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

# Party pages: one column, a 56px button under the card (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
body #attract:has(.arcpage[style*="block"]) .attname::after, body #attract:has(.arcover[style*="block"]) .attname::after{ display:none; }
'@ @'
body #attract:has(.arcpage[style*="block"]) .attname::after, body #attract:has(.arcover[style*="block"]) .attname::after{ display:none; }
/* v28.xx (cw-party-att3), his order 2026-10-18 (UI step 3, party screens 46, 56, 64): the critic scored how to play 3 and the board 2 ("the prompt sits 150px under the card, detached; a wordmark, a card and a prompt on three unrelated edges; the loudest thing is a glowing amber line"). While a page is up the screen is the same one column as the run over card: the wordmark flush left on the card edge, the card, a 24px gap, then Press any button as the 56px solid accent button flush right (no pulse, no glow). One layout for every party page. Restyle only. */
body #attract[style*="block"]:has(.arcpage[style*="block"]){ display:grid !important; grid-template-columns:max-content; justify-content:center; align-content:center; row-gap:calc(var(--sp-3) * var(--attz,1)); }
body #attract[style*="block"]:has(.arcpage[style*="block"]) > video{ position:absolute; left:0; top:0; }
body #attract[style*="block"]:has(.arcpage[style*="block"]) .attname{ position:relative; left:auto; right:auto; top:auto; order:0; padding:0; text-align:left; }
body #attract[style*="block"]:has(.arcpage[style*="block"]) .arcpage{ position:relative; left:auto; top:auto; transform:none; order:1; max-width:none; }
body #attract[style*="block"]:has(.arcpage[style*="block"]) .attpress{ position:relative; left:auto; right:auto; bottom:auto; order:2; width:auto; min-width:calc(var(--menu-w) * .4 * var(--attz,1)); justify-self:end; box-sizing:border-box; height:calc(var(--btn-h) * var(--attz,1)); min-height:0; display:flex; align-items:center; justify-content:center; padding:0 calc(var(--sp-5) * var(--attz,1)); font-size:calc(var(--fs-body) * var(--attz,1)); line-height:1; border:1px solid var(--acc); border-radius:var(--rad); background:var(--acc); color:var(--acc-ink); animation:none; opacity:1; }
'@

SubRx @'
var VER='29.83';
'@ @'
var VER='29.84';
'@

$pat = "(?m)^  now:'v29\.83:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.84: The score board and how to play pages line up with the run over card. Check 29.84 fails on v29.83',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
