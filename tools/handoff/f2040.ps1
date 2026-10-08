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

if ($s.Contains("  {v:'20.40',what:")) { throw "check 20.40 is in the fixture already" }

SubRx @'
  {v:'20.39',what:
'@ @'
  {v:'20.40',what:'a sound both windows make is heard once in each: a bolt from the host and its crack, and a teammate round landing, are played but never passed back to the party, while a sound only this window makes still is',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof NET!=='object'||!NET||typeof netWorldTake!=='function'||typeof strikeTick!=='function'||typeof netShotTake!=='function') return 'SKIP: no raid or party here';
     var NK={}, k, bad=[], oSfx=sfx, fw=[], g, i, peer={seat:0,state:'in'}, peer1={seat:1,state:'in'}, S=null, storm=null, e=null, wx0;
     for(i=0;i<WEATHER.length;i++) if(WEATHER[i].lightning){ storm=WEATHER[i]; break; }
     if(!storm) return 'SKIP: no lightning weather';
     for(k in NET) NK[k]=NET[k];
     try{
       NET.on=false; NET.role=null; NET.peers=[];
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over) return 'SKIP: no live raid';
       sfx=function(t){ if(!NET.fxIn) fw.push(String(t)); };   // the test page has its own sfx; this records whether a sound would be passed to the party (the real sfx passes it on unless NET.fxIn)
       NET.on=true; NET.role='join'; NET.seat=1; NET.peers=[peer]; NET.upSeed=g.seed>>>0;
       wx0=g.wx; g.wx=storm; g.strikeAt=99; g.strikes=[];
       netWorldTake(peer,{t:'wd',sd:g.seed>>>0,s:[[7771,Math.round(g.player.x+300),Math.round(g.player.y),0.5]]});
       for(i=0;i<g.strikes.length;i++) if(g.strikes[i].rid===7771) S=g.strikes[i];
       if(!S) return 'SKIP: staging: the host bolt did not arrive';
       if(fw.length) bad.push('a host bolt arriving was passed back to the party ('+fw.join(',')+')');
       fw=[]; S.t=0.001; strikeTick(0.01);
       if(fw.length) bad.push('a host bolt landing was passed back to the party ('+fw.join(',')+')');
       g.wx=wx0;
       fw=[]; NET.role='host'; NET.seat=0; NET.peers=[peer1];
       netEntsInit(g);
       for(i=0;i<g.ents.length;i++) if(g.ents[i].kind==='crawler'||g.ents[i].kind==='sentry'){ e=g.ents[i]; break; }
       if(e){
         netShotTake(peer1,{t:'shot',id:e.nid,dmg:1,x:Math.round(e.x),y:Math.round(e.y)});
         if(fw.indexOf('hit')>=0) bad.push('a teammate round landing on the host was passed back to the party');
       }
       fw=[]; if(typeof sfxHere==='function'){ sfxHere('clank',g.player.x,g.player.y); if(NET.fxIn) bad.push('a play-only sound left the pass-on switch set'); }
     }catch(ex){ bad.push('threw: '+(ex&&ex.message||ex)); }
     finally{
       sfx=oSfx;
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
       try{ var g2=__state(); if(g2&&!g2.over){ g2.strikes=[]; g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'20.39',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
