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

# TITLE: THE FIGHT CAN BE SEEN BEHIND THE SCOREBOARD AND HOW-TO PAGES (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var A=[[62,392,152,392],[638,392,548,392]], i, a, P, R;
'@ @'
var A=[[62,300,152,300],[638,300,548,300]], i, a, P, R;   // v28.xx (cw-title-see): the fights stand at mid height, in the light of the side margins, not down in the dark corner under the saves block
'@

SubRx @'
    if(titleOn()) continue;   // v17.84: no station names under the title
'@ @'
    if(titleOn()||tskOn()) continue;   // v17.84: no station names under the title; v28.xx (cw-title-see): nor behind the scoreboard and the how-to page, where they smeared into the fight
'@

SubRx @'
  if(titleOn()) return;   // v17.84: nothing of the floor HUD under the title
'@ @'
  if(titleOn()||tskOn()) return;   // v17.84: nothing of the floor HUD under the title; v28.xx (cw-title-see): nor behind the attract pages (the stray THE UNDERCROFT in the corner, critic 46)
'@

SubRx @'
if(!titleOn()){ if(hubBagOpen) drawHubBag(); else drawHubBelt(); }
'@ @'
if(!titleOn()&&!tskOn()){ if(hubBagOpen) drawHubBag(); else drawHubBelt(); }
'@

SubRx @'
/* v29.98 (cw-partyprompt), the critic on v29.97
'@ @'
/* v28.xx (cw-title-see), HIS ANSWERS 10-18 (Q52, Q54): "show the live map, dimmed, with REAL pillager-versus-robot combat happening in it". The 16px blur and the 90 percent edge scrim turned the fight into mud. The floor labels and HUD are no longer drawn behind these pages (they were the reason for the heavy blur), so the blur is 5px and the scrim lets about 40 percent of the world through at the edges, where the fights stand. The card keeps its own panel. */
body #attract{ -webkit-backdrop-filter:blur(5px); backdrop-filter:blur(5px); background:radial-gradient(ellipse at 50% 42%, color-mix(in srgb, var(--ui-raised) 24%, transparent) 0%, color-mix(in srgb, var(--ui-bg) 66%, transparent) 50%, color-mix(in srgb, var(--ui-void) 58%, transparent) 100%); }
/* v29.98 (cw-partyprompt), the critic on v29.97
'@

SubRx @'
var VER='30.72';
'@ @'
var VER='30.73';
'@

$pat = "(?m)^  now:'v30\.72:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v30.73: The fight behind the scoreboard and how-to can be seen. Check 30.73 fails on v30.72',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
