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

# NO KIT ANSWERS ON THE LET THEM GO CARD (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  ASKALT=null;
  var _y=document.getElementById('askyes'), _a=document.getElementById('askalt');
'@ @'
  ASKALT=null;
  // v22.30, from the whole-game bug hunt of 2026-10-08 (K39): THIS CARD NEVER CARRIES THE KIT ANSWERS. A kit question that the party
  // ascent closed unanswered (a screen change only takes the windows down) left RANDOM FROM STASH and TOP GEAR showing and armed on
  // the card, so this card showed them too, and either one shut it without letting the hire go, rewrote his packing and the guns
  // in his hands, and sent the host a stray kit answer. They are taken off before this card opens.
  kitExtraHide();
  var _y=document.getElementById('askyes'), _a=document.getElementById('askalt');
'@

SubRx @'
var VER='22.29';
'@ @'
var VER='22.30';
'@

$pat = "(?m)^  now:'v22\.29:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.30: The Let them go card at HIRE no longer shows RANDOM FROM STASH and TOP GEAR left over from a party ascent. Check 22.30 fails on v22.29',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
