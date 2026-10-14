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

if ($s.Contains("  {v:'26.09',what:")) { throw "check 26.09 is in the fixture already" }

SubRx @'
  {v:'26.08',what:
'@ @'
  {v:'26.09',what:'his note: the crowbar does a lot more damage, three swings kill a crawler: a standard crawler at full health survives two Q swings and dies on the third (it took nine), the cooldown still refuses a second swing in the same instant, a bare-hands punch stays well under a crowbar blow, and a blow from behind is still 1.5 times as hard',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof meleeStrike!=='function'||typeof mkCrawler!=='function'||typeof fireWeapon!=='function'||typeof WEAPONS!=='object'||!WEAPONS.fists) return 'SKIP: this fixture cannot stage a swing';
     if(typeof NET==='object'&&NET&&NET.on) return 'SKIP: a party is live';
     var bad=[], g=null, p=null, E0=null, C=null, n=0, hp=[], h0=0, dBar=0, dFist=0, dBack=0, kk;
     function clr(){ for(var q in keys) keys[q]=false; }
     // a fresh standard (not elite) crawler 40 in front of him, facing the way given (PI is facing him, 0 is his back to him)
     function fresh(face){
       var c=null, t;
       for(t=0;t<80&&(!c||c.elite);t++) c=mkCrawler(p.x+40,p.y);
       if(!c||c.elite) return null;
       c.face=face; c.hp=c.maxhp; g.ents=[c]; p.meleeAt=undefined; p.lastShot=undefined; p.cooking=0; g.searching=null; g.trade=null; clr();
       return c;
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0);
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g&&g.player; if(!g||g.over||!p||!g.zones||!g.zones.length||!g.ents) return 'SKIP: no live raid';
       E0=g.ents; g.paused=false; p.downed=false; p.dying=false; p.roll=0; p.iv=99; p.x=g.zones[0].x; p.y=g.zones[0].y; p.face=0;
       // 1. HIS NUMBER: swing until it dies, a cooldown apart; it must take exactly three
       C=fresh(Math.PI); if(!C) return 'SKIP: no standard crawler could be made';
       h0=C.hp;
       while(n<14&&C.hp>0){ g.t+=0.5; if(!meleeStrike()){ bad.push('swing '+(n+1)+' was refused after the cooldown'); break; } n++; hp.push(Math.round(C.hp)); }
       if(!bad.length&&n!==3) bad.push('a standard crawler of '+h0+' health took '+n+' crowbar swings to kill (health after each: '+hp.join(', ')+'), not 3');
       // 2. the cooldown: a second swing in the same instant is refused
       C=fresh(Math.PI); if(C){ g.t+=0.5; if(!meleeStrike()) bad.push('the first swing of the cooldown case did not land'); else { dBar=h0-C.hp; if(meleeStrike()) bad.push('a second swing in the same instant was allowed: the cooldown is gone'); } }
       // 3. a plain bare-hands punch (the left click) stays well under a crowbar blow
       C=fresh(Math.PI); if(C){ fireWeapon(p,WEAPONS.fists,p.x+100,p.y,true); dFist=h0-C.hp; }
       if(!(dFist>0)) bad.push('the bare-hands punch did no damage');
       else if(!(dBar>=2*dFist)) bad.push('a crowbar blow did '+dBar+' against '+dFist+' for the bare-hands punch, under twice as much');
       // 4. from behind the blow is still 1.5 times as hard as from the front
       C=fresh(0); if(C){ g.t+=0.5; if(meleeStrike()){ dBack=h0-C.hp; if(!(dBar>0&&Math.abs(dBack-1.5*dBar)<0.01)) bad.push('a crowbar blow from behind did '+dBack+', not 1.5 times the front blow of '+dBar); } else bad.push('the swing from behind was refused'); }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ for(kk in keys) keys[kk]=false; }catch(_k){}
       try{ if(g){ g.barT=0; g.punchT=0; g.shake=0; if(E0) g.ents=E0; } }catch(_g){}
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.iv=0; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'26.08',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
