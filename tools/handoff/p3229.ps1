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

# THE PICKED WHEEL WEDGE IS RAISED GREY, NOT OLIVE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function drawWheel(){

'@ @'
// v32.xx (cw-wheelwedge), the critic on screen 61: the picked wedge was a muddy olive fill with a lime border, a second colour system. It is now a raised neutral grey
// (lighter than the idle wedges) and the accent shows only as the edge and the inner arc.
function wheelFill(on,hv){
  if(on) return ['rgba(62,67,72,.97)','rgba(44,48,52,.97)'];
  if(hv) return ['rgba(44,48,52,.92)','rgba(28,31,34,.92)'];
  return ['rgba(34,38,41,.92)','rgba(20,23,25,.92)'];
}
function drawWheel(){

'@

SubRx @'
    if(on){ gr.addColorStop(0,'rgba(86,66,26,.96)'); gr.addColorStop(1,'rgba(52,40,16,.96)'); }
    else if(hv){ gr.addColorStop(0,'rgba(44,48,52,.92)'); gr.addColorStop(1,'rgba(28,31,34,.92)'); }
    else { gr.addColorStop(0,'rgba(34,38,41,.92)'); gr.addColorStop(1,'rgba(20,23,25,.92)'); }

'@ @'
    gr.addColorStop(0,wheelFill(on,hv)[0]); gr.addColorStop(1,wheelFill(on,hv)[1]);   // v32.xx (cw-wheelwedge)

'@

SubRx @'
var VER='32.28';
'@ @'
var VER='32.29';
'@

$pat = "(?m)^  now:'v32\.28:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.29: The item wheel picked wedge is a raised neutral grey with the accent edge, no olive fill. Check 32.29 fails on v32.28',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
