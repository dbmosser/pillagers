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

if ($s.Contains("  {v:'16.67',what:")) { throw "check 16.67 is in the fixture already" }

SubRx @'
  {v:'16.66',what:
'@ @'
  {v:'16.67',what:'while the host spectates from the Undercroft, the sounds of the kept raid still go out to the party in the same word the raid frame sends, and on the run card they are not sent twice',
   run:function(){
     if(typeof netSpecTick!=='function'||typeof netSpecStart!=='function'||typeof netFxStep!=='function'||typeof netFxNoise!=='function'||!window.__deploy||!window.__endRaid) return 'SKIP: this build has no spectating host or no party sounds';
     var keep={on:NET.on,role:NET.role,seat:NET.seat,upSeed:NET.upSeed,specG:NET.specG,up:NET.up,peers:NET.peers,specAcc:NET.specAcc,specIdle:NET.specIdle,specHow:NET.specHow,specErr:NET.specErr,status:NET.status,fxQ:NET.fxQ,fxAcc:NET.fxAcc,upN:NET.upN},
         oSend=netSend, oShown=netUpShown, oRef=netRefresh, oUE=updateEnts, bad=[], k, S=null, sent=[], ref=null, w=null, mk=0, made=null;
     function word(){ for(var j=0;j<sent.length;j++){ var m=sent[j]; if(m&&m.t==='fx'&&m.k==='n') return m; } return null; }
     function ours(m){ return !!(m&&m.n&&m.n.some(function(a){ return a&&a[0]==='clank'&&a[1]===4321&&a[2]===1234; })); }
     function shape(m){ return Object.keys(m).sort().join(','); }
     try{
       __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       netSend=function(q,m){ sent.push(m); return true; }; netUpShown=function(g){ return !!g; }; netRefresh=function(){};
       // The fixture stubs sfx, so the enemy step queues the sound the way the real sfx does, through netFxNoise.
       updateEnts=function(){ if(mk){ mk=0; made=netFxNoise('clank',4321,1234); } return oUE.apply(null,arguments); };
       NET.on=true; NET.role='host'; NET.seat=0; NET.upSeed=G.seed>>>0; NET.peers=[{state:'in',seat:1}]; NET.up=[{seat:1,n:1}];
       if(!netSpecStart('dead')) return 'SKIP: staging: the host did not start to spectate';
       G.over=true; S=G;
       // CONTROL, on the run card: the raid frame (netFxStep) sends the queued sound word.
       sent=[]; NET.fxQ=[['clank',4321,1234,'']]; NET.fxAcc=0; netFxStep(0.2); ref=word();
       if(!ours(ref)) return 'SKIP: staging: on the run card the raid frame sent no sound word, so there is nothing to compare';
       // On the run card the kept raid leaves it to the raid frame, so the word never goes twice.
       sent=[]; NET.fxQ=[['clank',4321,1234,'']]; NET.fxAcc=0; netSpecTick(0.2);
       if(ours(word())) bad.push('on the run card the kept raid sent the sound word itself as well as the raid frame');
       // THE FIX: in the Undercroft there is no raid frame, and a sound the kept raid makes still goes out.
       sent=[]; NET.fxQ=[]; NET.fxAcc=0; mk=1; G=null;
       netSpecTick(0.2); netSpecTick(0.2);
       G=S; w=word();
       if(mk) return 'SKIP: staging: the kept raid never stepped its enemies, so no sound was made';
       if(!made) return 'SKIP: staging: the kept raid did not count as shared, so the sound was never queued';
       if(!ours(w)) bad.push('a sound the kept raid made while the host was in the Undercroft never went out to the party ('+(NET.fxQ?NET.fxQ.length:0)+' still queued)');
       else if(shape(w)!==shape(ref)||w.s!==ref.s) bad.push('the sound word from the Undercroft is not the raid frame word ('+shape(w)+' against '+shape(ref)+')');
     } finally {
       updateEnts=oUE; netSend=oSend; netUpShown=oShown; netRefresh=oRef;
       if(S) G=S;
       for(k in keep) NET[k]=keep[k];
       try{ if(G&&G.player) G.player.specOut=0; }catch(e){}
       try{ __endRaid('abandon'); __topClear(); }catch(e){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'16.66',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
