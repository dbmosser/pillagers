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

if ($s.Contains("  {v:'18.74',what:")) { throw "check 18.74 is in the fixture already" }

SubRx @'
  {v:'18.73',what:
'@ @'
  {v:'18.74',what:'the Overseer health bar waits until you see him: near but behind you it is hidden, once he is in view it shows, and it stays when he steps out of view',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)) return 'SKIP: this fixture cannot deploy';
     if(typeof drawBossBar!=='function'||typeof canSee!=='function'||typeof BOSS_NAME==='undefined') return 'SKIP: no boss bar here';
     var bad=[], g, p, e=null, i, oFT=ctx.fillText, seen=false, f, d, bx, by, ok=false, o0;
     function drawn(){ seen=false; ctx.fillText=function(s){ if(String(s)===String(e.name)) seen=true; return oFT.apply(this,arguments); }; try{ __frame(0.016); } finally { delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; } return seen; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g.player; g.bagOpen=false; g.mapOpen=false;
       for(i=0;i<g.ents.length;i++) if(g.ents[i]&&g.ents[i].name===BOSS_NAME&&g.ents[i].hp>0){ e=g.ents[i]; break; }
       if(!e&&typeof bossTick==='function'){ g.t=Math.max(g.t||0,2.5); try{ e=bossTick(true); }catch(_bt){ e=null; } }
       if(!e) return 'SKIP: no Overseer in this raid';
       o0={x:e.x,y:e.y}; g.bossRef=e; delete e.barSeen;
       __frame(0.016); f=p.face||0;
       e.x=p.x-Math.cos(f)*320; e.y=p.y-Math.sin(f)*320;
       if(canSee(p.x,p.y,p.face,e.x,e.y,g.vseg)) return 'SKIP: the spot behind the player is in view';
       if(drawn()) bad.push('the bar showed for an Overseer behind the player that he has not seen');
       for(d=100;d<=260&&!ok;d+=40){ bx=p.x+Math.cos(p.face)*d; by=p.y+Math.sin(p.face)*d; if(canSee(p.x,p.y,p.face,bx,by,g.vseg)){ e.x=bx; e.y=by; ok=true; } }
       if(!ok) return bad.length?bad.join('; '):'SKIP: no clear spot in front of the player';
       if(!drawn()) bad.push('control: the bar did not show with the Overseer in plain view');
       e.x=p.x-Math.cos(p.face)*320; e.y=p.y-Math.sin(p.face)*320;
       if(!drawn()) bad.push('the bar went away when a seen Overseer stepped behind the player');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{ delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; try{ if(e&&o0){ e.x=o0.x; e.y=o0.y; delete e.barSeen; } }catch(_r){} try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'18.73',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
