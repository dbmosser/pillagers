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

if ($s.Contains("  {v:'17.69',what:")) { throw "check 17.69 is in the fixture already" }

SubRx @'
  {v:'17.68',what:
'@ @'
  {v:'17.69',what:'his ruling 2026-10-02: with the host gone, a teammate up top keeps the raid and runs it alone: not ended, the enemies run under its own update, bodies known only from host words let go, THE OVERSEER made again at its health',
   run:function(){
     if(typeof netHostGone!=='function'||typeof netEntMake!=='function') return 'SKIP: this build has no party raid';
     if(!window.__deploy||!window.__endRaid||typeof NET!=='object'||!NET||typeof BOSS_NAME==='undefined') return 'SKIP: no raid, party or boss in this fixture';
     var NK={}, k, bad=[], oSwf=sayWhenFree, oSay=say, d, n0, r, boss, i, x0, moved=0, e;
     for(k in NET) NK[k]=NET[k];
     try{
       NET.on=false; NET.role=null; NET.peers=[];
       __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!G||G.over||!G.player) return 'SKIP: staging: no raid';
       sayWhenFree=function(){}; say=function(){};
       NET.on=true; NET.role='join'; NET.seat=1; NET.max=4; NET.peers=[{seat:0,state:'in'}]; NET.upSeed=G.seed>>>0;
       netEntsInit(G); G.t=30; G.bossDone=0;
       d=netEntMake(900,'warden',G.player.x+700,G.player.y); d.name=BOSS_NAME; d.maxhp=4000; d.hp=1000; d.r=44; NET.entMap[900]=d; d.nIn=1; G.ents.push(d);
       n0=G.ents.length;
       r=netHostGone('lost');
       if(!r) bad.push('the host going was ignored ('+r+')');
       if(!G||G.over) bad.push('the raid ended when the host was gone (over '+(G&&G.over)+')');
       else{
         if(netEntsPeer()) bad.push('the window still waits on host words for its bodies');
         if(G.ents.some(function(q){ return q&&q.net; })) bad.push('a body known only from host words stayed');
         boss=null; for(i=0;i<G.ents.length;i++) if(G.ents[i]&&G.ents[i].name===BOSS_NAME&&!G.ents[i].net){ boss=G.ents[i]; break; }
         if(!boss) bad.push('THE OVERSEER was not made again');
         else if(!(boss.hp>900&&boss.hp<1100)) bad.push('THE OVERSEER came back at '+boss.hp+' health, not about 1000');
         if(G.netLeft) bad.push('the run card would say '+JSON.stringify(G.netLeft));
         if(!/running/.test(NET.status||'')) bad.push('the player was told '+JSON.stringify(NET.status));
         for(i=0;i<G.ents.length;i++){ e=G.ents[i]; if(e&&e.kind==='crawler'&&!e.net){ e.state='chase'; e.tx=G.player.x; e.ty=G.player.y; e.seenYou=true; x0=e.x; break; } }
         if(x0!==undefined){ try{ updateEnts(0.1); updateEnts(0.1); }catch(_u){ bad.push('the enemies threw under this window own update: '+_u.message); } if(Math.abs(e.x-x0)<0.5&&Math.abs(e.y-(e.ty))>10) bad.push('a chasing crawler did not move under this window own update'); }
       }
     }catch(ex){ bad.push('threw: '+(ex&&ex.message||ex)); }
     finally{
       sayWhenFree=oSwf; say=oSay;
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
       try{ if(G){ G.netLeft=''; __endRaid('abandon'); } __topClear(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'17.68',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
