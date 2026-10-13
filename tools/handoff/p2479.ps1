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

# THE DRINKS READ AS A MENU (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  .ui-key.pill{ border-radius:12px; padding:0 9px; }
'@ @'
  .ui-key.pill{ border-radius:12px; padding:0 9px; }
  /* vNN.xx, UI REDESIGN ui5q1o (his #50, from the AAA judge of the Last Pour shot): THE DRINKS READ AS A MENU. Each drink was a line
     of body text with a small 40px INGEST box and its price floating apart from it. The name is 20px condensed caps now (the words
     are not changed, only drawn in caps), the price is large and sits against a 48px amber INGEST, and out of reach INGEST is a solid
     greyed button whose words can be read. */
  #root #barmodal .plist .row{ min-height:84px; gap:16px; }
  #root #barmodal .plist .row b{ font-family:var(--f-cond); font-size:20px; font-weight:700; letter-spacing:.05em; text-transform:uppercase; }
  #root #barmodal .plist .row .vl{ font-family:var(--f-cond); font-size:22px; font-weight:700; min-width:72px; text-align:right; }
  #root #barmodal button[data-bz]{ min-height:48px; min-width:170px !important; font-size:17px; font-weight:700; letter-spacing:.12em;
    background:var(--acc); border-color:var(--acc); color:var(--acc-ink); }
  #root #barmodal button[data-bz]:hover:not(:disabled){ background:#f7c25a; border-color:#f7c25a; color:var(--acc-ink); }
  #root #barmodal button[data-bz]:disabled{ background:var(--ui-hover); border-color:var(--ui-line-hi) !important; color:var(--tx-2) !important; }
'@

SubRx @'
var VER='24.78';
'@ @'
var VER='24.79';
'@

$pat = "(?m)^  now:'v24\.78:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v24.79: At the Last Pour the drink names and prices are bigger and INGEST is a big amber button. Check 24.79 fails on v24.78',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
