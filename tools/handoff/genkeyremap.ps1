$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
# Turns parked/keyremap-plan.txt (the read-only remap workflow) into two data-driven
# builds, v13.45 (TAB does what Escape does) and v13.46 (B and I open the backpack, O
# orders the hire). Applies the review corrections to build 1 edits 4, 7 and 8,
# renumbers 13.42 to 13.45 and 13.43 to 13.46, re-anchors the version lines on the
# builds that ship first, and inserts each new check above the newest check.
$h = 'C:\claudecode\dark raiders\tools\handoff'
$j = [IO.File]::ReadAllText("$h\parked\keyremap-plan.txt") | ConvertFrom-Json
$r = $j.result; if ($r -is [string]) { $r = $r | ConvertFrom-Json }
function RenV([string]$s) { return $s.Replace('13.43', '13.46').Replace('13.42', '13.45') }
function Clean([string]$s) { return (($s -replace "[`r`n]+", ' ') -replace "['`"\\$]", '').Trim() }

$tags = @('1345', '1346'); $prevNow = @('13\.44', '13\.45')
$anchor = @("  {v:'13.44',what:'searching a box that finishes an open contract", "  {v:'13.45',what:'TAB does what Escape does")
for ($bi = 0; $bi -lt 2; $bi++) {
  $b = $r.plan.builds[$bi]; $tag = $tags[$bi]; $ver = '13.' + $tag.Substring(2)
  $edits = @()
  for ($k = 0; $k -lt $b.edits.Count; $k++) {
    $e = $b.edits[$k]
    $old = RenV ([string]$e.old_verbatim); $new = RenV ([string]$e.new_text)
    if ($bi -eq 0 -and $k -eq 0) { $old = "var VER='13.44';"; $new = "var VER='13.45';" }
    if ($bi -eq 0 -and $k -eq 1) { $old = "var WHATSNEW_VER='13.43';"; $new = "var WHATSNEW_VER='13.45';" }
    if ($bi -eq 0 -and $k -eq 3) { $new = $old.Substring(0, $old.IndexOf('Only')) + "Only P, TAB and ESC answer while it is up.'," }
    if ($bi -eq 0 -and $k -eq 6) { $new = "F is your melee strike, I opens the backpack, 1 to 9 is the tactical belt.'," }
    if ($bi -eq 0 -and $k -eq 7) { $new = '1-9 tactical belt &nbsp; I backpack &nbsp; ENTER equip from backpack &nbsp; M map &nbsp; H controls &nbsp; TAB back out &nbsp; P / TAB pause</div>' }
    $kind = 'h'; if ([string]$e.file -like '*mkfixture*') { $kind = 'f' }
    $edits += [pscustomobject]@{ kind = $kind; old = $old; new = $new }
  }
  $cb = (RenV ([string]$b.check_body)) -replace "`r?`n", "`r`n"
  if (-not $cb.EndsWith("`r`n")) { $cb += "`r`n" }
  $edits += [pscustomobject]@{ kind = 'f'; old = $anchor[$bi]; new = $cb + $anchor[$bi] }
  $title = (RenV ([string]$b.title)) -replace '^v13\.\d\d\s+', ''
  $effect = Clean (RenV ([string]$b.player_effect))
  $nowLine = "  now:'v${ver}: " + $title.ToUpper() + '. ' + $effect + "',"
  $data = [pscustomobject]@{ nowPat = "(?m)^  now:'v" + $prevNow[$bi] + ":.*$"; nowLine = $nowLine; edits = $edits }
  [IO.File]::WriteAllText("$h\km$tag.json", ($data | ConvertTo-Json -Depth 5), (New-Object Text.UTF8Encoding $false))

  $p = @(
    'param([string]$Html=''C:\claudecode\dark raiders\dark_raiders.html'',[string]$Fix=''C:\claudecode\dark raiders\tools\mkfixture.ps1'')',
    '$ErrorActionPreference = ''Stop''',
    'trap { Write-Output "FAILED: $_"; exit 1 }',
    "`$d = [IO.File]::ReadAllText('$h\km$tag.json') | ConvertFrom-Json",
    '$T = @{ h = [IO.File]::ReadAllText($Html); f = [IO.File]::ReadAllText($Fix) }; $n = 0',
    'foreach ($e in $d.edits) {',
    '  $pat = (($e.old -split "`n") | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"',
    '  $c = ([regex]::Matches($T[$e.kind], $pat)).Count',
    '  if ($c -ne 1) { throw "edit $n matched $c times: $($e.old.Substring(0,[Math]::Min(80,$e.old.Length)))" }',
    '  $nv = $e.new; $T[$e.kind] = [regex]::Replace($T[$e.kind], $pat, { param($m) $nv }); $n++',
    '}',
    '$c = ([regex]::Matches($T.h, $d.nowPat)).Count; if ($c -ne 1) { throw "DEVNOW now line matched $c times" }',
    '$nl = $d.nowLine; $T.h = [regex]::Replace($T.h, $d.nowPat, { param($m) $nl })',
    '[IO.File]::WriteAllText($Html, $T.h, (New-Object Text.UTF8Encoding $false))',
    '[IO.File]::WriteAllText($Fix, $T.f, (New-Object Text.UTF8Encoding $false))',
    'Write-Output "OK, $n edits applied plus DEVNOW"'
  )
  [IO.File]::WriteAllText("$h\p$tag.ps1", ($p -join "`r`n"), (New-Object Text.UTF8Encoding $false))
  [IO.File]::WriteAllText("$h\f$tag.ps1", "Write-Output 'OK, 0 edits applied (the check is inserted by p$tag)'", (New-Object Text.UTF8Encoding $false))

  $risk = Clean (RenV ([string]$b.risks)); if ($risk.Length -gt 600) { $risk = $risk.Substring(0, 600) }
  $d = @("## v$ver - " + $title.ToUpper(), '', 'His note of 2026-09-13: on itch, Escape kills fullscreen. Tab does what Escape did in the game; B and I open the backpack. Built under rulebook rule 1 on the default he was asked about: hire orders on O.', '', $effect, '', "Measured: check $ver fails on the previous build and passes on this one. Existing checks that asserted the old keys are repaired in this build.", '', "Not verified: $risk")
  [IO.File]::WriteAllText("$h\d$tag.txt", ($d -join "`n") + "`n", (New-Object Text.UTF8Encoding $false))
  [IO.File]::WriteAllText("$h\a$tag.txt", "| " + $title.ToUpper() + " | v$ver | HIS NOTE 2026-09-13 (Escape kills fullscreen on itch). " + $effect + " MEASURED: check $ver fails on the previous build. NOT VERIFIED: see DESIGN v$ver |`n", (New-Object Text.UTF8Encoding $false))
  [IO.File]::WriteAllText("$h\cm$tag.txt", "v${ver}: " + $title + "`n`nHis note: Escape kills fullscreen on itch. " + $effect.Substring(0, [Math]::Min(500, $effect.Length)) + "`n`nCheck $ver fails on the previous build.`n`nCo-Authored-By: Claude Opus 5 <noreply@anthropic.com>`n", (New-Object Text.UTF8Encoding $false))
  Write-Output "v$ver : $($edits.Count) edits"
}
