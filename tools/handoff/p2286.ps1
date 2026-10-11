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

# LINES UNDER THE PAUSE BOX SHOW ON IT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    if(msgAlertK(k)){ alertSay(m,k,o); return; }   // v22.13 (R08): crit, warn and ext take the alert lane, not a feed row
'@ @'
    if(msgAlertK(k)){ alertSay(m,k,o); return; }   // v22.13 (R08): crit, warn and ext take the alert lane, not a feed row
    // v22.xx, the raid text rewrite (R37): A LINE SAID UNDER THE SOLO PAUSE BOX SHOWS ON IT. HIS ORDER (2026-10-09): the raid text
    // reads like a shooter HUD, and a menu answers on the menu. With the pause box open in a solo raid (the world stopped), a key
    // or a Settings change said its line into the raid feed behind the box, where it was not seen, and its clock stood still, so it
    // showed only after the box shut, about a change already made. A system or info line said while the solo pause holds now goes
    // to the answer line (#hubtoast, z 200, over the pause box and scaled with the menus since v12.25), with its detail after a
    // middle dot. The co-op overlay pause, where the world runs on, keeps the lanes.
    if((k==='sys'||k==='info')&&G.paused&&!G.over){ var _npl=false; try{ _npl=netPauseLive(); }catch(_np){} if(!_npl){ hubToast((o&&o.sub)?String(m)+'  \u00b7  '+String(o.sub):String(m)); return; } }
'@

SubRx @'
var VER='22.85';
'@ @'
var VER='22.86';
'@

$pat = "(?m)^  now:'v22\.85:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.86: A line said while the solo pause box is open now shows over the box instead of behind it. Check 22.86 fails on v22.85',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
