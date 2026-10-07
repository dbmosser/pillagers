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

if ($s.Contains("  {v:'18.53',what:")) { throw "check 18.53 is in the fixture already" }

SubRx @'
  {v:'18.52',what:
'@ @'
  {v:'18.53',what:'a late out word belongs to its own raid: the word names its raid, a word about the last raid landing in the next one does not mark the teammate out of it, and one about this raid still does',
   run:function(){
     if(typeof netUpWord!=='function'||typeof netUpEnd!=='function'||typeof netUpAnnounce!=='function'||typeof netLateReply!=='function') return 'SKIP: no party raid words here';
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     var bad=[], NK={}, k, sent=[], oSend=netSend, oB=netBroadcast, oSay=say, oSWF=sayWhenFree, peer, sd, w;
     for(k in NET) NK[k]=NET[k];
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       netSend=function(p,m){ sent.push(m); return true; }; netBroadcast=function(m){ sent.push(m); };
       say=function(){}; sayWhenFree=function(){};
       NET.on=true; NET.role='join'; NET.seat=1; NET.max=4; NET.peers=[{seat:0,state:'in'}]; NET.lateBan=0; NET.upSeed=777;
       netUpEnd('abandon');
       w=sent.filter(function(m){ return m&&m.t==='up'&&m.st==='out'; })[0];
       if(!w||w.sd!==777) bad.push('the out word does not name its raid ('+(w?w.sd:'no word')+')');
       peer={seat:1,state:'in'}; NET.role='host'; NET.seat=0; NET.peers=[peer]; NET.lateOut={}; NET.upOut={};
       netUpAnnounce(__state()); sd=NET.upSeed>>>0;
       netUpWord(peer,{t:'up',st:'out',how:'extract',sd:(sd^0x5a5a)>>>0});
       if(NET.lateOut&&NET.lateOut[1]) bad.push('a late out word about the last raid marked the teammate out of this one');
       sent.length=0; netLateReply(peer);
       if(!sent.some(function(m){ return m&&m.t==='raid'; })) bad.push('the host refused the teammate the raid after a late word about the last one');
       netUpWord(peer,{t:'up',st:'out',how:'extract',sd:sd});
       if(!(NET.lateOut&&NET.lateOut[1])) bad.push('control: an out word about this raid did not mark the teammate out');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       netSend=oSend; netBroadcast=oB; say=oSay; sayWhenFree=oSWF;
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'18.52',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
