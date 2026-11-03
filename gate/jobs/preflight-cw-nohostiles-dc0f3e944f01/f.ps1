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

if ($s.Contains("  {v:'37.41',what:")) { throw "check 37.41 is in the fixture already" }

SubRx @'
  {v:'37.40',what:
'@ @'
  {v:'37.41',what:'cw-nohostiles, his order of 11-02 (the hostiles closing in message is not helpful): with hostiles chasing near a called ring the extract banner still draws and no hostile count line does',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__textTrace)||typeof drawHUD!=='function') return 'SKIP: this fixture cannot stage';
     var bad=[], g=null, p=null, z, i, tr, live=[], banner=false, count=null;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile(); keys={};
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       p=g.player; g.bagOpen=false; g.mapOpen=false; p.downed=false;
       z=g.active; if(!z) return 'SKIP: staging: no ring';
       for(i=0;i<g.ents.length&&live.length<2;i++) if(g.ents[i]&&g.ents[i].hp>0) live.push(g.ents[i]);
       if(live.length<2) return 'SKIP: staging: fewer than two live hostiles';
       g.ents.length=0; g.ents.push(live[0],live[1]);
       live[0].state='chase'; live[1].state='chase'; live[0].x=z.x+400; live[0].y=z.y; live[1].x=z.x-400; live[1].y=z.y;
       g.beaconT=20; z.beaconT=20; g.shipHold=null; p.x=z.x; p.y=z.y;
       tr=__textTrace(function(){ drawHUD(); });
       for(i=0;i<tr.length;i++){ if(/HOSTILES? CLOSING/i.test(tr[i].t)) count=tr[i].t; if(/EXTRACT\s+\S+\s+INBOUND/i.test(tr[i].t)) banner=true; }
       if(count) bad.push('the hud still draws '+JSON.stringify(count));
       if(!banner) bad.push('the extract inbound banner did not draw, so this staging proves nothing');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       keys={};
       try{ var g2=__state(); if(g2&&!g2.over){ g2.beaconT=null; g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'37.40',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
