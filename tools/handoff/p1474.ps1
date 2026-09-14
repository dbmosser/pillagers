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
      if(!ev.shiftKey) return;                  // plain click is the junk tag, below
'@ @'
      // v14.74, stash and trader audit finding 2: A ON A CONTROLLER PACKS ONE. The pad focuses stash cells and presses A as a
      // click with no SHIFT or ALT, which this handler ignored, and the pad has no right-click, drag or hover, so a pad player
      // could not pack anything from the stash while A on a backpack cell unpacked one. A pad press has detail 0, the test the
      // crafting button uses; a mouse click has detail 1 or more and still does nothing here.
      if(!ev.shiftKey){
        if(ev.detail===0){ ev.stopPropagation(); ev.preventDefault(); _packSome(1); }
        return;                                 // plain click is the junk tag, below
      }
'@
SubRx @'
var VER='14.73';
'@ @'
var VER='14.74';
'@

$pat = "(?m)^  now:'v14\.73:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.74: A ON A CONTROLLER PACKS ONE FROM THE STASH. The pad presses A on a stash cell as a plain click, which did nothing, and the pad has no right-click, drag or hover, so a pad player could not pack from the stash at all. A pad press now packs one; a mouse click still does nothing. Check 14.74 clicks a stash stack with the mouse and with the pad; it fails on v14.73',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
