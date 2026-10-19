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

# STASH TYPE FLOOR 16PX AND $ GOING UP (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
#root #kitsetup .ksnote{ display:none; }
'@ @'
#root #kitsetup .ksnote{ display:none; }
/* v28.xx (cw-uc-stash) b-31 step 7, stash (screen 04): the style guide keeps a 16px type floor, and the stash labels, tabs, counts, key bar, hint lines and the sell note were 14.2px, which the 0.92 stash scale brings to 13px. They are 17.4px now (16px painted). The loadout head said "0c going up", the old credits letter; money is $ (his Q59), so it reads "$0 going up". */
#root #hub .brand, #root #hub #verlabel, #root #hub #reptop, #root #hub #stashsort, #root #hub .lohead, #root #hub #invcols em,
#root #hub #kitcol em, #root #hub #kitcol b, #root #hub .cell .cnt, #root #hub .loslab, #root #hub #invkeybar kbd, #root #hub #invkeybar div,
#root #hub #stashdetail span, #root #hub #sellhint, #root #hub #nextunlock, #root #hub #firstkit, #root #hub #sellall, #root #hub #stashsearch,
#root #hub #hotplanwrap span, #root #hubfreekit b, #root #hubfreekit span, #root #hub [style*="font-size:13px"]{ font-size:17.4px !important; }
#root #hub #stashtabs .invtab{ font-size:17.4px !important; }
'@

SubRx @'
<div class="lohead">LOADOUT<em><span id="kitval">0</span>c going up</em></div>
'@ @'
<div class="lohead">LOADOUT<em>$<span id="kitval">0</span> going up</em></div>
'@

SubRx @'
var VER='31.65';
'@ @'
var VER='31.66';
'@

$pat = "(?m)^  now:'v31\.65:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.66: The stash text is 16px or more and the loadout head says $ going up. Check 31.66 fails on v31.65',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
