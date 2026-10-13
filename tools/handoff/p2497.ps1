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

# NO BACKPACK LINE AT EXTRACTION (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
      var _wh=(_g>=0.66)?'HEAVY BACKPACK':((_g>=0.33)?'LOADED BACKPACK':'LIGHT BACKPACK'),
          _wd=(_g>=0.66)?'They heard that.':((_g>=0.33)?'Expect company.':'Fewer will come.');
'@ @'
      // v24.xx (nobagline), HIS NOTE (2026-10-12): "'HEAVY BACKPACK ' - why does it say that when extracting -- we got rid of diff
      // backpack sizes etc a long time ago". The call said a third line after the siege, LIGHT, LOADED or HEAVY BACKPACK with They
      // heard that., Expect company. or Fewer will come. under it, read off _g. _g is what the haul is worth (the greed measure),
      // not a backpack size, and there is one grid backpack, so the line read as a pack size that no longer exists. It is gone, on
      // the local call and on a linked window (which runs this same call). The siege still scales with the haul, silently: _g still
      // sizes the ping, the ceiling (_scap) and the rate (_siv) exactly as before. No state, draw or timing changes.
'@

SubRx @'
      say(_wh,'info',{sub:_wd});
'@ @'
      // v24.xx (nobagline): no backpack weight line after the siege (see the nobagline note above)
'@

SubRx @'
var VER='24.96';
'@ @'
var VER='24.97';
'@

$pat = "(?m)^  now:'v24\.96:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v24.97: Calling extraction no longer says LIGHT, LOADED or HEAVY BACKPACK. Check 24.97 fails on v24.96',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
