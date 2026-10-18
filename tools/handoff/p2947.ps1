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

# The run over card is a Panel P card on the shared look (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
body #attract .arcstrip{ font:600 calc(var(--fs-body) * var(--attz,1))/1.4 var(--f-cond); letter-spacing:var(--track); color:var(--acc); }
'@ @'
/* v28.xx (cw-party-over), his order 2026-10-18 (UI step 3, party screens 52 and 55): the run over card on the shared look. The look book scored it plain:
   "the title is plain, a huge void, ext abbreviation, no panel". Now Panel P like the board page: --ui-panel at 90%, 1px line, 24 and 32px padding, the 3px accent tab,
   centred on the screen, left aligned. Run over 32px, the score 56px in the accent, the player rows 20px in tx-2, best moments 16px labels over 20px figures.
   Every size is a guide token times --attz. Restyle only: the words, the count-up and the initials keys are untouched. */
body #attract .arcover{ left:50%; right:auto; top:50%; transform:translate(-50%,-50%); width:max-content; min-width:calc(var(--menu-w) * var(--attz,1)); max-width:92%; box-sizing:border-box; padding:calc(var(--sp-3) * var(--attz,1)) calc(var(--sp-4) * var(--attz,1)); background:color-mix(in srgb, var(--ui-panel) 90%, transparent); border:1px solid var(--ui-line-hi); border-radius:var(--rad); font:600 calc(var(--fs-body) * var(--attz,1))/1.4 var(--f-cond); letter-spacing:var(--track); color:var(--tx-1); text-shadow:none; text-align:left; }
body #attract .arcover::before{ content:''; position:absolute; left:calc(var(--sp-4) * var(--attz,1)); top:-1px; width:calc(var(--sp-5) * var(--attz,1)); height:3px; background:var(--acc); }
body #attract .arcover .aoh{ font-size:calc(var(--fs-title) * var(--attz,1)); line-height:1.1; font-weight:700; color:var(--tx-1); }
body #attract .arcover .aoh + .aoh{ font-size:calc(var(--fs-body) * var(--attz,1)); line-height:1.4; color:var(--acc); margin-top:calc(var(--sp-1) * var(--attz,1)); }
body #attract .arcover .aos{ font-size:calc(var(--fs-hero) * var(--attz,1)); line-height:1.1; font-weight:800; color:var(--acc); margin:calc(var(--sp-1) * var(--attz,1)) 0 calc(var(--sp-2) * var(--attz,1)); }
body #attract .arcover .aor{ font-size:calc(var(--fs-body) * var(--attz,1)); color:var(--tx-2); margin:0; opacity:1; line-height:1.5; }
body #attract .arcover .aobm{ justify-content:flex-start !important; gap:calc(var(--sp-4) * var(--attz,1)) !important; margin:calc(var(--sp-3) * var(--attz,1)) 0 0 !important; }
body #attract .arcover .aobmt{ text-align:left !important; }
body #attract .arcover .aobmt > div:first-child{ font-size:calc(var(--fs-label) * var(--attz,1)) !important; color:var(--tx-2) !important; opacity:1 !important; letter-spacing:var(--track) !important; }
body #attract .arcover .aobmt > div:last-child{ font-size:calc(var(--fs-body) * var(--attz,1)) !important; line-height:1.4; color:var(--acc) !important; }
body #attract .arcover .aoi{ font-size:calc(var(--fs-label) * var(--attz,1)); color:var(--tx-2); margin-top:calc(var(--sp-3) * var(--attz,1)); }
body #attract .arcover .aol{ font-size:calc(var(--fs-hero) * var(--attz,1)); line-height:1.1; letter-spacing:.3em; margin:calc(var(--sp-1) * var(--attz,1)) 0; }
body #attract .arcover .aoq{ font-size:calc(var(--fs-label) * var(--attz,1)); color:var(--tx-2); opacity:1; }
body #attract .arcstrip{ font:600 calc(var(--fs-body) * var(--attz,1))/1.4 var(--f-cond); letter-spacing:var(--track); color:var(--acc); }
'@

SubRx @'
var VER='29.46';
'@ @'
var VER='29.47';
'@

$pat = "(?m)^  now:'v29\.46:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.47: The run over card is a clean panel with a big score. Check 29.47 fails on v29.46',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
