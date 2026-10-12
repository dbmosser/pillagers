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

# NO FAINT WORDS IN THE STATION WINDOWS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
<div style="font-size:13px;letter-spacing:.14em;color:var(--steel-hi);font-weight:700;margin-bottom:6px">THE GAMBLE</div>
'@ @'
<div style="font-size:13px;letter-spacing:.14em;color:var(--tx-2);font-weight:700;margin-bottom:6px">THE GAMBLE</div>
'@

SubRx @'
tb.style.cssText='color:'+TT.c+';font-weight:700;font-size:12.5px;letter-spacing:.06em;margin-right:8px';
'@ @'
tb.style.cssText='color:'+TT.c+';font-weight:700;font-size:13px;letter-spacing:.06em;margin-right:8px';   // v24.22 (ui6b): the menu floor is 13px
'@

SubRx @'
H+='<div style="margin:10px 0 4px 0;letter-spacing:2px;opacity:.7;font-size:12px">'+g[1]+'</div>';
'@ @'
H+='<div style="margin:10px 0 4px 0;letter-spacing:.12em;font-size:13px;color:var(--tx-2)">'+g[1]+'</div>';   // v24.22 (ui6b): readable rack heads
'@

SubRx @'
<span style="opacity:.55">'+((typeof netHubSeat
'@ @'
<span style="color:var(--tx-2)">'+((typeof netHubSeat
'@

SubRx @'
.costile.lock{opacity:.42;cursor:not-allowed}
'@ @'
/* v24.22, UI REDESIGN ui6b (his #50): a locked tile dims its picture, never its words, so its name and what unlocks it can be read */
.costile.lock{cursor:not-allowed}
.costile.lock > *{opacity:.42}
.costile.lock .cosname, .costile.lock .cosreq{opacity:1;color:var(--tx-2)}
'@

SubRx @'
.cosreq{margin-top:2px;font-size:13px;opacity:.65;letter-spacing:1px;text-transform:uppercase}
'@ @'
.cosreq{margin-top:2px;font-size:13px;color:var(--tx-2);letter-spacing:.08em;text-transform:uppercase}
'@

SubRx @'
var VER='24.21';
'@ @'
var VER='24.22';
'@

$pat = "(?m)^  now:'v24\.21:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v24.22: Words in the station windows are never faint: locked Fashion tiles dim only their picture, and every label is at least 13 pixels. Check 24.22 fails on v24.21',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
