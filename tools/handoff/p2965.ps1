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

# SETTINGS ONE STRIP (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
#root #keysmodal #keysreset{ min-height:var(--sp-5); font-size:var(--fs-body); }
'@ @'
#root #keysmodal #keysreset{ min-height:var(--sp-5); font-size:var(--fs-body); }

/* v28.xx (cw-setone) critic c-31 (Settings 2, P0): "two nav systems on one screen ... delete one". The Game and Send play data tabs beside the title are gone while you are on the Game page: Send play data is the last chip of the one section strip (same chip, same page), and the title row shows the two tabs only on the Send play data page, so the way back is still there. Keys: the row under the pointer gets the raised fill and the amber bar like Settings. */
#root #settingsmodal:not(.recmode) #settabs{ visibility:hidden; pointer-events:none; }
#root #setlist .setjump button[data-go]{ margin-left:auto; }
#root #keyslist .row:hover{ background:var(--ui-raised); box-shadow:inset 3px 0 0 var(--acc); }
'@

SubRx @'
<div class="row setjump"><div class="sj">'+j+'</div></div>
'@ @'
<div class="row setjump"><div class="sj">'+j+'<button type="button" data-go="rec">Send play data</button></div></div>
'@

SubRx @'
b.onclick=function(){ setSecJump(host,b.getAttribute('data-sec')); setSecSpy(host); };
'@ @'
b.onclick=function(){ if(b.getAttribute('data-go')){ openSettings(b.getAttribute('data-go')); return; } setSecJump(host,b.getAttribute('data-sec')); setSecSpy(host); };
'@

SubRx @'
var tb=document.getElementById('settabs');
'@ @'
var tb=document.getElementById('settabs'); try{ document.getElementById('settingsmodal').classList.toggle('recmode',want==='rec'); }catch(_rm){}
'@

SubRx @'
var VER='29.64';
'@ @'
var VER='29.65';
'@

$pat = "(?m)^  now:'v29\.64:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.65: Settings has one tab strip. Check 29.65 fails on v29.64',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
