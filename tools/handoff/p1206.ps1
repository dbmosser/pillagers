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

# FROM THE 2026-09-06 READ-ONLY REVIEW OF v11.74 (EXTRACT NOW): the sector
# map keeps a third copy of the boarding-window line, and while the map is
# open it is the only copy the player can read, because the map paints over
# the banner and the ring label. It still said OPEN TO EXTRACT, the wording
# he rejected at v8.68 and again at v11.74. It reads the same words now (the
# letter is already on the line above it, so the helper's letter is left
# out), and the stale comment over the ring label names the owner.
SubRx @'
      else if(_zHold) _zSub='OPEN TO EXTRACT  '+Math.max(0,Math.ceil(Z.hold))+'s';
'@ @'
      else if(_zHold) _zSub='EXTRACT NOW!  '+Math.max(0,Math.ceil(Z.hold))+'S LEFT';   // v11.98: the banner's words (v11.74); the letter is the line above
'@
SubRx @'
    // v8.68, his wording, same as the banner.
'@ @'
    // v11.74: extractNowLine, the same line as the banner (v8.68 named the window; v11.74 reworded it).
'@

# STAMPS.
SubRx @'
var VER='11.97';
'@ @'
var VER='11.98';
'@
SubRx @'
var WHATSNEW_VER='11.97';
'@ @'
var WHATSNEW_VER='11.98';
'@
$cnt=([regex]::Matches($s,"now:'v11\.97:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v11.97 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v11\.97:[^']*'",{ param($m) "now:'v11.98: from the read-only review of the shipped v11.74, the sector map still said OPEN TO EXTRACT under a landed ring, and with the map open that is the only boarding line the player can read. It says EXTRACT NOW with the seconds left, the banner wording. Check 11.98 records what the map draws under a ring in the hold and requires the new words and not the old; fails on v11.97.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
