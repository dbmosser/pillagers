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

SubRx @'
  {v:'15.03',what:
'@ @'
  {v:'15.04',what:'buying the Limited Time Offer is not logged as a gamble roll: with nothing rolled, buying the lot leaves the roll history empty and no roll listed under THE GAMBLE, and one real roll is still logged and listed (wirt audit finding)',
   run:function(){
     if(typeof renderGamble!=='function'||typeof renderWirtLot!=='function'||typeof wirtLotKey!=='function'||typeof WIRT_LOT_PRICE!=='number'||typeof GAMBLE_PRICE!=='number'||!window.__applyLoaded||!window.__P) return 'SKIP: no Wirt counter in this build';
     var gl=document.getElementById('gamblelist'), wl=document.getElementById('wirtlot');
     if(!gl||!wl||!document.getElementById('gamblebtn')) return 'SKIP: the Wirt panel, its roll list or its lot card is not in this page';
     var bad=[], snap=null, _s2=say2, keepR=RNGS;
     function rows(){ return gl.querySelectorAll('.row').length; }
     try{
       __topClear(); __cleanProfile();
       snap=JSON.parse(JSON.stringify(__P()));
       var q=__P();
       var lot=wirtLotKey();
       if(!lot||!lot.length||!ITEMS[lot[0]]) return 'SKIP: the counter is empty this window';
       say2=function(){};
       q.gambleLog=[]; q.stash=[]; q.wirtLotBought=null; q.credits=WIRT_LOT_PRICE+GAMBLE_PRICE;
       renderGamble();
       var lb=document.getElementById('wirtlotbtn');
       // CONTROL: nothing is rolled yet and the offer has a live Buy button.
       if(rows()!==0||(q.gambleLog||[]).length!==0) return 'SKIP: the roll list was not empty before the purchase';
       if(!lb||lb.disabled) return 'SKIP: the counter drew no live Buy button to press';
       var c0=q.credits, s0=q.stash.length;
       lb.click();
       // CONTROL: the purchase took: the price was paid and the lot was banked.
       if(q.credits!==c0-WIRT_LOT_PRICE||!(q.stash.length>s0)) return 'SKIP: the purchase did not go through here (credits '+q.credits+', stash '+q.stash.length+')';
       var logged=(q.gambleLog||[]).slice(), shown=rows();
       if(logged.length||shown) bad.push('buying the Limited Time Offer logged '+(logged.length&&ITEMS[logged[0]]?ITEMS[logged[0]].name:(logged.length+' items'))+' as a roll and THE GAMBLE lists '+shown+' roll row(s), though nothing was rolled');
       // A REAL ROLL is still logged and listed.
       q.gambleLog=[]; q.credits=GAMBLE_PRICE;
       renderGamble();
       var gb=document.getElementById('gamblebtn');
       if(!gb||gb.disabled){ if(!bad.length) return 'SKIP: the Gamble button was not live for the roll'; }
       else{
         var s1=q.stash.length;
         gb.click();
         if(q.stash.length!==s1+1){ if(!bad.length) return 'SKIP: the roll banked nothing here'; }
         else if((q.gambleLog||[]).length!==1||q.gambleLog[0]!==q.stash[q.stash.length-1]||rows()!==1) bad.push('a real roll is not logged: after one roll the history holds '+(q.gambleLog||[]).length+' entries and THE GAMBLE lists '+rows()+' row(s)');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       say2=_s2; RNGS=keepR;
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       try{ if(typeof wirtLotTick==='function') wirtLotTick(); }catch(_t){}
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'15.03',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
