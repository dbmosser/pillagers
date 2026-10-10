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

# A BLOCKED THROW SAYS SO IN A HEADLINE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(blocked&&rngT<(tk==='frag'?(CFG.fragR===undefined?190:CFG.fragR):110)) say(tk==='frag'?'It hit cover. MOVE.':'It hit cover, dropped short.');   // v12.20: the warning covers the whole blast
'@ @'
  // v21.85, the raid text rewrite, his order of 2026-10-09 (raid lines read like a shooter HUD): the throw that stops on cover says
  // so in a headline. A frag stopped short is a warn, GRENADE HIT COVER, his cookShout word for a thrown Frag Charge; a smoke or a
  // decoy stopped short is THROW BLOCKED. No advice and no explaining detail: the headline is the whole message.
  if(blocked&&rngT<(tk==='frag'?(CFG.fragR===undefined?190:CFG.fragR):110)){ if(tk==='frag') say('GRENADE HIT COVER','warn'); else say('THROW BLOCKED','info'); }   // v12.20: the warning covers the whole blast
'@

SubRx @'
var VER='21.84';
'@ @'
var VER='21.85';
'@

$pat = "(?m)^  now:'v21\.84:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.85: A grenade stopped short by cover says GRENADE HIT COVER and a smoke or decoy says THROW BLOCKED. Check 21.85 fails on v21.84',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
