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

# The attract page is a Panel P with a star tab and a full width table (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
body #attract .arcpage{ padding:calc(var(--sp-3) * var(--attz,1)) calc(var(--sp-4) * var(--attz,1)); background:var(--ui-scrim); border:1px solid var(--ui-line-hi); border-radius:var(--rad); font:600 calc(var(--fs-body) * var(--attz,1))/1.4 var(--f-cond); letter-spacing:var(--track); color:var(--tx-1); text-shadow:none; }

'@ @'
/* v28.xx (cw-uishared-board2): the critic scored the board and how to play 2 of 5 ("card barely separates, table in a narrow block, heading and
   table share no edge, no star tab"). Panel P: --ui-panel at 90%, 24 and 32px padding, the 3px accent tab on the top edge; the content fills it. */
body #attract .arcpage{ padding:calc(var(--sp-3) * var(--attz,1)) calc(var(--sp-4) * var(--attz,1)); background:color-mix(in srgb, var(--ui-panel) 90%, transparent); border:1px solid var(--ui-line-hi); border-radius:var(--rad); font:600 calc(var(--fs-body) * var(--attz,1))/1.4 var(--f-cond); letter-spacing:var(--track); color:var(--tx-1); text-shadow:none; text-align:left; }
body #attract .arcpage::before{ content:''; position:absolute; left:calc(var(--sp-4) * var(--attz,1)); top:-1px; width:calc(var(--sp-5) * var(--attz,1)); height:3px; background:var(--acc); }
body #attract .arcpage table{ width:100%; margin:0; }

'@

SubRx @'
body #attract .arcpage .aph{ font-size:calc(var(--fs-title) * var(--attz,1)); line-height:1.1; font-weight:700; color:var(--tx-1); margin-bottom:calc(var(--sp-2) * var(--attz,1)); }

'@ @'
body #attract .arcpage .aph{ font-size:calc(var(--fs-title) * var(--attz,1)); line-height:1.1; font-weight:700; color:var(--tx-1); text-align:left; margin-bottom:calc(var(--sp-3) * var(--attz,1)); }

'@

SubRx @'
body #attract .arcpage .apk{ color:var(--tx-2); }

'@ @'
body #attract .arcpage .apk{ color:var(--tx-2); width:24%; }
body #attract .arcpage td, body #attract .arcpage th{ text-align:left; padding-left:0; }

'@

SubRx @'
var VER='29.39';
'@ @'
var VER='29.40';
'@

$pat = "(?m)^  now:'v29\.39:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.40: The attract page is a proper panel with a tab, and the table fills it. Check 29.40 fails on v29.39',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
