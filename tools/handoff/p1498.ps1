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
  say('Rack '+P.racks+' hums to life. '+'$'+(P.racks*RACK_PAY)+' every time you make it home.');
'@ @'
  // v14.98, copies audit finding 2: THE RACK LINE SAYS WHAT THE WALL PAYS. It counted the racks alone, while an extraction pays
  // mfPayPer, racks and Arrays together, and the Mainframe status line says so: with one Array the new rack said $200.
  say('Rack '+P.racks+' hums to life. '+'$'+mfPayPer().toLocaleString()+' every time you make it home.');
'@
SubRx @'
var VER='14.97';
'@ @'
var VER='14.98';
'@

$pat = "(?m)^  now:'v14\.97:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.98: THE RACK LINE SAYS WHAT THE WALL PAYS. Building a rack said the racks alone pay per extraction, leaving out the Arrays the extraction pays for and the Mainframe line counts, so with one Array it said 200 where the wall pays 2,800. It now names the whole wall pay. Check 14.98 builds a rack beside an Array; it fails on v14.97',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
