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

# THE CALL PROMPT IS SAID ONCE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
ctx.fillStyle='#4de3d0';
        ctx.fillText('['+keyLabel('KeyE','E')+'] CALL FOR EXTRACTION',ps.x,ps.y);
        if(padZ.callT>0) bar(ps.x-30,ps.y+LH(6),60,6,clamp(padZ.callT/1.6,0,1),'#4de3d0');
'@ @'
        // v19.56, seen on the 4K ring screenshot (2026-10-08): standing in the ring this prompt printed over his own character, saying what
        // the line above the belt already says with its own hold bar (HOLD E TO CALL FOR EXTRACTION). While that line shows, this one
        // steps aside, as the EXTRACT prompt above already does inside the ring.
        if(!(G.active===padZ&&G.beaconT===null&&!G.over)){
ctx.fillStyle='#4de3d0';
        ctx.fillText('['+keyLabel('KeyE','E')+'] CALL FOR EXTRACTION',ps.x,ps.y);
        if(padZ.callT>0) bar(ps.x-30,ps.y+LH(6),60,6,clamp(padZ.callT/1.6,0,1),'#4de3d0');
        }
'@

SubRx @'
var VER='19.55';
'@ @'
var VER='19.56';
'@

$pat = "(?m)^  now:'v19\.55:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.56: In an extraction ring the call prompt no longer covers your character. Check 19.56 fails on v19.55',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
