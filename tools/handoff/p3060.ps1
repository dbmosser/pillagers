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

# TITLE: CLEAN THE STACK (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
<div style="margin-top:9px;font-size:13px;letter-spacing:.12em;color:var(--ash)">
'@ @'
<div id="titlefoot">
'@

SubRx @'
A 2.5D EXTRACTION RAID  &middot;  <span id="titlever">
'@ @'
<span id="titlever">
'@

SubRx @'
<span>BEST IN FULLSCREEN AT 1080p, 1440p OR 4K</span>
'@ @'
<!-- v28.xx (cw-title-clean): the best-in-fullscreen sentence is gone, the buttons stay -->
'@

SubRx @'
>Changing save reloads the game, which is why it leaves fullscreen.</div>
'@ @'
></div>
'@

SubRx @'
'First time out. Take the welcome pack, then walk to ENTER RAID.'
'@ @'
''
'@

SubRx @'
'First time out. Walk to ENTER RAID when you are ready.'
'@ @'
''
'@

SubRx @'
placeholder="NAME YOUR PILLAGER"
'@ @'
placeholder="Name your pillager"
'@

SubRx @'
#root #title .kbrow b{ font-size:var(--fs-fine) !important; }
'@ @'
#root #title .kbrow b{ font-size:var(--fs-fine) !important; }
/* v28.xx (cw-title-clean), the critic (2 of 5, P0/P1) on the title: "six stacked rows of small text between the logo and the menu; delete the subtitle, move Go fullscreen and Settings top-right, move the key legend to a bottom strip, the logo about 96px, version in a 14px footer". Logo 64 to 96px; Go fullscreen and Settings 44px high at the top-right, 32px from the top and 5vw from the edge; the version bottom-left, 16px, tx-2; the key legend one bottom strip, 16px, 24px from the bottom; the saves note line gone. */
#root #title .wordmark{ font-size:96px; }
#root #title #titleres{ position:fixed; top:32px; right:5vw; margin:0 !important; display:flex; gap:12px; z-index:2; }
#root #title #titleres button{ min-height:44px; padding:0 24px; font-size:16px; }
#root #title #titlefoot{ position:fixed; left:5vw; bottom:24px; margin:0; font:600 var(--fs-fine)/1 var(--f-cond); letter-spacing:var(--track); color:var(--tx-2); }
#root #title .kbrow, #root #title .padrow{ position:fixed; left:0; right:0; bottom:24px; margin:0 !important; text-align:center; font-size:16px !important; }
#root #title #slotnote{ margin:0 !important; }
'@

SubRx @'
rgba(17,19,21,.60) 0%, rgba(17,19,21,.84) 70%, rgba(17,19,21,.96) 100%)
'@ @'
rgba(17,19,21,.40) 0%, rgba(17,19,21,.60) 70%, rgba(17,19,21,.82) 100%)
'@

SubRx @'
var VER='30.59';
'@ @'
var VER='30.60';
'@

$pat = "(?m)^  now:'v30\.59:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v30.60: The title is cleaner: bigger logo, one line, the menu. Check 30.60 fails on v30.59',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
