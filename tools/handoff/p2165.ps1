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

# RECOVERING SHOWS ONLY WHEN YOU ARE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(p.downed||p.hp>=_top||p.combatT<CFG.regenDelay){ p.regenAcc=0; return; }
  p.regenAcc=(p.regenAcc||0)+dt;
'@ @'
  if(p.downed||p.hp>=_top||p.combatT<CFG.regenDelay){ p.regenAcc=0; return; }
  p.regenAcc=(p.regenAcc||0)+dt;
  p.regenLive=G.t;   // v21.65: the RECOVERING icon shows only while this really runs
'@

SubRx @'
      if(!p.downed&&p.hp>0&&p.hp<top&&(p.combatT||0)>=CFG.regenDelay){ E.on=true;
'@ @'
      // v21.65, HIS NOTE (2026-10-09): "the left hand side says recovering to 85 but i'm not". The icon worked the rule out for itself,
      // so it showed whenever the numbers allowed it, also in moments the regen was not running at all. It now shows only while the regen
      // actually ran in the last half second, so it never says RECOVERING while health stands still.
      if(!p.downed&&p.hp>0&&p.hp<top&&(p.combatT||0)>=CFG.regenDelay&&typeof p.regenLive==='number'&&G.t-p.regenLive<0.5){ E.on=true;
'@

SubRx @'
var VER='21.64';
'@ @'
var VER='21.65';
'@

$pat = "(?m)^  now:'v21\.64:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.65: The RECOVERING icon now shows only while your health is really coming back. Check 21.65 fails on v21.64',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
