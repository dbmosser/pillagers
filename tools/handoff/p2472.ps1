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

# THE PAUSE BOX HAS A PRIMARY (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  .ui-key.pill{ border-radius:12px; padding:0 9px; }
'@ @'
  .ui-key.pill{ border-radius:12px; padding:0 9px; }
  /* vNN.xx, UI REDESIGN ui5q1f (his #50, from the AAA judge of the raid pause shot): THE PAUSE BOX HAS A PRIMARY. RESUME RUN was an
     outline button like SETTINGS and the only coloured button was ABANDON RUN, so the eye went to the button that throws the run
     away; the buttons were 40px with 12px labels and the key legend was four lines of 13px words with bold key names. RESUME is the
     amber primary now, every button is 48px with a 16px label, and the legend draws each key as a keycap (the title and the stash
     key bars, ui7) at 15px. No word changed, the order is the same, and the arrows and the pad walk it as before (v24.15). */
  #root #pausekeys{ font-size:15px !important; line-height:2.1 !important; color:var(--tx-2) !important; }
  #root #pausekeys b{ display:inline-flex; align-items:center; justify-content:center; min-width:24px; height:24px; padding:0 6px; margin-right:3px;
    box-sizing:border-box; border:1px solid var(--tx-1); border-bottom-width:2px; border-radius:3px; background:rgba(0,0,0,.35); color:var(--tx-1) !important;
    font-family:var(--f-cond); font-weight:700; font-size:13px; line-height:1; letter-spacing:.04em; text-transform:uppercase; vertical-align:middle; }
  #root #pausebox > div:has(> #resumebtn){ gap:10px !important; margin-top:8px; }
  #root #pausebox #resumebtn, #root #pausebox #pausesetbtn, #root #pausebox #abandonbtn, #root #pausebox #confirmabandon,
  #root #pausebox #charselbtn, #root #pausebox #arcendbtn{ min-height:48px; padding:0 26px !important; font-size:16px; font-weight:700; letter-spacing:.1em; text-transform:uppercase; }
  #root #pausebox #resumebtn{ min-width:220px; background:var(--acc); border-color:var(--acc); color:var(--acc-ink); }
  #root #pausebox #resumebtn:hover:not(:disabled){ background:#f7c25a; border-color:#f7c25a; color:var(--acc-ink); }
'@

SubRx @'
var VER='24.71';
'@ @'
var VER='24.72';
'@

$pat = "(?m)^  now:'v24\.71:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v24.72: In the pause box RESUME RUN is the big amber button and the key list shows keycaps. Check 24.72 fails on v24.71',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
