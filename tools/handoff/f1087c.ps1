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

# ==== A RELEASE NOBODY SAW IS NOT A RELEASE. My first cut dropped the key and
# ==== pressed it again on the SAME frame, with no step between, so the line that
# ==== clears stamRelease, which only runs while the key is observed to be up,
# ==== never ran and the second sprint never came. Four frames of genuinely
# ==== letting go, which is what a player does.
SubRx @'
         // The release arm: let go and press again, which is what a player has
         // to do to sprint after running out under a hold.
         if(release&&f===420&&!__state().sprinting){ dropShift(); holdShift(); }
'@ @'
         // The release arm: let go, leave it up for four frames so the game can
         // SEE it up, then press again. That is what a player has to do to
         // sprint after running out under a hold.
         if(release&&f===420&&!__state().sprinting) dropShift();
         if(release&&f===424) holdShift();
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
