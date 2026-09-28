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

if ($s.Contains("  {v:'17.13',what:")) { throw "check 17.13 is in the fixture already" }

SubRx @'
  {v:'17.12',what:
'@ @'
  {v:'17.13',what:'while the host spectates, the kept raid makes no sound in his window: a teammate sound word reaches the sound player muted, his beacon call plays no beacon, a blip inside the kept raid plays nothing, and the host own click in the Undercroft still plays',
   run:function(){
     if(typeof netSpecStart!=='function'||typeof netOnMsg!=='function'||typeof netFxTake!=='function'||typeof netBeaconTake!=='function'||typeof _realBlip!=='function'||!window.__deploy||!window.__endRaid) return 'SKIP: this build has no spectating host or no real blip to trace';
     var keep={on:NET.on,role:NET.role,seat:NET.seat,upSeed:NET.upSeed,specG:NET.specG,specHow:NET.specHow,specTick:NET.specTick,specAcc:NET.specAcc,specIdle:NET.specIdle,specErr:NET.specErr,up:NET.up,upOut:NET.upOut,peers:NET.peers,roster:NET.roster,status:NET.status,fxIn:NET.fxIn,fxQ:NET.fxQ},
         oSend=netSend, oFast=netSendFast, oShown=netUpShown, oRef=netRefresh, oBlip=blip, oSfx=sfx, oAc=ac, keepG=G, bad=[], k, S=null, peer=null, heard=[], played=[], inB=null, r;
     function js(o){ return JSON.stringify(o); }
     try{
       __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!G||!G.player||!G.zones||!G.zones.length) return 'SKIP: staging: no live raid with a ring';
       peer={state:'in',seat:1,name:'ZQX MATE',timers:[],dc:{readyState:'open',send:function(){}}};
       netSend=function(){ return true; }; netSendFast=function(){ return true; }; netUpShown=function(g){ return !!g; }; netRefresh=function(){};
       NET.on=true; NET.role='host'; NET.seat=0; NET.upSeed=G.seed>>>0; NET.peers=[peer]; NET.up=[{seat:1,n:1}]; NET.upOut=undefined; NET.specG=null; NET.specTick=false;
       NET.roster=[{seat:0,name:'HOST',host:true},{seat:1,name:'ZQX MATE'}];
       if(!netSpecStart('dead')) return 'SKIP: staging: the host did not start to spectate';
       G.over=true; S=G; G=null;   // past his run card: he is in the Undercroft and the raid runs on for the party
       // A recorder in place of the audio device: a blip that gets as far as asking for it is written down, and nothing plays.
       ac=function(){ if(inB!==null) played.push(inB); return null; };
       blip=function(t){ var o=inB; inB=String(t); try{ return _realBlip.apply(null,arguments); } finally{ inB=o; } };
       sfx=function(t){ heard.push({t:String(t),mute:!!NET.specTick}); };
       // CONTROL: outside the kept raid his own click reaches the audio device.
       blip('pick');
       if(played.indexOf('pick')<0) return 'SKIP: staging: a click in the Undercroft never reached the recorder, so it cannot hear the kept raid';
       played=[];
       // A SOUND WORD FROM PLAYER 2: one of his rounds landing beside the host body.
       r=netOnMsg(peer,js({t:'fx',k:'n',s:1,n:[['hit',S.player.x+40,S.player.y]]}));
       if(r!=='fx:n') return 'SKIP: staging: the sound word was not taken against the kept raid ('+r+')';
       if(!heard.length) return 'SKIP: staging: the sound word never reached the sound player';
       if(heard.some(function(h){ return !h.mute; })) bad.push('a sound word from player 2 reached the sound player with the spectate mute off, so his hits play in the host Undercroft');
       // HIS BEACON CALL on the kept raid.
       r=netOnMsg(peer,js({t:'bcn',i:0,g:0.2}));
       if(r!=='called') return 'SKIP: staging: the beacon call was not taken against the kept raid ('+r+')';
       if(played.length) bad.push('player 2 calling the beacon played '+played.join(', ')+' in the spectating host window');
       played=[];
       // INSIDE THE KEPT RAID: a pillager going down calls blip directly, not sfx.
       NET.specTick=true; try{ blip('hit',100,0); } finally{ NET.specTick=false; }
       if(played.length) bad.push('a blip inside the kept raid played '+played.join(', ')+' in the spectating host window');
       played=[];
       // The mute is let go after each word, the window is back where it was, and his own click plays again.
       if(NET.specTick) bad.push('the spectate mute was left on after a word was handled');
       if(G!==null) bad.push('handling a word left the host window on the kept raid');
       blip('pick');
       if(played.indexOf('pick')<0) bad.push('after the party words the host own click in the Undercroft played nothing');
     } finally {
       ac=oAc; blip=oBlip; sfx=oSfx; netSend=oSend; netSendFast=oFast; netUpShown=oShown; netRefresh=oRef;
       for(k in keep) NET[k]=keep[k];
       if(S){ G=S; try{ if(G.player) G.player.specOut=0; }catch(e){} try{ __endRaid('abandon'); __topClear(); }catch(e){} }
       else { try{ if(G&&G!==keepG&&!G.over) __endRaid('abandon'); __topClear(); }catch(e){} }
     }
     return bad.length?bad.join('; '):null; }},
  {v:'17.12',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
