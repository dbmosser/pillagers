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

# THE QUIET HUD, PAUSE BOX AND CONTRACT NAMES (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    try{ feedSay(m,k,o); }catch(_fsy){}   // v27.24 (feed1): every other line said is in the feed
    // v22.xx, the raid text rewrite (R37): A LINE SAID UNDER THE SOLO PAUSE BOX SHOWS ON IT. HIS ORDER (2026-10-09): the raid text
    // reads like a shooter HUD, and a menu answers on the menu. With the pause box open in a solo raid (the world stopped), a key
    // or a Settings change said its line into the raid feed behind the box, where it was not seen, and its clock stood still, so it
    // showed only after the box shut, about a change already made. A system or info line said while the solo pause holds now goes
    // to the answer line (#hubtoast, z 200, over the pause box and scaled with the menus since v12.25), with its detail after a
    // middle dot. The co-op overlay pause, where the world runs on, keeps the lanes.
    if((k==='sys'||k==='info')&&G.paused&&!G.over){ var _npl=false; try{ _npl=netPauseLive(); }catch(_np){} if(!_npl){ hubToast((o&&o.sub)?String(m)+'  \u00b7  '+String(o.sub):String(m)); return; } }
'@ @'
    // v22.xx, the raid text rewrite (R37): A LINE SAID UNDER THE SOLO PAUSE BOX SHOWS ON IT. HIS ORDER (2026-10-09): the raid text
    // reads like a shooter HUD, and a menu answers on the menu. With the pause box open in a solo raid (the world stopped), a key
    // or a Settings change said its line into the raid feed behind the box, where it was not seen, and its clock stood still, so it
    // showed only after the box shut, about a change already made. A system or info line said while the solo pause holds now goes
    // to the answer line (#hubtoast, z 200, over the pause box and scaled with the menus since v12.25), with its detail after a
    // middle dot. The co-op overlay pause, where the world runs on, keeps the lanes.
    if((k==='sys'||k==='info')&&G.paused&&!G.over){ var _npl=false; try{ _npl=netPauseLive(); }catch(_np){} if(!_npl){ hubToast((o&&o.sub)?String(m)+'  \u00b7  '+String(o.sub):String(m)); return; } }
    // v35.xx (cw-quietpause), HIS ORDER (2026-10-27): "build the quiet hud, all 5 changes". ONE PLACE UNDER THE PAUSE BOX TOO. The feed took the line before
    // this test ran, so a key or a Settings change under the solo pause showed on the answer line over the box AND sat in the left feed behind it, and was read
    // again after the box shut, about a change already made. The answer line is now its one place; the co-op overlay pause, where the world runs on, keeps the feed.
    try{ feedSay(m,k,o); }catch(_fsy){}   // v27.24 (feed1): every other line said is in the feed
'@

SubRx @'
length<=4) segs.push({t:'  
'@ @'
length<=4||sub&&o&&o.key) segs.push({t:'  
'@

SubRx @'
var VER='35.30';
'@ @'
var VER='35.31';
'@

$pat = "(?m)^  now:'v35\.30:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.31: quiet hud: a line said under the pause box shows on the box only; contract done names the contract Check 35.31 fails on v35.30',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
