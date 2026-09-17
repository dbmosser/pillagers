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

SubRx @'
    if(_ir&&_sd) return {msg:'HOLD E TO EXTRACT',sub:'Extracting while downed is permitted',col:'#4de3d0'};
'@ @'
    // v15.32, extraction audit finding: ON A CONTROLLER THE EXTRACT PROMPT NAMES THE X BUTTON. Down in a landed ring this huge
    // line said E on a pad too, a key the pad does not have, and the ring badge is not drawn while he is down, so nothing on
    // screen named X, the button that extracts him. It asks keyLabel, as the call row under it does; the keyboard still reads E.
    if(_ir&&_sd) return {msg:'HOLD '+keyLabel('KeyE','E')+' TO EXTRACT',sub:'Extracting while downed is permitted',col:'#4de3d0'};
'@
SubRx @'
      _msg='HOLD E TO EXTRACT';
'@ @'
      // v15.32, extraction audit finding: ON A CONTROLLER THE EXTRACT PROMPT NAMES THE X BUTTON. This line said E on a pad too.
      // Standing in the landed ring he just called with X, the ring badge is skipped for the ring he stands in (v6.57), so this
      // was the only verb on screen and it named a key the pad does not have. It asks keyLabel, as both call prompts do.
      _msg='HOLD '+keyLabel('KeyE','E')+' TO EXTRACT';
'@
SubRx @'
var VER='15.31';
'@ @'
var VER='15.32';
'@

$pat = "(?m)^  now:'v15\.31:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.32: ON A CONTROLLER THE EXTRACT PROMPT NAMES THE X BUTTON. Standing in a landed extraction point, or down in one, the line telling him how to leave said to hold E on a controller too, a key the pad does not have, while the call prompts already said X. Both lines now ask the same button name helper the call prompts use, and the keyboard still reads E. Check 15.32 draws the HUD with a fake pad, standing and down in a landed ring; it fails on v15.31',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
