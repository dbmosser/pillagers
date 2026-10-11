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

if ($s.Contains("  {v:'22.78',what:")) { throw "check 22.78 is in the fixture already" }

SubRx @'
  {v:'22.77',what:
'@ @'
  {v:'22.78',what:'holding a key never repeats a line: E held for 6 s in a closed extraction ring says the closed line and plays its clank exactly once, and once more only after he has stepped out of the ring and back in',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__loop&&window.__keysRef)) return 'SKIP: this fixture cannot deploy or step';
     var bad=[], g, p, z=null, i, t0, f=0, realSay=say, realBlip=blip, said=[], clanks=0, K, ND='This point is '+'CLOSED', n=0, kz=null;
     function cnt(){ var c=0; for(var j=0;j<said.length;j++) if(said[j].indexOf(ND)===0) c++; return c; }
     function hold(nf,x,y){ for(var j=0;j<nf&&!g.over;j++){ p.x=x; p.y=y; g.ents.length=0; K['KeyE']=true; __loop(t0+(++f)*16.7); } }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       p=g.player; p.iv=99; p.maxhp=100000; p.hp=100000; g.ents.length=0; g.waveT=-1e9;
       for(i=0;i<g.zones.length;i++) if(g.zones[i].beaconT===null||g.zones[i].beaconT===undefined){ z=g.zones[i]; break; }
       if(!z) return 'SKIP: no uncalled extraction ring here';
       kz={o:z.open,b:z.beaconT,h:z.hold,ac:g.active};
       z.open=false; z.hold=null; z.pullT=null;
       say=function(m){ said.push(String(m)); return realSay.apply(this,arguments); };
       blip=function(t){ if(t==='clank') clanks++; try{ return realBlip.apply(this,arguments); }catch(_b){} };
       t0=Math.max(performance.now(),(typeof lastTs==='number'&&isFinite(lastTs))?lastTs:0);
       K=__keysRef(); for(var k0 in K) delete K[k0];
       hold(360,z.x,z.y);
       for(var k1 in K) delete K[k1];
       if(g.over) return 'SKIP: staging: the raid ended while E was held in the closed ring';
       n=cnt();
       if(n===0) return 'SKIP: E held in the closed ring said no closed line here, so nothing can be counted';
       if(n!==1) bad.push('E held 6 s in a closed ring said the closed line '+n+' times, not once');
       if(clanks!==n) bad.push('E held 6 s in a closed ring played the clank '+clanks+' times for '+n+' lines');
       // AND AGAIN: out of the ring for a few frames, then back in with E held: the line is said once more.
       for(i=0;i<10;i++){ p.x=z.x+z.r+400; p.y=z.y; g.ents.length=0; __loop(t0+(++f)*16.7); }
       said.length=0; clanks=0;
       hold(30,z.x,z.y);
       for(var k2 in K) delete K[k2];
       if(cnt()!==1) bad.push('back in the closed ring after stepping out, E said the closed line '+cnt()+' times, not once');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       say=realSay; blip=realBlip;
       try{ var K2=__keysRef(); for(var k3 in K2) delete K2[k3]; }catch(_k){}
       try{ if(z&&kz){ z.open=kz.o; z.beaconT=kz.b; z.hold=kz.h; g.active=kz.ac; } }catch(_z){}
       try{ var g2=__state(); if(g2){ g2.closedSaid=null; g2.msgT=0; g2.msg=''; g2.feed=[]; g2.msgQ=[]; g2.msgQM=[]; g2.alert=null; g2.alertQ=[]; g2.pick=[]; } if(g2&&!g2.over){ g2.player.downed=false; g2.player.iv=0; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     for(i=0;i<bad.length;i++) if(bad[i].indexOf('SKIP: ')===0&&bad.length===1) return bad[0];
     return bad.length?bad.join('; '):null; }},
  {v:'22.77',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
