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
  {v:'11.10',what:'the bot never hides
'@ @'
  {v:'11.11',what:'a friend arriving on a fresh profile can open every station on the floor without anything breaking or coming up blank',
   run:function(){
     if(!(window.__hubEnter&&window.__hub&&window.__station&&window.__P))
       return 'SKIP: this fixture cannot walk the Undercroft';
     if(!__vpAlive()) return 'SKIP: the pane has no layout, so nothing renders';
     var bad=[], prof=__P(), keep={}, k, i;
     var F=['runs','ext','died','best','credits','xp','xpLevel','stash','kit','log',
            'contracts','racks','arrays','notoriety','cstand','spClaimed','kills',
            'cosBought','junk','weapons','equipped','pack','cosAll','stashTab'];
     for(i=0;i<F.length;i++) keep[F[i]]=prof[F[i]];
     var caught=[];
     function onErr(ev){ caught.push(String((ev&&ev.message)||ev)); }
     window.addEventListener('error',onErr);
     try{
       __runPrep(); __resetCfg(); __pinDefaults(0);
       // THE PROFILE A FRIEND ARRIVES WITH. Nothing earned, nothing looted, one
       // gun, the starting money.
       prof.runs=0; prof.ext=0; prof.died=0; prof.best=0; prof.credits=600;
       prof.xp=0; prof.xpLevel=1; prof.stash=[]; prof.kit=[]; prof.log=[];
       prof.contracts=[]; prof.racks=0; prof.arrays=0; prof.notoriety=0;
       prof.cstand=0; prof.spClaimed=[]; prof.kills={}; prof.cosBought={};
       prof.junk={}; prof.weapons=['pistol']; prof.equipped='pistol';
       prof.pack=0; prof.cosAll=0; prof.stashTab='all';
       __hubEnter();
       var HB=__hub();
       if(!HB||!HB.stations||HB.stations.length<6)
         return 'SKIP: only '+((HB&&HB.stations)?HB.stations.length:0)+' stations on the floor';
       var walked=0;
       for(i=0;i<HB.stations.length;i++){
         var id=HB.stations[i].id, before=caught.length, threw=null;
         try{ __station(id); }catch(e){ threw=String(e&&e.message||e); }
         if(threw) bad.push('walking up to '+id+' threw: '+threw);
         if(caught.length>before) bad.push(id+' threw when he pressed E: '+caught.slice(before).join(' / '));
         // SOMETHING HAS TO HAPPEN. A station that opens nothing is a dead end on
         // the floor, and a panel with nothing in it is worse than a locked door.
         var open=document.querySelector('.modal.on');
         var hub=document.getElementById('hub');
         if(open){
           var t=(open.textContent||'').replace(/\s+/g,' ').trim();
           if(t.length<40) bad.push(id+' opens '+open.id+' and it is empty on a fresh profile');
           open.classList.remove('on');
         } else if(!(hub&&hub.classList.contains('on'))){
           bad.push('pressing E at '+id+' does nothing at all');
         }
         walked++;
       }
       if(walked<6) bad.push('control: only '+walked+' stations were walked');
       // AND THE STASH READS RIGHT WITH NOTHING IN IT. Counted in CELLS, not in
       // text: an owned gun draws as an icon and has no words in it, which read
       // as an empty panel the first time I looked.
       __station('term');
       var sl=document.getElementById('stashgrid');
       if(!sl) bad.push('the stash screen has no grid to draw into');
       else {
         var tabs=document.querySelectorAll('#stashtabs .invtab');
         if(tabs.length<5) bad.push('the stash has only '+tabs.length+' tabs');
         function clickTab(name){ for(var q=0;q<tabs.length;q++) if((tabs[q].textContent||'').indexOf(name)===0){ tabs[q].click(); return true; } return false; }
         if(!clickTab('GUNS')) bad.push('there is no GUNS tab to press');
         else {
           if(prof.stashTab!=='gun') bad.push('pressing the GUNS tab does not switch to it');
           if(sl.querySelectorAll('.cell').length<1)
             bad.push('the GUNS tab counts his one gun and draws nothing, so a new player is told he has a gun and shown an empty shelf');
         }
         clickTab('SALVAGE');
         if(sl.querySelectorAll('.cell').length!==0)
           bad.push('control: SALVAGE draws cells on a profile that has never looted anything, so the tabs are not filtering');
         clickTab('ALL');
       }
       // CONTROL: the listener must be able to hear a throw, or every clean line
       // above is decoration. An error inside a handler does not reach the caller.
       var heard=caught.length;
       var boom=document.createElement('button');
       boom.onclick=function(){ throw new Error('zqx station control'); };
       document.body.appendChild(boom);
       try{ boom.click(); }catch(_bc){}
       document.body.removeChild(boom);
       if(caught.length===heard) bad.push('control: a deliberate throw inside a click was not heard, so this check cannot see a station break');
     } finally {
       window.removeEventListener('error',onErr);
       for(i=0;i<F.length;i++) prof[F[i]]=keep[F[i]];
       try{ var op=document.querySelectorAll('.modal.on'); for(i=0;i<op.length;i++) op[i].classList.remove('on'); }catch(_cl){}
       try{ saveProfile(); }catch(_sp){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'11.10',what:'the bot never hides
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
