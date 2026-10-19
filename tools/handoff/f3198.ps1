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

if ($s.Contains("  {v:'31.98',what:")) { throw "check 31.98 is in the fixture already" }

SubRx @'
  {v:'31.97',what:
'@ @'
  {v:'31.98',what:'J5: hub pad View opens, all D-pad directions move, A picks up and places, Y drops a recoverable crate, B closes without keyboard events',
   run:function(){
     var ng=navigator.getGamepads,own=Object.prototype.hasOwnProperty.call(navigator,'getGamepads'),pk=Object.assign({},PAD),pp=P,ns=NET.same,no=NET.on,sv=saveProfile;
     var ao=ARCADE.on,at=ATT.on,wn=WNSEEN,st0=state,hb0=HB,g0=G,pad,bad=[],events=0,h,source,ix,drag,dropN,stashN,kitN;
     function keyEvent(){events++;}
     function poll(b){pad={connected:true,index:0,id:'Xbox J5',mapping:'standard',axes:[0,0,0,0],buttons:[]};for(var i=0;i<17;i++)pad.buttons.push({pressed:i===b,value:i===b?1:0});pollPad();}
     function tap(b){poll(-1);poll(b);poll(b);poll(-1);}
     function draw(){drawHubBag();h=hubBagG;}
     function select(key){draw();for(var i=0;i<h.bagCells.length;i++)if(h.bagCells[i].key===key){h.bagBelt=false;h.bagSel=h.bagCells[i].stackIx;return h.bagCells[i];}throw Error('staging: missing '+key+' tile');}
     try{
       P=JSON.parse(JSON.stringify(pp));saveProfile=function(){};
       __runPrep();__topClear();__resetCfg();__pinDefaults(0);__cleanProfile();NET.same=null;NET.on=false;ARCADE.on=false;ATT.on=false;WNSEEN=true;
       __hubEnter();__topClear();pauseOpen=false;hubBagOpenSet(false);
       [].forEach.call(document.querySelectorAll('.modal.on,.pausebox.on,#hub.on'),function(e){e.classList.remove('on');});
       P.weapons=[];P.equipped='fists';P.equippedSec='none';P.stash=['gun_rifle','gun_shotgun','medkit'];P.kit=P.stash.slice();P.hotAssign={};
       navigator.getGamepads=function(){return [pad];};PAD.prev=[];PAD.prevMap=null;PAD.mSpent=[];PAD.held={};PAD.announced=true;PAD.aSpent=true;PAD.focus=null;
       window.addEventListener('keydown',keyEvent,true);window.addEventListener('keyup',keyEvent,true);
       tap(8);if(!hubBagOpen||!hubBagG)return 'View did not open the floor backpack';draw();
       h.bagBelt=false;h.bagSel=0;tap(15);if(h.bagBelt||h.bagSel!==1)bad.push('D-right did not move once');
       h.bagBelt=false;h.bagSel=1;tap(14);if(h.bagBelt||h.bagSel!==0)bad.push('D-left did not move once');
       h.bagBelt=false;h.bagSel=0;tap(12);if(!h.bagBelt)bad.push('D-up did not reach the belt');
       h.bagBelt=true;h.bagBeltSel=0;tap(13);if(h.bagBelt||h.bagSel!==0)bad.push('D-down did not return to the grid');
       source=select('gun_shotgun');ix=source.bagIx;tap(0);drag=h.drag;
       if(!drag||drag.key!=='gun_shotgun'||!drag.pad)bad.push('A did not pick up the highlighted gun exactly once');
       // On the old build, stage a held item after recording the pickup failure so placing is tested independently too.
       if(!h.drag)h.drag={key:'gun_shotgun',bagIx:ix,pad:1};
       h.bagBelt=false;h.bagSel=0;h.bagBeltSel=0;tap(12);for(var j=0;j<4;j++)tap(15);
       if(!h.bagBelt||h.bagBeltSel!==4)bad.push('D-pad did not carry the held gun to belt key 5');
       h.bagBelt=true;h.bagBeltSel=4;draw();tap(0);
       if(h.drag||h.hotAssign[4]!=='gun_shotgun'||P.hotAssign[4]!=='gun_shotgun')bad.push('A did not place the gun on belt key 5');
       draw();if(h.bagCells.some(function(c){return c.key==='gun_shotgun';}))bad.push('placed gun did not move out of the backpack grid');
       // The shared helper must land on the tile in player 2, whose mouse listener reads client coordinates.
       source=select('gun_rifle');withHubBag(function(){NET.same='p2';try{bagPadAct();}finally{NET.same=null;}});
       if(!h.drag||h.drag.key!=='gun_rifle'||!h.drag.pad)bad.push('player 2 A missed the highlighted gun');
       h.drag=null;select('medkit');dropN=(HB.drops||[]).length;stashN=P.stash.length;kitN=h.bag.length;tap(3);
       if((HB.drops||[]).length!==dropN+1||HB.drops[dropN].k!=='medkit'||P.stash.length!==stashN-1||P.kit.length!==kitN-1||h.bag.indexOf('medkit')>=0)bad.push('Y did not drop exactly one packed medkit on the floor');
       else if(!(P.floorDrops||[]).some(function(d){return d.id===HB.drops[dropN].id&&d.k==='medkit';}))bad.push('Y drop is not recoverable after reload');
       if(keys.KeyE||keys.KeyF||keys.KeyR||keys.KeyT)bad.push('bag buttons leaked into station controls');
       tap(1);if(hubBagOpen||hubBagG)bad.push('B did not close the floor backpack');
       if(P.hotAssign[4]!=='gun_shotgun')bad.push('closing lost the placed gun');
       if(events)bad.push('pad flow generated '+events+' keyboard events');
       return bad.length?bad.join('; '):null;
     }finally{
       window.removeEventListener('keydown',keyEvent,true);window.removeEventListener('keyup',keyEvent,true);
       try{padRelease();hubBagOpenSet(false);__endRaid('abandon');}catch(e){}__topClear();
       if(own)navigator.getGamepads=ng;else delete navigator.getGamepads;
       P=pp;saveProfile=sv;NET.same=ns;NET.on=no;ARCADE.on=ao;ATT.on=at;WNSEEN=wn;state=st0;HB=hb0;G=g0;
       Object.keys(PAD).forEach(function(k){delete PAD[k];});Object.assign(PAD,pk);
     }
   }},
  {v:'31.97',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
