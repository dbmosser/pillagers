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

# RELOAD DONE ALWAYS SOUNDS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
      if(!G.sim){ if(fx) rlfxPlay(1); else blipMine('reloadin'); }   // v10.56: the bolt goes home; v25.52: the last step of the gun (the rack only when it was empty)
'@ @'
      // v25.xx (reloaddone), HIS ORDER 2026-10-13: "'reload done' needs a sound always". v25.52 gave each gun its own steps and played the
      // last one (the rack, the pump, the bolt) only when the gun was EMPTY, so a reload with a round still chambered finished in
      // silence on every gun. Now the short click and thud of v10.56 (reloadin, on the gun bus, quiet under gunfire) plays on EVERY
      // finished reload, tactical or empty, every gun class, after the gun's own last step. A reload cut short (a swap, a roll, a
      // sprint, going down) never gets here, so it plays nothing. Cosmetic only: no seeded draw, nothing under G.sim.
      if(!G.sim){ if(fx) rlfxPlay(1); blipMine('reloadin'); }   // v10.56: the bolt goes home; v25.52: the last step of the gun; reloaddone: and always the done cue
'@

SubRx @'
var VER='25.62';
'@ @'
var VER='25.63';
'@

$pat = "(?m)^  now:'v25\.62:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v25.63: Every finished reload now ends with a short click and thud, tactical or empty. Check 25.63 fails on v25.62',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
