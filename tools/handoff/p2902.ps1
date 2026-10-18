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

# A PILLAGER WITH A RARER COPY OF A GUN FIGHTS LIKE ONE WITH THE PLAIN GUN (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  w=(e.wep&&e.wep.id)||''; h=raiderHash(e);
'@ @'
  // v28.xx (cw-roletwin), CLOUD HUNT 2026-10-15: a rarity twin (shotgun_v and the rest) has its own id, so the tests below missed it
  // and the role fell to the hash pick (a twin Shotgun could come out a suppressor). gunBase reads the twin as the gun it is a copy of.
  w=gunBase((e.wep&&e.wep.id)||''); h=raiderHash(e);
'@

SubRx @'
var VER='29.01';
'@ @'
var VER='29.02';
'@

$pat = "(?m)^  now:'v29\.01:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.02: A pillager carrying a rarer copy of a gun now fights the way that guns carrier always does. Check 29.02 fails on v29.01',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
