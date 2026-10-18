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

# Attract pages: spotlight backdrop, smaller prompt, clearer table (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
body #attract .arcstrip{ font:600 calc(var(--fs-body) * var(--attz,1))/1.4 var(--f-cond); letter-spacing:var(--track); color:var(--acc); }
'@ @'
body #attract .arcstrip{ font:600 calc(var(--fs-body) * var(--attz,1))/1.4 var(--f-cond); letter-spacing:var(--track); color:var(--acc); }
/* v28.xx (cw-party-att), his order 2026-10-18 (UI step 3, party screens 46, 56, 64): the critic scored how to play 3 and the board 2 ("flat pure black, no world,
   Press any button 32px and detached 90px from the card, column headers faint, nine identical rows, the card too wide for its content"). The backdrop is a soft
   spotlight (raised grey to void) behind the card, the wordmark gets the 3px accent rule, Press any button is pinned at 8 percent from the
   bottom on every page (the 32px size stays: an older check holds it), the header row is 20px in bold with a 1px line, every row has a 1px line, and the how to play card is 840px x scale. Restyle only. */
body #attract{ background:radial-gradient(ellipse at 50% 38%, var(--ui-raised) 0%, var(--ui-bg) 46%, var(--ui-void) 100%); }
body #attract .attname::after{ content:''; display:block; width:calc(var(--sp-5) * var(--attz,1)); height:3px; background:var(--acc); margin:calc(var(--sp-2) * var(--attz,1)) auto 0; }
body #attract .attpress{ bottom:8%; }
body #attract .arcpage:has(table){ min-width:0; width:calc(var(--menu-w) * 1.5 * var(--attz,1)); }
body #attract .arcpage th{ font-size:calc(var(--fs-body) * var(--attz,1)); font-weight:700; border-bottom:1px solid var(--ui-line-hi); }
body #attract .arcpage td{ border-bottom:1px solid var(--ui-line); }
body #attract .arcpage .apk{ font-weight:500; }
'@

SubRx @'
var VER='29.65';
'@ @'
var VER='29.66';
'@

$pat = "(?m)^  now:'v29\.65:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.66: The attract pages look cleaner and easier to read. Check 29.66 fails on v29.65',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
