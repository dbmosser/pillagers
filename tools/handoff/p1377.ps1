$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# DOWNED AND EXTRACTION AUDIT OF 2026-09-14, finding 7: THE ABANDONED CARD SAID YOUR STALL MONEY
# WAS LOST WHERE YOU FELL. The line for stall money not carried out is shared by a death and an
# abandon, so a run he walked away from from the pause box told him he fell. A death still says
# it; an abandon says the money was left behind.
SubRx @'
      :'<span style="color:var(--rust)">Stall money lost where you fell: '+'$'+(G.pedCarry||0).toLocaleString()+'.</span>');
'@ @'
      :(how==='dead'
        ?'<span style="color:var(--rust)">Stall money lost where you fell: '+'$'+(G.pedCarry||0).toLocaleString()+'.</span>'
        // v13.77, downed and extraction audit: an abandoned run did not fall anywhere.
        :'<span style="color:var(--rust)">Stall money left behind: '+'$'+(G.pedCarry||0).toLocaleString()+'.</span>'));
'@
SubRx @'
var VER='13.76';
'@ @'
var VER='13.77';
'@

$pat = "(?m)^  now:'v13\.76:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.77: AN ABANDONED RUN DOES NOT SAY YOU FELL. Downed and extraction audit of 2026-09-14, finding 7: the stall money line for a run that did not extract was shared by a death and an abandon, so an abandoned run read Stall money lost where you fell. A death keeps that line; an abandon now reads Stall money left behind. Check 13.77 abandons a run a minute in with stall money carried and requires the card to say left behind and not where you fell, with a death saying where you fell as the control; it fails on v13.76',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
