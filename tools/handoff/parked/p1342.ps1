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

# A BOX THAT FINISHES AN OPEN OR DISTRICT CONTRACT: "CONTRACT DONE" WAS WRITTEN OVER BY
# THE FOUND LINE IN THE SAME CALL.
#
# Lead recorded by the v13.40 review (and d1340 Not verified). openContainer calls
# contractOpen, which calls contractStep, which says CONTRACT DONE with a plain say;
# then, still in openContainer, grantLoot says the Found line over it. So the only
# in-raid word that an open or district contract is done never reached the screen.
# contractOpen has one caller (openContainer), and nothing returns between it and the
# grant.
#
# FIX: contractStep takes an optional list. contractOpen passes one and returns it, so
# the lines a box finishes are held; openContainer says them through sayWhenFree just
# after the grant, while the Found line shows, before the v13.40 hot ground line. The
# kill path (contractKill) passes no list and says the line at once, as before. No
# wording or numbers change.
SubRx @'
function contractStep(c){
'@ @'
function contractStep(c,hold){   // v13.41: hold, when given, collects the line instead of saying it
'@

SubRx @'
    if(!G.sim) say('CONTRACT DONE: '+(c.desc||'contract')+'. Complete contract at mainframe.');
'@ @'
    if(!G.sim){
      var _doneLn='CONTRACT DONE: '+(c.desc||'contract')+'. Complete contract at mainframe.';
      if(hold) hold.push(_doneLn); else say(_doneLn);
    }
'@

SubRx @'
  if(ct&&ct.dropped) return;   // audit: searching your own discard farmed contracts
'@ @'
  if(ct&&ct.dropped) return;   // audit: searching your own discard farmed contracts
  var _hold=[];   // v13.41: lines this box finishes, said by openContainer after its grant
'@

SubRx @'
    if(c.type==='open'&&c.ct===ct.type&&c.prog<c.n) contractStep(c);
'@ @'
    if(c.type==='open'&&c.ct===ct.type&&c.prog<c.n) contractStep(c,_hold);
'@

SubRx @'
    if(c.type==='district'&&ct.d===c.d&&c.prog<c.n) contractStep(c);
  }
}
'@ @'
    if(c.type==='district'&&ct.d===c.d&&c.prog<c.n) contractStep(c,_hold);
  }
  return _hold;
}
'@

SubRx @'
  contractOpen(ct);
'@ @'
  var _contractLines=contractOpen(ct);   // v13.41: said after the grant below, not under it
'@

SubRx @'
  grantLoot(ct,ct.loot,_wnDelay);
  // v13.40: the Found line is showing now, so the hot ground line waits its turn behind it
'@ @'
  grantLoot(ct,ct.loot,_wnDelay);
  // v13.41: a contract this box finished waits its turn behind the Found line.
  if(_contractLines) for(var _cli=0;_cli<_contractLines.length;_cli++) sayWhenFree(_contractLines[_cli]);
  // v13.40: the Found line is showing now, so the hot ground line waits its turn behind it
'@

SubRx @'
var VER='13.40';
'@ @'
var VER='13.41';
'@

$pat = "(?m)^  now:'v13\.40:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.41: A BOX THAT FINISHES A CONTRACT SAYS SO. Opening a box that finished an open or district contract ran the contract step, which said CONTRACT DONE, and then the grant in the same call said the Found line over it, so the only in-raid word that the contract was done never reached the screen. The contract step now takes an optional list: opening a box passes one and gets the lines back, and they are said through sayWhenFree just after the grant, behind the Found line and before the hot ground line. The kill path passes no list and says the line at once, as before. No wording or numbers change. Check 13.41 stages an open contract one box short, holds X at a box of that type through the frame loop until it opens, confirms the contract finished and was recorded, and requires CONTRACT DONE on screen; it fails on v13.40',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
