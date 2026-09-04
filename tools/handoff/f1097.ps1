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
  {v:'10.96',what:'pausing in the Undercroft offers exactly his two choices
'@ @'
  {v:'10.97',what:'nothing the game wants is classified as salvage, and the sell button will not clear it',
   run:function(){
     if(typeof RECIPES==='undefined'||typeof ITEMS==='undefined') return 'SKIP: this build has no item tables';
     if(typeof sellable!=='function') return 'SKIP: this build has no sell rule';
     var bad=[], i, k;
     // WHAT WANTS AN ITEM, worked out here from the tables that do the wanting.
     // This is the one place the check is allowed to know the answer
     // independently, because the whole finding is that the game did not.
     var wanted={}, why={};
     for(i=0;i<RECIPES.length;i++){
       var need=RECIPES[i].need||{};
       for(k in need){ wanted[k]=1; why[k]='the '+RECIPES[i].name+' recipe'; }
     }
     if(typeof RACK_COST!=='undefined') for(k in RACK_COST){ wanted[k]=1; why[k]='a mainframe rack'; }
     // The repair parts. Ask the cost function rather than repeating its rule:
     // drive a gun to a light wear and a heavy one and see what it asks for.
     if(typeof repairCost==='function'&&typeof WEAPONS!=='undefined'){
       var prof=__P(), keepW=prof.wear;
       prof.wear={};
       var gid=null;
       for(k in WEAPONS){ if(WEAPONS[k]&&WEAPONS[k].mag!==0){ gid=k; break; } }
       if(gid){
         prof.wear[gid]=600;  var rl=repairCost(gid);
         prof.wear[gid]=1800; var rh=repairCost(gid);
         if(rl&&rl.part){ wanted[rl.part]=1; why[rl.part]='repairing a worn gun'; }
         if(rh&&rh.part){ wanted[rh.part]=1; why[rh.part]='repairing a badly worn gun'; }
         if(rl&&rh&&rl.part===rh.part)
           bad.push('control: light and heavy wear both ask for '+rl.part+', so only one repair part is being tested');
       } else bad.push('control: no gun was found to wear, so the repair parts are untested');
       prof.wear=keepW;
     }
     // The contract board. Same rule: ask it, do not repeat it.
     if(typeof CON_ITEMS!=='undefined')
       for(i=0;i<CON_ITEMS.length;i++){ wanted[CON_ITEMS[i]]=1; why[CON_ITEMS[i]]='a contract asking for it by name'; }
     else bad.push('control: this build keeps the contract shopping list where nothing can read it, which is how three items ended up as salvage');
     // The mainframe burns one of these for intel.
     if(typeof slotCore==='function'){ wanted.core=1; why.core='the mainframe, which burns one for intel'; }
     var list=[]; for(k in wanted) list.push(k);
     if(list.length<6) bad.push('control: only '+list.length+' items were found to be wanted by anything, so this is not enumerating the game');
     // 1. NOTHING WANTED IS SHELVED AS SALVAGE. Measured on v10.96: servo, optic
     //    and core all came back salvage while something was asking for them.
     if(typeof stashTabOf!=='function')
       bad.push('the stash keeps its shelf rule inside its own renderer, so nothing can ask what shelf an item is on');
     else for(i=0;i<list.length;i++){
       if(!ITEMS[list[i]]) continue;
       var tab=stashTabOf(list[i]);
       if(tab==='salvage') bad.push(ITEMS[list[i]].name+' is shelved as salvage and '+why[list[i]]+' wants it');
     }
     // 2. AND THE SELL BUTTON WILL NOT CLEAR IT. The shelf is a label; this is
     //    the money. Junk tags are cleared first, because a tag he set himself
     //    outranks all of this and would make every answer below true.
     var prof2=__P(), keepJunk=prof2.junk;
     prof2.junk={};
     try{
       for(i=0;i<list.length;i++){
         if(!ITEMS[list[i]]) continue;
         if(sellable(list[i])) bad.push(ITEMS[list[i]].name+' is cleared by the sell button and '+why[list[i]]+' wants it');
       }
       // 3. CONTROL, AND WITHOUT IT THE TWO ABOVE COULD PASS BY KEEPING
       //    EVERYTHING. Real salvage must still be salvage and must still sell,
       //    or the fix is just an off switch on the sell button.
       var junkN=0, junkEg=null;
       for(k in ITEMS){
         if(wanted[k]||ITEMS[k].use) continue;
         if(stashTabOf(k)==='salvage'&&sellable(k)){ junkN++; if(!junkEg) junkEg=ITEMS[k].name; }
       }
       if(junkN<3) bad.push('control: only '+junkN+' items are still loose salvage, so the sell button has been turned off rather than taught');
       // 4. CONTROL: and a junk tag still beats all of it, which is his escape
       //    hatch for a part he has decided to be rid of.
       var _pk=null;
       for(i=0;i<list.length;i++) if(ITEMS[list[i]]&&!ITEMS[list[i]].use){ _pk=list[i]; break; }
       if(_pk){
         prof2.junk[_pk]=1;
         if(!sellable(_pk)) bad.push('tagging '+ITEMS[_pk].name+' as junk no longer lets him sell it');
         prof2.junk={};
       }
     } finally { prof2.junk=keepJunk; }
     return bad.length?bad.join('; '):null; }},
  {v:'10.96',what:'pausing in the Undercroft offers exactly his two choices
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
