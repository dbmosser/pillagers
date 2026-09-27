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

# A SPECTATING HOST IS STILL HOSTING (co-op hunt and review 2026-09-27).

SubRx @'
  return !!(typeof NET==='object'&&NET&&NET.on&&NET.role==='host'&&netInCount()>0&&NET.upSeed&&typeof G!=='undefined'&&G&&!G.sim&&(!G.over||G===NET.specG));
'@ @'
  // v16.64, stability (co-op hunt): a host back in the Undercroft is still running the raid for the party (NET.specG, v16.14).
  // This read only the host own raid, so once he left his run card nothing warned before the window closed or reloaded, and
  // closing it abandoned his teammate raid. The pause box line and the leave warning now hold while he spectates.
  return !!(typeof NET==='object'&&NET&&NET.on&&NET.role==='host'&&netInCount()>0&&(NET.specG||(NET.upSeed&&typeof G!=='undefined'&&G&&!G.sim&&(!G.over||G===NET.specG))));
'@

SubRx @'
  var _rOff=(typeof G!=='undefined'&&G&&!G.over&&!G.sim)?' disabled':'';
'@ @'
  var _rOff=((typeof G!=='undefined'&&G&&!G.over&&!G.sim)||(typeof NET==='object'&&NET&&NET.on&&NET.specG))?' disabled':'';   // v16.64: and while the host runs the raid for his party
'@

SubRx @'
var VER='16.63';
'@ @'
var VER='16.64';
'@

$pat = "(?m)^  now:'v16\.63:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.64: A SPECTATING HOST IS STILL HOSTING. Stability pass before a co-op session. Once the host left his run card for the Undercroft while his teammate was still up top, his window still ran the raid for the party, but nothing warned before it closed or reloaded (which abandoned the teammate raid), the pause box stopped saying he was hosting, and Settings offered the buttons that reload the window. All three now hold until the party is out. Check 16.64 fails on v16.63',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
