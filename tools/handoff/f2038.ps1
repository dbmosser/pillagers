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

if ($s.Contains("  {v:'20.38',what:")) { throw "check 20.38 is in the fixture already" }

SubRx @'
  {v:'20.37',what:
'@ @'
  {v:'20.38',what:'a Crier that marked player 2 never brands the host: the host gets no MARKED banner and no line, the party is told, and player 2 window gets the countdown, its line and its banner',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof NET!=='object'||!NET||typeof updateEnts!=='function'||typeof netEntMake!=='function') return 'SKIP: no raid or party here';
     var NK={}, k, bad=[], oSay=say, oBc=netBroadcast, lines=[], words=[], g, i, c=null, d, peer={seat:0,state:'in'}, w0;
     for(k in NET) NK[k]=NET[k];
     try{
       NET.on=false; NET.role=null; NET.peers=[];
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over) return 'SKIP: no live raid';
       for(i=0;i<g.ents.length;i++) if(g.ents[i].kind==='snitch'){ c=g.ents[i]; break; }
       if(!c) return 'SKIP: staging: no Crier on this map';
       say=function(s){ lines.push(String(s)); }; netBroadcast=function(w){ words.push(JSON.parse(JSON.stringify(w))); };
       NET.on=true; NET.role='host'; NET.seat=0; NET.peers=[]; NET.upSeed=g.seed>>>0;
       c.x=g.player.x+160; c.y=g.player.y; c.state='alarm'; c.wind=0.001; c.lost=0; c.markX=c.x; c.markY=c.y; c.markSeat=1; g.marked=0;
       updateEnts(0.05);
       if(c.wind!==null&&c.wind!==undefined) return 'SKIP: staging: the Crier windup did not run out';
       if(g.marked>0) bad.push('the host was branded MARKED by a Crier that marked player 2');
       if(lines.some(function(s){ return s.indexOf('raised the alarm')>=0; })) bad.push('the host was told a Crier raised the alarm on him');
       if(!words.some(function(w){ return w.t==='mark'&&w.k==='fire'&&w.seat===1; })) bad.push('player 2 was never told the Crier fired');
       netBroadcast=oBc; lines=[];
       NET.role='join'; NET.seat=1; NET.peers=[peer];
       d=netEntMake(951,'snitch',g.player.x+200,g.player.y); NET.entMap=NET.entMap||{}; NET.entMap[951]=d; d.nIn=1; g.ents.push(d);
       netMarkTake(peer,{t:'mark',k:'on',nid:951,wind:3.5,seat:1});
       if(!(d.wind>3.4)) bad.push('player 2 window has no countdown for the Crier on him ('+d.wind+')');
       if(!lines.some(function(s){ return s.indexOf('crier has you')>=0; })) bad.push('player 2 was not told a Crier has him');
       w0=d.wind; netEntsEase(1); if(!(d.wind<w0-0.9)) bad.push('the countdown on player 2 window does not run ('+w0+' to '+d.wind+')');
       g.marked=0; netMarkTake(peer,{t:'mark',k:'fire',nid:951,seat:1,sees:1});
       if(!(g.marked>2)) bad.push('player 2 window shows no MARKED banner when the Crier fires');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       say=oSay; netBroadcast=oBc;
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
       try{ var g2=__state(); if(g2&&!g2.over){ g2.marked=0; g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'20.37',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
