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

# PUBLIC REPORT COPY TEXT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
<div class="msub">Every raid is logged here. Copy it out and send it to Daniel so the game can be tuned on real play.</div>
'@ @'
<div class="msub">copy the raid log</div>
'@

SubRx @'
<div id="oc_copynote" style="font-size:13px;color:var(--ash);margin-top:8px;max-width:774px;line-height:1.5;margin-bottom:26px">Copy report puts this raid, and every raid before it, on your clipboard. Paste it to Daniel and the game gets fixed from it.</div>
'@ @'
<div id="oc_copynote" style="font-size:13px;color:var(--ash);margin-top:8px;max-width:774px;line-height:1.5;margin-bottom:26px">full raid log on your clipboard</div>
'@

SubRx @'
"Every raid is logged here. Copy it out and send it to Daniel so the game can be tuned on real play.":"Copy this and send it to Daniel."
'@ @'
"copy the raid log":"copy the raid log"
'@

SubRx @'
"Copy report puts this raid, and every raid before it, on your clipboard. Paste it to Daniel and the game gets fixed from it.":" "
'@ @'
"full raid log on your clipboard":" "
'@

SubRx @'
  'THE CARD AT THE END OF A RAID HAS A COPY REPORT BUTTON. It puts that raid and every raid before it on your clipboard, ready to paste straight to Daniel. That is the fastest way to get anything fixed.',
'@ @'
  'copy report copies the full raid log',
'@

SubRx @'
say2('This page cannot save files. Use COPY REPORT and paste it to Daniel.')
'@ @'
say2('download blocked: use copy report')
'@

SubRx @'
function done(){ b.textContent='Copied. Paste it to Daniel.'; setTimeout(function(){ b.textContent=was; },2600); }
'@ @'
function done(){ b.textContent='report copied'; setTimeout(function(){ b.textContent=was; },2600); }
'@

SubRx @'
function done(){ show('Copied. Paste it to Daniel.',2600); }
'@ @'
function done(){ show('report copied',2600); }
'@

SubRx @'
var VER='33.42';
'@ @'
var VER='33.43';
'@

$pat = "(?m)^  now:'v33\.42:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v33.43: Report help names the raid log. A successful copy says report copied. Check 33.43 fails on v33.42',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
