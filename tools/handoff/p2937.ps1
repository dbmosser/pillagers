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

# The attract board and how to play page use the shared UI look (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
#root #title #slotpanel #pnamein{ text-transform:none; }
</style>
'@ @'
#root #title #slotpanel #pnamein{ text-transform:none; }
/* v28.xx (cw-uishared-board), his order 2026-10-18 (UI step 2): the attract board and how to play page (screens 45, 46) on the shared look.
   Every size is a guide token times --attz (menuScale, set by attZ in the script), so a 4K screen keeps the same share as 1080p. The page is a
   1px panel on the scrim; the accent is the PRESS ANY KEY line and your own row; action names in tx-2, keys and scores in tx-1. */
body #attract .attname{ font:800 calc(var(--fs-hero) * var(--attz,1))/1.1 var(--f-cond); letter-spacing:var(--track); color:var(--tx-1); }
body #attract .attpress{ font:700 calc(var(--fs-title) * var(--attz,1))/1.2 var(--f-cond); letter-spacing:var(--track); color:var(--acc); }
body #attract .arcpage{ padding:calc(var(--sp-3) * var(--attz,1)) calc(var(--sp-4) * var(--attz,1)); background:var(--ui-scrim); border:1px solid var(--ui-line-hi); border-radius:var(--rad); font:600 calc(var(--fs-body) * var(--attz,1))/1.4 var(--f-cond); letter-spacing:var(--track); color:var(--tx-1); text-shadow:none; }
body #attract .arcpage .aph{ font-size:calc(var(--fs-title) * var(--attz,1)); line-height:1.1; font-weight:700; color:var(--tx-1); margin-bottom:calc(var(--sp-2) * var(--attz,1)); }
body #attract .arcpage .apr{ gap:calc(var(--sp-4) * var(--attz,1)); line-height:1.4; }
body #attract .arcpage .apr.hl{ color:var(--acc); }
body #attract .arcpage .apn{ color:var(--tx-2); opacity:1; line-height:1.4; }
body #attract .arcpage .apb{ color:var(--tx-2); margin-top:calc(var(--sp-1) * var(--attz,1)); }
body #attract .arcpage .apcols{ gap:calc(var(--sp-5) * var(--attz,1)); }
body #attract .arcpage th{ font-size:calc(var(--fs-label) * var(--attz,1)); font-weight:600; color:var(--tx-2); }
body #attract .arcpage td, body #attract .arcpage th{ padding:calc(var(--sp-1) * var(--attz,1)) calc(var(--sp-3) * var(--attz,1)); }
body #attract .arcpage .apk{ color:var(--tx-2); }
body #attract .arcstrip{ font:600 calc(var(--fs-body) * var(--attz,1))/1.4 var(--f-cond); letter-spacing:var(--track); color:var(--acc); }
</style>
'@

SubRx @'
function attShow(src){
  var d=attEl(), v=d.querySelector('video');
'@ @'
// v28.xx (cw-uishared-board): the shared look sizes the attract text as a token times the menu scale; attZ puts that scale on the overlay.
function attZ(d){ try{ var z=Math.round(menuScale()*1000)/1000; if(d.getAttribute('data-attz')!==String(z)){ d.setAttribute('data-attz',String(z)); d.style.setProperty('--attz',String(z)); } }catch(_z){} return d; }
function attShow(src){
  var d=attZ(attEl()), v=d.querySelector('video');
'@

SubRx @'
  var now=Date.now(), a=ARCADE.att, clip=!!ATT.src, d=attEl(), v=d.querySelector('video'), pg=arcadeAttEl('arcpage')
'@ @'
  var now=Date.now(), a=ARCADE.att, clip=!!ATT.src, d=attZ(attEl()), v=d.querySelector('video'), pg=arcadeAttEl('arcpage')
'@

SubRx @'
var VER='29.36';
'@ @'
var VER='29.37';
'@

$pat = "(?m)^  now:'v29\.36:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.37: The attract board and how to play page now share the menu sizes, panel and colors. Check 29.37 fails on v29.36',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
