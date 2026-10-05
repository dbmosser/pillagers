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

# THE POSTURE CHIP IS A HUD PANEL (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    ctx.fillStyle='rgba(6,9,13,.72)';
    ctx.fillRect(20,by-_up-LH(17),_pw+10,LH(14));
'@ @'
    // v18.41, THE STYLING PASS IN THE RAID (2026-10-04): the posture chip (STANDING, CROUCHED, SPRINTING...) is a small rounded
    // HUD panel like the boxes around it, same place and size.
    if(typeof hudPanel==='function') hudPanel(18,by-_up-LH(18),_pw+14,LH(16),0.78);
    else { ctx.fillStyle='rgba(6,9,13,.72)'; ctx.fillRect(20,by-_up-LH(17),_pw+10,LH(14)); }
'@

SubRx @'
var VER='18.40';
'@ @'
var VER='18.41';
'@

$pat = "(?m)^  now:'v18\.40:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.41: The STANDING / CROUCHED chip matches the other HUD panels. Check 18.41 fails on v18.40',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
