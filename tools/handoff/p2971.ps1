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

# Undercroft lines go quiet (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  #root .vdet .vbuy{ min-height:56px; font-size:20px; letter-spacing:.06em; }
  #root .vdet .vbuy:disabled:not(.padfocus){ background:var(--ui-hover); color:var(--tx-3) !important; border-color:var(--ui-line) !important; }
'@ @'
  #root .vdet .vbuy{ min-height:56px; font-size:20px; letter-spacing:.06em; }
  #root .vdet .vbuy:disabled:not(.padfocus){ background:var(--ui-hover); color:var(--tx-3) !important; border-color:var(--ui-line) !important; }
  /* v28.xx (cw-undercroft2), UI STEP 7 (his bar: "style consistency across menus"; critic on 08 and 12): amber is for focus only, so the
     credits and reputation lines under the Undercroft tabs go tx-2 at the 16px body floor; the hint lines and contract rows rise
     from 13.5 and 13 to 16 and 14; the picked contract row loses its full amber outline (the 3px amber bar stays) and sits on the
     raised fill; the stat bars are tx-2, 4px, so the rule under each stat no longer outshouts its number. Colours and sizes only. */
  #root #tradermodal .msub, #root #opmodal .msub, #root #gamblemodal .msub, #root #barmodal .msub{ font-size:16px; line-height:1.5; }
  #root #repline, #root #wallet_work, #root #wallet_merc, #root #wallet_gamble, #root #wallet_bar{ color:var(--tx-2) !important; font-weight:400 !important; }
  #root #tradermodal .hint, #root #opmodal .hint{ font-size:16px; line-height:1.5; }
  #root .crow .cd{ color:var(--tx-1); }
  #root .crow .cd > span{ font-size:14px !important; }
  #root .crow .cd > div{ color:var(--tx-2) !important; font-size:16px !important; }
  #root .crow .cp{ color:var(--tx-2); font-size:16px; }
  #root .crow .cp b{ color:var(--tx-1); font-weight:700; }
  #root .crow.sel{ background:var(--ui-raised); border-color:transparent !important; border-bottom-color:var(--ui-line) !important; }
  #root .vdet .vbar{ height:4px; }
  #root .vdet .vbar i{ background:var(--tx-2); }
'@

SubRx @'
var VER='29.70';
'@ @'
var VER='29.71';
'@

$pat = "(?m)^  now:'v29\.70:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.71: The shop, craft and Mainframe lines are quieter and easier to read. Check 29.71 fails on v29.70',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
