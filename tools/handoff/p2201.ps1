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

# A CONTROLLER CAN READ AND SELL ONE STASH ITEM (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
      act:function(){ P.junk=P.junk||{}; if(isJ) delete P.junk[key]; else P.junk[key]=1; saveProfile(); refreshInv(); }});
'@ @'
      act:function(){ P.junk=P.junk||{}; if(isJ) delete P.junk[key]; else P.junk[key]=1; saveProfile(); refreshInv(); }});
    // v22.01, from the whole-game bug hunt of 2026-10-08 (K11): SELL ONE IS ON THE ITEM MENU. The Stash screen sold a single item
    // only through the Sell one button in the hover line, and a controller never hovers, so a pad player could not sell one item at
    // all, only tag it and sell every tagged item. The menu Y opens (and a right-click) offers it now on the Stash screen, with the
    // same body as the hover button: the plain price, paid in credits and in XP (v10.02, v12.67).
    var _hbS=document.getElementById('hub');
    if(ctx==='stash'&&held>0&&_hbS&&_hbS.classList.contains('on')) rows.push({label:'Sell one',hint:'$'+ival(key).toLocaleString(),act:function(){
      var ix=P.stash.indexOf(key); if(ix<0) return;
      P.stash.splice(ix,1); clearKeysFor(key); P.credits+=ival(key); P.xp=(P.xp||0)+ival(key); syncXpLevel(); saveProfile(); refreshInv();
    }});
'@

SubRx @'
  PAD.focus=el;
  try{ el.scrollIntoView({block:'nearest',inline:'nearest'}); }catch(_e){}
'@ @'
  PAD.focus=el;
  try{ el.scrollIntoView({block:'nearest',inline:'nearest'}); }catch(_e){}
  // v22.01, from the whole-game bug hunt of 2026-10-08 (K11): A HIGHLIGHTED STASH ITEM IS NAMED. The line above the stash grid
  // (name, count, price, what wants it, a gun's damage) is written when the mouse comes onto a cell, and the controller highlight
  // never sent that, so a pad player read the idle hint whatever he picked. A stash or armoury cell the highlight lands on now
  // writes the line as the mouse would.
  if(el!==old&&el.closest&&el.closest('#stashgrid')){ try{ if(typeof el.onmouseenter==='function') el.onmouseenter(); else el.dispatchEvent(new MouseEvent('mouseenter')); }catch(_me){} }
'@

SubRx @'
var VER='22.00';
'@ @'
var VER='22.01';
'@

$pat = "(?m)^  now:'v22\.00:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.01: On a controller the stash now names the highlighted item and its price, and Y offers Sell one. Check 22.01 fails on v22.00',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
