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

# Corner readout: $ money, no credits label (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  el.innerHTML=c+' <small>CREDITS</small> '+x+' <small>XP</small> <span class="trsub">
'@ @'
  el.innerHTML='$'+c+'<span class="trgap"></span>'+x+' <small>XP</small> <span class="trsub">
'@

SubRx @'
  #topright small:nth-last-child(2){ margin-right:24px; }
'@ @'
  #topright small:nth-last-child(2){ margin-right:24px; }
  /* v28.xx (cw-uc-trdollar) b-31 step 7, critic on 10, 11, 15 (P1 "900 credits mixes $ and credits"): the corner readout says $900 (his Q59: $ for money), no credits label, 24px before the xp pair. */
  #topright .trgap{ display:inline-block; width:24px; }
'@

SubRx @'
var VER='32.49';
'@ @'
var VER='32.50';
'@

$pat = "(?m)^  now:'v32\.49:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.50: The top right readout shows $900 and no longer the word credits. Check 32.50 fails on v32.49',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
