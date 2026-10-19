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

# OPERATOR CARD: ONE FRAME, 40PX X, READABLE CONFIRM (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
top:var(--sp-3);right:var(--sp-3);width:var(--btn-h-sm);height:var(--btn-h-sm);padding:0;display:flex;align-items:center;justify-content:center;background:transparent;color:var(--tx-1)
'@ @'
/* v31.xx (cw-partylook9), critic on 62 and 63 (3 of 5): the 48px X was heavier than the 32px title and its centre sat 4px off the title. 40px, centred on the title line, right edge on the 32px content edge. */top:calc(var(--sp-4) - 2px);right:var(--sp-4);width:var(--btn-h-xs);height:var(--btn-h-xs);padding:0;display:flex;align-items:center;justify-content:center;background:transparent;color:var(--tx-1)
'@

SubRx @'
fg=red?'var(--danger)':'var(--tx-1)';
'@ @'
fg=(red&&ex)?'var(--danger)':'var(--tx-1)';   /* v31.xx (cw-partylook9) critic 63 (3 of 5): red text on the maroon fill was only about 3.5 to 4 to 1. The armed confirm keeps the danger fill and border but reads in tx-1, with the lime focus bar every other row has. Exit demo stays red while focused. */
'@

SubRx @'
(on?(red?'var(--danger)':'var(--acc)'):bc))+';'+
'@ @'
(on?((red&&ex)?'var(--danger)':'var(--acc)'):bc))+';'+
'@

SubRx @'
((i===0&&!ARCOP.arm&&on)?'box-shadow:0 0 0 2px var(--ui-panel),0 0 0 4px var(--acc);':'');
'@ @'
'';   /* v31.xx (cw-partylook9) critic 62 (3 of 5): the lime fill plus a 2px ring and glow was a double frame. One treatment: the fill. */
'@

SubRx @'
var VER='31.81';
'@ @'
var VER='31.82';
'@

$pat = "(?m)^  now:'v31\.81:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.82: The operator card has one frame on the lime row, a lighter 40px X, and the armed confirm is readable. Check 31.82 fails on v31.81',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
