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

# THE BOARDING WINDOW READS EXTRACT IN PROGRESS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(z.hold!==null&&z.hold!==undefined) return 'EXTRACTION POINT - EXTRACT NOW! '+Math.max(0,Math.ceil(z.hold))+'S UNTIL EXTRACTION ENDS';
'@ @'
  if(z.hold!==null&&z.hold!==undefined) return 'EXTRACTION POINT - EXTRACT IN PROGRESS! '+Math.max(0,Math.ceil(z.hold))+'S UNTIL EXTRACTION ENDS';   // v17.95: his words of 2026-10-03
'@

SubRx @'
  return 'EXTRACT NOW!  '+letter+'  '+Math.max(0,Math.ceil(secs))+'S LEFT';
'@ @'
  return 'EXTRACT IN PROGRESS!  '+letter+'  '+Math.max(0,Math.ceil(secs))+'S LEFT';   // v17.95: his words of 2026-10-03 (EXTRACT NOW from v11.74 until then)
'@

SubRx @'
      else if(_zHold) _zSub='EXTRACT NOW!  '+Math.max(0,Math.ceil(Z.hold))+'S LEFT';   // v12.21: the banner's words (v11.74); the letter is the line above
'@ @'
      else if(_zHold) _zSub='EXTRACT IN PROGRESS!  '+Math.max(0,Math.ceil(Z.hold))+'S LEFT';   // v12.21: the banner's words (v11.74, his rewording of 2026-10-03); the letter is the line above
'@

SubRx @'
var VER='17.94';
'@ @'
var VER='17.95';
'@

$pat = "(?m)^  now:'v17\.94:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.95: The extraction banner now reads EXTRACT IN PROGRESS! with the ring letter and the seconds left. Check 17.95 fails on v17.94',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
