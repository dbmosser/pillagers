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

if ($s.Contains("  {v:'32.84',what:")) { throw "check 32.84 is in the fixture already" }

SubRx @'
  {v:'32.83',what:
'@ @'
  {v:'32.84',what:'the floor backpack on a pad: one item card (the focused cell), clear of the header row and the footer hint, and the keyboard chip clear of the location title',
   run:function(){
     var ng=navigator.getGamepads,own=Object.prototype.hasOwnProperty.call(navigator,'getGamepads'),pk=Object.assign({},PAD),pp=P,ns=NET.same,no=NET.on,sv=saveProfile;
     var ao=ARCADE.on,at=ATT.on,wn=WNSEEN,st0=state,hb0=HB,g0=G,pad,bad=[],h,mx0=mouse.x,my0=mouse.y;
     function poll(b){pad={connected:true,index:0,id:'Xbox J5',mapping:'standard',axes:[0,0,0,0],buttons:[]};for(var i=0;i<17;i++)pad.buttons.push({pressed:i===b,value:i===b?1:0});pollPad();}
     function tap(b){poll(-1);poll(b);poll(b);poll(-1);}
     function hit(a,b){return a&&b&&a.x<b.x+b.w&&b.x<a.x+a.w&&a.y<b.y+b.h&&b.y<a.y+a.h;}
     function at1(w,hh){
       var i,c,cards,bp,hd,ft,box,tag,r,sc,t,tb,hr;
       __forceSize(w,hh);__pinDPR(1);
       drawHubBag();h=hubBagG;
       for(i=0;i<h.bagCells.length;i++)if(h.bagCells[i].key==='gun_rifle'){h.bagBelt=false;h.bagSel=h.bagCells[i].stackIx;}
       drawHubBag();
       c=h.hotCells&&h.hotCells[4];if(!c)return w+': no belt cell 5';
       mouse.x=c.x+c.w/2;mouse.y=c.y+c.h/2;
       drawHubBag();BELTHOV.at=BELTHOV.at-1;drawHubBag();
       if(!padOn())return w+': staging: the stub pad is not the active input';
       cards=(h.bagCardBox?1:0)+(BELTHOV.box?1:0);
       if(!h.bagCardBox)return w+': the focused cell shows no card';
       if(cards!==1)bad.push(w+': '+cards+' item cards are up at once, wanted 1');
       bp=h.bagPanel;hr=Math.max(1,hudRes());
       hd=h.bagHead||{x:bp.x,y:bp.y,w:bp.w,h:Math.round(46*hr)};
       ft=h.bagFoot||{x:bp.x,y:bp.y+bp.h-Math.round(40*hr),w:bp.w,h:Math.round(40*hr)};
       box=h.bagCardBox;
       if(hit(box,hd))bad.push(w+': the item card covers the panel header row');
       if(hit(box,ft))bad.push(w+': the item card covers the footer hint row');
       if(BELTHOV.box&&hit(BELTHOV.box,ft))bad.push(w+': the belt card covers the footer hint row');
       kbMarkSet(true);tag=document.getElementById('kbmark');r=tag.getBoundingClientRect();
       t=cv.getBoundingClientRect();sc=t.width/W;
       ctx.save();ctx.font=FS(TYPE.head);tb={x:0,y:0,w:(16+ctx.measureText('THE UNDERCROFT').width)*hr*sc,h:48*hr*sc};ctx.restore();
       if(hit({x:r.left-t.left,y:r.top-t.top,w:r.width,h:r.height},tb))bad.push(w+': the keyboard chip sits over the location title');
       kbMarkSet(false);
       return null;
     }
     try{
       P=JSON.parse(JSON.stringify(pp));saveProfile=function(){};
       __runPrep();__topClear();__resetCfg();__pinDefaults(0);__cleanProfile();NET.same=null;NET.on=false;ARCADE.on=false;ATT.on=false;WNSEEN=true;
       __hubEnter();__topClear();pauseOpen=false;hubBagOpenSet(false);
       [].forEach.call(document.querySelectorAll('.modal.on,.pausebox.on,#hub.on'),function(e){e.classList.remove('on');});
       P.weapons=[];P.equipped='fists';P.equippedSec='none';P.stash=['gun_rifle','gun_shotgun','medkit'];P.kit=P.stash.slice();P.hotAssign={4:'gun_shotgun'};
       navigator.getGamepads=function(){return [pad];};PAD.prev=[];PAD.prevMap=null;PAD.mSpent=[];PAD.held={};PAD.announced=true;PAD.aSpent=true;PAD.focus=null;
       tap(8);if(!hubBagOpen||!hubBagG)return 'View did not open the floor backpack';
       var e1=at1(1920,1080);if(e1)bad.push(e1);
       var e2=at1(3840,2160);if(e2)bad.push(e2);
       return bad.length?bad.join('; '):null;
     }finally{
       try{kbMarkSet(false);__forceSize(1920,1080);}catch(e){}
       try{padRelease();hubBagOpenSet(false);__endRaid('abandon');}catch(e){}__topClear();
       mouse.x=mx0;mouse.y=my0;
       if(own)navigator.getGamepads=ng;else delete navigator.getGamepads;
       P=pp;saveProfile=sv;NET.same=ns;NET.on=no;ARCADE.on=ao;ATT.on=at;WNSEEN=wn;state=st0;HB=hb0;G=g0;
       Object.keys(PAD).forEach(function(k){delete PAD[k];});Object.assign(PAD,pk);
     }
   }},
  {v:'32.83',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
