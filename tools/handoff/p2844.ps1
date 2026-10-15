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

# NO FREE CONVOY CRATE WHEN THE HOST LEAVES (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  for(_i=G.ents.length-1;_i>=0;_i--){ _e=G.ents[_i]; if(_e&&_e.net){ if(_e.name===BOSS_NAME) _boss=_e; G.ents.splice(_i,1); } }
'@ @'
  if(G.flow&&G.flow.ev&&G.flow.ev.live) for(_i=0;_i<G.flow.ev.live.length;_i++){ _e=G.flow.ev.live[_i]; if(_e&&_e.d&&!_e.d.over&&((_e.id==='convoy'&&_e.d.car&&_e.d.car.net)||(_e.id==='bounty'&&_e.d.e&&_e.d.e.net)||(_e.id==='rampage'&&_e.d.b&&_e.d.b.net))) _e.d.over=1; }   // v28.44 (cloud-cloud-coop-takeover-no-free-event), CLOUD HUNT 2026-10-15: a live convoy, bounty or rampage whose body came only in host words ends here quietly, since that body is let go just below
  for(_i=G.ents.length-1;_i>=0;_i--){ _e=G.ents[_i]; if(_e&&_e.net){ if(_e.name===BOSS_NAME) _boss=_e; G.ents.splice(_i,1); } }
'@

SubRx @'
var VER='28.43';
'@ @'
var VER='28.44';
'@

$pat = "(?m)^  now:'v28\.43:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.44: If your host leaves while a machine convoy, a bounty pillager or an Overseer rampage is live, that event just ends for you instead of dropping a crate nobody earned or calling a line that is not true. Check 28.44 fails on v28.43',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
