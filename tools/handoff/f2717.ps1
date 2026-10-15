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

if ($s.Contains("  {v:'27.17',what:")) { throw "check 27.17 is in the fixture already" }

SubRx @'
  {v:'27.16',what:
'@ @'
  {v:'27.17',what:'his note: the gun card on pickup has a spot of its own, clear of CONDITIONS, the run goals, the kill feed and the pickup rows, standing on the gear readout',
   run:function(){
     if(!window.__deploy||!window.__endRaid||!window.__frame||typeof gunCardHud!=='function'||typeof gunCompare!=='function'||typeof EDGEBOX==='undefined'||!WEAPONS.dmr) return 'SKIP: this fixture cannot draw the gun card';
     var bad=[], g, hudWas=P.hud, netOn=NET.on, netFeed=NET.feed, i, gc, bx, nm, b, n=0;
     function hit(a,b2){ return !!a&&!!b2&&a.w>0&&b2.w>0&&a.x<b2.x+b2.w&&a.x+a.w>b2.x&&a.y<b2.y+b2.h&&a.y+a.h>b2.y; }
     function r(b2){ return Math.round(b2.x)+','+Math.round(b2.y)+' '+Math.round(b2.w)+'x'+Math.round(b2.h); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __pinDPR(1); }catch(_d){}
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       try{ careerPostBuild(g); }catch(_c){}
       g.bagOpen=false; g.mapOpen=false; g.ents.length=0; keys={};
       P.hud=hudWas?JSON.parse(JSON.stringify(hudWas)):{}; P.hud.cond={dx:0,dy:Math.round(H*0.22),c:false};
       NET.on=true; NET.feed=[]; for(i=0;i<4;i++) NET.feed.push({txt:'PLAYER 2 killed SENTRY '+i,me:false,at:Date.now()});
       say('Scrap Metal','pick',{item:'scrap',n:3}); say('Bandage','pick',{item:'bandage',n:1}); say('Armour Plate','pick',{item:'plate',n:2});
       g.gunCard={gk:'dmr',w:WEAPONS.dmr,vs:g.player.wep,route:'SLOT 2',t0:g.t||0};
       __frame(0.016); g.gunCard.t0=g.t||0; __frame(0.016);
       gc=GUNCARD_LAST;
       if(!gc||!(gc.w>0)) return 'SKIP: the gun card was not drawn';
       if(!HUDBOX.cond) return 'SKIP: no CONDITIONS panel here';
       bx=[['CONDITIONS',HUDBOX.cond],['the run goals',EDGEBOX.goals],['the kill feed',EDGEBOX.feed],['the pickup rows',EDGEBOX.pick]];
       for(i=0;i<bx.length;i++){ nm=bx[i][0]; b=bx[i][1]; if(b&&b.w>0) n++; if(hit(gc,b)) bad.push('the gun card ('+r(gc)+') covers '+nm+' ('+r(b)+')'); }
       if(HUDBOX.gear&&gc.y+gc.h>HUDBOX.gear.y+0.5) bad.push('the gun card ('+r(gc)+') runs into the gear readout ('+r(HUDBOX.gear)+')');
       if(gc.x<0||gc.y<0||gc.x+gc.w>W||gc.y+gc.h>H) bad.push('the gun card is off the screen ('+r(gc)+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ NET.on=netOn; NET.feed=netFeed; P.hud=hudWas; }catch(_r){} try{ var g2=__state(); if(g2){ g2.gunCard=null; g2.pick=[]; if(!g2.over){ g2.player.downed=false; __endRaid('abandon'); } } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'27.16',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
