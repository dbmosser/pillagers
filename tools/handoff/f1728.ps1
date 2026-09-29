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

if ($s.Contains("  {v:'17.28',what:")) { throw "check 17.28 is in the fixture already" }

SubRx @'
  {v:'17.27',what:
'@ @'
  {v:'17.28',what:'on a linked window a downed pillager or a survivor from the window own build (a copy the host runs, never marked as one) is not offered and E neither picks him up nor pays him, while with no party both still are offered',
   run:function(){
     if(typeof updatePlayer!=='function'||typeof netEntsPeer!=='function'||typeof netEntMake!=='function'||typeof mkStray!=='function'||typeof strayGive!=='function'||!window.__deploy||!window.__endRaid) return 'SKIP: this build has no body copies';
     var keep={}, k, oSend=netSend, oCast=netBroadcast, oGive=strayGive, k0=keys, bad=[], dn=null, st=null, gave=0, MARK={zqx:1};
     for(k in NET) if(Object.prototype.hasOwnProperty.call(NET,k)) keep[k]=NET[k];
     function look(e){ G.nearDown=MARK; G.nearStray=MARK; G.revLock=0; G.strayLock=0; keys=e?{KeyE:true}:{}; updatePlayer(0.016); }
     try{
       __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!G||!G.player) return 'SKIP: staging: no raid';
       netSend=function(){ return true; }; netBroadcast=function(){}; strayGive=function(){ gave++; };
       G.player.downed=false; G.sim=0; G.over=false;
       dn=netEntMake(990011,'raider',G.player.x+20,G.player.y); delete dn.net; dn.downed=1; dn.bag=['medkit'];
       st=mkStray(G.player.x-20,G.player.y); st.nid=990012; st.nIn=1;
       G.ents.push(dn); G.ents.push(st);
       NET.on=false; look(false);
       if(G.nearDown===MARK) return 'SKIP: staging: the look did not run with no party';
       if(G.nearDown!==dn||G.nearStray!==st) return 'SKIP: staging: with no party the downed pillager or the survivor was not offered either';
       NET.on=true; NET.same=''; NET.role='join'; NET.seat=1; NET.upSeed=G.seed>>>0; NET.peers=[{state:'in',seat:0}]; NET.up=[];
       if(!netEntsPeer()) return 'SKIP: staging: this window does not count as linked to the host raid';
       look(false);
       if(G.nearDown===MARK||G.nearStray===MARK) return 'SKIP: staging: the look did not run on a linked window';
       if(G.nearDown===dn) bad.push('a downed pillager from this window own build, run by the host, is offered for pick up on a linked window');
       if(G.nearStray===st) bad.push('a survivor from this window own build, run by the host, is offered a hand over on a linked window');
       look(true);
       if(!dn.downed||dn.bag.length!==1) bad.push('E on a linked window picked the host pillager up on this window alone (downed '+dn.downed+', his pack '+dn.bag.length+')');
       if(gave) bad.push('E on a linked window paid the host survivor on this window alone');
     } finally {
       netSend=oSend; netBroadcast=oCast; strayGive=oGive; keys=k0||{};
       for(k in keep) NET[k]=keep[k];
       try{ if(G&&G.ents){ if(dn&&G.ents.indexOf(dn)>=0) G.ents.splice(G.ents.indexOf(dn),1); if(st&&G.ents.indexOf(st)>=0) G.ents.splice(G.ents.indexOf(st),1); G.nearDown=null; G.nearStray=null; G.revLock=0; G.strayLock=0; } __endRaid('abandon'); __topClear(); }catch(e){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'17.27',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
