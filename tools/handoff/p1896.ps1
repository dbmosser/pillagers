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

# THE LAST POUR WARNING STAYS INSIDE THE ROOM (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
      wc.fillText('***EXPERIMENTAL***',_lx2,Math.max(s3.y-35,_lyT+_lDsc+3+_eAsc+2));
'@ @'
      // v18.96, seen on the 4K Undercroft screenshot (2026-10-07): his warning is wider than the station name above it, and centred
      // under the name it ran across the room's right wall. It slides inward like the names do (v6.73), measured as he wrote it (TX).
      var _ewd=wc.measureText((typeof TX==='function')?TX('***EXPERIMENTAL***'):'***EXPERIMENTAL***').width, _exx=_lx2;
      if(_ewd<HUBW-_lm2*2){ if(_exx+_ewd/2>HUBW-_lm2) _exx=HUBW-_lm2-_ewd/2; if(_exx-_ewd/2<_lm2) _exx=_lm2+_ewd/2; }
      wc.fillText('***EXPERIMENTAL***',_exx,Math.max(s3.y-35,_lyT+_lDsc+3+_eAsc+2));
'@

SubRx @'
var VER='18.95';
'@ @'
var VER='18.96';
'@

$pat = "(?m)^  now:'v18\.95:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.96: The warning under THE LAST POUR no longer runs into the wall. Check 18.96 fails on v18.95',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
