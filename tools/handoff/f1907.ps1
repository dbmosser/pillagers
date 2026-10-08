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

if ($s.Contains("  {v:'19.07',what:")) { throw "check 19.07 is in the fixture already" }

SubRx @'
  {v:'19.06',what:
'@ @'
  {v:'19.07',what:'the co-op HUD draws where it should: in a party at 4K the teammate row is on screen at the left, below the board, and the kill feed is on screen at the right',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame&&window.__forceSize)) return 'SKIP: this fixture cannot deploy at a forced size';
     if(typeof netTeamHud!=='function'||typeof netFeedDraw!=='function') return 'SKIP: no co-op HUD here';
     var bad=[], g, NK={}, k, oShown=netUpShown, oName=netSeatName, oFT=ctx.fillText, rows=[], feed=null;
     for(k in NET) NK[k]=NET[k];
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __pinDPR(1); }catch(_d){}
       __forceSize(3840,2160);
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); g.bagOpen=false; g.mapOpen=false;
       NET.on=true; NET.up=[{seat:1,hp:70,mh:100,ar:0,ac:0,x:g.player.x+40,y:g.player.y,dn:0}]; NET.feed=[{txt:'ZQ killed a sentry',at:Date.now(),me:0}];
       netUpShown=function(u){ return !!u; }; netSeatName=function(s){ return (s===1)?'ZQMATE':oName(s); };
       __frame(0.016); __frame(0.016);   // warm up: the board box is written as the board draws
       ctx.fillText=function(s,x,y){ var m=ctx.getTransform(), d=(typeof DPR==='number'&&DPR>0)?DPR:1, sx=(m.a*x+m.c*y+m.e)/d, sy=(m.b*x+m.d*y+m.f)/d; if(String(s)==='ZQMATE') rows.push([sx,sy]); if(String(s)==='ZQ killed a sentry') feed=[sx,sy]; return oFT.apply(this,arguments); };
       try{ __frame(0.016); } finally { delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; }
       if(!rows.length) bad.push('the teammate row was not drawn');
       else { if(rows[0][1]<0||rows[0][1]>H||rows[0][0]<0||rows[0][0]>W*0.4) bad.push('the teammate row lands at '+Math.round(rows[0][0])+','+Math.round(rows[0][1])+', not on the left of the screen');
         if(HUDBOX.raiders&&rows[0][1]<HUDBOX.raiders.y+HUDBOX.raiders.h) bad.push('the teammate row is inside the CURRENT PILLAGERS board'); }
       if(!feed) bad.push('the kill feed was not drawn');
       else if(feed[0]<W*0.5||feed[0]>W+1||feed[1]<0||feed[1]>H) bad.push('the kill feed lands at '+Math.round(feed[0])+','+Math.round(feed[1])+', off screen');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; netUpShown=oShown; netSeatName=oName; for(k in NET) if(!(k in NK)) delete NET[k]; for(k in NK) NET[k]=NK[k]; try{ cv.style.width='';cv.style.height='';hcv.style.width='';hcv.style.height=''; resize(); }catch(_f){} try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'19.06',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
