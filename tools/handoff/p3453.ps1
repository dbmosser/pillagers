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

# SETTINGS PANE VALUE LIT ONLY WHEN ON (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
(vt?'<div class="sdv">'+escHtml(vt)+'</div>':'')
'@ @'
(vt?'<div class="sdv'+(/^on$/i.test(vt)?' on':'')+'">'+escHtml(vt)+'</div>':'')
'@

SubRx @'
#root #settingsmodal #setwrap > #setdetail:not(.daily-restore-detail) .sdv{ color:var(--tx-1); margin-top:var(--sp-2); }
'@ @'
#root #settingsmodal #setwrap > #setdetail:not(.daily-restore-detail) .sdv{ color:var(--tx-2); margin-top:var(--sp-2); }
#root #settingsmodal #setwrap > #setdetail:not(.daily-restore-detail) .sdv.on{ color:var(--acc); }   /* v34.53 (cw-playdata3) job 113, critic round 3 on 92: the live value is lime only when it is on; the restore warning is body size (the critic read it as 12px) */
#root #settingsmodal.recmode #spane_rec > div:has(> #rescode) > .msub{ font-size:var(--fs-body) !important; }
'@

SubRx @'
var VER='34.52';
'@ @'
var VER='34.53';
'@

$pat = "(?m)^  now:'v34\.52:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v34.53: The settings detail pane lights an on value and mutes an off one; the restore warning is bigger. Check 34.53 fails on v34.52',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
