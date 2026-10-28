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

if ($s.Contains("  {v:'35.63',what:")) { throw "check 35.63 is in the fixture already" }

SubRx @'
  {v:'35.62',what:
'@ @'
  {v:'35.63',what:'cw-cx-hudtv: large for tv grows drawn vitals, ammo, minimap, belt and partner row in either seat; belt cells stay on screen above the corners; hub and text choice stay unchanged',
   run:function(){
     var c0=JSON.stringify(CFG), nk={}, k, us, hd, bad=[], g=null;
     function box(b){ return b?{x:b.x,y:b.y,w:b.w,h:b.h}:null; }
     function shot(tv){
       CFG.hudTv=tv; drawHUD(); drawHUD();
       return {body:box(HUDBOX.body),gear:box(HUDBOX.gear),map:box(MMAP.box),mate:box(NETTEAMBOX),cells:(g.hotCells||[]).map(box),top:VITBOX.top};
     }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       us=P.uiScale; hd=P.hud; P.uiScale=1.2; P.hud={};
       ['on','role','seat','roster','up','upSeed'].forEach(function(n){nk[n]=NET[n];});
       CFG.xfPix=0; CFG.minimap=1; CFG.mmSz=1;
       __deploy({kit:['gun_carbine','gun_smg','medkit','bandage','plate','frag','smoke'],mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'could not stage a raid';
       g.bagOpen=false; g.mapOpen=false; g.paused=false; g.legendOn=0; g.player.armor=40; g.player.stam=60; keys={}; mouse.down=false;
       for(var seat=0;seat<2;seat++){
         NET.on=true; NET.role=seat?'peer':'host'; NET.seat=seat; NET.upSeed=4242;
         NET.roster=[{seat:0,name:'player 1'},{seat:1,name:'player 2'}];
         NET.up=[{n:1,age:0,seat:1-seat,sd:4242,hp:75,mh:100,ar:40,ac:100,x:g.player.x+60,y:g.player.y+40}];
         var a=shot(0), b=shot(1);
         ['body','gear','map','mate'].forEach(function(n){
           if(!a[n]||!b[n]||!(a[n].w>0)) bad.push('seat '+seat+' missing '+n);
           else if(Math.abs(b[n].w/a[n].w-1.2)>0.025) bad.push('seat '+seat+' '+n+' width '+a[n].w+' -> '+b[n].w);
         });
         if(!a.cells.length||a.cells.length!==b.cells.length) bad.push('belt cells missing or changed count');
         else for(var i=0;i<b.cells.length;i++){
           var q=b.cells[i];
           if(q.w<a.cells[i].w*1.1) bad.push('seat '+seat+' belt slot '+i+' did not grow');
           if(q.x<0||q.y<0||q.x+q.w>W||q.y+q.h>H) bad.push('belt slot off screen');
           if(q.y+q.h>Math.min(b.top,b.gear.y)-LH(8)) bad.push('belt slot overlaps bottom corners');
           if(i&&q.x<b.cells[i-1].x+b.cells[i-1].w) bad.push('belt slots overlap');
         }
         if(P.uiScale!==1.2) bad.push('tv choice changed text size');
         CFG.hudTv=0; var z=hudRes(); CFG.hudTv=1; g.hubFloor=true;
         if(hudRes()!==z) bad.push('tv choice changed the hub');
         g.hubFloor=false;
       }
       return bad.length?bad.join('; '):null;
     }finally{
       for(k in nk) NET[k]=nk[k];
       if(g) g.hubFloor=false;
       try{__endRaid('abandon');}catch(_e){}
       for(k in CFG) delete CFG[k]; var old=JSON.parse(c0); for(k in old) CFG[k]=old[k];
       P.uiScale=us; P.hud=hd; keys={}; mouse.down=false; __topClear();
     }
   }},
  {v:'35.62',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
