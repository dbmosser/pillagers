$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# v12.80 CHECK, inserted before the v12.79 entry. Two arms on one staging, and
# the needle is assembled rather than written, so a check that greps the page
# cannot find this row in its own source. The control arm is the same man in the
# same place with no extraction waiting: the prompt must be drawn and the hold
# must run, or a missing prompt in the finding arm would only mean the overlay
# was never drawn at all.
SubRx @'
  {v:'12.79',what:'the price of walking out is the price he actually pays: with nothing banked the confirm button quotes no fine and the line afterwards announces none, while a character who has the XP still reads the full price and still pays exactly it (2026-09-08 first-hour audit)',
'@ @'
  {v:'12.80',what:'the downed screen stops offering a surrender it will not take: with an extraction waiting on the point he is lying in, the row says so and the key is refused as it always was, while in every other downed state the prompt is drawn and the hold runs (2026-09-07 audit)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__loop&&window.__keys&&window.__frame&&window.__textTrace&&window.__forceSize)) return 'SKIP: this fixture cannot deploy, press keys and read the drawn text';
     if(!window.innerWidth||!window.innerHeight) return 'SKIP: the pane is 0x0, nothing here can be drawn';
     if(typeof giveUpTick!=='function') return 'SKIP: this build has no surrender';
     var bad=[];
     // Assembled, never written whole, so the phrase cannot be found in the
     // source of the very check that is looking for it.
     var PROMPT='TO '+'SURRE'+'NDER', REFUSE='NO '+'SURRE'+'NDER';
     function arm(waiting){
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __pinDPR(1); __forceSize(1920,1080); }catch(_f){}
       __deploy({kit:[],mapIx:0,seed:4242});
       var g=__state(); if(!g||!g.player||!g.zones||!g.zones.length) return null;
       var p=g.player, z=g.active||g.zones[0], K=__keys(), k, i;
       for(k in K) delete K[k];
       g.ents.length=0;
       g.active=z; z.open=true;
       if(waiting){ z.beaconT=0; g.beaconT=0; g.shipHold=20; z.hold=20; p.x=z.x; p.y=z.y; }
       else { z.beaconT=null; g.beaconT=null; g.shipHold=null; z.hold=null;
              p.x=z.x+(z.r+900); p.y=z.y; }
       p.hp=20; p.armor=0; p.iv=99; p.roll=0; p.cooking=0;
       p.revived=true; p.downed=true; p.downT=CFG.downTime; p.giveT=0; p.healLock=true;
       var clk=Math.max((typeof performance!=='undefined'&&performance.now)?performance.now():0,(lastTs||0)+100);
       K.Space=1;
       var peak=0;
       for(i=0;i<40;i++){ p.iv=99; p.downT=CFG.downTime; clk+=16.7; __loop(clk);
                          if((p.giveT||0)>peak) peak=p.giveT||0;
                          if(!p.downed||g.over) break; }
       var lines=[];
       try{ lines=__textTrace(function(){ __frame(0.016); }); }catch(_t){ }
       var txt=''; for(i=0;i<lines.length;i++) txt+=' | '+lines[i].t;
       var out={peak:peak,down:!!p.downed,over:!!g.over,txt:txt,
                prompt:txt.indexOf(PROMPT)>=0,refuse:txt.indexOf(REFUSE)>=0,
                verb:txt.indexOf('TO EXTRACT')>=0};
       for(k in K) delete K[k];
       return out;
     }
     var keepTs=lastTs;
     try{
       // CONTROL FIRST: the same man, downed with his revive spent, nowhere near
       // a waiting extraction. The prompt must be drawn and the hold must run, or
       // a missing prompt below would only say the overlay was never drawn.
       var B=arm(false);
       if(!B) return 'SKIP: no raid with an extraction point to lie down in';
       if(!B.down&&!B.over) return 'SKIP: he did not stay on the floor long enough to read the screen';
       if(!B.prompt) return 'SKIP: with no extraction waiting the downed screen did not draw the surrender row at all, so this check cannot see it and proves nothing';
       if(!(B.peak>0)) return 'SKIP: with no extraction waiting two seconds on the key started no hold, so this check cannot see a hold and proves nothing';
       // THE FINDING: downed inside a point with an extraction waiting, which is
       // the one state the key is refused in, on purpose, since v9.71.
       var A=arm(true);
       if(!A) return 'SKIP: no raid with an extraction point to lie down in';
       if(A.peak>0) bad.push('staging: the hold started inside a waiting extraction, so this is not the refused state the check is about');
       if(A.prompt) bad.push('with an extraction waiting on the point he is lying in the screen still offers the surrender, and the key does nothing: the row is drawn, the bar never comes, and nothing tells him why');
       if(!A.refuse) bad.push('with an extraction waiting the screen says nothing at all about the surrender being refused; the drawn text is ['+A.txt.slice(0,200)+']');
       if(!A.verb) bad.push('control: the working verb is not drawn in this state either, so the screen is not the one this check thinks it is reading');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ var K3=__keys(); for(var k3 in K3) delete K3[k3]; }catch(_k){}
       try{ lastTs=keepTs; }catch(_t2){}
       try{ var gz=__state(); if(gz&&gz.player){ gz.player.downed=false; gz.player.giveT=0; gz.player.iv=0; gz.player.revived=false; gz.player.healLock=false; } }catch(_a){}
       try{ var g2=__state(); if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'12.79',what:'the price of walking out is the price he actually pays: with nothing banked the confirm button quotes no fine and the line afterwards announces none, while a character who has the XP still reads the full price and still pays exactly it (2026-09-08 first-hour audit)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
