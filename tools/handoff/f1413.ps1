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

SubRx @'
  {v:'14.12',what:
'@ @'
  {v:'14.13',what:'downed in an uncalled ring, the overlay offers the call and not another ring ship: with one ring called and the player down inside a different open ring, the HUD draws no EXTRACTION INBOUND and does draw the call row, while down inside the called ring it reads inbound (raid HUD and map screen audit 2026-09-15, finding 1)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__drawHUD)) return 'SKIP: this fixture cannot deploy or draw the HUD';
     if(typeof damagePlayer!=='function'||typeof standingRing!=='function') return 'SKIP: no downed ring logic in this build';
     var bad=[], realFill=null;
     var INB='EXTRACTION '+['IN','BOUND'].join(''), CALL='TO CALL FOR '+['EXTRAC','TION'].join('');
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __pinDPR(1); __forceSize(1920,1080); }catch(_fs){}
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g.player;
       if(!g||!p||g.sim) return 'SKIP: no live raid';
       if(!(g.zones&&g.zones.length>=2)) return 'SKIP: fewer than two extraction points';
       g.ents.length=0;
       var A=g.zones[0], B=g.zones[1];
       var seen=[];
       realFill=ctx.fillText;
       ctx.fillText=function(t){ seen.push(String(t)); return realFill.apply(ctx,arguments); };
       function downIn(z){
         for(var i=0;i<g.zones.length;i++){ var q=g.zones[i]; q.open=true; q.beaconT=null; q.hold=null; q.pullT=null; q.callT=0; }
         A.beaconT=20; g.active=A; g.beaconT=20;
         p.x=z.x; p.y=z.y; p.downed=false; p.downT=0; p.revived=false; p.dying=false; p.hp=20; p.armor=0; p.iv=0;
         damagePlayer(999,'sentry','PROBE UNIT NINE',p.x-2,p.y);
         if(!p.downed) return null;
         g.active=A; g.beaconT=20;
         seen.length=0; __drawHUD();
         return {inb:seen.some(function(t){ return t.indexOf(INB)>=0; }), call:seen.some(function(t){ return t.indexOf(CALL)>=0; })};
       }
       // CONTROL: down inside the called ring reads inbound.
       var C=downIn(A);
       if(C===null) return 'SKIP: the staged hit did not put him on the floor';
       if(!C.inb) return 'SKIP: down inside the called ring the overlay did not read inbound, so the trace cannot see it here';
       // THE FINDING: down inside a different, uncalled ring.
       var D=downIn(B);
       if(D&&D.inb) bad.push('down inside an open ring nobody called, the overlay read EXTRACTION INBOUND for a ship going to another ring');
       if(D&&!D.call) bad.push('down inside an open uncalled ring, the overlay did not offer the call for extraction');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       try{ if(realFill) ctx.fillText=realFill; }catch(_r){}
       try{ var g2=__state(); if(g2){ if(g2.player){ g2.player.downed=false; g2.player.hp=100; } if(!g2.over) __endRaid('abandon'); } }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'14.12',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
