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

if ($s.Contains("  {v:'21.62',what:")) { throw "check 21.62 is in the fixture already" }

SubRx @'
  {v:'21.61',what:
'@ @'
  {v:'21.62',what:'a pillager shot from behind returns fire within half a second instead of waiting to have the shooter in his view cone',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof updateEnts!=='function'||typeof netShotTake!=='function') return 'SKIP: no raid here';
     if(typeof returnFire!=='function') return 'control: a shot pillager has no return fire';
     var NK={}, k, bad=[], g, e=null, i, E0, b0, fired=0, d, peer={seat:1,state:'in'};
     for(k in NET) NK[k]=NET[k];
     try{
       NET.on=false; NET.role=null; NET.peers=[];
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over) return 'SKIP: no live raid';
       for(i=0;i<g.ents.length;i++){ var c=g.ents[i]; if(c.kind==='raider'&&!c.merc&&!c.friendlyPC&&!c.downed&&c.hp>0&&c.wep&&c.wep.rng>200){ e=c; break; } }
       if(!e) return 'SKIP: staging: no armed pillager';
       d=Math.min(220,e.wep.rng*0.6);
       g.player.x=e.x+d; g.player.y=e.y;
       if(!losClear(e.x,e.y,g.player.x,g.player.y,g.vseg)) return 'SKIP: staging: no clear line to the pillager';
       e.hostile=true; e.face=Math.PI; e.state='patrol'; e.cd=0; e.acqT=0;
       NET.on=true; NET.role='host'; NET.seat=0; NET.peers=[peer]; NET.upSeed=g.seed>>>0;
       netEntsInit(g);
       netShotTake(peer,{t:'shot',id:e.nid,dmg:1,x:Math.round(g.player.x),y:Math.round(g.player.y)});
       NET.on=false; NET.role=null; NET.peers=[];
       E0=g.ents; g.ents=[e]; b0=g.bullets.length;
       for(i=0;i<8;i++){ updateEnts(0.05); }
       for(i=b0;i<g.bullets.length;i++) if(g.bullets[i]&&g.bullets[i].owner===e) fired++;
       g.ents=E0; E0=null;
       if(!fired) bad.push('a pillager shot from behind did not fire back within 0.4 seconds');
     }catch(ex){ bad.push('threw: '+(ex&&ex.message||ex)); }
     finally{
       try{ if(E0&&G) G.ents=E0; }catch(_r){}
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; g2.player.hp=g2.player.maxhp; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'21.61',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
