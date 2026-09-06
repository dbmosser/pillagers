$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
# v11.73, second cut. Adding pname to the default literal is right but it cannot
# be PROVEN by the harness: __cleanProfile rebuilds the profile through the
# loader, and the loader is exactly what hands out a name, so the never-saved
# state is unreachable from a check and the control passed on the old build.
# The observable guarantee is the line that PRINTS the name, so that line gets
# the same fallback every other reader of P.pname already has (restoreMake at
# 30403 uses it). Now the defect can be reproduced by taking the name off a live
# profile, which is the state a first-time player is in.
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(60,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

SubRx @'
        ? (P.pname+'  \u00b7  '+P.runs+' raid'+(P.runs===1?'':'s')+' logged  \u00b7  '+'$'+P.credits.toLocaleString()+' banked')
'@ @'
        // v11.73: the same fallback every other reader of the name already has.
        // The default is born set now, but this is the line a player SEES, and
        // a name is not something to print raw.
        ? ((P.pname||'PILLAGER')+'  \u00b7  '+P.runs+' raid'+(P.runs===1?'':'s')+' logged  \u00b7  '+'$'+P.credits.toLocaleString()+' banked')
'@

if ($n -ne 1) { throw "expected 1 edit, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edit applied to the game"

# the same edit into the v11.73 draft, so it reproduces
$f = 'C:\claudecode\dark raiders\tools\handoff\p1173.ps1'
$t = [IO.File]::ReadAllText($f)
$anchor = "# STAMPS."
$block = @"
# AND THE LINE THAT PRINTS IT. The default is born set above, but the character
# screen is what a player reads, and every other reader of the name already
# falls back. This is also the only part of the defect a check can observe,
# since the harness rebuilds profiles through the loader.
SubRx @'
        ? (P.pname+'  \u00b7  '+P.runs+' raid'+(P.runs===1?'':'s')+' logged  \u00b7  '+'`$'+P.credits.toLocaleString()+' banked')
'@ @'
        // v11.73: the same fallback every other reader of the name already has.
        // The default is born set now, but this is the line a player SEES, and
        // a name is not something to print raw.
        ? ((P.pname||'PILLAGER')+'  \u00b7  '+P.runs+' raid'+(P.runs===1?'':'s')+' logged  \u00b7  '+'`$'+P.credits.toLocaleString()+' banked')
'@

# STAMPS.
"@
if ($t.IndexOf($anchor) -lt 0) { throw "no STAMPS anchor in p1173" }
$t = $t.Replace($anchor, $block)
[IO.File]::WriteAllText($f, $t, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, draft p1173 carries the same edit"
