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

# ==== MY CHECK WAS MILDER THAN MY REPRODUCTION. It failed the old build by ONE
# ==== pixel where the reproduction had the button 21 below the card, and a
# ==== control that only just fails is nearly a control that passes. The
# ==== difference is the safe pocket: arming it adds a line, and the content goes
# ==== 896 to 945 against an 826 box, so the button lands 66 below instead of 1.
# ==== The ledger shows at most seven items and then "and N more", so piling on
# ==== extra loot does nothing; the lines that matter are the ones with their own
# ==== sentence. Measured on a v10.73 fixture: none 1, safe pocket 66, and 16 or
# ==== 24 extra items still 66.
SubRx @'
     function seat(bag,guns,extra){
'@ @'
     function seat(bag,guns,extra,safe){
'@

SubRx @'
       P2.freeKit=0; P2.hotAssign={}; P2.autoExport=false; P2.safe=null;
       P2.stash=bag.slice(); P2.kit=bag.slice();
       P2.weapons=guns.slice(); P2.equipped=guns[0]||'fists'; P2.equippedSec=guns[1]||'none';
       try{ saveProfile(); }catch(_s){}
       __deploy({kit:bag.slice(),safe:null,mapIx:0,seed:4242});
'@ @'
       P2.freeKit=0; P2.hotAssign={}; P2.autoExport=false; P2.safe=safe||null;
       P2.stash=bag.slice(); P2.kit=bag.slice();
       P2.weapons=guns.slice(); P2.equipped=guns[0]||'fists'; P2.equippedSec=guns[1]||'none';
       try{ saveProfile(); }catch(_s){}
       __deploy({kit:bag.slice(),safe:safe||null,mapIx:0,seed:4242});
'@

SubRx @'
       var FULL=['medkit','medkit','plate','plate','servo','scrap','wire','bandage','smoke','frag'];
       seat(FULL,['smg','carbine'],8);
'@ @'
       // The safe pocket is armed on purpose. It adds its own line to the ledger
       // and that is what carries the card past the fold: measured on a v10.73
       // fixture the content is 896 without it and 945 with it, against an 826
       // pixel box, so the button lands 66 pixels below the card rather than 1.
       // Piling on more loot does not help, because the ledger shows seven and
       // then says how many more.
       var FULL=['medkit','medkit','plate','plate','servo','scrap','wire','bandage','smoke','frag'];
       seat(FULL,['smg','carbine'],8,'medkit');
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
