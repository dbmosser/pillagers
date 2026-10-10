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

if ($s.Contains("  {v:'22.08',what:")) { throw "check 22.08 is in the fixture already" }

SubRx @'
  {v:'22.07',what:
'@ @'
  {v:'22.08',what:'calling extraction, the siege pull every two seconds (on the host raid and on the raid kept for the party) and a party call leave the Peddler and the Survivor at their pitch, calm, and off the ring',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof NET!=='object'||!NET||typeof tryExtractTick!=='function'||typeof tickExtractPoints!=='function'||typeof netSpecRings!=='function'||typeof netBeaconTake!=='function') return 'SKIP: no raid, ring or party here';
     var NK={}, k, bad=[], g=null, p, z=null, zi=-1, i, e, N=[], peer={seat:1,state:'in'}, r;
     function stage(){ var j, q; for(j=0;j<N.length;j++){ q=N[j]; q.e.x=q.x; q.e.y=q.y; q.e.tx=q.x; q.e.ty=q.y; q.e.state='idle'; q.e.alert=0; q.e.pullZ=undefined; } }
     function look(when){ var j, q, nm; for(j=0;j<N.length;j++){ q=N[j]; nm=(q.e.kind==='peddler')?'the Peddler':'the Survivor';
       if(q.e.tx!==q.x||q.e.ty!==q.y) bad.push(when+' moved the pitch of '+nm+' to '+Math.round(q.e.tx-z.x)+','+Math.round(q.e.ty-z.y)+' from the ring');
       if(q.e.state!=='idle') bad.push(when+' left '+nm+' in '+q.e.state);
       if((q.e.alert||0)>=1) bad.push(when+' left '+nm+' alerted at '+(+q.e.alert).toFixed(1)); } }
     function siege(){ var j; stage(); for(j=0;j<g.ents.length;j++) if(g.ents[j].kind!=='peddler'&&g.ents[j].kind!=='stray') g.ents[j].pullZ=z; z.pullN=0; z.siege=1.99; z.siegeSpawnT=-1000; z.beaconT=20; z.hold=null; }
     for(k in NET) NK[k]=NET[k];
     try{
       NET.on=false; NET.role=null; NET.peers=[];
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player||!g.zones) return 'SKIP: staging: no raid';
       p=g.player;
       for(i=0;i<g.zones.length;i++) if(g.zones[i].open&&(g.zones[i].beaconT===null||g.zones[i].beaconT===undefined)){ z=g.zones[i]; zi=i; break; }
       if(!z) return 'SKIP: staging: no open ring';
       for(i=0;i<g.ents.length;i++){ e=g.ents[i]; if(e&&(e.kind==='peddler'||e.kind==='stray')&&e.hp>0) N.push({e:e,x:z.x+(e.kind==='peddler'?613.25:-587.75),y:z.y+(e.kind==='peddler'?211.5:-198.25)}); }
       if(!N.length) return 'SKIP: staging: no Peddler and no Survivor in this raid';
       stage();
       p.x=z.x; p.y=z.y; p.downed=false; z.callT=1.7; z.beaconT=null; z.hold=null; z.pullT=null;
       tryExtractTick(0.016,true);
       if(z.beaconT===null||z.beaconT===undefined) return 'SKIP: staging: standing in the ring with E held called nothing';
       look('calling extraction');
       siege(); tickExtractPoints(0.02);
       look('the siege pull');
       siege(); netSpecRings(0.02);
       look('the siege pull of the raid kept for the party');
       stage(); z.beaconT=null; z.hold=null; z.open=true;
       NET.on=true; NET.role='host'; NET.seat=0; NET.max=4; NET.peers=[peer]; NET.upSeed=g.seed>>>0;
       r=netBeaconTake(peer,{t:'bcn',i:zi,g:0});
       if(r!=='called') bad.push('staging: the host refused the party call ('+r+')');
       else look('a party call');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'22.07',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
