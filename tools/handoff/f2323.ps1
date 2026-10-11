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

if ($s.Contains("  {v:'23.23',what:")) { throw "check 23.23 is in the fixture already" }

SubRx @'
  {v:'23.22',what:
'@ @'
  {v:'23.23',what:'his order: an arcade extraction pays 2,500 plus the haul pot again, shows the EXTRACTED! banner and re-drops him 900 from every ring, nothing settled',
   run:function(){
     var bad=[], g, p, runs0, f, i, z, dm=1e9, d, oc, cx=null, own=false, seen=[], ft, z0, txt;
     try{
       __topClear(); __runPrep();
       if(typeof arcadeDeploy!=='function'||typeof ARCADE!=='object') return 'no arcadeDeploy in this build';
       if(typeof arcadeExtracted!=='function') return 'no arcadeExtracted in this build';
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); p=g.player; runs0=P.runs;
       for(f=0;f<3;f++) __loop(performance.now()+f*16.7);
       z0=g.zones&&g.zones[0];
       if(!z0) return 'SKIP: no ring on map 0';
       p.x=z0.x; p.y=z0.y; z0.beaconT=null; z0.hold=12; z0.holdMax=30; z0.pullT=1.0; p.hp=40;
       ARCADE.pot=300;
       __endRaid('extract');
       if(__state()!==g) bad.push('the arcade raid was ended or replaced by the extraction');
       if(g.over) bad.push('the arcade raid ended ('+g.over+')');
       if(!((ARCADE.mine|0)>=2800)) bad.push('ARCADE.mine is '+ARCADE.mine+', not 2,500 plus the pot of 300');
       if(ARCADE.pot!==0) bad.push('the pot was not paid out ('+ARCADE.pot+')');
       if(ARCADE.ext!==1) bad.push('ARCADE.ext is '+ARCADE.ext);
       if(!ARCADE.banner) bad.push('no banner');
       if(!(ARCADE.holdT>5)) bad.push('the re-drop hold is '+ARCADE.holdT);
       if(p.hp!==p.maxhp) bad.push('hp is '+p.hp+' of '+p.maxhp+' after the re-drop');
       if(z0.hold!=null||z0.pullT!=null) bad.push('the ring kept his hold or pull ('+z0.hold+', '+z0.pullT+')');
       for(i=0;i<g.zones.length;i++){ z=g.zones[i]; d=Math.hypot(p.x-z.x,p.y-z.y); if(d<dm) dm=d; }
       if(!(dm>=700)) bad.push('the re-drop is '+Math.round(dm)+' from a ring');
       if(typeof spotFree==='function'&&!spotFree(g.map,p.x,p.y,10)) bad.push('the re-drop spot is inside a wall');
       if(P.runs!==runs0) bad.push('a run was counted ('+runs0+' to '+P.runs+')');
       oc=document.getElementById('outcome');
       if(oc&&oc.classList.contains('on')) bad.push('the outcome card is on');
       if(!g.over&&__state()===g){
         cx=hcv.getContext('2d'); ft=cx.fillText; own=true;
         cx.fillText=function(s){ seen.push(String(s)); return ft.apply(this,arguments); };
         for(f=0;f<3;f++) __loop(performance.now()+(10+f)*16.7);
         if(!seen.length){ try{ drawHUD(); }catch(_dh){} }
         delete cx.fillText; own=false;
         txt=seen.join('|');
         if(txt.indexOf('EXTRAC'+'TED!')<0) bad.push('the banner was not drawn');
         if(txt.indexOf('TEAM SCORE 2,8'+'00')<0) bad.push('the banner shows no TEAM SCORE 2,800');
         for(f=0;f<320&&ARCADE.banner&&__state()===g;f++) __loop(performance.now()+(20+f)*16.7);
         if(ARCADE.banner) bad.push('the banner was still up after 320 frames');
         if(__state()!==g||g.over) bad.push('the raid did not go on after the re-drop');
       }
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       if(own&&cx){ try{ delete cx.fillText; }catch(_df){} }
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'23.22',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
