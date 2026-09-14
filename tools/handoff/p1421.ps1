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
  if(tap(0)&&PAD.focus){ PAD.focus.click(); }
'@ @'
  // v14.21, controller audit finding 3: AN A THAT CLICKS A MENU BUTTON IS SPENT UNTIL IT IS LET GO. The click happens on the
  // press, and ASCEND switches to the raid on the spot, so on the next poll no menu was open and the same held A reached the
  // raid as the trigger: every pad ascent fired a shot at the spawn point. A mouse click on the button never did, since the
  // fire listener is on the canvas. The raid branch ignores A until it has been released once.
  if(tap(0)&&PAD.focus){ PAD.aSpent=1; PAD.focus.click(); }
'@
SubRx @'
  var rtOn=!G.over&&!G.paused&&pressed(0);
'@ @'
  if(PAD.aSpent&&!pressed(0)) PAD.aSpent=0;
  var rtOn=!PAD.aSpent&&!G.over&&!G.paused&&pressed(0);
'@
SubRx @'
var VER='14.20';
'@ @'
var VER='14.21';
'@

$pat = "(?m)^  now:'v14\.20:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.21: AN A THAT CLICKS A MENU BUTTON DOES NOT FIRE ON ARRIVAL. The pad clicks a menu button on the press, ASCEND starts the raid on the spot, and on the next poll the same held A was the trigger, so every pad ascent fired a shot at the spawn point. An A spent on a menu click is now ignored by the raid until it is let go. Check 14.21 presses A on a probe window button, starts a raid with A held, then lets go and presses again; it fails on v14.20',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
