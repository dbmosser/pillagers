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

if ($s.Contains("  {v:'22.38',what:")) { throw "check 22.38 is in the fixture already" }

SubRx @'
  {v:'22.37',what:
'@ @'
  {v:'22.38',what:'extraction moments in the alert lane: calling for extraction by holding E in a ring draws EXTRACTION CALLED and then THE SIEGE within 4 s, the siege detail names how many are coming, and no line said is longer than 56 characters',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__loop&&window.__frame&&window.__keysRef)) return 'SKIP: this fixture cannot deploy, step or draw';
     if(window.__vpAlive&&!__vpAlive()) return 'SKIP: the pane has no layout, so the frame loop cannot draw';
     var bad=[], g, p, z=null, bd=1e9, d, i, j, t0, f=0, realSay=say, oFT=ctx.fillText, said=[], drawn={}, K, XC=['EXTRACTION','CALLED'].join(' '), SG=['THE','SIEGE'].join(' '), long=[], n=null, n0=0;
     function unspy(){ delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __pinDPR(1); }catch(_d){}
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       p=g.player; p.iv=99; p.maxhp=100000; p.hp=100000; g.ents.length=0; g.waveT=-1e9; g.mapOpen=false; g.bagOpen=false;
       g.msgT=0; g.msg=''; g.msgQ=[]; g.msgQM=[]; g.feed=[]; g.alert=null; g.alertQ=[];
       for(i=0;i<g.zones.length;i++){ if(g.zones[i].open===false) continue; d=Math.hypot(g.zones[i].x-p.x,g.zones[i].y-p.y); if(d<bd){ bd=d; z=g.zones[i]; } }
       if(!z) return 'SKIP: no open extraction ring here';
       say=function(m,k,o){ said.push({m:String(m),sub:String((o&&o.sub)||'')}); return realSay.apply(this,arguments); };
       t0=Math.max(performance.now(),(typeof lastTs==='number'&&isFinite(lastTs))?lastTs:0);
       K=__keysRef(); for(var k0 in K) delete K[k0];
       p.x=z.x; p.y=z.y; K['KeyE']=true;
       for(i=0;i<200&&(z.beaconT===null||z.beaconT===undefined);i++){ p.x=z.x; p.y=z.y; g.ents.length=0; n0=said.length; __loop(t0+(++f)*16.7); if(g.over) break; }
       for(var k1 in K) delete K[k1];
       if(z.beaconT===null||z.beaconT===undefined) return 'SKIP: holding E in the ring did not call for extraction here';
       said=said.slice(n0);   // from the frame that called, on
       for(i=0;i<80&&!g.over;i++){
         p.x=z.x; p.y=z.y; g.ents.length=0; __loop(t0+(++f)*50);
         if(i%4===3){
           ctx.fillText=function(t){ drawn[String(t)]=1; return oFT.apply(this,arguments); };
           try{ __frame(0.016); } finally { unspy(); }
         }
       }
       if(!drawn[XC]) bad.push('the call never drew '+XC+' as a headline in 4 s');
       if(!drawn[SG]) bad.push('the call never drew '+SG+' as a headline in 4 s');
       for(j=0;j<said.length;j++){
         if(said[j].m.length>56) long.push(said[j].m.length+': '+said[j].m.slice(0,70));
         if(said[j].sub.length>56) long.push(said[j].sub.length+': '+said[j].sub.slice(0,70));
         if(said[j].m===SG) n=(/(\d+) machine/.exec(said[j].sub)||[])[1]||null;
       }
       if(long.length) bad.push('lines longer than 56 characters were said: '+long.slice(0,3).join(' | '));
       if(drawn[SG]&&n===null) bad.push('the siege detail does not say how many are coming');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       unspy(); say=realSay;
       try{ var K2=__keysRef(); for(var k2 in K2) delete K2[k2]; }catch(_k){}
       try{ var g2=__state(); if(g2){ g2.msgT=0; g2.msg=''; g2.feed=[]; g2.msgQ=[]; g2.msgQM=[]; g2.alert=null; g2.alertQ=[]; } if(g2&&!g2.over){ g2.player.downed=false; g2.player.iv=0; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'22.37',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
