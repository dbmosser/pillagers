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

# BACKPACK TILES SHARE ONE BORDER, RARITY IS A BAR (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var hh=LH(244)*BZ+rows
'@ @'
var hh=LH(226)*BZ+rows
'@

SubRx @'
if(_bf){ ctx.fillStyle=_bf; ctx.fillRect(tx,ty,TILE,TILE); }
'@ @'
if(it){ ctx.fillStyle=RCOL[dispR(stacks[si].key)]||'#4a5257'; ctx.fillRect(tx+1,ty+TILE-4,TILE-2,3); }   // v28.xx (cw-bagpolish3), the critic (2026-10-20): every tile gets the same 1px line and rarity is only a 3 px bar at the foot (style guide: rarity as a bar), not a tinted fill and a coloured border
'@

SubRx @'
(RCOL[it?dispR(stacks[si].key):null]||'#4a5257');
'@ @'
'#4a5257';
'@

SubRx @'
var VER='32.80';
'@ @'
var VER='32.81';
'@

$pat = "(?m)^  now:'v32\.80:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.81: Backpack tiles have one border colour with a rarity bar, and the panel is trimmed to its content. Check 32.81 fails on v32.80',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
