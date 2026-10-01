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

# THE OVERSEER BY NAME IN A PARTY (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  var who=(e.kind==='raider'&&e.name)?netClean(e.name,24):String(e.kind||'').toUpperCase();
'@ @'
  var who=((e.kind==='raider'||e.boss)&&e.name)?netClean(e.name,24):String(e.kind||'').toUpperCase();   // v17.56: the boss by its name
'@

SubRx @'
  try{ deathAnimAdd(e); }catch(_dz){}   // v17.47: his pick 29, the death animation in a linked window
'@ @'
  try{ deathAnimAdd(e); }catch(_dz){}   // v17.47: his pick 29, the death animation in a linked window
  if(e&&e.name===BOSS_NAME){ try{ say(BOSS_NAME+' is down. Its hoard is open.'); }catch(_bs){} }   // v17.56: the teammate hears the boss go down, as the host does
'@

SubRx @'
var VER='17.55';
'@ @'
var VER='17.56';
'@

$pat = "(?m)^  now:'v17\.55:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.56: THE OVERSEER in a party: the kill feed names it, and both windows say when it is down and its hoard is open. Check 17.56 fails on v17.55',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
