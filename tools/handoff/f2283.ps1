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

if ($s.Contains("  {v:'22.83',what:")) { throw "check 22.83 is in the fixture already" }

SubRx @'
  {v:'22.82',what:
'@ @'
  {v:'22.83',what:'far-off chatter stays off the screen: a pillager riding out of a ring 4000 away says no line and is still counted in the run report, his call for extraction 4000 away says nothing, and the same call 200 away still says his name',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__ents)) return 'SKIP: this fixture cannot deploy or step';
     var bad=[], g, p, e=null, z, i, realSay=say, said=[], keep=null, kz=null, n0, cnt, ents0=null;
     function named(){ var c=0; for(var j=0;j<said.length;j++) if(said[j].indexOf(e.name)>=0) c++; return c; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player||!g.tel) return 'SKIP: staging: no raid';
       p=g.player; p.iv=99; p.maxhp=100000; p.hp=100000; g.waveT=-1e9;
       z=g.active; if(!z) return 'SKIP: no active extraction ring';
       for(i=0;i<g.ents.length;i++) if(g.ents[i]&&g.ents[i].kind==='raider'&&g.ents[i].hp>0&&g.ents[i].name){ e=g.ents[i]; break; }
       if(!e) return 'SKIP: no pillager in this raid';
       ents0=g.ents.slice(); g.ents.length=0; g.ents.push(e);
       kz={o:z.open,b:z.beaconT,h:z.hold,gb:g.beaconT,gs:g.shipHold};
       keep={x:p.x,y:p.y};
       say=function(m){ said.push(String(m)); return realSay.apply(this,arguments); };
       // FAR: he rides out of the ring 4000 away. No line, and the run report still counts him.
       p.x=z.x+4000; p.y=z.y; if(p.x>WORLD_W-50) p.x=z.x-4000;
       e.state='extract'; e.x=z.x; e.y=z.y; e.extracting=99; e.hitT=0; e.goal=null; e.hostile=false; z.open=true; z.beaconT=null; z.hold=5;
       n0=g.tel.raidersExtracted||0;
       for(i=0;i<6&&g.ents.indexOf(e)>=0;i++){ e.state='extract'; e.x=z.x; e.y=z.y; __ents(0.05); }
       if(g.ents.indexOf(e)>=0) return 'SKIP: staging: the pillager in the ring did not ride out';
       cnt=named();
       if(cnt) bad.push('a pillager riding out 4000 away said '+cnt+' line(s): '+said.join(' | '));
       if((g.tel.raidersExtracted||0)!==n0+1) bad.push('the run report counted '+((g.tel.raidersExtracted||0)-n0)+' pillagers out, not 1');
       // HIS CALL: far says nothing, near says his name.
       if(typeof chatNear==='function'){
         said.length=0; g.ents.length=0; g.ents.push(e);
         z.hold=null; z.beaconT=null; z.open=true; if(z===g.active){ g.beaconT=null; g.shipHold=null; }
         e.state='extract'; e.x=z.x; e.y=z.y; e.extracting=0; e.rcallT=1.59; e.hp=Math.max(e.hp||0,50);
         __ents(0.05);
         if(z.beaconT===null||z.beaconT===undefined) bad.push('SKIP: staging: the pillager in the ring did not call extraction');
         else if(named()) bad.push('a pillager calling extraction 4000 away said a line: '+said.join(' | '));
         said.length=0;
         z.hold=null; z.beaconT=null; z.open=true; if(z===g.active){ g.beaconT=null; g.shipHold=null; }
         p.x=z.x+200; p.y=z.y; e.state='extract'; e.x=z.x; e.y=z.y; e.extracting=0; e.rcallT=1.59;
         if(g.ents.indexOf(e)<0) g.ents.push(e);
         __ents(0.05);
         if(z.beaconT!==null&&z.beaconT!==undefined&&!named()) bad.push('a pillager calling extraction 200 away said no line naming him');
       }
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       say=realSay;
       try{ if(z&&kz){ z.open=kz.o; z.beaconT=kz.b; z.hold=kz.h; g.beaconT=kz.gb; g.shipHold=kz.gs; } }catch(_z){}
       try{ if(keep&&p){ p.x=keep.x; p.y=keep.y; } }catch(_p){}
       try{ var g2=__state(); if(g2){ g2.msgT=0; g2.msg=''; g2.feed=[]; g2.msgQ=[]; g2.msgQM=[]; g2.alert=null; g2.alertQ=[]; g2.pick=[]; } if(g2&&!g2.over){ g2.player.downed=false; g2.player.iv=0; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     if(bad.length===1&&bad[0].indexOf('SKIP: ')===0) return bad[0];
     return bad.length?bad.join('; '):null; }},
  {v:'22.82',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
