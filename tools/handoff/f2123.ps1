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

if ($s.Contains("  {v:'21.23',what:")) { throw "check 21.23 is in the fixture already" }

SubRx @'
  {v:'21.22',what:
'@ @'
  {v:'21.23',what:'a Crier marks the player whose round woke it and plays its alarm once on player 2 window: a party round sets the marked seat, and the windup word adds no second alarm',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof NET!=='object'||!NET||typeof netShotTake!=='function'||typeof netMarkTake!=='function'||typeof netEntMake!=='function') return 'SKIP: no raid or party here';
     var NK={}, k, bad=[], oSfx=sfx, oSay=say, heard=[], g, c=null, i, d, peer1={seat:1,state:'in'};
     for(k in NET) NK[k]=NET[k];
     try{
       NET.on=false; NET.role=null; NET.peers=[];
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over) return 'SKIP: no live raid';
       for(i=0;i<g.ents.length;i++) if(g.ents[i].kind==='snitch'){ c=g.ents[i]; break; }
       if(!c) return 'SKIP: staging: no Crier';
       say=function(){}; sfx=function(t){ heard.push(String(t)); };
       NET.on=true; NET.role='host'; NET.seat=0; NET.peers=[peer1]; NET.upSeed=g.seed>>>0;
       netEntsInit(g);
       c.state='patrol'; c.markSeat=0;
       netShotTake(peer1,{t:'shot',id:c.nid,dmg:1,x:Math.round(c.x+100),y:Math.round(c.y)});
       if(c.state!=='alarm') return 'SKIP: staging: the round did not start the alarm';
       if(c.markSeat!==1) bad.push('a round from player 2 started the alarm but the Crier marks seat '+c.markSeat);
       NET.role='join'; NET.seat=1; NET.peers=[{seat:0,state:'in'}];
       d=netEntMake(952,'snitch',g.player.x+200,g.player.y); NET.entMap[952]=d; d.nIn=1; g.ents.push(d);
       heard=[];
       netMarkTake({seat:0,state:'in'},{t:'mark',k:'on',nid:952,wind:3.5,seat:1});
       if(heard.indexOf('alarm')>=0) bad.push('the windup word played a second alarm on player 2 window');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       sfx=oSfx; say=oSay;
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'21.22',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
