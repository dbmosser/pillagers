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

# THE FLOOR SAYS HOW TO TRADE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    s('Enter')+' equip from backpack &nbsp; '+s('KeyM')+' map &nbsp; '+s('KeyH')+' controls &nbsp; TAB back out &nbsp; '+s('KeyP')+' / TAB pause';
'@ @'
    s('Enter')+' equip from backpack &nbsp; '+s('KeyM')+' map &nbsp; '+s('KeyT')+' offer or take a traded item &nbsp; '+s('KeyN')+' ping &nbsp; '+s('KeyH')+' controls &nbsp; TAB back out &nbsp; '+s('KeyP')+' / TAB pause';   // v18.25: the trade key, from the audit
'@

SubRx @'
    var _lg=['WASD','walk','SHIFT','jog','SPACE','roll','E','use the station in front of you',
             'B or I','your things','TAB','pause, or back out','M','the map, on the surface','H','close this'];
'@ @'
    var _lg=['WASD','walk','SHIFT','jog','SPACE','roll','E','use the station in front of you',
             'B or I','your things','TAB','pause, or back out','M','the map, on the surface'];
    if(typeof NET==='object'&&NET&&NET.on) _lg.push('T','take an offer from your teammate (offer from the stash)');   // v18.25: trading on the floor card
    _lg.push('H','close this');
'@

SubRx @'
  if(padOn()){ ctx.fillText('L STICK WALK  \u00b7  LS JOG  \u00b7  '+keyLabel('KeyE','E')+' USE STATION',W/2,H-16); ctx.textAlign='left'; return; }
'@ @'
  if(padOn()){ ctx.fillText('L STICK WALK  \u00b7  LS JOG  \u00b7  '+keyLabel('KeyE','E')+' USE STATION'+((typeof NET==='object'&&NET&&NET.on)?'  \u00b7  Y TAKE AN OFFER':''),W/2,H-16); ctx.textAlign='left'; return; }   // v18.25: and the trade button while a party is on
'@

SubRx @'
  E USE STATION',W/2,H-16);
'@ @'
  E USE STATION'+((typeof NET==='object'&&NET&&NET.on)?'  \u00b7  T TAKE AN OFFER':''),W/2,H-16);   // v18.25: and the trade key while a party is on
'@

SubRx @'
    if(detail) detail.innerHTML='<span style="opacity:.55">Hover an item and press J to tag it JUNK. '+
'@ @'
    if(detail) detail.innerHTML='<span style="opacity:.55">'+((typeof netHubSeat==='function'&&netHubSeat()>=0)?('Right-click an item (Y on a controller) and pick Offer to hand it to '+(netSeatName(netHubSeat())||'your teammate')+'; they take it with T or Y. '):'')+'Hover an item and press J to tag it JUNK. '+
'@

SubRx @'
var VER='18.24';
'@ @'
var VER='18.25';
'@

$pat = "(?m)^  now:'v18\.24:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.25: The pause box, the stash screen and the Undercroft floor all say how to trade while a party is on. Check 18.25 fails on v18.24',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
