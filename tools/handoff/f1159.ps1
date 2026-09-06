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

# v11.59 HOOK: the lot the clock picks right now, so a check can tell a rolled
# window from the one the card was drawn in.
SubRx @'
window.__loadProfile=function(){ return loadProfile(); };
'@ @'
window.__loadProfile=function(){ return loadProfile(); };
window.__wirtLot=function(){ return wirtLotKey(); };
'@

# v11.59 CHECK, inserted before the v11.58 entry.
SubRx @'
  {v:'11.51',what:'the two baked sector-facts lines are exact-only: the line with its own figures still maps to his wording, and a sector line with other figures is left as the game drew it instead of being rewritten by digit shape into the other map name',
'@ @'
  {v:'11.59',what:'Wirt Buy delivers the lot that was named and priced on the card, even if the five-minute window rolled between the card being drawn and the click',
   run:function(){
     if(!(window.__wirtLot&&window.__station&&window.__P)) return 'SKIP: this fixture cannot open Wirt';
     __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
     var P=window.__P(), bad=[], realNow=Date.now;
     P.credits=999999; P.stash=[];
     var st=null; try{ st=window.__station('gamble','KeyE'); }catch(e){ st={err:String(e)}; }
     if(st&&st.err) return 'SKIP: '+st.err;
     var shown=window.__wirtLot();
     if(!(shown&&shown.length)) return 'SKIP: the counter is empty';
     var btn=document.getElementById('wirtlotbtn');
     if(!btn) return 'SKIP: no Buy button on the counter';
     // THE WINDOW ROLLS between the card and the click: move the clock forward
     // one window, or two, or three, until the lot differs from the shown one.
     var base=realNow(), next=null, rolled=0;
     for(var r=1;r<=3&&!next;r++){ Date.now=function(){ return base+r*300000; }; var cand=window.__wirtLot(); if(cand&&cand.length&&cand[0]!==shown[0]){ next=cand; rolled=r; } }
     if(!next){ Date.now=realNow; return 'SKIP: the next three windows hold the same lot, so a roll cannot be told apart'; }
     Date.now=function(){ return base+rolled*300000; };
     try{ btn.click(); }catch(e2){}
     Date.now=realNow;
     var got=(P.stash||[]).length?P.stash[P.stash.length-1]:null;
     // THE FIX: he receives what the card NAMED AND PRICED.
     if(got!==shown[0]) bad.push('after the window rolled, Buy delivered '+got+' instead of the shown '+shown[0]);
     // CONTROL: he was charged, so a buy went through and the comparison is real.
     if(!(P.credits<999999)) bad.push('control: no credits were taken, so nothing was bought and the comparison proves nothing');
     try{ var gm=document.getElementById('gamblemodal'); if(gm) gm.classList.remove('on'); }catch(e3){}
     __cleanProfile(); __topClear();
     return bad.length?bad.join('; '):null; }},
  {v:'11.51',what:'the two baked sector-facts lines are exact-only: the line with its own figures still maps to his wording, and a sector line with other figures is left as the game drew it instead of being rewritten by digit shape into the other map name',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
