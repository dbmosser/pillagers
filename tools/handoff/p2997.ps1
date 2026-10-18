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

# Party pages: the button in the card, the logo in the corner, a blurred backdrop (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
body #attract .arcover .aosc i{ display:block; margin-top:calc(var(--sp-1) * var(--attz,1)); font-style:normal; font-size:calc(var(--fs-label) * var(--attz,1)); font-weight:600; color:var(--tx-2); }
'@ @'
body #attract .arcover .aosc i{ display:block; margin-top:calc(var(--sp-1) * var(--attz,1)); font-style:normal; font-size:calc(var(--fs-label) * var(--attz,1)); font-weight:600; color:var(--tx-2); }
/* v29.95 (cw-partycard), the critic on v29.94 (46 = 2, 55 = 3, 56 = 2): "the primary hangs outside the card, the wordmark floats off the card edge, the hub shows through and stays legible". One card per page: Press any button sits in its bottom right corner as the footer action, the wordmark is the logo on the top left margin, the run over card is 720 x scale wide, and the backdrop blurs the world behind it so labels and HUD smear out and the glow stays. Restyle only. */
body #attract{ -webkit-backdrop-filter:blur(var(--sp-2)); backdrop-filter:blur(var(--sp-2)); background:radial-gradient(ellipse at 50% 38%, color-mix(in srgb, var(--ui-raised) 34%, transparent) 0%, color-mix(in srgb, var(--ui-bg) 82%, transparent) 46%, color-mix(in srgb, var(--ui-void) 94%, transparent) 100%); }
body #attract[style*="block"]:has(.arcpage[style*="block"]) .attname{ position:absolute; left:calc(var(--sp-5) * var(--attz,1)); top:calc(var(--sp-5) * var(--attz,1)); color:var(--tx-1); }
body #attract[style*="block"]:has(.arcpage[style*="block"]) .arcpage, body #attract[style*="block"]:has(.arcover[style*="block"]) .arcover{ grid-area:1 / 1; padding-bottom:calc((var(--sp-3) * 2 + var(--btn-h)) * var(--attz,1)); }
body #attract[style*="block"]:has(.arcpage[style*="block"]) .attpress, body #attract[style*="block"]:has(.arcover[style*="block"]) .attpress{ grid-area:1 / 1; align-self:end; justify-self:end; z-index:2; margin:0 calc(var(--sp-4) * var(--attz,1)) calc(var(--sp-3) * var(--attz,1)) 0; }
body #attract[style*="block"]:has(.arcpage[style*="block"]) .arcpage.uimghost{ grid-row:1; }
body #attract[style*="block"]:has(.arcover[style*="block"]) .arcover{ min-width:calc(var(--sp-5) * 15 * var(--attz,1)); }
'@

SubRx @'
var VER='29.96';
'@ @'
var VER='29.97';
'@

$pat = "(?m)^  now:'v29\.96:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.97: The party pages have the button inside the card and a soft backdrop. Check 29.97 fails on v29.96',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
