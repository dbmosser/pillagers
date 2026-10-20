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

# Rewards and bar: one focus, fewer lines (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
#root #termsmodal #termsclear{ min-width:200px; min-height:48px; font-size:18px; }
'@ @'
#root #termsmodal #termsclear{ min-width:200px; min-height:48px; font-size:18px; }
/* v28.xx (cw-uc-rewbar) b-31 step 7, critic on 13 rewards (2: no hierarchy, intro sentence, 13px bar, dead right column) and 16 bar (2: two lime buttons, flavour line, duplicate money line): rewards intro hidden, xp label 24px, bar 28px with 16px count, list 1400px wide with 64px rows; bar and craft lose the duplicate "you hold" line, the bar loses its flavour line, ingest buttons are ghost until hovered or focused, prices light instead of lime. */
#root #opane_rew{ max-width:1400px !important; }
#root #opane_rew > .msub:not(#roadmaphead){ display:none !important; }
#root #seasonhead{ font-size:24px !important; font-weight:800; letter-spacing:.08em !important; color:#e8e2d4 !important; padding-bottom:4px !important; }
#root #seasonbar{ height:28px !important; }
#root #seasontext{ font-size:16px !important; line-height:28px !important; }
#root #seasonclaimall{ width:auto !important; padding:10px 28px !important; align-self:flex-end; }
#root #seasonlist .row{ min-height:64px; font-size:20px; }
#root #seasonlist .row .vl{ color:var(--ash); }
#root #wallet_work, #root #wallet_merc, #root #wallet_bar, #root #bar_line{ display:none !important; }
#root #barmodal .row .hint{ font-size:16px; }
#root #barmodal .row .vl{ color:#e8e2d4; }
#root #barmodal .row button:not(:disabled):not(:hover):not(:focus){ background:transparent; color:#e6ff3d; border:1px solid #e6ff3d; }
'@

SubRx @'
var VER='32.44';
'@ @'
var VER='32.45';
'@

$pat = "(?m)^  now:'v32\.44:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.45: The rewards page loses its intro and gets a bigger bar; the bar page loses two lines and its buttons go ghost until selected. Check 32.45 fails on v32.44',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
