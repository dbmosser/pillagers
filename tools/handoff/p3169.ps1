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

# STASH LOSES ITS EXPLAINING SENTENCES (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
      'PARTS are eaten by recipes and racks; SALVAGE is safe to sell. '+
'@ @'
      ''+   /* v28.xx (cw-uc-stash2): Q8, the parts line was an explaining sentence on the stash help row (reason in notes/ui/changes.md) */
'@

SubRx @'
      'The sell button clears junk and loose salvage.</span>';
'@ @'
      '</span>';
'@

SubRx @'
Right-click an item (Y on a controller) and pick Drop on the floor to hand it to 
'@ @'
Drop on the floor for 
'@

SubRx @'
'; they walk to it and press E. '
'@ @'
'. '
'@

SubRx @'
  var _sh=document.getElementById('sellhint');
'@ @'
  var _sh=document.getElementById('sellhint');
  if(_sh) _sh.style.display='none';   /* v28.xx (cw-uc-stash2): Q8, the sell note was a three sentence paragraph under the sell button (reason in notes/ui/changes.md) */
'@

SubRx @'
>FIRST RAID: drag a gun and two heals in here, then go up at ENTER RAID!</div>
'@ @'
>FIRST RAID: drag a gun and two heals in, then ENTER RAID</div>
'@

SubRx @'
'<span>'+(on?'Taking the freebie kit. '+escHtml(freeKitText())+(P.kitSaved?' Your own loadout is saved for when you switch back.':''):
'@ @'
'<span>'+(on?'In use: '+escHtml(freeKitText()):
'@

SubRx @'
      'Go up with issued gear instead of your own. '+escHtml(freeKitText()))+'</span>'+
'@ @'
      escHtml(freeKitText()))+'</span>'+
'@

SubRx @'
var VER='31.68';
'@ @'
var VER='31.69';
'@

$pat = "(?m)^  now:'v31\.68:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.69: The stash help row, sell note and freebie bar are short. Check 31.69 fails on v31.68',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
