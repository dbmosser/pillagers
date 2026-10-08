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

if ($s.Contains("  {v:'20.32',what:")) { throw "check 20.32 is in the fixture already" }

SubRx @'
  {v:'20.31',what:
'@ @'
  {v:'20.32',what:'when the host leaves, the bodies far from the players come back: a body taken off the map for having no rows is on it again, and an Overseer out of range is made again at its health, not marked done',
   run:function(){
     if(typeof netHostGone!=='function'||typeof netEntMake!=='function'||typeof netEntsInit!=='function') return 'SKIP: this build has no party raid';
     if(!window.__deploy||!window.__endRaid||typeof NET!=='object'||!NET||typeof BOSS_NAME==='undefined') return 'SKIP: no raid, party or boss in this fixture';
     var NK={}, k, bad=[], oSwf=sayWhenFree, oSay=say, d, i, far=null, boss;
     for(k in NET) NK[k]=NET[k];
     try{
       NET.on=false; NET.role=null; NET.peers=[];
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!G||G.over||!G.player) return 'SKIP: staging: no raid';
       sayWhenFree=function(){}; say=function(){};
       NET.on=true; NET.role='join'; NET.seat=1; NET.max=4; NET.peers=[{seat:0,state:'in'}]; NET.upSeed=G.seed>>>0;
       netEntsInit(G); G.t=30; G.bossDone=0;
       for(i=0;i<G.ents.length;i++){ if(G.ents[i]&&!G.ents[i].net&&G.ents[i].hp>0&&dist(G.ents[i],G.player)>1600){ far=G.ents[i]; break; } }
       if(!far) return 'SKIP: staging: no body far from the player';
       G.ents.splice(G.ents.indexOf(far),1); far.nIn=0;
       d=netEntMake(900,'warden',G.player.x+2400,G.player.y); d.name=BOSS_NAME; d.maxhp=4000; d.hp=1000; d.r=44; NET.entMap[900]=d; d.nIn=0;
       netHostGone('lost');
       if(!G||G.over) return 'the raid ended when the host left';
       if(G.ents.indexOf(far)<0) bad.push('a '+far.kind+' far from the players, off the map for want of rows, did not come back');
       boss=null; for(i=0;i<G.ents.length;i++) if(G.ents[i]&&G.ents[i].name===BOSS_NAME&&!G.ents[i].net){ boss=G.ents[i]; break; }
       if(!boss) bad.push('THE OVERSEER out of range was not made again (done '+G.bossDone+')');
       else if(!(boss.hp>900&&boss.hp<1100)) bad.push('THE OVERSEER came back at '+boss.hp+' health, not about 1000');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       sayWhenFree=oSwf; say=oSay;
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
       try{ if(G&&!G.over){ G.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'20.31',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
