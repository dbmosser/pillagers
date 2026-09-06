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

# CHECK 11.79 read the price row's r for a gun's rarity and scanned SHOP for a
# purchase price that three of the four guns do not have; it reads dispR and
# replaceCost now, and requires at least one of each colour rather than two.
SubRx @'
       var G2=guns[i], rar=G2.it.r;
'@ @'
       var G2=guns[i], rar=((typeof dispR==='function')?dispR(G2.out):null)||G2.it.r;   // v11.95: the rarity every screen shows
'@
SubRx @'
       var shopRow=null; if(typeof SHOP!=='undefined') for(var si=0;si<SHOP.length;si++) if(SHOP[si].kind==='wep'&&SHOP[si].k===G2.it.gk) shopRow=SHOP[si];
       if(shopRow&&parts>=shopRow.price) bad.push(G2.r.name+' costs '+parts+' in parts against '+shopRow.price+' to buy, which is a trap');
'@ @'
       var buy=(typeof replaceCost==='function')?replaceCost(G2.it.gk):null;   // v11.95: the game's own purchase price, which exists for every gun
       if(!buy) bad.push('control: no purchase price could be found for '+G2.r.name);
       else if(parts>=buy) bad.push(G2.r.name+' costs '+parts+' in parts against '+buy+' to buy, which is a trap');
'@
SubRx @'
     if(green!==2||blue!==2) bad.push('the bench holds '+green+' green and '+blue+' blue gun recipes, not two of each');
'@ @'
     if(green<1||blue<1) bad.push('the bench holds '+green+' green and '+blue+' blue gun recipes, not at least one of each');   // v11.95: the Carbine is blue by dispR
'@
SubRx @'
  {v:'11.79',what:'four guns are on the crafting bench, two green and two blue, each priced in parts between what it sells for and what it costs to buy, and crafting one through the real row puts the gun in the stash and takes the parts (his order of 2026-09-06)',
'@ @'
  {v:'11.79',what:'four guns are on the crafting bench, one green and three blue by the rarity every screen shows, each priced in parts between what it sells for and what it costs to buy, and crafting one through the real row puts the gun in the stash and takes the parts (his order of 2026-09-06)',
'@
# THE v9.43 CHECK asserted a servo is in no recipe; four recipes eat it now.
SubRx @'
       if(__stashRules.craftPart('servo'))
         bad.push('the Servo Actuator is still classed as a crafting part and appears in no recipe');
'@ @'
       // v11.95: four gun recipes eat the servo, so it is a craft part again and
       // the stash must say so; the repair reason above is still forbidden.
       if(!__stashRules.craftPart('servo'))
         bad.push('the Servo Actuator is not classed as a crafting part though four recipes eat it');
'@

# v11.95 CHECK, inserted before the v11.94 entry.
SubRx @'
  {v:'11.94',what:'the bench detail button crafts on a synthetic click (a pad press) and on a hold, spends nothing on a real mouse click, and a hold dies when the trader window is hidden (2026-09-06 review of v11.75)',
'@ @'
  {v:'11.95',what:'the crafting bench tells the truth about its guns: one green and three blue by the rarity every other screen shows, the detail panel describes a gun as a gun with its shown rarity, and the stash says servos and optics are kept for guns and contracts (2026-09-06 review of v11.79)',
   run:function(){
     if(typeof RECIPES==='undefined'||typeof dispR!=='function'||typeof itemBlurb!=='function'||typeof itemWanted!=='function') return 'SKIP: no bench, rarity or blurb in this build';
     if(typeof openTrader!=='function'||typeof renderCraftDetail!=='function'||!window.__hubEnter) return 'SKIP: this fixture cannot open the bench';
     var bad=[], i, k, green=0, blue=0, carbIx=-1;
     for(i=0;i<RECIPES.length;i++){
       var out=null; for(k in RECIPES[i].out){ out=k; break; }
       var it=ITEMS[out]; if(!it||it.use!=='gun') continue;
       var rar=dispR(out)||it.r;
       if(rar==='uncommon') green++; else if(rar==='rare') blue++; else bad.push(RECIPES[i].name+' shows as '+rar);
       if(out==='gun_carbine') carbIx=i;
     }
     if(!(green>=1&&blue>=1)) bad.push('by the shown rarity the bench holds '+green+' green and '+blue+' blue');
     var line=null; if(typeof WHATSNEW!=='undefined') for(i=0;i<WHATSNEW.length;i++) if(WHATSNEW[i].indexOf('FOUR GUNS ON THE CRAFTING BENCH')===0) line=WHATSNEW[i];
     if(line&&line.indexOf('Compact SMG and Burst Carbine in green')>=0) bad.push('the card still calls the Burst Carbine green');
     var bl=itemBlurb('gun_smg')||'';
     if(bl.indexOf('Salvage')===0||bl.toLowerCase().indexOf('gun')<0) bad.push('the blurb for a crafted gun reads: '+bl);
     var sv=itemWanted('servo')||'', op=itemWanted('optic')||'';
     if(sv.indexOf('contracts')<0) bad.push('the stash keeps a servo for "'+sv+'", not for guns and contracts');
     if(op.indexOf('contracts')<0) bad.push('the stash keeps an optic for "'+op+'", not for the rifle and contracts');
     try{
       __topClear(); __cleanProfile();
       G=null; keys={}; __showScreen('hub'); __hubEnter();
       __P().stash=['comp','comp','comp','comp','servo','servo','board','board'];
       openTrader('craft'); renderWork();
       var rows=[].slice.call(document.querySelectorAll('#worklist .row')), ix=-1;
       for(i=0;i<rows.length;i++) if(rows[i].getAttribute('data-w')==='recipe:'+carbIx) ix=i;
       if(ix<0||carbIx<0) bad.push('control: the bench drew no Burst Carbine row');
       else {
         __P()._craftSel=ix; renderCraftDetail(rows);
         var pill=document.querySelector('#craftdetail .vpill.r');
         var txt=pill?pill.textContent.trim().toUpperCase():'';
         if(txt!=='RARE') bad.push('the detail panel calls the Burst Carbine '+(txt||'nothing')+' where every other screen says RARE');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ var ms=document.querySelectorAll('.modal.on'); for(var j=0;j<ms.length;j++) ms[j].classList.remove('on'); }catch(_c){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'11.94',what:'the bench detail button crafts on a synthetic click (a pad press) and on a hold, spends nothing on a real mouse click, and a hold dies when the trader window is hidden (2026-09-06 review of v11.75)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
