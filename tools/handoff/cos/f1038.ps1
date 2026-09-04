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
  {v:'10.37',what:'the message line scales with the monitor like the panels do',
'@ @'
  {v:'10.38',what:'the full controls list is centred, on the screen and clear of the conditions panel at 1080p, 1440p and 4K',
   run:function(){
     var bad=[];
     if(!__vpAlive()) return 'SKIP: the pane has no layout, nothing is drawn';
     if(!(window.__textTrace&&window.__deploy&&window.__frame&&window.__hudBox)) return 'SKIP: this fixture cannot read what the HUD draws';
     __resetCfg(); __pinDefaults(0); __cleanProfile();
     __deploy({kit:['medkit','frag','plate'],safe:null,mapIx:0,seed:4242});
     var g=__state(); if(!g) return 'SKIP: no raid';
     var p=g.player; p.hp=100000; p.maxhp=100000; g.ents.length=0;
     var SIZES=[[1920,1080],[2560,1440],[3840,2160]], keepLeg=g.legendOn;
     for(var si=0;si<SIZES.length;si++){
       var W=SIZES[si][0], H=SIZES[si][1];
       __pinDPR(1); __forceSize(W,H); g.legendOn=2;
       for(var f=0;f<10;f++) __frame(0.016);
       var tr=__textTrace(function(){ __frame(0.016); });
       var boxes=__hudBox()||{}, cond=boxes.cond;
       var move=null, hide=null, sound=null, rules=[];
       for(var i=0;i<tr.length;i++){
         var d=tr[i], t=String(d.t);
         if(t==='MOVE') move=d; else if(/^H  hide$/.test(t)) hide=d; else if(t==='SOUND') sound=d;
         else if(/they go to the backpack|keep one on a key|Plates top you up|selects, FIRE uses|in the stash or on the/.test(t)) rules.push(d);
       }
       if(!move||!hide) { bad.push('at '+W+'x'+H+' the full list did not draw its heading or its hide line'); continue; }
       // THE FINDING. On v10.37 at 4K the list was drawn at x 4797 on a 3840 wide
       // screen, and at 1080p the MOVE heading sat at y -52.
       function inside(d){ var x0=d.align==='right'?d.x-d.w:(d.align==='center'?d.x-d.w/2:d.x); return x0>=0&&x0+d.w<=W&&d.y>=0&&d.y<=H; }
       if(!inside(move)) bad.push('at '+W+'x'+H+' the MOVE heading is at '+Math.round(move.x)+','+Math.round(move.y)+', off the screen');
       if(!inside(hide)) bad.push('at '+W+'x'+H+' the hide line is at '+Math.round(hide.x)+','+Math.round(hide.y)+', off the screen');
       if(sound&&!inside(sound)) bad.push('at '+W+'x'+H+' the SOUND key is at '+Math.round(sound.x)+','+Math.round(sound.y)+', off the screen');
       // centred: the list spans from MOVE (left column) to the rule cards (right column)
       var left=move.x, right=0; for(var r=0;r<rules.length;r++) right=Math.max(right,rules[r].x+rules[r].w);
       if(right>left){ var mid=(left+right)/2; if(Math.abs(mid-W/2)>W*0.12) bad.push('at '+W+'x'+H+' the list is centred at x='+Math.round(mid)+', not near '+W/2); }
       // and clear of the conditions panel
       if(cond){ var hit=0; for(var q=0;q<rules.length;q++){ var rd=rules[q]; if(rd.x+rd.w>cond.x&&rd.x<cond.x+cond.w&&rd.y>cond.y&&rd.y<cond.y+cond.h) hit++; } if(hit) bad.push('at '+W+'x'+H+' '+hit+' rule lines sit inside the conditions panel'); }
     }
     // CONTROL: the compact legend still sits bottom left, inside the screen.
     __pinDPR(1); __forceSize(1920,1080); g.legendOn=1;
     for(var f2=0;f2<6;f2++) __frame(0.016);
     var lb=(__hudBox()||{}).legend;
     if(!lb) bad.push('control: the compact legend reports no box');
     else if(lb.x<0||lb.y<0||lb.x+lb.w>1920||lb.y+lb.h>1080||lb.x>400) bad.push('control: the compact legend moved to '+Math.round(lb.x)+','+Math.round(lb.y));
     g.legendOn=keepLeg;
     return bad.length?bad.join('; '):null; }},
  {v:'10.37',what:'the message line scales with the monitor like the panels do',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
