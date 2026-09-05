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
  {v:'11.35',what:'the storm strike warning ring is drawn on the ground: a strike at the player position draws its ring at the centre of the screen, not off at the world coordinate as raw screen pixels',
'@ @'
  {v:'11.36',what:'a frag by the Peddler does not send him chasing and does not move his pitch; a frag by a downed pillager leaves him down; a frag by a live crawler still turns it to chase',
   run:function(){
     if(!(window.__deploy&&window.__state&&(window.__explodeFrag||window.__rawStep))) return 'SKIP: this fixture cannot explode a frag';
     var bad=[];
     function boom(fx,fy){ var g=__state(); if(!g.frags) g.frags=[]; var fr={x:fx,y:fy,t:0,fuse:0,by:null,r:0}; if(window.__explodeFrag){ __explodeFrag(fr); } else { g.frags.push(fr); __rawStep(0.15); } }
     // THE PEDDLER. A charge a stride from his stall.
     __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
     __deploy({kit:[],safe:null,mapIx:0,seed:4242});
     var g=__state(), p=g.player, PD=null, i;
     for(i=0;i<g.ents.length;i++) if(g.ents[i].kind==='peddler'){ PD=g.ents[i]; break; }
     if(!PD) return 'SKIP: no Peddler on this map';
     var st0=PD.state, tx0=Math.round(PD.tx||0), ty0=Math.round(PD.ty||0);
     p.x=PD.x+40; p.y=PD.y;
     boom(PD.x+20, PD.y);
     if(PD.state==='chase') bad.push('a frag by the stall put the Peddler into chase (was '+st0+')');
     if(Math.round(PD.tx||0)!==tx0||Math.round(PD.ty||0)!==ty0) bad.push('a frag by the stall moved the Peddler pitch from '+tx0+','+ty0+' to '+Math.round(PD.tx||0)+','+Math.round(PD.ty||0));
     // A DOWNED PILLAGER. A charge beside a man on the floor.
     __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
     __deploy({kit:[],safe:null,mapIx:0,seed:4242});
     g=__state(); p=g.player; var R2=null;
     for(i=0;i<g.ents.length;i++) if(g.ents[i].kind==='raider'&&!g.ents[i].merc){ R2=g.ents[i]; break; }
     if(R2){ R2.downed=1; R2.state='down'; R2.hp=Math.max(1,R2.hp*0.3); var dst=R2.state;
       p.x=R2.x+40; p.y=R2.y; boom(R2.x+20,R2.y);
       if(R2.state==='chase') bad.push('a frag by a downed pillager stood him into chase (was '+dst+', downed '+R2.downed+')'); }
     // CONTROL: a LIVE hostile crawler in the blast still turns to chase, so the
     // guard did not disarm the aggro the frag is supposed to cause.
     __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
     __deploy({kit:[],safe:null,mapIx:0,seed:4242});
     g=__state(); p=g.player; var CR=null;
     for(i=0;i<g.ents.length;i++){ var e=g.ents[i]; if((e.kind==='crawler'||e.kind==='sentry')&&!e.downed&&e.hp>0&&e.state!=='alarm'){ CR=e; break; } }
     if(CR){ var cs0=CR.state; p.x=CR.x+40; p.y=CR.y; CR.hp=CR.maxhp||CR.hp; boom(CR.x+20,CR.y);
       if(CR.hp>0&&CR.state!=='chase'&&CR.state!=='alarm') bad.push('control: a frag by a live '+CR.kind+' left it in '+CR.state+' rather than chase, so the guard disarmed the aggro (was '+cs0+')'); }
     else bad.push('control: no live crawler or sentry found to confirm the aggro still fires');
     __topClear();
     return bad.length?bad.join('; '):null; }},
  {v:'11.35',what:'the storm strike warning ring is drawn on the ground: a strike at the player position draws its ring at the centre of the screen, not off at the world coordinate as raw screen pixels',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
