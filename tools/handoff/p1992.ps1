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

# A DEAD CONTROL LOOKS DEAD UNDER THE PAD HIGHLIGHT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    box-shadow:0 0 0 6px rgba(255,192,74,.35), 0 0 22px 4px rgba(255,192,74,.45) !important; }
'@ @'
    box-shadow:0 0 0 6px rgba(255,192,74,.35), 0 0 22px 4px rgba(255,192,74,.45) !important; }
  /* v19.92, from the code review of 2026-10-08: the full strength above made a button that went dead under the highlight (the last
     affordable rack just built, v15.52 keeps the highlight there on purpose) or a locked shop cell look live. They stay dimmed. */
  button:disabled.padfocus, .vcell.locked.padfocus{ opacity:.55 !important; }
'@

SubRx @'
var VER='19.91';
'@ @'
var VER='19.92';
'@

$pat = "(?m)^  now:'v19\.91:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.92: On a controller, a greyed-out button still looks greyed out when highlighted. Check 19.92 fails on v19.91',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
