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

# A FOUND GUN NEVER BUMPS A BETTER ONE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
      var tierUp=(WTIER[itm.gk]||0)>(WTIER[p.wep.id]||0);
      var condUp=(WTIER[itm.gk]||0)===(WTIER[p.wep.id]||0)&&found.qRank>(p.wep.qRank===undefined?1:p.wep.qRank);
'@ @'
      // v21.63, HIS NOTE (2026-10-09): "i picked up a scav pistol and it replaced the better gun in slot 1 -- this should never happen".
      // A found gun was weighed against the gun in your hands alone, so holding Bare Hands in one slot a Scav Pistol counted as better
      // and was put in your hands while a far better gun sat in the other slot. It is weighed against the best gun you carry in either
      // slot now: a gun takes a slot by itself only when it beats both; anything else goes into the backpack.
      var _bestT=Math.max(WTIER[p.wep.id]||0,(p.sec&&p.sec.mag!==0)?(WTIER[p.sec.id]||0):0);
      var tierUp=(WTIER[itm.gk]||0)>_bestT;
      var condUp=(WTIER[itm.gk]||0)===_bestT&&(WTIER[itm.gk]||0)===(WTIER[p.wep.id]||0)&&found.qRank>(p.wep.qRank===undefined?1:p.wep.qRank);
'@

SubRx @'
var VER='21.62';
'@ @'
var VER='21.63';
'@

$pat = "(?m)^  now:'v21\.62:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.63: A gun you pick up only takes a slot when it is better than both your guns; otherwise it goes in the backpack. Check 21.63 fails on v21.62',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
