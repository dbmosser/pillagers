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

# v11.79 CHECK, inserted before the v11.78 entry. The table is read for the
# four recipes and their price window, and one is crafted through the real row.
SubRx @'
  {v:'11.78',what:'the credits and XP readout is twice the size on the Undercroft floor, and keeps its compact size and its clearance from the CONDITIONS box in a raid (his note of 2026-09-06)',
'@ @'
  {v:'11.79',what:'four guns are on the crafting bench, two green and two blue, each priced in parts between what it sells for and what it costs to buy, and crafting one through the real row puts the gun in the stash and takes the parts (his order of 2026-09-06)',
   run:function(){
     if(typeof RECIPES==='undefined'||typeof ITEMS==='undefined') return 'SKIP: no recipes in this build';
     if(!window.__P||typeof renderWork!=='function') return 'SKIP: this fixture cannot reach the bench';
     var bad=[], guns=[], i, k;
     for(i=0;i<RECIPES.length;i++){
       var r=RECIPES[i], out=null; for(k in r.out){ out=k; break; }
       var it=ITEMS[out];
       if(it&&it.use==='gun') guns.push({ix:i,r:r,out:out,it:it});
     }
     if(guns.length!==4) bad.push('the bench holds '+guns.length+' gun recipe(s) and not four');
     var green=0, blue=0;
     for(i=0;i<guns.length;i++){
       var G2=guns[i], rar=G2.it.r;
       if(rar==='uncommon') green++; else if(rar==='rare') blue++; else bad.push(G2.r.name+' is '+rar+', and only green and blue guns belong on the bench');
       // THE PRICE WINDOW: parts worth more than the gun sells for, less than buying it.
       var parts=0; for(k in G2.r.need){ parts+=(ITEMS[k]?ITEMS[k].val:0)*G2.r.need[k]; if(typeof CON_ITEMS!=='undefined'&&CON_ITEMS.indexOf(k)>=0) bad.push(G2.r.name+' asks for '+k+', a contract item'); }
       if(parts<=G2.it.val) bad.push(G2.r.name+' costs '+parts+' in parts and sells for '+G2.it.val+', which prints money');
       var shopRow=null; if(typeof SHOP!=='undefined') for(var si=0;si<SHOP.length;si++) if(SHOP[si].kind==='wep'&&SHOP[si].k===G2.it.gk) shopRow=SHOP[si];
       if(shopRow&&parts>=shopRow.price) bad.push(G2.r.name+' costs '+parts+' in parts against '+shopRow.price+' to buy, which is a trap');
     }
     if(green!==2||blue!==2) bad.push('the bench holds '+green+' green and '+blue+' blue gun recipes, not two of each');
     // AND ONE CRAFTS THROUGH THE REAL ROW.
     var smg=null; for(i=0;i<guns.length;i++) if(guns[i].out==='gun_smg') smg=guns[i];
     if(smg){
       var prof=__P(), keepStash=(prof.stash||[]).slice();
       try{
         __topClear(); __cleanProfile(); prof=__P();
         var st=[]; for(k in smg.r.need) for(var q=0;q<smg.r.need[k];q++) st.push(k);
         prof.stash=st;
         renderWork();
         var row=document.querySelector('#worklist [data-w="recipe:'+smg.ix+'"]');
         var btn=row?row.querySelector('button'):null;
         if(!btn) bad.push('control: the bench drew no row for the Compact SMG');
         else if(btn.disabled) bad.push('control: with every part in the stash the Compact SMG row is still locked');
         else {
           btn.click();
           if((prof.stash||[]).indexOf('gun_smg')<0) bad.push('crafting the Compact SMG put no gun in the stash (stash: '+(prof.stash||[]).join(',')+')');
           var left=0; for(var j=0;j<(prof.stash||[]).length;j++) if(prof.stash[j]!=='gun_smg') left++;
           if(left) bad.push('control: '+left+' part(s) were left in the stash after the craft');
         }
       }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
       finally{ try{ __P().stash=keepStash; }catch(_r){} __topClear(); __cleanProfile(); }
     }
     return bad.length?bad.join('; '):null; }},
  {v:'11.78',what:'the credits and XP readout is twice the size on the Undercroft floor, and keeps its compact size and its clearance from the CONDITIONS box in a raid (his note of 2026-09-06)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
