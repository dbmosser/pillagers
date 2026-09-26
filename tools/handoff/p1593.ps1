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

# THE GAMBLE HISTORY AT WIRT PRINTS WHAT THE ITEM IS WORTH. The history rows renderGamble lists under THE GAMBLE printed it.val,
# the raw table value, while every other price surface prints ival(), the table value scaled by CFG.lootMult (OPTIONS, How much
# is out there). Display only: the row now reads ival(log[i]).
SubRx @'
    if(!it) continue;
    h+='<div class="row">'+iconImgHTML(log[i],22)+'<span class="nm" style="color:'+(RCOL[dispR(log[i])||it.r]||'#cdd6dd')+'">'+it.name+'</span>'+
       '<span class="vl">'+'$'+it.val.toLocaleString()+'</span></div>';
'@ @'
    if(!it) continue;
    // v15.93, credits audit finding: THE GAMBLE HISTORY AT WIRT PRINTS WHAT THE ITEM IS WORTH. This row printed it.val, the raw
    // table value, while every other price surface (the stash hover, the tag-junk hint, the Peddler panel, the shelf line at the
    // Mainframe, and Sell one itself) prints ival(), which is the table value scaled by CFG.lootMult, the OPTIONS row How much is
    // out there, whose own hint promises it moves what everything is worth. So on Lean a rolled Data Core read $520 here while the
    // stash hover said $364 each and Sell one paid $364; on Rich, $520 here against $702 everywhere else. Display only: on Standard
    // the two numbers are the same, the value credited on a sale was already ival(), and no dial, table or seeded draw moves.
    h+='<div class="row">'+iconImgHTML(log[i],22)+'<span class="nm" style="color:'+(RCOL[dispR(log[i])||it.r]||'#cdd6dd')+'">'+it.name+'</span>'+
       '<span class="vl">'+'$'+ival(log[i]).toLocaleString()+'</span></div>';
'@
SubRx @'
var VER='15.92';
'@ @'
var VER='15.93';
'@

$pat = "(?m)^  now:'v15\.92:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.93: THE GAMBLE HISTORY AT WIRT PRINTS WHAT THE ITEM IS WORTH. With How much is out there set to Lean or Rich, each row under THE GAMBLE printed the table value of the rolled item, 520 for a Data Core, while the stash hover and Sell one said 364 or 702. The rows now print the same price every other price surface prints, and on Standard nothing changes. Check 15.93 rolls a Data Core into the history on Lean and Rich and reads its row; it fails on v15.92',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
