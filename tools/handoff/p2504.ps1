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

# RARITY: GREEN, BLUE, PURPLE, GOLD (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var RCOL={common:'#cfd8ef',uncommon:'#7fc4a0',rare:'#7cc4ff',elite:'#d08ce8',gold:'#ffc72e'};
'@ @'
// 2026-10-12 (rarity), HIS ANSWER 14: rarity colours "green blue purple gold". There were two tables: this one (pale mint, sky blue,
// orchid) for the world, the loot rows and the belt, and the menu tokens (--r-* and UIC.r_*, a stronger green, blue and purple, and
// an ORANGE gold) for the menus, so the same item changed colour between the raid and the stash and the top tier read orange. One
// set now: common grey, uncommon green, rare blue, elite purple, gold gold, the same five in this table, in UIC and in the stylesheet.
// Gold stays #ffc72e, the gold every gun of tier 5 has worn since v7.99.
var RCOL={common:'#9da3a8',uncommon:'#5fbf6a',rare:'#3f9de9',elite:'#a866e0',gold:'#ffc72e'};
'@

SubRx @'
    --r-common:#9da3a8; --r-uncommon:#5fbf6a; --r-rare:#3f9de9; --r-elite:#a866e0; --r-gold:#f08f2e;
'@ @'
    --r-common:#9da3a8; --r-uncommon:#5fbf6a; --r-rare:#3f9de9; --r-elite:#a866e0; --r-gold:#ffc72e;
'@

SubRx @'
  .cell.c-gold{ border-color:var(--r-gold); box-shadow:inset 0 0 10px rgba(240,143,46,.30); }
'@ @'
  .cell.c-gold{ border-color:var(--r-gold); box-shadow:inset 0 0 10px rgba(255,199,46,.30); }
'@

SubRx @'
  r_common:'#9da3a8', r_uncommon:'#5fbf6a', r_rare:'#3f9de9', r_elite:'#a866e0', r_gold:'#f08f2e'};
'@ @'
  r_common:'#9da3a8', r_uncommon:'#5fbf6a', r_rare:'#3f9de9', r_elite:'#a866e0', r_gold:'#ffc72e'};   // 2026-10-12 (rarity): gold is gold, as RCOL
'@

SubRx @'
          (_wt>=5?'#ffc72e':_wt>=4?'#d08ce8':_wt===3?'#7cc4ff':_wt===2?'#7fc4a0':'#cfd8ef'));
'@ @'
          (_wt>=5?RCOL.gold:_wt>=4?RCOL.elite:_wt===3?RCOL.rare:_wt===2?RCOL.uncommon:RCOL.common));   // 2026-10-12 (rarity): the one table
'@

SubRx @'
var VER='25.03';
'@ @'
var VER='25.04';
'@

$pat = "(?m)^  now:'v25\.03:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v25.04: Rarity colours are now the same everywhere: green, blue, purple and gold, with common items grey. Check 25.04 fails on v25.03',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
