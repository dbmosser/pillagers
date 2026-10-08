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

# THE BAR WARNING SITS UNDER ITS OWN NAME (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
      var _ewd=wc.measureText((typeof TX==='function')?TX('***EXPERIMENTAL***'):'***EXPERIMENTAL***').width, _exx=_lx2;
'@ @'
      var _ewd=wc.measureText((typeof TX==='function')?TX('***EXPERIMENTAL***'):'***EXPERIMENTAL***').width, _exx=_lx2;
      // v19.43, seen on the 4K Undercroft screenshot (2026-10-08): his warning is about twice as wide as THE LAST POUR, so even slid
      // in from the wall it reached across under THE STASH and read as that station's line. It shrinks to sit under its own name
      // (never below 70 percent), his words as he wrote them.
      if(_ewd>tw*1.15){ var _ek=Math.max(0.7,tw*1.15/_ewd); wc.font=String(wc.font).replace((/([\d.]+)px/),function(m0,n0){ return (parseFloat(n0)*_ek).toFixed(1)+'px'; }); _ewd=wc.measureText((typeof TX==='function')?TX('***EXPERIMENTAL***'):'***EXPERIMENTAL***').width; }
'@

SubRx @'
var VER='19.42';
'@ @'
var VER='19.43';
'@

$pat = "(?m)^  now:'v19\.42:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.43: The bar warning on the Undercroft floor sits under THE LAST POUR only. Check 19.43 fails on v19.42',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
