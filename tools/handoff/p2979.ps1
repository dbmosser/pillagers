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

# Run over card: a 56px button flush right (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
body #attract[style*="block"]:has(.arcover[style*="block"]) .attpress{ position:relative; left:auto; right:auto; bottom:auto; order:2; width:auto; box-sizing:border-box; min-height:calc(var(--sp-5) * 2.25 * var(--attz,1)); display:flex; align-items:center; justify-content:center; padding:0 calc(var(--sp-5) * var(--attz,1)); border:1px solid var(--acc); border-radius:var(--rad); background:var(--acc); color:var(--acc-ink); animation:none; opacity:1; }
'@ @'
/* v28.xx (cw-party-over6), the critic on v29.76 (screen 55, score 2): "a 108px amber slab as wide as the card is the loudest thing on screen, not the 56px button the guide specifies". The button is 56px x scale high, 200px x scale wide at least, flush right under the card, 20px label, so the result is read first and the button second. */
body #attract[style*="block"]:has(.arcover[style*="block"]) .attpress{ position:relative; left:auto; right:auto; bottom:auto; order:2; width:auto; min-width:calc(var(--menu-w) * .4 * var(--attz,1)); justify-self:end; box-sizing:border-box; height:calc(var(--btn-h) * var(--attz,1)); min-height:0; display:flex; align-items:center; justify-content:center; padding:0 calc(var(--sp-5) * var(--attz,1)); font-size:calc(var(--fs-body) * var(--attz,1)); line-height:1; border:1px solid var(--acc); border-radius:var(--rad); background:var(--acc); color:var(--acc-ink); animation:none; opacity:1; }
'@

SubRx @'
var VER='29.78';
'@ @'
var VER='29.79';
'@

$pat = "(?m)^  now:'v29\.78:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.79: The run over button is smaller and tidier. Check 29.79 fails on v29.78',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
