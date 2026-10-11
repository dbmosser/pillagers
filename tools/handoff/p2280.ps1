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

# BACKPACK AND OFFER LINES IN CAPS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    if(_bix<0) say(s2.name+' is not in your backpack.');
'@ @'
    if(_bix<0) say('NOT IN BACKPACK','info',{sub:String(s2.name).toUpperCase()});   // v22.80 (tr6fixb): the caps callout, as the drag already says it
'@

SubRx @'
  if(gi&&!gi.yes&&(G.t||0)-gi.t>GIFT_T){ G.giftIn=null; try{ say(('Offer from '+(netSeatName(gi.from)||'your teammate')+' expired').toUpperCase(),'ally'); }catch(_x1){} }
'@ @'
  // v22.80 (tr6fixb), the review of raid text batch 6: the headline is at most 34 characters (HIS ORDER of 2026-10-09). With a 16
  // letter name and a long item, NAME DID NOT TAKE THE SCAV PISTOL ran past it. The headline is now OFFER EXPIRED with the name as
  // the detail, and NAME DID NOT TAKE IT (at most 32) with the item as the detail.
  if(gi&&!gi.yes&&(G.t||0)-gi.t>GIFT_T){ G.giftIn=null; try{ say('OFFER EXPIRED','ally',{sub:String(netSeatName(gi.from)||'your teammate').toUpperCase()}); }catch(_x1){} }
'@

SubRx @'
  if(go&&(G.t||0)-go.t>GIFT_T+5){ G.giftOut=null; try{ it=ITEMS[go.k]; say(((netSeatName(go.to)||'Your teammate')+' did not take the '+(it?it.name:go.k)).toUpperCase(),'ally'); }catch(_x2){} }
'@ @'
  if(go&&(G.t||0)-go.t>GIFT_T+5){ G.giftOut=null; try{ it=ITEMS[go.k]; say(String(netSeatName(go.to)||'Your teammate').toUpperCase()+' DID NOT TAKE IT','ally',{sub:String(it?it.name:go.k).toUpperCase()}); }catch(_x2){} }
'@

SubRx @'
    if(s<0){ say('Nobody close enough to give it to.'); return true; }
'@ @'
    if(s<0){ say('NO TEAMMATE IN RANGE'); return true; }   // v22.80 (tr6fixb): the caps callout
'@

SubRx @'
    if(bagBeltNo('Move the item into the backpack to offer it.')) return true;   // v20.53 (H17): never the unmarked stack the highlight left
'@ @'
    if(bagBeltNo('TO OFFER IT')) return true;   // v20.53 (H17): never the unmarked stack the highlight left
'@

SubRx @'
  if(bagBeltNo('Move the item into the backpack to drop it.')) return false;   // v20.53 (H17): never the unmarked stack the highlight left
'@ @'
  if(bagBeltNo('TO DROP IT')) return false;   // v20.53 (H17): never the unmarked stack the highlight left
'@

SubRx @'
      var _sg=bagBeltNo('Walk it back into the backpack to pick a gun.')?null:bagStacks()[clamp(G.bagSel,0,_stN-1)];   // v20.53 (H17): never the unmarked stack the highlight left
'@ @'
      var _sg=bagBeltNo('TO PICK A GUN')?null:bagStacks()[clamp(G.bagSel,0,_stN-1)];   // v20.53 (H17): never the unmarked stack the highlight left
'@

SubRx @'
  say('The highlight is on your belt. '+tail);
'@ @'
  // v22.80 (tr6fixb): the caps callout. It said The highlight is on your belt. and a sentence; it is MOVE IT TO THE BACKPACK FIRST
  // with what for (TO OFFER IT, TO DROP IT, TO PICK A GUN) as the detail.
  say('MOVE IT TO THE BACKPACK FIRST','info',{sub:tail});
'@

SubRx @'
var VER='22.79';
'@ @'
var VER='22.80';
'@

$pat = "(?m)^  now:'v22\.79:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.80: The backpack and offer lines read as short caps callouts, such as NOT IN BACKPACK, OFFER EXPIRED and NO TEAMMATE IN RANGE. Check 22.80 fails on v22.79',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
