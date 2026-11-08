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

if ($s.Contains("  {v:'37.66',what:")) { throw "check 37.66 is in the fixture already" }

SubRx @'
  {v:'37.65',what:
'@ @'
  {v:'37.66',what:'every raid HUD panel drags, saves per window role and resets without firing',run:function(){
    if(typeof hudMoveGrab!=='function'||typeof hudLayoutReset!=='function') return 'fixed HUD elements have no drag or reset';
    var g, oldP, oldHUD, oldLayout, oldArc, oldWN, oldStale, oldSub, net0={}, stores={}, k, staged=false;
    var ids=['body','cond','gear','legend','mmap','raiders','clock','score','extract','extarrow','belt','air','team','feed','danger','chips'];
    function frame(){ __frame(0); drawHUD(); }
    function paint(id){
      // The folded f1 hint has no panel handle. Exercise the existing compact panel while it is open.
      g.legendOn=id==='legend'?1:0; g.legendAutoDone=true; g.legendExtDone=true;
      frame(); if(id==='extarrow') extEdgeArrow({za:true,z:g.zones[0],d:500,sx:W+500,sy:H/2});
    }
    function copyBox(b){ return b&&{x:b.x,y:b.y,w:b.w,h:b.h,tg:b.tg,move:b.move}; }
    function move(x,y){ var r=cv.getBoundingClientRect(); cv.dispatchEvent(new MouseEvent('mousemove',{clientX:r.left+x,clientY:r.top+y,bubbles:true})); }
    try{
      __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
      __deploy({kit:['gun_carbine','bandage','frag'],safe:null,mapIx:0,seed:4242});
      g=__state(); if(!g||!g.player||g.over) return 'no staged raid';
      oldP=P; oldHUD=P.hud; oldLayout=HUDLAYOUT; oldArc=ARCADE.on; oldWN=WNSEEN; oldStale=SAVE_STALE; oldSub=SETSUB;
      for(k in NET) net0[k]=NET[k]; staged=true;
      ARCADE.on=false; NET.seat=0; NET.same=false; SAVE_STALE=false; WNSEEN=1;
      for(var seat=0;seat<2;seat++){ NET.seat=seat; k=hudLayoutKey(); stores[k]=localStorage.getItem(k); localStorage.removeItem(k); } NET.seat=0;
      HUDLAYOUT={p:null,key:'',g:null};
      g.mapFirst=false; g.mapOpen=false; g.bagOpen=false; g.paused=false; pauseOpen=false; g.trade=null; g.wheel=null;
      hudLayoutReset(); keys={}; mouse.down=false;
      // Exercise actual draw paths, with active meter, chips, alert, feed and teammate.
      g.career=true; g.sim=false; g.raidLen=600; g.timeLeft=500; g.t=10; g.legendOn=0; CFG.mmSz=1;
      NET.on=true; NET.upSeed=g.seed>>>0; NET.roster=[{seat:0,name:'one'},{seat:1,name:'two'}];
      NET.up=[{seat:1,n:1,age:0,sd:g.seed>>>0,x:g.player.x+100,y:g.player.y,hp:80,mh:100}];
      airS().m=10; pwrS().act[PWR_KINDS[0].k]=30;
      feedAdd('layout check','info',{}); feedS().t=2;
      alertShow('location revealed','warn',{},g.t-1);
      var i,id,b,after,bar,dx,dy,mag=g.player.ammo,key=hudLayoutKey(), saved, offsets={}, baseline={};
      for(i=0;i<ids.length;i++){
        id=ids[i];
        hudLayoutReset(); paint(id); paint(id); b=copyBox(HUDBOX[id]);
        if(!b) return id+' draw path has no handle';
        baseline[id]=b; bar=hudBar(b); dx=b.x>W/2?-24:24; dy=b.y>H/2?-18:18;
        offsets[id]={dx:dx,dy:dy};
        // Keep the real drawn rectangle, isolating only input priority for this panel.
        HUDBOX={}; HUDBOX[id]=b;
        move(bar.x+Math.min(35,bar.w/3),bar.y+Math.min(5,bar.h/2)); cv.dispatchEvent(new MouseEvent('mousedown',{button:0,bubbles:true,cancelable:true}));
        if(!HUDDRAG||HUDDRAG.id!==id||mouse.down||g.drag) return id+' grab fired or opened an item';
        move(mouse.x+dx,mouse.y+dy); window.dispatchEvent(new MouseEvent('mouseup',{button:0,bubbles:true}));
        if(hudOff(id).dx!==dx||hudOff(id).dy!==dy||HUDDRAG||g.player.ammo!==mag) return id+' drag or release failed';
        saved=JSON.parse(localStorage.getItem(key)||'{}'); if(!saved[id]||saved[id].dx!==dx||saved[id].dy!==dy) return id+' was not saved';
        paint(id); after=HUDBOX[id];
        if(!after||Math.abs(after.x-b.x-dx)>1||Math.abs(after.y-b.y-dy)>1) return id+' drawn position did not follow the drag';
        P.hud={}; HUDLAYOUT.p=null; hudLayoutLoad(); paint(id); after=HUDBOX[id];
        if(!after||Math.abs(after.x-b.x-dx)>1||Math.abs(after.y-b.y-dy)>1) return id+' drawn position lost on reload';
        hudLayoutReset(); paint(id); after=HUDBOX[id];
        if(!after||Math.abs(after.x-b.x)>1||Math.abs(after.y-b.y)>1) return id+' drawn position did not reset';
      }
      hudLayoutReset(); frame();
      var cell=g.hotCells&&g.hotCells[0], cb=HUDBOX.clock;
      if(!cell||!cb) return 'no belt overlap staging';
      P.hud.clock={dx:cell.x-cb.x,dy:cell.y-cb.y}; frame(); cb=HUDBOX.clock;
      move(cell.x+5,cell.y+5); cv.dispatchEvent(new MouseEvent('mousedown',{button:0,bubbles:true,cancelable:true}));
      if(!HUDDRAG||HUDDRAG.id!=='clock'||g.drag||mouse.down) return 'clock grab opened the belt underneath';
      window.dispatchEvent(new MouseEvent('mouseup',{button:0,bubbles:true}));
      P.hud=offsets; hudLayoutSave();
      P.hud={}; HUDLAYOUT.p=null; hudLayoutLoad();
      for(i=0;i<ids.length;i++) if(hudOff(ids[i]).dx!==offsets[ids[i]].dx||hudOff(ids[i]).dy!==offsets[ids[i]].dy) return ids[i]+' lost on reload';
      NET.seat=1; HUDLAYOUT.p=null; hudLayoutLoad(); P.hud={clock:{dx:81,dy:42}}; hudLayoutSave();
      NET.seat=0; HUDLAYOUT.p=null; hudLayoutLoad(); if(hudOff('clock').dx!==offsets.clock.dx) return 'player 2 replaced player 1 layout';
      // v28.xx (cw-cx-hudmoveall): Settings wires ids through document, so exercise its real mounted list.
      SETSUB=''; renderSettings(); var reset=document.querySelector('#setlist #set_hudreset');
      if(!reset||typeof reset.onclick!=='function') return 'settings has no wired reset hud layout'; reset.click();
      for(i=0;i<ids.length;i++) if(hudOff(ids[i]).dx||hudOff(ids[i]).dy) return ids[i]+' did not reset';
      HUDLAYOUT.p=null; hudLayoutLoad(); if(Object.keys(P.hud).length) return 'reset did not persist';
      NET.seat=1; HUDLAYOUT.p=null; hudLayoutLoad(); if(hudOff('clock').dx!==81) return 'reset changed other window';
      return null;
    }finally{
      HUDDRAG=null; HUDRESIZE=null; mouse.down=false;
      try{__endRaid('abandon');}catch(_e){} __topClear();
      if(staged){
        P=oldP; P.hud=oldHUD; HUDLAYOUT=oldLayout; ARCADE.on=oldArc; WNSEEN=oldWN; SAVE_STALE=oldStale; SETSUB=oldSub;
        for(k in NET) if(!Object.prototype.hasOwnProperty.call(net0,k)) delete NET[k];
        for(k in net0) NET[k]=net0[k];
        for(k in stores){ if(stores[k]===null) localStorage.removeItem(k); else localStorage.setItem(k,stores[k]); }
        try{ renderSettings(); }catch(_setRestore){}
      }
    }
  }},
  {v:'37.65',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
