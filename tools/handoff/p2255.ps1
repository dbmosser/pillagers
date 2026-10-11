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

# A GUN DRAGS BACK TO ITS KEY (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
          if(_gOld&&_gOld.a===d.key){ G.hot=gunCell(); dropped=true; break; }
'@ @'
          // v22.55, from the review of the four-gun belt (build 5): A GUN HE PUT ON A KEY PAST THE GUN KEYS DRAGS BACK ONTO THE GUN KEY
          // THAT SHOWS IT. A gun in his hands always shows on a gun key too (v15.25, his note: key 1 never goes black while he holds a
          // gun), so after the rifle went from key 1 to key 6 key 1 still showed it, and dragging it from key 6 back onto key 1 was
          // read as a drop on its own key: nothing changed, nothing was said, and key 6 kept it. Now his key for it comes off and the
          // gun is pinned on the gun key, as any gun dropped on a gun key is, and the line names the key.
          if(_gOld&&_gOld.a===d.key&&_gA[HC.i]===undefined&&d.fromHot!==undefined&&d.fromHot!==HC.i&&_gA[d.fromHot]===d.key) _gOld=null;
          if(_gOld&&_gOld.a===d.key){ G.hot=gunCell(); dropped=true; break; }
'@

SubRx @'
var VER='22.54';
'@ @'
var VER='22.55';
'@

$pat = "(?m)^  now:'v22\.54:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.55: A gun put on a later key drags back onto the gun key that shows it. Check 22.55 fails on v22.54',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
