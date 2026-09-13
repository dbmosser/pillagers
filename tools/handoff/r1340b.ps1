$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# HARNESS: THE RUNNER NAMES EACH CHECK IN THE CONSOLE BEFORE RUNNING IT.
#
# The v13.40 corpus stalled in three different setups (three tabs, a single seed tab,
# and a freshly restarted pane). Every script call and screenshot then timed out, so
# __PROG.cur could not be read, yet read_console_messages still answered. The page is
# stuck inside one synchronous check. A console line written just before each check
# names the one that never returns. Logging only; no check or result changes.
SubRx @'
    __PROG.cur='v'+t.v; res.checked++;
'@ @'
    __PROG.cur='v'+t.v; res.checked++;
    try{ console.log('REGRESS start '+i+' v'+t.v); }catch(_lg){}   // r1340b: the last line names a check that never returns
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
