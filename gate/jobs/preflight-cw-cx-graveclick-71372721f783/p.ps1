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

# GRAVEYARD BUTTONS OPEN AND CLOSE BY CLICK (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
<button type="button" id="hcgraves" class="deploy ghost" style="display:none" onclick="hcGraveOpen()">graveyard</button>
'@ @'
<button type="button" id="hcgraves" class="deploy ghost" style="display:none">graveyard</button>
'@

SubRx @'
<button type="button" id="hcgraveclose" class="deploy ghost" onclick="hcGraveClose()">close <span class="ui-key">esc</span></button>
'@ @'
<button type="button" id="hcgraveclose" class="deploy ghost">close <span class="ui-key">esc</span></button>
'@

SubRx @'
document.addEventListener('keydown',function(e){if(e.key==='Escape'&&document.getElementById('hcgrave').classList.contains('on')){e.preventDefault();e.stopImmediatePropagation();hcGraveClose();}},true);
'@ @'
// v28.xx (cw-cx-graveclick): both buttons reach the graveyard functions inside the game closure.
document.getElementById('hcgraves').addEventListener('click',hcGraveOpen);
document.getElementById('hcgraveclose').addEventListener('click',hcGraveClose);
document.addEventListener('keydown',function(e){if(e.key==='Escape'&&document.getElementById('hcgrave').classList.contains('on')){e.preventDefault();e.stopImmediatePropagation();hcGraveClose();}},true);
'@

SubRx @'
var VER='37.72';
'@ @'
var VER='37.73';
'@

$pat = "(?m)^  now:'v37\.72:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v37.73: The title graveyard button opens the ranked records, and close returns focus to the title button. Check 37.73 fails on v37.72',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
