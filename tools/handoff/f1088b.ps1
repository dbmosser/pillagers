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

# ---- v10.66's TITLE still promised a handover that no longer happens. A check
# ---- whose name describes a deleted feature misleads every run it appears in.
# ---- The nine remaining mentions of the old profile flags are save-and-restore
# ---- lines: they preserve a field nothing reads any more, which is inert, and
# ---- leaving them costs nothing while touching them risks a real check.
SubRx @'
  {v:'10.66',what:'a brand new character meets the welcome pack and then the primer, one at a time, and the primer is still owed after a first raid instead of being stamped away unread',
'@ @'
  {v:'10.66',what:'a brand new character meets the welcome pack, once, and it does not come back after a raid',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
