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

# THE RUN CARD BUTTONS SIT ON A SOLID STRIP (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    padding:10px 0 4px;
    background:linear-gradient(180deg,rgba(0,0,0,0),var(--win-bot) 38%); }
'@ @'
    padding:12px 0 6px;
    background:var(--win-bot); }
  /* v19.36, seen on the 4K death card screenshot (2026-10-08): with five lost items the card scrolls, and the fade started at clear
     inside the button row itself, so half-faded feel tags showed round and behind the two buttons. The row is solid now and the
     fade is a strip just above it, so the tags pass under cleanly. */
  .ocacts::before{ content:''; position:absolute; left:0; right:0; top:-28px; height:28px; pointer-events:none;
    background:linear-gradient(180deg,rgba(0,0,0,0),var(--win-bot)); }
'@

SubRx @'
var VER='19.35';
'@ @'
var VER='19.36';
'@

$pat = "(?m)^  now:'v19\.35:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.36: On a long run card the two buttons sit on a clean strip. Check 19.36 fails on v19.35',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
