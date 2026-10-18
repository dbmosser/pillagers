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

# KEYS WINDOW CLEAN (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
#root #pausebox #abandonbtn, #root #pausebox #arcendbtn, #root #pausebox #charselbtn{ color:var(--danger) !important; border-color:var(--danger) !important; }
'@ @'
#root #pausebox #abandonbtn, #root #pausebox #arcendbtn, #root #pausebox #charselbtn{ color:var(--danger) !important; border-color:var(--danger) !important; }
/* v28.xx (cw-keysclean) critic c-31 round 3 (Keys window 32 at 2): "16 duplicate Rebind buttons ... 32 near-identical boxes ... merge them: make the key cap itself the button", the section heads in amber (amber is for focus), and 15px labels under the 16px floor. Now: the key cap is the one control (it already waits for a press, and a second press cancels), the Rebind box is gone, section heads are tx-2 at --fs-label, action names --fs-body, caps wider */
#root #keyslist .rebind{ display:none; }
#root #keyslist .keysec{ color:var(--tx-2); font-size:var(--fs-label); }
#root #keyslist .row b{ font-size:var(--fs-body); }
#root #keyslist .keybtn{ min-width:calc(var(--sp-1) * 20) !important; }
'@

SubRx @'
var VER='29.58';
'@ @'
var VER='29.59';
'@

$pat = "(?m)^  now:'v29\.58:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.59: The Keys window is cleaner: the key is the button. Check 29.59 fails on v29.58',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
