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
    if(typeof _v!=='number'||!isFinite(_v)||_v<0) P[_k]=Math.max(0,(typeof _v==='number'&&isFinite(_v))?_v:0);
  }
})();
'@ @'
    if(typeof _v!=='number'||!isFinite(_v)||_v<0) P[_k]=Math.max(0,(typeof _v==='number'&&isFinite(_v))?_v:0);
  }
})();
// v14.30, progression audit finding 3: THE LEVEL IS WORKED OUT FROM THE XP WHEN A PROFILE LOADS. P.xpLevel was recomputed
// only when XP was added, so a save whose stored level had fallen behind its XP (an old stash sale, the reputation merge
// above, or an xp value the cleanup just reset) loaded at the wrong level: level-gated cosmetics showed locked or unlocked
// against it, the card printed it, and a worn level cosmetic could be taken off, until the next raid or sale fixed it.
if(typeof syncXpLevel==='function') syncXpLevel();
'@
SubRx @'
var VER='14.29';
'@ @'
var VER='14.30';
'@

$pat = "(?m)^  now:'v14\.29:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.30: THE LEVEL IS WORKED OUT FROM THE XP WHEN A PROFILE LOADS. The stored level was recomputed only when XP was added, so a save whose level had fallen behind its XP loaded at the wrong level, with level-gated cosmetics and the card reading it until the next raid or sale. The loader now recomputes it right after it cleans the numbers. Check 14.30 loads a save with 1,980 XP and a stored level of 1 through the real loader; it fails on v14.29',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
