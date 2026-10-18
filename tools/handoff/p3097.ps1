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

# OPERATOR CARD DROPS THE EMPTY RUN COUNT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
d.textContent='Tonight: '+n+' run'+(n===1?'':'s')+(arcadePartyCode()?'  \u00b7  Seed '+arcadePartyCode():''); d.style.cssText='font:600 var(--fs-label)/1.3 var(--f-cond);letter-spacing:var(--track);color:var(--tx-2);margin:var(--sp-1) 0 var(--sp-2)';
'@ @'
var _sp=[]; if(n>0) _sp.push('Tonight: '+n+' run'+(n===1?'':'s')); if(arcadePartyCode()) _sp.push('Seed '+arcadePartyCode()); d.textContent=_sp.join('  \u00b7  '); d.style.cssText=_sp.length?'font:600 var(--fs-label)/1.3 var(--f-cond);letter-spacing:var(--track);color:var(--tx-2);margin:var(--sp-1) 0 var(--sp-2)':'height:var(--sp-2)';   /* v30.xx (cw-opclean) critic 62 (3 of 5): "tonight: 0 runs" is noise on a card whose job is two actions. The line shows only when there is a run to count or a seed to read */
'@

SubRx @'
box-shadow:0 0 0 2px var(--ui-panel),0 0 0 4px var(--tx-1);
'@ @'
box-shadow:0 0 0 2px var(--ui-panel),0 0 0 4px var(--acc);
'@

SubRx @'
var VER='30.96';
'@ @'
var VER='30.97';
'@

$pat = "(?m)^  now:'v30\.96:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v30.97: The operator card shows no run count until there is one; the focus ring is amber. Check 30.97 fails on v30.96',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
