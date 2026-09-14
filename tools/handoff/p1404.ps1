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

# SAVING, PROFILE AND SETTINGS AUDIT OF 2026-09-15, finding 3: A RESTORE CODE KEPT THE OLD SAVE'S HIRE, CONTRACTS, SEAL
# CUTTING, EXPLORED MAP AND SIGNED TERMS. restoreApply replaces what the code carries and, since v13.61, clears the kit,
# the belt, the saved packings and an armed core. The code carries none of these others, and nothing cleared them: the
# restored character walked out with the old one's paid hire (and was billed his death benefit), his half-done contract
# board, his seconds of cutting on a sealed door, his explored map and his signed Terms. The panel promises the code
# replaces the save. They are cleared with the rest; the boot refills the contract board.
SubRx @'
  P.kit=[]; P.hotAssign={}; P.kitSaved=null; P.kitBeforeFree=null; P.intel=0;
'@ @'
  P.kit=[]; P.hotAssign={}; P.kitSaved=null; P.kitBeforeFree=null; P.intel=0;
  // v14.04, save audit: and the rest the code does not carry. A hire he paid for, a contract board half done, cutting on
  // a sealed door, an explored map and signed Terms all belonged to the character being replaced.
  P.merc=null; P.contracts=[]; P.seals={}; P.mapSeen={}; P.discover={}; P.terms=[]; P.notExt=0;
  P.freeKit=0; P.kitChosen=0; P.dropKit=[];
'@
SubRx @'
var VER='14.03';
'@ @'
var VER='14.04';
'@

$pat = "(?m)^  now:'v14\.03:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.04: A RESTORE CODE REPLACES THE HIRE, CONTRACTS, CUTTING, MAP AND TERMS TOO. Saving, profile and settings audit of 2026-09-15, finding 3: restoreApply cleared the kit, belt, saved packings and core but none of the other state the code does not carry, so a restored character kept the old one paid hire and death benefit, contract progress, seal cutting, explored map and signed Terms. They are cleared with the rest, and the boot refills the board. Check 14.04 restores a code over a character with a hire, a contract at five of six, thirty seconds of cutting and signed Terms, and requires all four gone, with the code name applied as the control; it fails on v14.03',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
