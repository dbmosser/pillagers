$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# CHECK 9.63 MEASURES THE SHOT MARK ALONE AGAIN. No game code changes. v15.67 drew the red noise marks for unseen sounds above the
# darkness, as the stealth audit asked, so a hidden pillager's shot now shows its noise ring as well as the v9.63 shot mark. Check 9.63
# compares red pixels with the shot mark dial on and off, and the noise ring now reds the OFF arm (712 pixels), so its control failed
# in the v15.72 corpus. The fixture clears the noise ring before its frame so only the shot mark is measured.
SubRx @'
var VER='15.72';
'@ @'
var VER='15.73';
'@

$pat = "(?m)^  now:'v15\.72:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.73: CHECK 9.63 MEASURES THE SHOT MARK ALONE AGAIN. No game code changes. Since v15.67 the noise ring of a hidden pillager shot shows above the darkness, which reddened the mark-off arm of check 9.63 and failed its control in the v15.72 corpus. The fixture now clears the noise ring before measuring. Check 15.73 requires check 9.63 to pass. Fixture only: the unchanged 9.63 failed on v15.72 alone and in the corpus',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
