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

# THE STAMINA WORD SITS BESIDE ITS BAR (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  ctx.font=FS(TYPE.micro); ctx.fillStyle='#0a0e14';
ctx.fillText(p.stamLock?'WINDED':'STAMINA',24,by-15);
'@ @'
  // v18.40, THE STYLING PASS IN THE RAID (2026-10-04): THE STAMINA WORD SITS BESIDE ITS BAR. It was dark text inside a 12 unit bar
  // in a face taller than the bar, so it spilled over the top edge and read as a smudge. It sits just past the bar's end now, in
  // the bar's own colour, and WINDED still replaces it when the bar locks.
  ctx.font=FS(TYPE.micro); ctx.fillStyle=_stc;
  ctx.fillText(p.stamLock?'WINDED':'STAMINA',16+280+8,by-15);
'@

SubRx @'
var VER='18.39';
'@ @'
var VER='18.40';
'@

$pat = "(?m)^  now:'v18\.39:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.40: The stamina label sits beside its bar instead of spilling over it. Check 18.40 fails on v18.39',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
