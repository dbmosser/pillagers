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

# A FOURTH CHECK ENCODED THE REVERSED RULE, AND THE SHARD TRIAL CAUGHT IT. v13.29
# repaired 13.07, 10.67 and 10.29 for his ruling that the welcome pack goes to the
# stash, and missed 10.66, whose TAKE arm also required a gun in the armoury. The
# first sharded corpus run reported it as the one real failure among four shards.
#
# Mine: f1329 was built from a search for the checks that read equipped slots and the
# armoury after TAKE, and 10.66 reads the armoury in a line that search did not show.
# Its stash assertion beside it stands, and so does the rest of the check.
SubRx @'
       if(!(P2.weapons||[]).length) bad.push('taking the pack put no gun in the armoury');
'@ @'
       // r1329: the armoury assertion retired. His ruling of 2026-09-13 sends the whole
       // pack to the stash, guns as items, so the armoury is not where the pack goes.
       if((P2.stash||[]).indexOf('gun_smg')<0) bad.push('taking the pack did not put its gun in the stash');
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
