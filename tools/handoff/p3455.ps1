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

# SETTINGS PANE BACK TO ONE SHAPE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
#root #settingsmodal #setwrap > #setdetail:not(.daily-restore-detail) .sdv{ display:block; flex:1 1 100%; margin:var(--sp-2) 0 0; padding:0; border:0; font:800 var(--fs-hero)/1.1 var(--f-cond); letter-spacing:var(--track); color:var(--acc); overflow-wrap:anywhere; }
'@ @'
/* v34.54 (cw-setrevert) job 113: the detail pane hero value and the packed pane (v34.51 to v34.53) are out again. Reason: the older rulings and checks 30.05, 31.75 and 33.28 say the pane never repeats the row value (the row shows it) and runs the full list height; the critic scored the two shapes against each other with no gain (92 stayed 3). */
'@

SubRx @'
#root #settingsmodal #setwrap > #setdetail:not(.daily-restore-detail){ align-self:flex-start; min-height:0; }
'@ @'

'@

SubRx @'
#root #settingsmodal #setwrap > #setdetail:not(.daily-restore-detail) .sdv{ color:var(--tx-2); margin-top:var(--sp-2); }
'@ @'

'@

SubRx @'
#root #settingsmodal #setwrap > #setdetail:not(.daily-restore-detail) .sdv.on{ color:var(--acc); }   /* v34.53 (cw-playdata3) job 113, critic round 3 on 92: the live value is lime only when it is on; the restore warning is body size (the critic read it as 12px) */
'@ @'

'@

SubRx @'
scroll-padding-top:64px; -webkit-mask-image:linear-gradient(to bottom,#000 calc(100% - 48px),transparent); mask-image:linear-gradient(to bottom,#000 calc(100% - 48px),transparent); }
'@ @'
scroll-padding-top:64px; -webkit-mask-image:linear-gradient(to bottom,black calc(100% - 48px),transparent); mask-image:linear-gradient(to bottom,black calc(100% - 48px),transparent); }
'@

SubRx @'
try{ el.scrollIntoView({block:'nearest',inline:'nearest'}); }catch(_e){}
'@ @'
try{ if(!(el.closest&&el.closest('.setjump'))) el.scrollIntoView({block:'nearest',inline:'nearest'}); }catch(_e){}   // v34.54 (cw-setrevert): the jump chips are sticky, so focusing one never moves the list
'@

SubRx @'
var VER='34.54';
'@ @'
var VER='34.55';
'@

$pat = "(?m)^  now:'v34\.54:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v34.55: The settings side pane is back to its full height and no longer repeats the row value. Check 34.55 fails on v34.54',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
