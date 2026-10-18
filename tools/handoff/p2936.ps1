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

# THE TITLE HAS A SETTINGS BUTTON (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
      <button id="titlefs" style="padding:5px 14px;font-size:13px;letter-spacing:.12em">GO FULLSCREEN</button></div>

'@ @'
      <button id="titlefs" style="padding:5px 14px;font-size:13px;letter-spacing:.12em">GO FULLSCREEN</button>
      <!-- v28.xx (cw-menu-titleset), UI step 30 (menu map): the title had no way into Settings. A party guest who wanted the sound down, or the text bigger, had to start a game, press ESC and find Settings there. It sits beside Go fullscreen, the other screen-level setting. -->
      <button id="titleset" style="padding:5px 14px;font-size:13px;letter-spacing:.12em">SETTINGS</button></div>

'@

SubRx @'
      if(fb) fb.onclick=function(ev){ if(ev) ev.stopPropagation(); fsToggle(); };

'@ @'
      if(fb) fb.onclick=function(ev){ if(ev) ev.stopPropagation(); fsToggle(); };
      // v28.xx (cw-menu-titleset): the title's own way into Settings; CLOSE and ESC come back here.
      var _tset=document.getElementById('titleset');
      if(_tset) _tset.onclick=function(ev){ if(ev) ev.stopPropagation(); openSettings(); };

'@

SubRx @'
#root #title #titlefs{ min-height
'@ @'
#root #title #titlefs, #root #title #titleset{ min-height
'@

SubRx @'
var VER='29.35';
'@ @'
var VER='29.36';
'@

$pat = "(?m)^  now:'v29\.35:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.36: The title has a Settings button next to Go fullscreen. It opens the same Settings window and ESC closes it. Check 29.36 fails on v29.35',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
