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

# THE MODE LIST READS FROM THE COUCH (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  .ui-key.pill{ border-radius:12px; padding:0 9px; }
'@ @'
  .ui-key.pill{ border-radius:12px; padding:0 9px; }
  /* vNN.xx, UI REDESIGN ui5q1a (his #50, from the AAA judge of the title shots 01, 44 and 57): THE MODE LIST READS FROM THE COUCH.
     The mode rows were 13px caps in 40px rows, smaller than the old start button; they are 52px rows with 18px labels now, and
     1 PLAYER is the amber primary at 62px and 22px. The two SERVER rows are shorter and carry their COMING LATER tag inside the row
     at its right end, not hanging off the side of the column. A darker band behind the centre of the title keeps the walking
     Undercroft out from behind the key row and the mode list (the sides still show it, v17.83). The SAVES block is a 900px panel and
     not a 1500px web form: the name box, CHANGE NAME and CREATE A NEW SAVE share one row. No word changed and the rows keep their
     order, so the arrows and the pad walk them as before. */
  #root #title.on{ background:radial-gradient(ellipse 75% 85% at 50% 50%, transparent 55%, rgba(6,7,8,.6) 100%),
    linear-gradient(90deg, rgba(17,19,21,.66) 0%, rgba(17,19,21,.9) 26%, rgba(17,19,21,.9) 74%, rgba(17,19,21,.66) 100%); }
  #root #modemenu{ gap:6px; margin-top:14px !important; }
  #root #title .kbrow, #root #title .padrow{ margin-top:14px !important; }
  #root #modemenu button.moderow{ min-width:560px; min-height:52px; padding:0 32px; font-size:18px; font-weight:700; letter-spacing:.1em; }
  #root #modemenu #titlestart{ min-height:62px; padding:0 48px !important; font-size:22px !important; letter-spacing:.12em !important; }
  #root #modemenu .modelater button.moderow{ min-height:40px; font-size:15px; }
  #root #modemenu .modelater span{ left:auto; right:14px; margin-left:0; padding:4px 8px; border:1px solid var(--ui-line); border-radius:2px;
    font-family:var(--f-cond); font-weight:600; font-size:13px; letter-spacing:.12em; color:var(--tx-2); pointer-events:none; }
  #root #slotpanel{ max-width:900px; margin-left:auto; margin-right:auto; }
'@

SubRx @'
        <button class="deploy ghost" id="pnamesave" style="padding:7px 16px">CHANGE NAME</button>
      </div>
      <button class="deploy ghost" id="newgame" style="margin-top:8px;padding:8px 16px;width:100%">CREATE A NEW SAVE</button>
'@ @'
        <button class="deploy ghost" id="pnamesave" style="padding:7px 16px">CHANGE NAME</button>
        <!-- vNN.xx (ui5q1a, his #50): CREATE A NEW SAVE shares the name row, so the saves block is not a web form -->
        <button class="deploy ghost" id="newgame" style="padding:7px 16px">CREATE A NEW SAVE</button>
      </div>
'@

SubRx @'
var VER='24.62';
'@ @'
var VER='24.63';
'@

$pat = "(?m)^  now:'v24\.62:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v24.63: The title mode list has big readable rows, the COMING LATER notes sit inside their rows, and the saves block is a compact panel. Check 24.63 fails on v24.62',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
