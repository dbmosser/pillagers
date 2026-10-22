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

# PIXEL WARDROBE FOCUS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
</style><canvas id="cv"></canvas>
'@ @'
</style>
<style id="pix-fashion-focus">
/* v28.xx (cw-cx-pixrackfocus): keep thirteen tiles on their grid; worn is a left rail, focus is an inset ring. */
#root #appearmodal.pixfashion #appavatarpicker .costile{scale:1 !important;translate:none !important;transform:none !important}
#root #appearmodal.pixfashion #appavatarpicker .costile.on{border:1px solid var(--ui-line-hi) !important;border-left:3px solid var(--acc) !important;box-shadow:none !important;padding:4px 12px 4px 10px !important}
#root #appearmodal.pixfashion #appavatarpicker .costile.padfocus,#root #appearmodal.pixfashion #appavatarpicker .costile:focus-visible{outline:2px solid var(--acc) !important;outline-offset:-4px !important;box-shadow:none !important;background:#1e2225 !important}
#root #appearmodal.pixfashion #appavatarpicker .costile.on.padfocus,#root #appearmodal.pixfashion #appavatarpicker .costile.on:focus-visible{box-shadow:none !important}
body:has(#appearmodal.pixfashion.on) > #uimring{display:none !important}
#root #appearmodal.pixfashion #applooks > .glab{letter-spacing:0 !important}
#root #appearmodal.pixfashion #appavatar{position:relative;flex:0 0 320px !important}
#root #appearmodal.pixfashion #appavatar::before{content:'';position:absolute;top:16px;left:16px;width:36px;height:3px;background:var(--acc)}
#root #appearmodal.pixfashion #applooks{flex:1 !important}
@media(max-height:1000px){#root #appearmodal.pixfashion #appavatarpicker .costile.on{padding:3px 12px 3px 10px !important}}

</style><canvas id="cv"></canvas>
'@

SubRx @'
(own?(on?'worn':'owned'):need)
'@ @'
(own?(on?'worn':''):need)
'@

SubRx @'
var VER='34.17';
'@ @'
var VER='34.18';
'@

$pat = "(?m)^  now:'v34\.17:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v34.18: Four equal set tiles stay still, with an inset focus ring, a separate worn rail and concise status labels. Check 34.18 fails on v34.17',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
