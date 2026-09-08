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

# v12.64 CHECK, inserted before the v12.63 entry. It reads the DRAWN panel
# rather than the source, because the whole finding is that a sentence exists in
# the source and cannot be reached. Four arms, and the first is the one my v8.18
# check never ran: wanting one thing he cannot afford at all. The second is the
# case v8.18 DID measure, which must still work.
SubRx @'
  {v:'12.63',what:'a contract paying a gun he already owns pays what the gun is worth and says so, instead of handing over nothing and printing a receipt saying it paid; the same payout on a gun he does not own still hands over the gun (2026-09-08 audit)',
'@ @'
  {v:'12.64',what:'the buy button says how short he is even when he cannot afford one unit, which is the commonest refusal at the counter and the only one it used to answer with a dead grey button and no words; the partly affordable case still says it, an affordable order does not, and a row locked for a reason that is not money keeps its own words (2026-09-08 audit, my defect from v8.18)',
   run:function(){
     if(!(window.__P&&window.__shopPanel&&__shopPanel.detail)) return 'SKIP: this fixture cannot read the drawn counter panel';
     if(typeof SHOP==='undefined'||!SHOP.length) return 'SKIP: this build has no counter to read';
     var bad=[], P2=__P();
     var keep={credits:P2.credits,xp:P2.xp,qty:P2._shopQty,sel:P2._shopSel,pack:P2.pack};
     // An ordinary row with no XP lock, and separately a row that HAS one, both
     // found by what the table says rather than named here.
     var plain=-1, locked=-1, i;
     for(i=0;i<SHOP.length;i++){
       var o=SHOP[i];
       if(o.kind==='pack') continue;                 // its own tier rule, its own words
       if(!o.rep&&plain<0) plain=i;
       if(o.rep>0&&locked<0) locked=i;
     }
     if(plain<0) return 'SKIP: every row on this counter carries an XP lock, so the money case cannot be isolated';
     var price=SHOP[plain].price;
     function panel(ix,credits,xp,qty){
       P2.credits=credits; P2.xp=xp; P2._shopQty=qty;
       return String(__shopPanel.detail(ix)||'');
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __cleanProfile();
       // THE FINDING: one unit, and he cannot afford it. The commonest refusal.
       var t1=panel(plain,Math.max(0,price-1),999999,1);
       if(t1.indexOf('NEED')<0)
         bad.push('wanting one thing he cannot afford answered with no words at all: the panel reads ['+t1.slice(0,110)+'] and never says how short he is, which is the commonest refusal at this counter');
       // CONTROL ONE: the case v8.18 measured, where he can afford some but not
       // all. It must still say it, or this build has moved the fault rather than
       // fixing it.
       var t2=panel(plain,price*3,999999,5);
       if(t2.indexOf('NEED')<0)
         bad.push('control: an order he can partly afford no longer says how short he is either, so this build has broken what v8.18 shipped');
       // CONTROL TWO: an order he CAN afford must not be told he is short.
       var t3=panel(plain,price*5,999999,1);
       if(t3.indexOf('NEED')>=0)
         bad.push('control: an order he can afford tells him he is short: ['+t3.slice(0,110)+']');
       // CONTROL THREE: a row locked for a reason that is NOT money keeps its own
       // words, so the money line has not been made to answer for everything.
       if(locked>=0){
         var t4=panel(locked,999999,0,1);
         if(t4.indexOf('NEED $')>=0)
           bad.push('control: a row he cannot buy for want of XP, with money in hand, says he is short of money: ['+t4.slice(0,110)+']');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ P2.credits=keep.credits; P2.xp=keep.xp; P2._shopQty=keep.qty; P2._shopSel=keep.sel; P2.pack=keep.pack;
            saveProfile(); }catch(_p){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'12.63',what:'a contract paying a gun he already owns pays what the gun is worth and says so, instead of handing over nothing and printing a receipt saying it paid; the same payout on a gun he does not own still hands over the gun (2026-09-08 audit)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
