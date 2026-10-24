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

# PLAY DATA PAGE AND SETTINGS PANE POLISH (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
      <div class="msub">Paste a RESTORE CODE from the end of a run report. It REPLACES the save you are playing. Read it first: the game will tell you whose character it is before anything is written.</div>
'@ @'
      <div class="msub">paste a restore code. replaces your save.</div>
'@

SubRx @'
#root #settingsmodal #setwrap > #setdetail .sdkey{ display:inline-block; flex:0 0 auto; padding:var(--sp-1) var(--sp-2); border:1px solid var(--ui-line-hi); border-radius:var(--rad); color:var(--tx-1); font:600 var(--fs-label)/1.2 var(--f-cond); }
'@ @'
/* v34.52 (cw-playdata2) job 113, critic round 2 (31 and 92 both 3). 31: the counts are the page headline (32px), the actions group at an 8px gap, restore is its own quiet panel and its helper is one short amber line (the old sentence pointed "above" at a box that is folded now). 92: the pane packs to its content instead of a tall empty box, the hero value is tx-1 (lime stays for focus only), the chip is body size and the gaps sit on the 8px grid. */
#root #settingsmodal.recmode #spane_rec > #expsum{ font:700 var(--fs-title)/1.2 var(--f-cond); color:var(--tx-1); letter-spacing:var(--track); margin:0 0 var(--sp-4); }
#root #settingsmodal.recmode #exporttext + div{ gap:var(--sp-1) !important; }
#root #settingsmodal.recmode #exporttext + div + div{ margin-top:var(--sp-4) !important; padding:var(--sp-3) !important; border:1px solid var(--ui-line-hi); border-radius:var(--rad); background:var(--ui-panel); }
#root #settingsmodal.recmode #spane_rec > div:has(> #rescode) > .msub{ font:600 var(--fs-label)/1.4 var(--f-cond) !important; color:var(--warn); }
#root #settingsmodal #setwrap > #setdetail:not(.daily-restore-detail){ align-self:flex-start; min-height:0; }
#root #settingsmodal #setwrap > #setdetail:not(.daily-restore-detail) .sdv{ color:var(--tx-1); margin-top:var(--sp-2); }
#root #settingsmodal #setwrap > #setdetail .sdkey{ display:inline-block; flex:0 0 auto; margin-top:var(--sp-2); padding:var(--sp-1) var(--sp-2); border:1px solid var(--ui-line-hi); border-radius:var(--rad); color:var(--tx-1); font:600 var(--fs-body)/1.2 var(--f-cond); letter-spacing:var(--track); }
'@

SubRx @'
var VER='34.51';
'@ @'
var VER='34.52';
'@

$pat = "(?m)^  now:'v34\.51:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v34.52: Send play data reads as a headline, one copy button and a quiet restore panel; the settings detail pane no longer shows a tall empty box. Check 34.52 fails on v34.51',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
