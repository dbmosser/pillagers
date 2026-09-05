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
  {v:'11.33',what:'the player-facing word for the pack is BACKPACK, not bag: the title controls line, the empty-panel hint and the full-pack message; and none of the three old strings survives anywhere the player reads',
'@ @'
  {v:'11.35',what:'the storm strike warning ring is drawn on the ground: a strike at the player position draws its ring at the centre of the screen, not off at the world coordinate as raw screen pixels',
   run:function(){
     if(!(window.__deploy&&window.__state&&(window.__frame||window.__loop))) return 'SKIP: this fixture cannot draw a raid frame';
     if(!__vpAlive()) return 'SKIP: the pane has no layout';
     var bad=[];
     __pinDPR(1); __forceSize(1920,1080);
     __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
     __deploy({kit:[],safe:null,mapIx:0,seed:4242});
     var g=__state(), p=g.player;
     if(!p) return 'SKIP: no player';
     var R=118, DPR=window.devicePixelRatio||1;
     // A strike centred on the player. Its ring must land at the centre of the
     // screen if it is drawn on the ground; if it is drawn in screen space with
     // the world coordinate, it lands near p.x*DPR, off the screen.
     if(!g.strikes) g.strikes=[];
     g.strikes.length=0;
     g.strikes.push({x:p.x, y:p.y, t:0.8, hit:0});
     var proto=CanvasRenderingContext2D.prototype, origArc=proto.arc, caught=[];
     proto.arc=function(cx,cy,r){
       if(r>=R-1.5&&r<=R+1.5){
         var m=(this.getTransform?this.getTransform():null);
         if(m){ var sx=m.a*p.x+m.c*p.y+m.e, sy=m.b*p.x+m.d*p.y+m.f; caught.push([sx/DPR, sy/DPR]); }
       }
       return origArc.apply(this,arguments);
     };
     var threw=null;
     try{
       // draw one frame; __frame is the draw path, __loop the fallback. Re-push
       // before each in case the call clears strikes.
       if(window.__frame){ g.strikes.length=0; g.strikes.push({x:p.x,y:p.y,t:0.8,hit:0}); __frame(16.7); }
       if(!caught.length&&window.__loop){ g.strikes.length=0; g.strikes.push({x:p.x,y:p.y,t:0.8,hit:0}); __loop(performance.now()); }
     }catch(e){ threw=String(e); }
     proto.arc=origArc;
     if(threw) return 'the strike frame threw: '+threw;
     if(!caught.length) return 'SKIP: no strike ring of radius '+R+' was drawn, so the warning ring path did not run in this frame';
     // THE FINDING. On the ground, a strike at the player's own world position
     // maps to where the player is drawn, which is ON the screen. Screen space
     // with the world coordinate lands at p.x,p.y raw, off the screen for any
     // world position past the viewport, which is nearly all of both maps.
     var W=innerWidth, H=innerHeight, cx=caught[0][0], cy=caught[0][1];
     if(cx<0||cx>W||cy<0||cy>H) bad.push('the strike ring for a strike at the player position drew off the screen at ('+Math.round(cx)+','+Math.round(cy)+'), viewport '+W+'x'+H+', so it is not on the ground');
     // CONTROL: a strike 400 world units east lands to the RIGHT of the player,
     // and still on the screen, which a screen-space draw at world x would not.
     caught.length=0;
     var ex=p.x+400;
     proto.arc=function(cx2,cy2,r){ if(r>=R-1.5&&r<=R+1.5){ var m=(this.getTransform?this.getTransform():null); if(m){ caught.push([( m.a*ex+m.c*p.y+m.e)/DPR, (m.b*ex+m.d*p.y+m.f)/DPR]); } } return origArc.apply(this,arguments); };
     try{ if(window.__frame){ g.strikes.length=0; g.strikes.push({x:ex,y:p.y,t:0.8,hit:0}); __frame(16.7); } if(!caught.length&&window.__loop){ g.strikes.length=0; g.strikes.push({x:ex,y:p.y,t:0.8,hit:0}); __loop(performance.now()); } }catch(e2){}
     proto.arc=origArc;
     if(caught.length){ var rx=caught[0][0];
       if(!(rx>cx+10)) bad.push('control: a strike 400 units east drew at x '+Math.round(rx)+', not to the right of the player-centred ring at '+Math.round(cx)+', so the ring does not track the world');
       if(rx>W) bad.push('control: the eastern strike drew off the right of the screen at x '+Math.round(rx)+', which is the screen-space bug');
     }
     __topClear();
     return bad.length?bad.join('; '):null; }},
  {v:'11.33',what:'the player-facing word for the pack is BACKPACK, not bag: the title controls line, the empty-panel hint and the full-pack message; and none of the three old strings survives anywhere the player reads',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
