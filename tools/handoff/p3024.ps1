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

# PARTY BOARD AND OPERATOR CARD CLEAN UP (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
body #attract[style*="block"]:has(.arcover[style*="block"]) .arcover{ min-width:calc(var(--sp-5) * 15 * var(--attz,1)); }
'@ @'
body #attract[style*="block"]:has(.arcover[style*="block"]) .arcover{ min-width:calc(var(--sp-5) * 15 * var(--attz,1)); }
/* v30.xx (cw-partyempty) critic 56 and 64 (2 of 5), the fourth time: "Delete the 5 rows. Show one centred No scores yet in tx-2. Size the card to its content". The five ghost rows stay in the page (a check counts them) but are not drawn; the empty line is one centred 16px tx-2 line and the card shrinks round it */
body #attract .arcpage .apg{ display:none; }
body #attract .arcpage .apn{ text-align:center; padding:var(--sp-3) 0 var(--sp-2); color:var(--tx-2); font-weight:600; }
'@

SubRx @'
'background:'+bg+';color:'+fg+';border:1px solid '+bc+';border-left:3px solid '+(on?(red?'var(--danger)':'var(--acc)'):bc)+';';
'@ @'
'background:'+((i===0&&!ARCOP.arm)?'var(--acc)':(on?(red?'var(--danger-bg)':'var(--ui-hover)'):'transparent'))+';color:'+((i===0&&!ARCOP.arm)?'var(--acc-ink)':fg)+';border:1px solid '+((i===0&&!ARCOP.arm)?'var(--acc)':bc)+';border-left:3px solid '+((i===0&&!ARCOP.arm)?'var(--acc)':(on?(red?'var(--danger)':'var(--acc)'):bc))+';'+((i===0&&!ARCOP.arm&&on)?'box-shadow:0 0 0 2px var(--ui-panel),0 0 0 4px var(--tx-1);':'');   /* v30.xx (cw-partyempty) critic 62 (3 of 5): "no primary action, the focused row nearly matches the idle row". New party is the one amber fill with a ring when focused; Exit demo is a ghost until focused (red only then); the armed confirm stays the red outline */
'@

SubRx @'
var VER='30.23';
'@ @'
var VER='30.24';
'@

$pat = "(?m)^  now:'v30\.23:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v30.24: An empty board is one centred line; the operator card has one amber New party button. Check 30.24 fails on v30.23',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
