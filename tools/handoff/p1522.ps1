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
  if(!sim&&P&&P.merc){ for(var _mi=0;_mi<idPool.length;_mi++) if(idPool[_mi].id===P.merc){ idPool.push(idPool.splice(_mi,1)[0]); break; } }
'@ @'
  // v15.22, hire audit: AND NOT AT THE BACK EITHER. Moving him to the back of the 28 names kept him out only while a map drew fewer
  // than 28 strangers. THE COLD MILE draws 33 at Standard and 49 at Many, so stranger 28 wore the hire's own identity, and killing
  // that stranger recorded a kill that makes the hire refuse to work for him for good. The hired identity leaves the pool; stranger
  // 28 onward takes the numbered names the pool already falls back to. No draw is spent, so the seeded stream is untouched.
  if(!sim&&P&&P.merc){ for(var _mi=0;_mi<idPool.length;_mi++) if(idPool[_mi].id===P.merc){ idPool.splice(_mi,1); break; } }
'@
SubRx @'
var VER='15.21';
'@ @'
var VER='15.22';
'@

$pat = "(?m)^  now:'v15\.21:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.22: THE HIRE IS NEVER ALSO A STRANGER. His identity was only moved to the back of the 28 names, so on THE COLD MILE at Standard or Many, where more than 28 strangers spawn, one stranger wore it, and killing him made the hire refuse work for good. The hired identity now leaves the pool. Check 15.22 deploys THE COLD MILE at Standard with and without a hire; it fails on v15.21',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
