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

if ($s.Contains("  {v:'20.56',what:")) { throw "check 20.56 is in the fixture already" }

SubRx @'
  {v:'20.55',what:
'@ @'
  {v:'20.56',what:'THE OVERSEER guards its lair: having lost you beside it, it stays home instead of heading for an extraction ring; sent far past its leash it goes home; and its unaware walks stay near the lair',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof bossTick!=='function'||typeof updateEnts!=='function') return 'SKIP: no raid or no boss in this fixture';
     if(typeof NET==='object'&&NET&&NET.on) return 'SKIP: a party is live';
     var bad=[], g, p, e=null, i, E0=null, oSay=say, px0=null, py0=null, cs, c=null, best=-1, d, far=0, n, cbOff=false;
     var home=function(){ e.x=e.lairX; e.y=e.lairY; e.overheat=0; e.blind=0; e.windup=null; e.state='patrol'; if(e.maxhp>0) e.hp=e.maxhp; };
     var step=function(){ if(typeof refreshVseg==='function') refreshVseg(); updateEnts(0.016); };
     try{
       __topClear(); __runPrep(); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       say=function(){};
       for(i=0;i<g.ents.length;i++) if(g.ents[i]&&g.ents[i].boss&&g.ents[i].hp>0){ e=g.ents[i]; break; }
       if(!e){ if(CFG.boss===0){ cbOff=true; CFG.boss=1; } g.t=Math.max(g.t||0,2.5); try{ e=bossTick(true); }catch(_bt){ e=null; } }
       if(!e||e.lairX===undefined) return 'SKIP: no Overseer in this raid';
       g.bossDone=1; g.lightning=0;
       p=g.player; px0=p.x; py0=p.y;
       cs=[[120,120],[WORLD_W-120,120],[120,WORLD_H-120],[WORLD_W-120,WORLD_H-120]];
       for(i=0;i<cs.length;i++){ d=Math.hypot(cs[i][0]-e.lairX,cs[i][1]-e.lairY); if(d>best){ best=d; c=cs[i]; } }
       p.x=c[0]; p.y=c[1]; p.downed=false;
       E0=g.ents; g.ents=[e];
       home(); e.seenYou=true; e.tx=e.lairX+30; e.ty=e.lairY; e.cd=5;
       step();
       d=Math.hypot(e.tx-e.lairX,e.ty-e.lairY);
       if(d>45) bad.push('having lost the player beside its lair it set off for a spot '+Math.round(d)+' away');
       home(); e.seenYou=true; e.tx=p.x; e.ty=p.y; e.cd=5;
       step();
       d=Math.hypot(e.tx-e.lairX,e.ty-e.lairY);
       if(d>1100) bad.push('sent '+Math.round(best)+' from its lair it kept going there ('+Math.round(d)+' out)');
       e.seenYou=false;
       for(n=0;n<6;n++){ home(); e.cd=0; e.tx=e.lairX; e.ty=e.lairY; step(); d=Math.hypot(e.tx-e.lairX,e.ty-e.lairY); if(d>far) far=d; }
       if(far>400) bad.push('not yet aware of anyone, it picked a walk '+Math.round(far)+' from its lair');
     }catch(ex){ bad.push('threw: '+(ex&&ex.message||ex)); }
     finally{
       say=oSay; if(cbOff) CFG.boss=0;
       try{ if(E0&&G) G.ents=E0; }catch(_r){}
       try{ if(G&&G.player&&px0!==null){ G.player.x=px0; G.player.y=py0; } }catch(_p){}
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'20.55',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
