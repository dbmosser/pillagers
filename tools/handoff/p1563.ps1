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

SubRx @'
  var y=document.getElementById('askyes'), a=document.getElementById('askalt');
  if(y) y.textContent='MY LOADOUT';
  if(a){ a.textContent='FREEBIE KIT'; a.style.display=''; }
  openModal('askmodal');
'@ @'
  var y=document.getElementById('askyes'), a=document.getElementById('askalt');
  if(y) y.textContent='MY LOADOUT';
  if(a){ a.textContent='FREEBIE KIT'; a.style.display=''; }
  // v15.63, menus audit finding: BACKING OUT OF THE LOADOUT QUESTION RETURNS TO THE SECTOR PAGE. The only caller is ASCEND TO
  // THIS SECTOR, which takes the sector page down to raise this card, and this card never named the window to put back, the
  // v12.68 rule written above ASKBACK that the Hire nobody card follows. ESC, TAB, controller B and Not yet all end at #askno,
  // and askRestore found nothing to restore, so he was left on the bare floor. Walking back to the lift for the page ran
  // liftResetDay, so the NIGHT he had picked went back to DAY. Declining now puts the sector page back as he left it. MY
  // LOADOUT and FREEBIE KIT still ascend: askRestore runs before their callbacks, and ascendNow takes the sector page down
  // before startRaid. No player text, no number and no seeded draw moved.
  ASKBACK='sectormodal';
  openModal('askmodal');
'@
SubRx @'
var VER='15.62';
'@ @'
var VER='15.63';
'@

$pat = "(?m)^  now:'v15\.62:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.63: BACKING OUT OF THE LOADOUT QUESTION RETURNS TO THE SECTOR PAGE. On What are you taking up, raised by ASCEND TO THIS SECTOR, ESC, TAB or Not yet left him on the bare floor, and walking back to the lift for the page put his NIGHT pick back to DAY. Backing out now puts the sector page back as he left it, NIGHT still picked, and MY LOADOUT and FREEBIE KIT still ascend. Check 15.63 backs out by TAB, ESC and Not yet with NIGHT picked, then ascends by both answers; it fails on v15.62',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
