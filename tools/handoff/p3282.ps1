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

# INVITE CODE KEEPS ITS CASE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(NCLOWER) return (typeof s==='string')?s.toLowerCase():s;
'@ @'
  // v28.xx (cw-codeguard): the party code tag is a code, not a word. It starts PTY1o (invite) or PTY1a (reply) and the join code reads it
  // case sensitive, so the lower case door leaves exactly that tag as it is. Every word around it is still lower case.
  if(NCLOWER) return (typeof s==='string')?((s.indexOf('PTY1')<0)?s.toLowerCase():s.toLowerCase().replace(/pty1([oa])/g,'PTY1$1')):s;
'@

SubRx @'
var VER='32.81';
'@ @'
var VER='32.82';
'@

$pat = "(?m)^  now:'v32\.81:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.82: The tag PTY1o and PTY1a is left as typed by the lower case door; every other word stays lower case. Check 32.82 fails on v32.81',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
