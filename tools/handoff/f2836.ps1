$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $new = $new.Replace("`r`n", "`n")
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

if ($s.Contains("  {v:'28.36',what:")) { throw "check 28.36 is in the fixture already" }

SubRx @'
  {v:'28.35',what:
'@ @'
  {v:'28.36',what:'cloud-coop-p2-kept-kit: player 2 goes up with his kept kit (BEST KIT, RANDOM KIT) when the host lift R starts the raid or he drops in, as player 1 does, and a kit card he answered MY LOADOUT still wins',
   run:function(){
     if(!(window.__runPrep&&window.__topClear&&window.__P)) return 'SKIP: no hooks here';
     if(typeof netUpStart!=='function'||typeof netKitTake!=='function'||typeof kitFill!=='function'||typeof kitPickOf!=='function'||typeof startRaid!=='function'||typeof NET!=='object') return 'SKIP: no party or kit pick in this fixture';
     var bad=[], fills=[], NK={}, k, q, PS=null, oFill=kitFill, oStart=startRaid, oS=netSend, oSF=netSendFast, oB=netBroadcast, oG=G, oSt=state, staged=false, h={seat:0,state:'in',name:'HOST'}, r;
     function word(late){ var m={t:'up',seed:4242,mapIx:0,cond:'day',cfg:{},terms:[],merc:'',wx:'any'}; if(late) m.late=1; return m; }
     function stage(pick){ q=__P(); q.weapons=['pistol','smg','rifle','lmg']; q.equipped='pistol'; q.equippedSec='none'; q.kit=[]; q.hotAssign={}; q.freeKit=0; q.kitSaved=null; q.stash=['medkit','smoke','frag','bandage','stim','ammobox']; q.kitPick=pick; fills.length=0; G=null; state='hub'; }
     try{
       __topClear(); __runPrep();
       for(k in NET) NK[k]=NET[k];
       PS=JSON.stringify(__P());
       staged=true;
       kitFill=function(rnd){ fills.push(rnd?'rand':'best'); return oFill(rnd); };
       startRaid=function(){};
       netSend=function(){ return true; }; netSendFast=netSend; netBroadcast=function(){};
       NET.on=true; NET.role='join'; NET.seat=1; NET.peers=[h]; NET.specG=false; NET.kitWait=null;
       // ONE: the host lift R started the raid (no kit card): player 2 kept BEST KIT
       stage('best'); netUpStart(word(false));
       if(fills.join()!=='best') bad.push('ONE: the host word with no kit card filled ['+fills.join()+'] for a kept BEST KIT, not [best]');
       // TWO: a drop-in (lift R or JOIN THE RAID IN PROGRESS) with RANDOM KIT kept
       stage('rand'); netUpStart(word(true));
       if(fills.join()!=='rand') bad.push('TWO: the drop in word filled ['+fills.join()+'] for a kept RANDOM KIT, not [rand]');
       // THREE (control): the kit card was raised and he answered MY LOADOUT: the up word fills nothing
       stage('best'); r=netKitTake(h,{t:'kitask'});
       if(r!=='kit:ask') bad.push('THREE: staging: the kit ask was answered '+r);
       else { if(typeof ASKYES==='function') ASKYES(); fills.length=0; netUpStart(word(false));
         if(fills.length) bad.push('THREE: he answered MY LOADOUT on the kit card and the up word still filled ['+fills.join()+']'); }
       // FOUR (control): the kit card was raised and timed out unanswered: he goes up with his current kit, as the card says
       stage('best'); r=netKitTake(h,{t:'kitask'});
       if(r==='kit:ask'){ fills.length=0; netUpStart(word(false)); if(fills.length) bad.push('FOUR: the kit card timed out (current kit) and the up word filled ['+fills.join()+']'); }
       // FIVE: the card is spent: the next raid with no card takes the kept kit again
       stage('best'); netUpStart(word(false));
       if(fills.join()!=='best') bad.push('FIVE: the next host word after a kit card filled ['+fills.join()+'], not [best]');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       kitFill=oFill; startRaid=oStart; netSend=oS; netSendFast=oSF; netBroadcast=oB;
       if(staged){
         if(NET.kitWait&&NET.kitWait.tm) try{ clearTimeout(NET.kitWait.tm); }catch(_t){}
         for(k in NET) if(!Object.prototype.hasOwnProperty.call(NK,k)) delete NET[k];
         for(k in NK) NET[k]=NK[k];
         if(PS){ q=JSON.parse(PS); var P0=__P(); for(k in P0) if(!Object.prototype.hasOwnProperty.call(q,k)) delete P0[k]; for(k in q) P0[k]=q[k]; try{ saveProfile(); }catch(_sp){} }
       }
       G=oG; state=oSt; keys={};
       try{ var mo=document.querySelectorAll('.modal.on'); for(var j=0;j<mo.length;j++) mo[j].classList.remove('on'); }catch(_m){}
       try{ __topClear(); }catch(_tc){}
     }
     return bad.length?bad.join(' | '):null;
   }},
  {v:'28.35',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
