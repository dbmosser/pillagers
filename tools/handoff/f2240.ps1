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

if ($s.Contains("  {v:'22.40',what:")) { throw "check 22.40 is in the fixture already" }

SubRx @'
  {v:'22.39',what:
'@ @'
  {v:'22.40',what:'no repeating called line: holding E for 6 s in a ring already called and still inbound never says the Called, Inbound line again',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__loop&&window.__keysRef)) return 'SKIP: this fixture cannot deploy or step';
     var bad=[], g, p, z=null, i, t0, f=0, realSay=say, said=[], K, ND='Called. '+'Inbound', n=0, kz=null, bt0=0;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       p=g.player; p.iv=99; p.maxhp=100000; p.hp=100000; g.ents.length=0; g.waveT=-1e9;
       for(i=0;i<g.zones.length;i++) if(g.zones[i].open!==false){ z=g.zones[i]; break; }
       if(!z) return 'SKIP: no open extraction ring here';
       kz={b:z.beaconT,h:z.hold,ac:g.active,gb:g.beaconT};
       if(!(CFG.extractWait>=10)) return 'SKIP: a call takes '+CFG.extractWait+' s here, too short to hold E for 6 s while inbound';
       bt0=CFG.extractWait; z.beaconT=bt0; z.hold=null; z.pullT=null; g.active=z; g.beaconT=bt0; g.shipHold=null;
       say=function(m){ said.push(String(m)); return realSay.apply(this,arguments); };
       t0=Math.max(performance.now(),(typeof lastTs==='number'&&isFinite(lastTs))?lastTs:0);
       K=__keysRef(); for(var k0 in K) delete K[k0];
       for(i=0;i<360&&!g.over;i++){ p.x=z.x; p.y=z.y; g.ents.length=0; K['KeyE']=true; __loop(t0+(++f)*16.7); }
       for(var k1 in K) delete K[k1];
       if(!(z.beaconT>0&&z.beaconT<bt0)) bad.push('SKIP: staging: the ring did not stay inbound while E was held ('+z.beaconT+')');
       for(i=0;i<said.length;i++) if(said[i].indexOf(ND)===0) n++;
       if(n) bad.push('holding E for 6 s in an inbound ring said the Called, Inbound line '+n+' times');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       say=realSay;
       try{ var K2=__keysRef(); for(var k2 in K2) delete K2[k2]; }catch(_k){}
       try{ if(z&&kz){ z.beaconT=kz.b; z.hold=kz.h; g.active=kz.ac; g.beaconT=kz.gb; } }catch(_z){}
       try{ var g2=__state(); if(g2){ g2.msgT=0; g2.msg=''; g2.feed=[]; g2.msgQ=[]; g2.msgQM=[]; g2.alert=null; g2.alertQ=[]; } if(g2&&!g2.over){ g2.player.downed=false; g2.player.iv=0; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     for(i=0;i<bad.length;i++) if(bad[i].indexOf('SKIP: ')===0&&bad.length===1) return bad[0];
     return bad.length?bad.join('; '):null; }},
  {v:'22.39',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
