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
  if(ss) ss.innerHTML='<b>Your loadout</b>: '+
    (kitN?('the '+kitN+' item'+(kitN===1?'':'s')+' you packed, plus your current tactical belt and backpack.')
         :'your current tactical belt and backpack.')+
'@ @'
  // v14.77, first-hour audit finding 1: THE QUESTION SAYS WHAT GOES UP WHEN NOTHING IS PACKED. With nothing packed MY LOADOUT
  // commits an empty list, kitChosen stays 0 and buildRaid packs the standard kit out of the stash (v8.40, deliberate), so a
  // fresh character took up six of the ten welcome pack items after reading that only an empty belt and backpack went up.
  // standardKit works on a copy, so counting it here moves nothing.
  var autoN=0; if(!kitN){ try{ autoN=standardKit().length; }catch(_sk){ autoN=0; } }
  if(ss) ss.innerHTML='<b>Your loadout</b>: '+
    (kitN?('the '+kitN+' item'+(kitN===1?'':'s')+' you packed, plus your current tactical belt and backpack.')
         :(autoN?('nothing is packed, so '+autoN+' item'+(autoN===1?' goes':'s go')+' up from your stash, picked for you: grenades first, then plates, ammo and heals. Anything that goes up can be lost.')
                :'your current tactical belt and backpack.'))+
'@
SubRx @'
var VER='14.76';
'@ @'
var VER='14.77';
'@

$pat = "(?m)^  now:'v14\.76:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.77: THE ASCENT QUESTION SAYS WHAT GOES UP WHEN NOTHING IS PACKED. With nothing packed the raid packs the standard kit out of the stash, so a fresh character took up six welcome pack items after reading that only an empty belt and backpack went up. The question now names how many items will be packed from the stash and that they can be lost. Check 14.77 asks with one item packed and with none; it fails on v14.76',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
