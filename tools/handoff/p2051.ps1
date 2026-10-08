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

# A CONTROLLER CAN PICK A SAVE ON THE TITLE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  var out=[],q=root.querySelectorAll('button,.cell,.vcell,.crow,.invtab,.scard,.vpill,.sectorpick,input,select,[data-plan],.imenurow:not(.dim)');
'@ @'
  // v20.51, from the whole-game bug hunt of 2026-10-08 (H44): A CONTROLLER CAN PICK A SAVE ON THE TITLE. Each save in the SAVES list
  // is a plain [data-slot] div, named nowhere in this list, so the highlight walked the mode rows, DELETE, the name box, CHANGE NAME
  // and CREATE A NEW SAVE but never a save: a pad player could arm DELETE on a save and never load one, and the player 2 window,
  // played on a pad only, could not pick its character (v17.93). The rows are in the list now. They are laid out and never
  // disabled, and A runs the row's own click, which already does nothing on the save in play and on the save the other window has
  // open. [data-slot] exists only in the title's #slotlist, so no other panel gains a control. No player text and no number moved.
  var out=[],q=root.querySelectorAll('button,.cell,.vcell,.crow,.invtab,.scard,.vpill,.sectorpick,input,select,[data-plan],.imenurow:not(.dim),[data-slot]');
'@

SubRx @'
var VER='20.50';
'@ @'
var VER='20.51';
'@

$pat = "(?m)^  now:'v20\.50:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.51: On a controller you can now highlight a save on the title and load it with A. Check 20.51 fails on v20.50',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
