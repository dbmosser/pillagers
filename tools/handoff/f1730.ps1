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

if ($s.Contains("  {v:'17.30',what:")) { throw "check 17.30 is in the fixture already" }

SubRx @'
  {v:'17.29',what:
'@ @'
  {v:'17.30',what:'a noise player 2 makes up top wakes nothing in his own window and goes to the host, where it wakes a sleeping Listener already scaled once',
   run:function(){
     if(typeof ping!=='function'||typeof netFxStep!=='function'||typeof netFxTake!=='function'||typeof netEntsPeer!=='function'||typeof netEntsHost!=='function'||typeof mkListener!=='function'||typeof NET!=='object'||!NET||!window.__deploy||!window.__endRaid) return 'SKIP: this build has no party noise';
     var keep={}, k, oSend=netSend, oRef=netRefresh, oSay=say, hadNm=Object.prototype.hasOwnProperty.call(CFG,'noiseMult'), nm0=CFG.noiseMult,
         bad=[], g=null, p=null, L=null, sent=[], r, i, got=null, hp={state:'in',seat:1}, LG=(CFG.listenGain===undefined?1.35:CFG.listenGain);
     for(k in NET) if(Object.prototype.hasOwnProperty.call(NET,k)) keep[k]=NET[k];
     try{
       __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=G; p=g&&g.player;
       if(!g||!p||!g.ents) return 'SKIP: staging: no live raid';
       if(!(LG>1.1)) return 'SKIP: staging: the Listener falloff is set too low to stage';
       netSend=function(q,m){ sent.push(m); return true; }; netRefresh=function(){}; say=function(){};
       L=mkListener(p.x+2000,p.y); L.state='dormant';
       g.ents.length=0; g.ents.push(L);
       NET.on=true; NET.role='join'; NET.seat=1; NET.upSeed=g.seed>>>0; NET.peers=[{state:'in',seat:0}]; NET.up=[]; NET.nzQ=[]; NET.nzAcc=0; NET.fxQ=[];
       if(!netEntsPeer()) return 'SKIP: staging: the window is not linked up top';
       ping(L.x+20,L.y,300,false,false,'player','move');
       if(L.state!=='dormant') bad.push('on the player 2 window his own step woke the copy of the Listener the host runs (state '+L.state+')');
       netFxStep(0.5);
       for(i=0;i<sent.length;i++) if(sent[i]&&sent[i].t==='fx'&&sent[i].k==='z'&&sent[i].z&&sent[i].z.length) got=sent[i];
       if(!got) bad.push('the player 2 window sent the host no word of his noise');
       L.state='dormant'; sent.length=0;
       NET.role='host'; NET.seat=0; NET.peers=[hp]; NET.fxQ=[];
       if(!netEntsHost()) return 'SKIP: staging: the window is not a host up top';
       CFG.noiseMult=0.5;
       r=netFxTake(hp,{t:'fx',k:'z',s:1,z:[[Math.round(L.x+300),Math.round(L.y),300,0,'move']]});
       if(L.state!=='hunt') bad.push('on the host a noise of strength 300 player 2 made 300 away did not wake the Listener, or was scaled a second time ('+r+', state '+L.state+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       netSend=oSend; netRefresh=oRef; say=oSay; if(hadNm) CFG.noiseMult=nm0; else delete CFG.noiseMult;
       for(k in NET) if(Object.prototype.hasOwnProperty.call(NET,k)&&!Object.prototype.hasOwnProperty.call(keep,k)) delete NET[k];
       for(k in keep) NET[k]=keep[k];
       try{ __endRaid('abandon'); __topClear(); }catch(e2){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'17.29',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
