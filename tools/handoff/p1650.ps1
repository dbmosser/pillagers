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

# IN A RAID, SETTINGS GREYS OUT THE THREE BUTTONS THAT LEAVE THE RAID (stability pass before his co-op session, 2026-09-27).

SubRx @'
  host.innerHTML=_go+kidRowHtml()+
'@ @'
  // v16.50, stability: Settings opens in a raid since v16.45, and three of its buttons do not belong there. PICK FILE opens a
  // file window a controller cannot shut, and a restore or its UNDO reloads the window, which drops a teammate out of the party
  // and loses the run. In a raid they are greyed out; in the Undercroft they work as before.
  var _rOff=(typeof G!=='undefined'&&G&&!G.over&&!G.sim)?' disabled':'';
  host.innerHTML=_go+kidRowHtml()+
'@

SubRx @'
    '<button id="set_restore" style="padding:6px 12px">PICK FILE</button>'+
'@ @'
    '<button id="set_restore" style="padding:6px 12px"'+_rOff+'>PICK FILE</button>'+
'@

SubRx @'
    (hasPreRestore()?'<button id="set_unrestore" style="padding:6px 12px;margin-left:8px">UNDO</button>':'')+
'@ @'
    (hasPreRestore()?'<button id="set_unrestore" style="padding:6px 12px;margin-left:8px"'+_rOff+'>UNDO</button>':'')+
'@

SubRx @'
    '<button id="set_tune" style="padding:6px 12px">OPEN</button></div>'+
'@ @'
    '<button id="set_tune" style="padding:6px 12px"'+_rOff+'>OPEN</button></div>'+
'@

SubRx @'
var VER='16.49';
'@ @'
var VER='16.50';
'@

$pat = "(?m)^  now:'v16\.49:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.50: IN A RAID, SETTINGS GREYS OUT THE BUTTONS THAT LEAVE THE RAID. Stability pass before a co-op session. Settings opens in a raid since v16.45, and three of its buttons do not belong there: PICK FILE opens a file window a controller cannot shut, a restore or its UNDO reloads the window (a teammate drops out of the party and loses the run), and the tuning console can change the game settings mid raid. In a raid they are greyed out; in the Undercroft they work as before. Check 16.50 fails on v16.49',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
