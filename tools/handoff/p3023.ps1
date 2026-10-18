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

# MODAL CARDS LOSE THE CHAMFER TICK (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
#root #pausebox::after{ content:'Esc  Resume'; font:600 var(--fs-label)/1 var(--f-cond); letter-spacing:var(--track); color:var(--tx-2); margin-top:var(--sp-1); }
'@ @'
#root #pausebox::after{ content:'Esc  Resume'; font:600 var(--fs-label)/1 var(--f-cond); letter-spacing:var(--track); color:var(--tx-2); margin-top:var(--sp-1); }
/* v28.xx (cw-modalflat) critic 49 (pause card, 3 of 5): "chamfered top-left corner with a one-off tick, the guide says no corner tick and a 4px radius, a 2px tab 36px wide", "the gap before End run is 40, off the grid". Now every modal card and the pause card are a plain 4px rectangle with a 1px line, the accent tab is 36 x 2 (the arcade cards share the 36 wide tab), and End run sits 48 below Feedback */
#root .modal::before, #root #pausebox::before{ border-radius:var(--rad); clip-path:none;
  background:linear-gradient(var(--acc),var(--acc)) var(--sp-3) 0/calc(var(--sp-1) * 4.5) 2px no-repeat,
    var(--ui-grain) 0 0/128px 128px repeat, var(--ui-bg); background-origin:border-box; }
body #attract .arcpage::before, body #attract .arcover::before{ width:calc(var(--sp-1) * 4.5 * var(--attz,1)); }
#root #pausebox #abandonbtn, #root #pausebox #arcendbtn, #root #pausebox #charselbtn{ margin-top:var(--sp-4); }
'@

SubRx @'
var VER='30.22';
'@ @'
var VER='30.23';
'@

$pat = "(?m)^  now:'v30\.22:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v30.23: Cards are a plain rectangle with a short accent tab and no cut corner. Check 30.23 fails on v30.22',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
