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

# v12.62 CHECK, inserted before the v12.61 entry. It buys by clicking the real
# button on the real counter, found by the name the row prints, so nothing here
# depends on the order of the shop table. Three arms, and the first is the one
# that costs him a gun: buying a spare while already holding one.
SubRx @'
  {v:'12.61',what:'quick ascent starts at day like the other door does: pressing the ascent key at the lift no longer inherits the surface he chose last raid, the sector page door still resets it, and a night he chooses on the page and ascends from the page is still night (2026-09-08 audit, his answer 24)',
'@ @'
  {v:'12.62',what:'the Undercroft counter says what it did with his money, and a gun bought as a spare goes to the armoury instead of taking the slot off the gun in his hands; with empty hands a bought gun still arrives in them (2026-09-08 audit)',
   run:function(){
     if(!(window.__P&&window.__hubEnter&&window.__showScreen)) return 'SKIP: this fixture cannot reach the counter';
     if(typeof openTrader!=='function'||typeof renderShop!=='function'||typeof SHOP==='undefined') return 'SKIP: this build has no counter to buy at';
     if(!document.getElementById('shop')) return 'SKIP: this build has no shop list to click';
     var bad=[], P2=__P();
     var keep={credits:P2.credits,weapons:(P2.weapons||[]).slice(),equipped:P2.equipped,
               equippedSec:P2.equippedSec,stash:(P2.stash||[]).slice(),xp:P2.xp,pack:P2.pack};
     // The cheapest gun on the counter and any ordinary item, both found by what
     // the row prints rather than by where they sit in the table.
     var gunRow=null, itemRow=null, i;
     for(i=0;i<SHOP.length;i++){
       var o=SHOP[i];
       if(o.kind==='wep'&&(!gunRow||o.price<gunRow.price)) gunRow=o;
       if(!o.kind&&!itemRow&&ITEMS[o.k]) itemRow=o;
       if(o.kind==='item'&&!itemRow&&ITEMS[o.k]) itemRow=o;
     }
     if(!gunRow) return 'SKIP: the counter sells no guns in this build';
     function nameOf(o){ return (o.kind==='wep')?WEAPONS[o.k].name:(ITEMS[o.k]?ITEMS[o.k].name:null); }
     function clickRow(o){
       __showScreen('hub'); __hubEnter(); openTrader('buy'); renderShop();
       var host=document.getElementById('shop'); if(!host) return 'no shop list';
       var want=nameOf(o); if(!want) return 'no name for that row';
       var kids=host.children, k, r, btn=null;
       for(k=0;k<kids.length&&!btn;k++){
         r=kids[k];
         if(String(r.textContent||'').indexOf(want)<0) continue;
         btn=r.querySelector('button');
       }
       if(!btn) return 'no row on the counter named '+want;
       if(btn.disabled) return 'the button for '+want+' is disabled';
       HUBSAY=''; btn.click();
       return null;
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __cleanProfile();
       // THE FINDING: he already carries a gun, and buys a spare.
       P2.credits=999999; P2.xp=999999; P2.stash=[];
       P2.weapons=['sniper']; P2.equipped='sniper'; P2.equippedSec='none';
       var e1=clickRow(gunRow);
       if(e1) return 'SKIP: '+e1;
       if(P2.equipped!=='sniper')
         bad.push('buying a spare '+nameOf(gunRow)+' at the counter took the primary slot off the gun he was already carrying: gun 1 now reads '+P2.equipped+' and nothing said a word about it');
       if(P2.weapons.indexOf(gunRow.k)<0) bad.push('control: the bought gun did not reach the armoury at all');
       if(!String(HUBSAY||'').length)
         bad.push('the counter took his credits for a '+nameOf(gunRow)+' and said nothing at all');
       else if(String(HUBSAY).indexOf('Bought')<0)
         bad.push('the counter said "'+HUBSAY+'" rather than telling him what it did with his money');
       // CONTROL ONE: with empty hands the same purchase must arrive IN them, or
       // the build has taken away the convenience instead of fixing the theft.
       P2.weapons=[]; P2.equipped='fists'; P2.credits=999999;
       var e2=clickRow(gunRow);
       if(!e2&&P2.equipped!==gunRow.k)
         bad.push('control: buying a gun with empty hands no longer puts it in them (gun 1 reads '+P2.equipped+'), so the fix has gone too far');
       // CONTROL TWO: an ordinary purchase still lands and still says so.
       if(itemRow){
         P2.credits=999999; P2.stash=[];
         var e3=clickRow(itemRow);
         if(!e3){
           if(P2.stash.indexOf(itemRow.k)<0) bad.push('control: an ordinary purchase no longer reaches the stash');
           if(String(HUBSAY||'').indexOf('Bought')<0) bad.push('control: an ordinary purchase says "'+(HUBSAY||'')+'" rather than what it did');
         }
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ var tm=document.getElementById('tradermodal'); if(tm) tm.classList.remove('on'); }catch(_m){}
       try{ P2.credits=keep.credits; P2.weapons=keep.weapons; P2.equipped=keep.equipped;
            P2.equippedSec=keep.equippedSec; P2.stash=keep.stash; P2.xp=keep.xp; P2.pack=keep.pack;
            saveProfile(); }catch(_p){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'12.61',what:'quick ascent starts at day like the other door does: pressing the ascent key at the lift no longer inherits the surface he chose last raid, the sector page door still resets it, and a night he chooses on the page and ascends from the page is still night (2026-09-08 audit, his answer 24)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
