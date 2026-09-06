$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# HIS ORDER, 2026-09-06, with a screenshot of the raid CONDITIONS panel:
# '"left to be gone" -- no idea why this is in the conditions menu or what
# it means. "nothing killed yet" -- same comment. remove both of these from
# conditions'. They were the live verdicts of two conduct contracts he holds
# (Extract without killing anything; Extract within 3 minutes of landing),
# printed without the contract's name. Removed from the panel as ordered; the
# contracts still stand and pay at the Mainframe.
SubRx @'
        if(!CC||CC.type!=='conduct'||CC.prog>=CC.n) continue;
        var lost=false,note='';
        if(CC.ck==='clean'){ lost=(T.heals||0)>0; note=lost?'BROKEN, you healed':'no heals yet'; }
'@ @'
        if(!CC||CC.type!=='conduct'||CC.prog>=CC.n) continue;
        // v11.88, HIS ORDER: '"left to be gone" -- no idea why this is in the
        // conditions menu or what it means. "nothing killed yet" -- same
        // comment. remove both of these from conditions'. The kill-nothing and
        // three-minute contracts keep their verdicts off this panel; they still
        // stand and pay at the Mainframe.
        if(CC.ck==='quiet'||CC.ck==='swift') continue;
        var lost=false,note='';
        if(CC.ck==='clean'){ lost=(T.heals||0)>0; note=lost?'BROKEN, you healed':'no heals yet'; }
'@

# STAMPS.
SubRx @'
var VER='11.87';
'@ @'
var VER='11.88';
'@
SubRx @'
var WHATSNEW_VER='11.87';
'@ @'
var WHATSNEW_VER='11.88';
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'THE RAID CONDITIONS PANEL NO LONGER PRINTS "left to be gone" OR "nothing killed yet", on his order; those two contracts still stand at the Mainframe.',
'@
$cnt=([regex]::Matches($s,"now:'v11\.87:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v11.87 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v11\.87:[^']*'",{ param($m) "now:'v11.88: HIS ORDER of 2026-09-06, with a screenshot: left to be gone and nothing killed yet mean nothing to him in the conditions panel, remove both. They were the live verdicts of the kill-nothing and three-minute conduct contracts, printed without their names; the panel skips those two now and the contracts still stand at the Mainframe. Check 11.88 holds both contracts plus a no-heals one, draws a raid frame with the canvas text recorded, and requires neither verdict drawn and the no-heals one still there; fails on v11.87.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
