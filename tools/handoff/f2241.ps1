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

if ($s.Contains("  {v:'22.41',what:")) { throw "check 22.41 is in the fixture already" }

SubRx @'
  {v:'22.40',what:
'@ @'
  {v:'22.41',what:'the in-ring INBOUND prompt steps aside: standing in the ring the band counts in, with extraction 20 s out, exactly one drawn line says INBOUND',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)) return 'SKIP: this fixture cannot deploy or draw';
     if(window.__vpAlive&&!__vpAlive()) return 'SKIP: the pane has no layout, so nothing is drawn';
     var bad=[], g, p, z=null, i, oFT=ctx.fillText, ev=[], n=0, kz=null;
     function unspy(){ delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __pinDPR(1); }catch(_d){}
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       p=g.player; g.ents.length=0; g.mapOpen=false; g.bagOpen=false; keys={};
       g.msgT=0; g.msg=''; g.msgQ=[]; g.msgQM=[]; g.feed=[]; g.alert=null; g.alertQ=[];
       for(i=0;i<g.zones.length;i++) if(g.zones[i].open!==false){ z=g.zones[i]; break; }
       if(!z) return 'SKIP: no open extraction ring here';
       kz={b:z.beaconT,h:z.hold,ac:g.active,gb:g.beaconT,x:p.x,y:p.y};
       p.x=z.x; p.y=z.y; p.downed=false; z.beaconT=Math.max(2,Math.min(20,CFG.extractWait-1)); z.hold=null; g.active=z; g.beaconT=z.beaconT; g.shipHold=null;
       ctx.fillText=function(t){ ev.push(String(t)); return oFT.apply(this,arguments); };
       try{ __frame(0.016); } finally { unspy(); }
       for(i=0;i<ev.length;i++) if(ev[i].indexOf('INBOUND')>=0) n++;
       if(n!==1) bad.push('standing in the called ring 20 s out, '+n+' drawn lines say INBOUND ('+ev.filter(function(t){ return t.indexOf('INBOUND')>=0; }).join(' | ')+'), not one');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       unspy(); keys={};
       try{ if(z&&kz){ z.beaconT=kz.b; z.hold=kz.h; g.active=kz.ac; g.beaconT=kz.gb; p.x=kz.x; p.y=kz.y; } }catch(_z){}
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'22.40',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
