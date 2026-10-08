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

# A CONTROLLER CAN USE FASHION AND THE RUN TAGS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  var out=[],q=root.querySelectorAll('button,.cell,.vcell,.crow,.invtab,.scard,.vpill,.sectorpick,input,select,[data-plan],.imenurow:not(.dim),[data-slot]');
'@ @'
  // v20.58, from the whole-game bug hunt of 2026-10-08 (H45): A CONTROLLER CAN DRESS, AND CAN SAY HOW THE RUN FELT. The FASHION rack
  // tiles are .costile divs, the slot rows and the three saved looks are .avslot divs, and the HOW DID THAT RUN FEEL tags on the
  // end-of-raid card are .tag divs, and this list named none of them. So in FASHION the pad reached only SURPRISE ME, the three SAVE
  // buttons and CLOSE: no cosmetic could be worn or bought, no slot chosen and no saved look worn, the operator panel on the ascent
  // check had the same gap, and no run tag could be picked. They are in the list now and A runs the click a mouse runs (a locked
  // tile that cannot be bought still clanks). The card still opens on Log run and return (padMenu).
  var out=[],q=root.querySelectorAll('button,.cell,.vcell,.crow,.invtab,.scard,.vpill,.sectorpick,input,select,[data-plan],.imenurow:not(.dim),[data-slot],.costile,.avslot,.tag');
'@

SubRx @'
  if(md.id==='title'&&(!PAD.focus||!md.contains(PAD.focus))){ var _tsb=document.getElementById('titlestart'); if(_tsb&&list.indexOf(_tsb)>=0) padSetFocus(_tsb); }
'@ @'
  if(md.id==='title'&&(!PAD.focus||!md.contains(PAD.focus))){ var _tsb=document.getElementById('titlestart'); if(_tsb&&list.indexOf(_tsb)>=0) padSetFocus(_tsb); }
  // v20.58 (H45): the end-of-raid card opens on Log run and return, now that the run tags above it are controls too
  if(md.id==='outcome'&&(!PAD.focus||!md.contains(PAD.focus))){ var _ocb=document.getElementById('oc_btn'); if(_ocb&&list.indexOf(_ocb)>=0) padSetFocus(_ocb); }
'@

SubRx @'
var VER='20.57';
'@ @'
var VER='20.58';
'@

$pat = "(?m)^  now:'v20\.57:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.58: On a controller you can now wear, buy and save looks at the Fashion station, and pick how the run felt after a raid. Check 20.58 fails on v20.57',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
