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
  {v:'10.87',what:'sprint follows the SHIFT key: let go and you stop running, while crouch is s
'@ @'
  {v:'10.89',what:'X does not swap weapons any more and says so nowhere, while every other way of bringing a gun up still works',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__keysRef&&window.__loop)) return 'SKIP: this fixture cannot drive keys through a raid';
     var bad=[];
     __runPrep(); __resetCfg(); __pinDefaults(0);
     __deploy({kit:[],safe:null,mapIx:0,seed:4242});
     var g=__state(), p=g.player, K=__keysRef();
     for(var k in K) delete K[k];          // a latched key has faked this twice
     g.ents.length=0; p.downed=0;
     if(!p.wep||!p.sec) return 'SKIP: this deploy did not give the operator two guns';
     var held=p.wep.id, stowed=p.sec.id;
     if(held===stowed) return 'SKIP: both guns are the same, so a swap cannot be seen';
     // 1. THE KEY DOES NOTHING. This is his note.
     try{ window.dispatchEvent(new KeyboardEvent('keydown',{code:'KeyX'})); }catch(e){}
     try{ document.dispatchEvent(new KeyboardEvent('keydown',{code:'KeyX',bubbles:true})); }catch(e2){}
     if(p.wep.id!==held||p.sec.id!==stowed)
       bad.push('pressing X still swapped the guns, '+held+' to '+p.wep.id);
     // 2. AND THE SWAP ITSELF STILL WORKS, or this deleted a feature rather than
     //    a key. Four other callers depend on it: dragging a gun onto the one in
     //    your hands, the hotbar bringing a stowed gun up, and two in the bot.
     if(typeof swapGuns!=='function') bad.push('the swap function itself is gone, which takes the hotbar and the bot with it');
     else {
       swapGuns();
       if(p.wep.id!==stowed||p.sec.id!==held)
         bad.push('calling the swap directly no longer swaps: holding '+p.wep.id+' with '+p.sec.id+' stowed');
       swapGuns();
     }
     // 3. AND NOTHING TELLS A PLAYER TO PRESS IT. A key removed from the handler
     //    but left in a legend is worse than leaving the key alone.
     var legends=[];
     try{ legends.push(JSON.stringify(LEGEND)); }catch(e3){}
     try{ legends.push(JSON.stringify(LEGEND_MINI)); }catch(e4){}
     var text=legends.join(' ');
     if(text){
       // Assembled, so this check cannot find itself in the page.
       var swapWord=['swap',' ','weapon'].join(''), swapGun=['swap',' ','gun'].join('');
       if(text.indexOf(swapWord)>=0||text.indexOf(swapGun)>=0)
         bad.push('a keyboard legend still teaches swapping a weapon with a key');
     } else bad.push('control: no legend could be read, so this proved nothing about what a player is told');
     // 4. THE CONTROLLER IS UNTOUCHED. Its X is a face button meaning search and
     //    goes through a different table; removing it would take search off the pad.
     if(typeof PADHOLD==='undefined'||PADHOLD[2]!=='KeyE')
       bad.push('the controller X no longer maps to search, so the pad lost a button it needs');
     return bad.length?bad.join('; '):null; }},
  {v:'10.87',what:'sprint follows the SHIFT key: let go and you stop running, while crouch is s
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
