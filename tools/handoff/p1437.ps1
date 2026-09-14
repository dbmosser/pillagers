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
    g4.gain.setValueAtTime(.07,t); g4.gain.exponentialRampToValueAtTime(.001,t+.12);
'@ @'
    // v14.37, audio audit finding 3: A PICK FAR AWAY SOUNDS FAR AWAY. This voice ignored the distance its callers pass, so
    // a hire or a crew looting a crate 580 units off played at full loudness, as if it were in your own hands. Without a
    // distance vol is 1, so every Undercroft and menu pick is exactly as loud as before.
    g4.gain.setValueAtTime(.07*vol,t); g4.gain.exponentialRampToValueAtTime(.001,t+.12);
'@
SubRx @'
var VER='14.36';
'@ @'
var VER='14.37';
'@

$pat = "(?m)^  now:'v14\.36:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.37: A PICK FAR AWAY SOUNDS FAR AWAY. The pick sound ignored the distance passed to it, so a hire or crew looting a crate across the street played at full loudness, as if in your own hands. It now scales with distance like the other voices; with no distance it is exactly as loud as before. Check 14.37 plays a pick with no distance and at 580 units with a fake audio context; it fails on v14.36',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
