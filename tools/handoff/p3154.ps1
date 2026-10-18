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

# PAD BUTTONS TABLE WIDE, SETTINGS FOCUS LINE, LONGER FADE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
#root #pausebox:not(.asking) #abandonbtn, #root #pausebox:not(.asking) #arcendbtn, #root #pausebox:not(.asking) #charselbtn{ border-color:transparent !important; background:transparent; font-weight:600; }
'@ @'
#root #pausebox:not(.asking) #abandonbtn, #root #pausebox:not(.asking) #arcendbtn, #root #pausebox:not(.asking) #charselbtn{ border-color:transparent !important; background:transparent; font-weight:600; }
/* v31.xx (cw-pset9) critic c-31w round 2 (Pad buttons 74 at 2: "the table is a 950px column in a 1820px card, 430px of dead black each side", "the locked line is sliced in half by the footer divider"; Settings 72 at 3: "the focused row is hardly distinct, fill #1e2225 on #16191b", "the last row fades into a smudge"). Now: the Pad buttons and Keys table is 1440 wide (the two columns spread, 30 x 48), the pointed Settings row has the hover fill and a 1px accent line round it as well as the 4px bar, and both lists fade over 48px with 48px under the last row so a cut line fades out instead of being sliced. */
#root #keysmodal #keyslist{ max-width:calc(var(--sp-5) * 30); }
#root #setlist .row:not(.setjump):hover, #root #setlist .row:not(.setjump):focus-within, #root #setlist .row.dshow:not(.setjump), #root #setlist .row:not(.setjump):has(.padfocus){ background:var(--ui-hover); box-shadow:inset 4px 0 0 var(--acc), inset 0 0 0 1px var(--acc); }
#root #keyslist, #root #setlist{ padding-bottom:var(--sp-5); -webkit-mask-image:linear-gradient(to bottom, var(--ui-void) calc(100% - var(--sp-5)), transparent); mask-image:linear-gradient(to bottom, var(--ui-void) calc(100% - var(--sp-5)), transparent); }
'@

SubRx @'
var VER='31.53';
'@ @'
var VER='31.54';
'@

$pat = "(?m)^  now:'v31\.53:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.54: The pad buttons table spreads to 1440, the pointed Settings row has a lime outline and lighter fill, and list ends fade out over 48px. Check 31.54 fails on v31.53',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
