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

# THE STYLING PASS, STAGE D: THE RUN CARD (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
</style>
'@ @'
  /* v18.31, THE STYLING PASS, STAGE D: THE RUN CARD. A glass card with a soft drop shadow and a light from the top, the outcome
     word with a glow in its own colour, the feel tags as rounded pills, and LOG RUN AND RETURN as the one primary button.
     Positions, ids and every word are unchanged. */
  #root .ocwin{ border-radius:14px; border:1px solid rgba(127,146,216,.45);
    background:radial-gradient(900px 420px at 50% -12%, rgba(127,146,216,.16), transparent 62%), linear-gradient(180deg,var(--win-top),var(--win-bot));
    box-shadow:0 24px 60px rgba(0,0,0,.55), inset 0 1px 0 rgba(255,255,255,.07); }
  #root .outcome h1{ font-size:34px; text-shadow:0 0 22px currentColor, 0 3px 0 rgba(0,0,0,.5); }
  #root .tag{ border-radius:999px; padding:6px 14px; transition:background .12s, border-color .12s, color .12s; }
  #root .tag:hover{ background:rgba(127,146,216,.10); }
  #root #oc_btn{ background:linear-gradient(180deg,#ffd97f 0%,#ffb634 100%); color:#1a1408; border:1px solid #ffe9b0; border-radius:8px;
    font-weight:800; letter-spacing:.16em; box-shadow:0 8px 22px rgba(255,180,50,.22); }
  #root #oc_btn:hover{ filter:brightness(1.06); }
</style>
'@

SubRx @'
var VER='18.30';
'@ @'
var VER='18.31';
'@

$pat = "(?m)^  now:'v18\.30:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.31: The end-of-raid card has the new look: glass card, glowing outcome, pill tags and a clear main button. Check 18.31 fails on v18.30',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
