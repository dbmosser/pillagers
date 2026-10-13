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

# THE KEYS LIST READS LIKE SETTINGS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  .ui-key.pill{ border-radius:12px; padding:0 9px; }
'@ @'
  .ui-key.pill{ border-radius:12px; padding:0 9px; }
  /* vNN.xx, UI REDESIGN ui5q1w (his #50, from the visual QA of the Keys window): THE KEYS LIST READS LIKE SETTINGS. The list ran the
     whole width of the window, lower case action names at the left edge and plain boxes at the right, nearly 1900px apart. It is a
     1100px list on the left edge now, the action names in the 18px condensed caps of the Settings rows (the words are unchanged), and
     every key is a keycap: a key with a lip, as on the title, the stash and the pause box. A key changed from its default stays amber. */
  #root #keyslist{ max-width:1100px; width:100%; max-height:none !important; flex:1 1 auto; min-height:0; }
  #root #keysmodal > .pbox{ margin-top:auto !important; padding-top:12px; border-top:1px solid var(--ui-line); width:100%; }
  #root #keyslist .row{ min-height:56px; padding:6px 16px; }
  #root #keyslist .row b{ font-family:var(--f-cond); font-weight:600; font-size:18px; letter-spacing:.06em; text-transform:uppercase; color:var(--tx-1); }
  #root #keyslist .keybtn{ min-width:120px !important; min-height:40px; border:1px solid var(--tx-1); border-bottom-width:3px; border-radius:4px;
    background:rgba(0,0,0,.35); font-family:var(--f-cond); font-weight:700; font-size:16px; letter-spacing:.06em; }
  #root #keyslist .keybtn:hover:not(:disabled){ border-color:var(--acc); background:var(--ui-hover); }
'@

SubRx @'
var VER='24.86';
'@ @'
var VER='24.87';
'@

$pat = "(?m)^  now:'v24\.86:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v24.87: The Keys window is a tidy list with the keys drawn as keycaps. Check 24.87 fails on v24.86',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
