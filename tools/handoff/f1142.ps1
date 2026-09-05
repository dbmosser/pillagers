$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# v11.42: expose the shipped edit map so a check can count what got baked. get:TX
# is already on __tx, so the exact and pattern paths are drivable already.
SubRx @'
  try{ window.__tx.arm=function(){ return applyGameOpts(); }; }catch(e3){}
'@ @'
  try{ window.__tx.arm=function(){ return applyGameOpts(); }; }catch(e3){}
  try{ window.__tx.ship=function(){ var o={}; if(typeof TXSHIP!=='undefined'){ for(var k in TXSHIP) o[k]=TXSHIP[k]; } return o; }; }catch(e4){}
'@

# v11.42 CHECK, inserted before the v11.41 entry.
SubRx @'
  {v:'11.41',what:'claiming a finished contract refills the freed slot with a job that is NOT already on the board (the no-duplicate rule the board is topped up by), and the refill still happens with the board held at eight',
'@ @'
  {v:'11.42',what:'his in-game text edits are baked in: TX rewrites his edited strings to his wording with the editor off, exact and number-pattern lines alike, and leaves unrelated text alone',
   run:function(){
     if(!(window.__tx&&__tx.get)) return 'SKIP: this build has no text engine to drive';
     var bad=[];
     function chk(oldS,wantS){ var g=__tx.get(oldS); if(g!==wantS) bad.push('"'+oldS.slice(0,32)+'" did not become his wording (got "'+(''+g).slice(0,40)+'")'); }
     // exact edits, ASCII samples of the baked set
     chk('Human-shaped rivals looting the same map. They fight each other and the machines as well as you.','Make some friends.');
     chk('no armour on','no armour equipped');
     chk('The freebie kit','The Freebie Kit');
     chk('XP comes from selling salvage in the Undercroft.','Shop before you drop.');
     // number-pattern edit driven with a DIFFERENT number, to prove the shape not the instance
     chk('Rainy. Harder going, so XP pays 2.5x.','XP multiplier = 2.5x');
     // an unedited line must pass through untouched
     var u='This exact line was never one he edited.'; if(__tx.get(u)!==u) bad.push('an unedited line was rewritten (got "'+(''+__tx.get(u)).slice(0,40)+'")');
     // the shipped map is present and roughly complete
     if(__tx.ship){ var _n=0,_o=__tx.ship(); for(var _k in _o) _n++; if(_n<60) bad.push('only '+_n+' edits are baked, expected the full set (~67)'); }
     return bad.length?bad.join('; '):null; }},
  {v:'11.41',what:'claiming a finished contract refills the freed slot with a job that is NOT already on the board (the no-duplicate rule the board is topped up by), and the refill still happens with the board held at eight',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
