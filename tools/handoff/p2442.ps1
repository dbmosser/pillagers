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

# THE GAMBLE IS THE BUTTON (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  .ui-key.pill{ border-radius:12px; padding:0 9px; }
'@ @'
  .ui-key.pill{ border-radius:12px; padding:0 9px; }
  /* vNN.xx, UI REDESIGN ui5q1m (his #50, from the AAA judge of the Wirt shot): THE GAMBLE IS THE BUTTON. GAMBLE and BUY were small
     outline buttons with 12px labels, greyed to ghosts when the credits fall short, so the main action of the window was its weakest
     element. GAMBLE is a full width 48px amber primary now and the offer BUY a 48px button; when the credits fall short both read as
     solid greyed buttons with words in the second text colour. No word changed. */
  #root #gamblebtn{ flex:1; min-height:48px; padding:0 22px !important; font-size:17px; font-weight:700; letter-spacing:.12em; text-transform:uppercase;
    background:var(--acc); border-color:var(--acc) !important; color:var(--acc-ink) !important; }
  #root #gamblebtn:hover:not(:disabled){ background:#f7c25a; border-color:#f7c25a !important; }
  #root #gamblebtn:disabled, #root #wirtlot button:disabled{ background:var(--ui-hover); border-color:var(--ui-line-hi) !important; color:var(--tx-2) !important; }
  #root #wirtlot button{ min-height:48px; min-width:180px; font-size:16px; font-weight:700; letter-spacing:.1em; }
'@

SubRx @'
var VER='24.41';
'@ @'
var VER='24.42';
'@

$pat = "(?m)^  now:'v24\.41:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v24.42: At Wirt, GAMBLE is a big full width button and BUY is bigger. Check 24.42 fails on v24.41',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
