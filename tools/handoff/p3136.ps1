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

# PAUSE AND SETTINGS POLISH (56PX REPORT ROW, FLUSH TAB, SHORT PAD LABELS) (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
[7,'fire, use what is selected','FIGHT']
'@ @'
[7,'fire / use','FIGHT']
'@

SubRx @'
[2,'use, search, reload, call for extraction','FIGHT'],[3,'search in a ring, help a teammate, finish a downed pillager','FIGHT']
'@ @'
[2,'use / reload','FIGHT'],[3,'help / finish','FIGHT']
'@

SubRx @'
#root #pausebox.asking #pausefb{ display:none !important; }
'@ @'
#root #pausebox.asking #pausefb{ display:none !important; }
/* v31.xx (cw-pset6) critic c-31z (pause 25 at 3: "report a problem is a 72px input while every other row is a 56px button, dim grey text"; "the lime tab is inset, not flush"; Pad buttons 75 at 2: "labels wrap to three lines", "scrollbar is a thin sliver"; Keys 32: "make the key cap look like a key"). Now: the report box is one 56px row like the buttons (centred, tx-2 hint, grows to two rows only while you type), the accent tab on the pause, Settings and Keys cards sits flush in the top-left corner, the Settings and Keys scrollbar is 6px in the line colour, key caps have a 3px lip, and two pad labels are short (his words shortened under Q8: use / reload and help / finish, so they stay on one line). */
#root #pausebox #pausefb{ height:var(--btn-h); padding:calc((var(--btn-h) - 28px) / 2) var(--sp-2); line-height:26px; overflow:hidden; }
#root #pausebox #pausefb:focus{ height:calc(var(--btn-h) * 2); padding-top:var(--sp-2); overflow:auto; }
#root #pausebox #pausefb:placeholder-shown:not(:focus){ text-align:center; }
#root #pausebox #pausefb::placeholder{ color:var(--tx-2); }
#root #pausebox::before, #root #settingsmodal::before, #root #keysmodal::before{ background:linear-gradient(var(--acc),var(--acc)) 0 0/calc(var(--sp-1) * 4.5) 2px no-repeat, var(--ui-grain) 0 0/128px 128px repeat, var(--ui-bg); background-origin:border-box; }
#root #setlist::-webkit-scrollbar, #root #keyslist::-webkit-scrollbar{ width:6px; }
#root #setlist::-webkit-scrollbar-thumb, #root #keyslist::-webkit-scrollbar-thumb{ background:var(--ui-line-hi); border-radius:3px; }
#root #keyslist .keybtn{ border-radius:var(--rad); font-weight:700; box-shadow:inset 0 -3px 0 var(--ui-line-hi); }
#root #keyslist .keybtn.wait{ box-shadow:none; }
'@

SubRx @'
var VER='31.35';
'@ @'
var VER='31.36';
'@

$pat = "(?m)^  now:'v31\.35:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.36: The pause report box is a 56px row, the card tab sits in the corner, pad labels fit on one line, the scrollbar is 6px, key caps have a lip. Check 31.36 fails on v31.35',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
