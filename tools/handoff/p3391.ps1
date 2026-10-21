$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
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

# PIXEL SETS AND FOUR RACKS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function pxBuildUpper(o){
'@ @'
function pxBuildUpper(o){
  if(pxIsSet(o.clothes))return pxSetUpper(o); // v28.xx (cw-cx-pixsets): the same upper rig for every set pose
'@

SubRx @'
function pxBuildLegs(o){
'@ @'
function pxBuildLegs(o){
  if(pxIsSet(o.clothes))return pxSetLegs(o); // v28.xx (cw-cx-pixsets): the existing gait clocks and frame indices
'@

SubRx @'
function pxBuildRoll(o){
'@ @'
function pxBuildRoll(o){
  if(pxIsSet(o.clothes))return pxSetRoll(o); // v28.xx (cw-cx-pixsets): a set stays on through a roll
'@

SubRx @'
var PXB_HEADS=['short','long','hood'], PXB_SKINS=['fair','tan','umber'], PXB_CLOTHS=['scav','recon','heavy'];
'@ @'
var PXB_HEADS=['short','long','hood'], PXB_SKINS=['fair','tan','umber'], PXB_CLOTHS=['scav','recon','heavy'];
// v28.xx (cw-cx-pixsets): his 10-20 23:05 order: three full body skins, on the existing pose rig, with the seat band.
var PXS_BONE=['#f0e4c0','#cabb95','#94866b','#5c5146'];
var PXS_DARK=['#626573','#3e404c','#262733','#151621'];
var PXS_WHITE=['#fff3ed','#dbd6db','#aaa5b6','#747083'];
var PXS_PALE=['#fff1e8','#eadbd5','#c8b8be','#948896'];
PXB_RAMP.skeleton={coat:PXS_BONE,trs:PXS_BONE,gear:PXS_DARK,pack:PXB_RAMP.scav.pack,acc:'#e2cf9b'};
PXB_RAMP.trooper={coat:['#a0af78','#748254','#4b593a','#2c3626'],trs:PXS_DARK,gear:['#c3c9a0','#919b71','#606b4b','#3b452e'],pack:PXB_RAMP.recon.pack,acc:'#edc86b'};
PXB_RAMP.android={coat:PXS_DARK,trs:PXS_DARK,gear:PXS_WHITE,pack:PXS_DARK,acc:'#e2d7ca'};
function pxIsSet(id){ return id==='skeleton'||id==='trooper'||id==='android'; }
function pxSetUpper(o){
  var p=pxPaint(o.mir), id=o.clothes, C=PXB_RAMP[id], bone=PXS_BONE, white=PXS_WHITE, dark=PXS_DARK, skin=PXS_PALE, x,y,m;
  if(id==='skeleton'){
    // v28.xx (cw-cx-pixsets): exposed ribs, spine and pelvis; a canvas pack and strap are the only clothing.
    p.put(pxRR(pxM(),4,25,10,38,2),C.pack);
    p.put(pxRect(pxM(),17,20,18,36),bone);
    for(y=23;y<=31;y+=3){
      p.put(pxSeg(pxM(),11,y,23,y,0.7),bone);
      p.P(11,y+1,bone[2]); p.P(23,y+1,bone[2]);
    }
    p.put(pxSeg(pxM(),11,22,24,22,1),bone);
    p.put(pxSeg(pxM(),11,34,15,37,1.2),bone); p.put(pxSeg(pxM(),24,34,20,37,1.2),bone);
    p.put(pxSeg(pxM(),10,23,23,34,0.7),C.pack);
    if(o.arms){
      p.put(pxSeg(pxM(),9,24,8,35,0.9),bone); p.put(pxSeg(pxM(),26,24,27,35,0.9),bone);
      p.put(pxRR(pxM(),7,35,10,38,1),bone); p.put(pxRR(pxM(),25,35,28,38,1),bone);
    }
    p.put(pxEll(pxM(),9,2,26,16),bone); p.put(pxRR(pxM(),12,13,23,19,1.5),bone);
    p.put(pxEll(pxM(),11,8,16,13),dark,{line:false}); p.put(pxEll(pxM(),20,8,25,13),dark,{line:false});
    p.P(17,13,dark[3]); p.P(18,13,dark[3]); p.P(17,14,dark[3]);
    for(x=13;x<=22;x+=3){p.P(x,17,bone[3]);p.P(x,18,bone[3]);}
    p.Pl(12,4,bone[0]); p.Pl(13,4,bone[0]);
  }else if(id==='trooper'){
    // v28.xx (cw-cx-pixsets): original split chest plates, square shoulders and a recessed gold visor; no emblem.
    p.put(pxRR(pxM(),3,19,10,38,1),C.pack);
    p.put(pxRR(pxM(),8,22,27,37,2),dark);
    p.put(pxRR(pxM(),9,21,17,29,1),C.coat); p.put(pxRR(pxM(),19,21,26,29,1),C.coat);
    p.put(pxRR(pxM(),11,30,24,35,1),C.coat); p.put(pxRect(pxM(),15,30,20,31),C.gear);
    p.put(pxRR(pxM(),4,20,10,27,1),C.coat); p.put(pxRR(pxM(),25,20,31,27,1),C.coat);
    if(o.arms){
      p.put(pxRR(pxM(),5,27,10,36,1),C.coat); p.put(pxRR(pxM(),25,27,30,36,1),C.coat);
      p.put(pxRR(pxM(),6,36,10,39,1),dark); p.put(pxRR(pxM(),25,36,29,39,1),dark);
    }
    p.put(pxRR(pxM(),6,0,29,20,4),C.coat); p.put(pxRect(pxM(),9,16,26,20),C.gear);
    p.put(pxRR(pxM(),9,6,26,14,2),dark);
    p.put(pxRR(pxM(),10,7,25,12,1),['#fff0b1','#ebc367','#b68035','#765027']);
    p.Pl(11,7,'#fff0b1'); p.Pl(12,7,'#fff0b1'); p.Pl(13,8,'#fff0b1');
    p.put(pxRect(pxM(),15,15,20,17),dark,{line:false}); p.Pl(8,3,C.coat[0]);
  }else{
    // v28.xx (cw-cx-pixsets): pale face, cropped white bob and a blindfold over a slim dark dress and tall boots.
    p.put(pxRR(pxM(),11,22,24,35,2),dark);
    m=pxM(); for(y=33;y<=40;y++)pxRect(m,11-Math.floor((y-33)/3),y,24+Math.floor((y-33)/3),y);
    p.put(m,dark); p.put(pxRect(pxM(),10,39,25,40),[dark[0],dark[1],dark[2],dark[3]],{line:false});
    p.put(pxRect(pxM(),16,19,19,23),skin);
    p.put(pxSeg(pxM(),14,23,17,27,0.6),white); p.put(pxSeg(pxM(),21,23,18,27,0.6),white);
    if(o.arms){
      p.put(pxRR(pxM(),8,23,11,30,1),skin);p.put(pxRR(pxM(),24,23,27,30,1),skin);
      p.put(pxRR(pxM(),8,30,11,38,1),dark);p.put(pxRR(pxM(),24,30,27,38,1),dark);
    }
    p.put(pxRR(pxM(),7,0,28,19,4),white);
    p.put(pxEll(pxM(),10,5,25,18),skin);
    p.put(pxRR(pxM(),7,1,28,8,3),white);p.put(pxRect(pxM(),7,8,10,18),white);p.put(pxRect(pxM(),25,8,28,18),white);
    p.put(pxRect(pxM(),10,10,25,13),dark,{line:false});p.Pl(12,9,white[0]);p.Pl(13,8,white[0]);p.P(18,16,skin[3]);
  }
  if(o.band){p.put(pxRect(pxM(),id==='android'?12:10,35,id==='android'?23:25,36),pixRamp(o.band),{line:false});p.P(15,35,o.band);p.P(16,35,o.band);}
  if(o.lamp){p.P(11,23,o.lamp);p.P(12,23,o.lamp);}
  if(o.low){p.Pl(14,27,'#8a1c14');p.Pl(15,27,'#b02a1e');}
  return p.sprite();
}
function pxSetLegs(o){
  var p=pxPaint(o.mir), id=o.clothes,C=PXB_RAMP[id], bone=PXS_BONE, dark=PXS_DARK, skin=PXS_PALE,sw=0,lA=0,lB=0,ph,k;
  if(o.kind==='w'||o.kind==='r'){
    ph=((o.fr|0)+0.5)/6*6.28318;sw=Math.sin(ph)*(o.kind==='r'?5:3.4);k=o.kind==='r'?3.4:2.2;
    lA=Math.max(0,Math.sin(ph))*k;lB=Math.max(0,-Math.sin(ph))*k;
  }
  function leg(cx,su,sl,lift,toe){
    var bt=49-lift, xx=Math.round(cx+su),foot=Math.round(cx+sl);
    if(id==='skeleton'){
      p.put(pxSeg(pxM(),cx,38,xx,44-lift,0.8),bone);p.put(pxSeg(pxM(),xx,45-lift,foot,bt+3,0.8),bone);
      p.put(pxRect(pxM(),foot-2,bt+3,foot+2,bt+4),bone);p.P(xx,44-lift,bone[0]);
    }else{
      p.put(pxRR(pxM(),cx-2+su,39,cx+2+su,bt,1),id==='android'?skin:C.trs);
      if(id==='trooper'){p.put(pxRR(pxM(),cx-3+su,39,cx+3+su,44-lift,1),C.coat);p.put(pxRR(pxM(),cx-2+sl,46-lift,cx+2+sl,bt+1,1),C.coat);}
      else p.put(pxRR(pxM(),cx-2+sl,44-lift,cx+2+sl,bt+2,1),dark);
      p.put(pxRR(pxM(),cx+(toe>0?-2:-4)+sl,bt,cx+(toe>0?4:2)+sl,bt+4,1),dark);
    }
  }
  if(o.kind==='c'){
    p.put(pxSeg(pxM(),12,43,15,48,id==='skeleton'?1:2),id==='skeleton'?bone:C.trs);
    p.put(pxSeg(pxM(),23,43,20,48,id==='skeleton'?1:2),id==='skeleton'?bone:C.trs);
    p.put(pxRR(pxM(),8,49,15,53,1),id==='skeleton'?bone:dark);p.put(pxRR(pxM(),20,49,27,53,1),id==='skeleton'?bone:dark);
  }else{
    if(id==='trooper')p.put(pxRR(pxM(),10,35,25,40,1),C.coat);
    leg(14,Math.round(-sw*.45),Math.round(-sw*.9),Math.round(lB),-1);leg(21,Math.round(sw*.45),Math.round(sw*.9),Math.round(lA),1);
  }
  return p.sprite();
}
function pxSetRoll(o){
  // v28.xx (cw-cx-pixsets): bend the actual set into the existing four roll angles at art resolution.
  var s=pixCanvas(64,64),lg=pxSetLegs({clothes:o.clothes,mir:o.mir,kind:'c',fr:0}),up=pxSetUpper({clothes:o.clothes,mir:o.mir,arms:1,band:o.band||''});
  s.x.imageSmoothingEnabled=false;s.x.translate(32,39);s.x.rotate((o.fr|0)*Math.PI/2);s.x.scale(.55,.55);
  s.x.drawImage(lg.c,-lg.ax,-lg.ay+24);s.x.drawImage(up.c,-up.ax,-up.ay+24);pixHarden(s,128);
  return pixSprite(pixRing(s.c,PIX_INK).c,33,64,PIX_ACT);
}
function pixSetCell(id,mir,band){
  var s=pixCanvas(PXB.W+2,PXB.H+2),lg=pxSetLegs({clothes:id,mir:mir||0,kind:'s',fr:0}),up=pxSetUpper({clothes:id,mir:mir||0,arms:1,band:band||''});
  s.x.drawImage(lg.c,0,0);s.x.drawImage(up.c,0,0);return s.c;
}
['skeleton','trooper','android'].forEach(function(id){pixReg('set '+id,function(){return pixSprite(pixSetCell(id,0,''),0,0,PIX_ACT);});});

// v28.xx (cw-cx-pixsets): his 10-20 22:50 order: head, skin, clothes and set. Old ids and saved picks stay intact.
var PIX_RACKS=[
  ['head',[['short',{hat:'none',cut:'crop'}],['long',{hat:'none',cut:'long'}],['hood',{hat:'hood'}]]],
  ['skin',[['fair',{skin:'fair'}],['tan',{skin:'tan'}],['umber',{skin:'umber'}]]],
  ['clothes',[['scav',{scheme:'schsand',pack:'packbrown'}],['recon',{scheme:'schdrab',pack:'packbrown'}],['heavy',{scheme:'schcharcoal',pack:'packbrown'}]]],
  ['set',[['off',{outfit:'outnone'}],['skeleton',{outfit:'outskeleton'}],['trooper',{outfit:'outtrooper'}],['android',{outfit:'outandroid'}]]]
];
function pixRawLook(){var lk={};for(var k in COSKEY)lk[k]=P[COSKEY[k]];return lk;}
function pixKeptOwned(kind,id){
  if((kind==='hat'&&(id==='none'||id==='hood'))||(kind==='cut'&&(id==='crop'||id==='long'))||(kind==='skin'&&PXB_SKINS.indexOf(id)>=0)||(kind==='scheme'&&['schsand','schdrab','schcharcoal'].indexOf(id)>=0)||(kind==='pack'&&id==='packbrown'))return true;
  var set=pixPick(PIX_SETS,id,'none');return kind==='outfit'&&(id==='outnone'||(set!=='none'&&pixOwned(set)));
}
function pixWear(kind,id,free){
  var rack=PIX_RACKS.filter(function(r){return r[0]===kind;})[0],tile=rack&&rack[1].filter(function(t){return t[0]===id;})[0];
  if(!tile||(!free&&kind==='set'&&id!=='off'&&!pixOwned(id)))return false;
  for(var k in tile[1])P[COSKEY[k]]=tile[1][k];
  return true;
}
// v28.xx (cw-cx-pixsets): twelve equally likely complete looks: nine ordinary looks balance all three axes, then one of each set.
function pixRollLook(n){
  n=n===undefined?Math.floor(Math.random()*12):Math.max(0,Math.min(11,n|0));
  var a=n%3,b=Math.floor(n/3)%3;
  return {hat:['none','none','hood'][a],cut:a===1?'long':'crop',skin:PXB_SKINS[b],scheme:['schsand','schdrab','schcharcoal'][(a+b)%3],pack:'packbrown',outfit:n<9?'outnone':['outskeleton','outtrooper','outandroid'][n-9],faceIx:0};
}
function pixRollWear(owned){
  var pool=[],i,lk,k;
  for(i=0;i<12;i++)if(i<9||!owned||pixOwned(['skeleton','trooper','android'][i-9]))pool.push(i);
  lk=pixRollLook(pool[Math.floor(Math.random()*pool.length)]);
  for(k in lk)if(COSKEY[k])P[COSKEY[k]]=lk[k];
  return lk;
}
var PIX_TILE_CACHE={},PIX_TILE_COUNT=0;
function pixTileCanvas(kind,id){
  var r=pixLook(pixRawLook()),set=kind==='set'&&id!=='off'?id:'none',head=r.head,skin=r.skin,clothes=r.clothes,src,s,y=0,h=PXB.H+2;
  if(kind==='head')head=id;if(kind==='skin')skin=id;if(kind==='clothes')clothes=id;
  var key=kind+'|'+id+'|'+head+'|'+skin+'|'+clothes;if(PIX_TILE_CACHE[key])return PIX_TILE_CACHE[key];
  src=set!=='none'?pixSetCell(set,0,''):pixBodyCell(head,skin,clothes,0,0,0);
  if(kind==='head'||kind==='skin')h=26;
  s=pixCanvas(src.width*2,h*2);s.x.imageSmoothingEnabled=false;s.x.drawImage(src,0,y,src.width,h,0,0,s.c.width,s.c.height);
  if(PIX_TILE_COUNT>=64){PIX_TILE_CACHE={};PIX_TILE_COUNT=0;}PIX_TILE_CACHE[key]=s.c;PIX_TILE_COUNT++;return s.c;
}
function pixAvatarHTML(){
  // v28.xx (cw-cx-pixsets): the existing turntable, with one set of controls in the racks on the right.
  return '<canvas class="avcv" id="avcv" width="380" height="470"></canvas>';
}
function renderPixWardrobe(box,hid,pid){
  var r=pixLook(pixRawLook()),H='';
  PIX_RACKS.forEach(function(rack){
    H+='<section class="pixrack" data-pixrack="'+rack[0]+'"><div class="glab">'+rack[0]+'</div><div class="pixtiles">';
    rack[1].forEach(function(t){
      var id=t[0],own=rack[0]!=='set'||id==='off'||pixOwned(id),on=r[rack[0]]===(id==='off'?'none':id),need='';
      if(!own)need=cosNeed(cosFind(t[1].outfit)).toLowerCase();
      H+='<button type="button" class="costile'+(own?'':' lock')+(on?' on':'')+'" data-pixkind="'+rack[0]+'" data-pixid="'+id+'" aria-pressed="'+on+'" aria-label="'+id+(need?', '+need:'')+'">'+
         '<canvas width="76" height="'+((rack[0]==='head'||rack[0]==='skin')?52:112)+'" style="image-rendering:pixelated"></canvas><span class="cosname">'+id+'</span><span class="cosreq">'+(own?(on?'worn':'owned'):need)+'</span></button>';
    });H+='</div></section>';
  });
  box.classList.add('pixwardrobe');box.innerHTML=H;
  [].forEach.call(box.querySelectorAll('[data-pixid]'),function(el){
    var kind=el.getAttribute('data-pixkind'),id=el.getAttribute('data-pixid'),cv=el.querySelector('canvas'),pic=pixTileCanvas(kind,id);
    cv.width=pic.width;cv.height=pic.height;cv.getContext('2d').drawImage(pic,0,0);
    el.onclick=function(){
      if(!pixWear(kind,id,false)){try{sfx('clank');}catch(e){}return;}
      saveProfile();try{sfx('pick');}catch(e){}
      if(hid&&document.getElementById(hid))renderAvatar(hid,pid);else renderPixWardrobe(box,hid,pid);
      var next=box.querySelector('[data-pixkind="'+kind+'"][data-pixid="'+id+'"]');if(next)next.focus();
    };
  });
}


// v28.xx (cw-cx-pixsets): same barT and punchT clocks, no hit, reach or cooldown changes. Art rotates at actor density.
function pxSetMelee(x,y,face,lk){
  var crow=!!(G&&G.barT>0),t=crow?1-Math.max(0,Math.min(1,G.barT/.22)):1-Math.max(0,Math.min(1,(G&&G.punchT||0)/.22)),q=Math.min(1,t/.85),a=crow?face-1.2217+2.4434*q*(2-q):face,step=((Math.round(a/(Math.PI/16))%32)+32)%32,m=wc.getTransform(),hand=lk.clothes==='skeleton'?PXS_BONE[1]:(lk.clothes==='trooper'?PXS_DARK[1]:PXS_PALE[1]);
  var fam='setmelee|'+lk.clothes+'|'+(crow?1:0),sp=pixFetch('actors',fam+'|'+step,function(){
    var s=pixCanvas(116,116),c=s.x;c.translate(58,58);c.rotate(step*Math.PI/16);c.fillStyle=PIX_INK;c.fillRect(0,-3,19,6);c.fillStyle=hand;c.fillRect(1,-2,17,4);
    if(crow){c.fillStyle='#88949c';c.fillRect(16,-2,36,4);c.fillRect(48,-7,4,7);c.fillStyle='#b6382c';c.fillRect(17,-2,8,4);}
    else{c.fillStyle=hand;c.fillRect(16,-4,6,8);}pixHarden(s,128);return pixSprite(s.c,58,58,PIX_ACT);
  },fam,step);if(sp)pxBlit(sp,x,y-PXB.PV,m);
}

'@

SubRx @'
  oid=hero?cosWorn('outfit'):st.outfit;
'@ @'
  oid=hero?P.cosOutfit:st.outfit; // v28.xx (cw-cx-pixsets): read saved picks without the old rack ownership filter
  var set=pixPick(PIX_SETS,oid,'none');
  if(set!=='none'&&(!hero||pixOwned(set)))return {head:'short',skin:'fair',clothes:set,bot:0};
'@

SubRx @'
  lk=hero?{hat:cosWorn('hat'),cut:cosWorn('cut'),skin:cosWorn('skin'),scheme:sc?sc.id:cosWorn('scheme'),fit:cosWorn('fit'),outfit:oid}
'@ @'
  lk=hero?{hat:P.cosHat,cut:P.cosCut,skin:P.cosSkin,scheme:P.cosScheme,fit:P.cosFit,outfit:oid} // v28.xx (cw-cx-pixsets): always-owned pixel picks are raw ids
'@

SubRx @'
         :{hat:st.hat,cut:st.cut,skin:st.skin,scheme:sc?sc.id:st.scheme,outfit:oid};
'@ @'
         :{hat:st.hat,cut:st.cut,skin:st.skin,scheme:st.scheme,fit:st.fit,outfit:oid}; // v28.xx (cw-cx-pixsets): the wire look matches its owner; seats use trim, not a clothes remap
'@

SubRx @'
  if(c&&c.kind===kind&&cosOwned(c)) return c.id;
'@ @'
  // v28.xx (cw-cx-pixsets): kept ids also travel through saved looks and NET_LOOK, with the old rules when off.
  if(c&&c.kind===kind&&typeof PIX_RACKS!=='undefined'&&PIX_RACKS&&pixOn()&&pixKeptOwned(kind,want))return c.id;
  if(c&&c.kind===kind&&cosOwned(c)) return c.id;
'@

SubRx @'
    if(c&&c.kind===k&&cosOwned(c)) P[COSKEY[k]]=c.id;
'@ @'
    if(c&&c.kind===k&&(cosOwned(c)||(pixOn()&&pixKeptOwned(k,c.id)))) P[COSKEY[k]]=c.id; // v28.xx (cw-cx-pixsets): saved pixel picks remain always owned
'@

SubRx @'
function hubRollLook(){
'@ @'
function hubRollLook(){
  if(pixOn())return pixRollLook(); // v28.xx (cw-cx-pixsets): the crowd uses the same twelve rolls as the demo
'@

SubRx @'
  P.cosAll=1;
  for(k in COSKEY){
'@ @'
  P.cosAll=1;
  if(pixOn()){pixRollWear(false);return true;} // v28.xx (cw-cx-pixsets): no cut ids on a demo roll
  for(k in COSKEY){
'@

SubRx @'
function lookRandom(){
'@ @'
function lookRandom(){
  if(pixOn()){pixRollWear(true);saveProfile();return;} // v28.xx (cw-cx-pixsets): surprise me keeps to the visible wardrobe
'@

SubRx @'
function lookLabel(L){
  if(!L) return 'empty';
'@ @'
function lookLabel(L){
  if(!L) return 'empty';
  if(pixOn()){var p=pixLook(L);return p.set!=='none'?p.set:[p.head,p.skin,p.clothes].join(' / ');} // v28.xx (cw-cx-pixsets): label saved looks through the same read-side cut
'@

SubRx @'
function avatarHTML(){
'@ @'
function avatarHTML(){
  if(pixOn())return pixAvatarHTML(); // v28.xx (cw-cx-pixsets): one control per pick, in the four racks
'@

SubRx @'
  var box=document.getElementById('apptabs'); if(!box) return;
  box.innerHTML='';
'@ @'
  var box=document.getElementById('apptabs'); if(!box) return;
  box.innerHTML='';
  if(pixOn())return; // v28.xx (cw-cx-pixsets): four racks fit on the existing page without tabs
'@

SubRx @'
  var box=document.getElementById(pid); if(!box) return;
  var slot=P._avSlot;
'@ @'
  var box=document.getElementById(pid); if(!box) return;
  if(pixOn()){renderPixWardrobe(box,hid,pid);return;} // v28.xx (cw-cx-pixsets): ignore a stale old slot in pixel mode
  box.classList.remove('pixwardrobe');
  var slot=P._avSlot;
'@

SubRx @'
  var box=target||document.getElementById('cosbody'); if(!box) return;
  var H='';
'@ @'
  var box=target||document.getElementById('cosbody'); if(!box) return;
  if(pixOn()){renderPixWardrobe(box,hid,pid);return;} // v28.xx (cw-cx-pixsets): the old nineteen groups stay below
  box.classList.remove('pixwardrobe');
  var H='';
'@

SubRx @'
function pixDrawOp(x,y,face,ph,coat,pk,muzzle,mode,iv,st){
'@ @'
function pixDrawOp(x,y,face,ph,coat,pk,muzzle,mode,iv,st){
  // v28.xx (cw-cx-pixsets): retain the set body during melee, with the existing crowbar arc over it.
  if(mode==='fist'&&st){var slk=pxLookOf(st);if(slk&&pxIsSet(slk.clothes)){
    var ok=pixDrawOp(x,y,face,ph,coat,pk,muzzle,'none',iv,st);
    if(ok)pxSetMelee(x,y,face,slk);return ok;
  }}
'@

SubRx @'
    ro=pxRoll({head:lk.head,skin:lk.skin,clothes:lk.clothes,bot:lk.bot,mir:mir,fr:Math.floor(((ph/12.6)%1+1)%1*4)%4});
'@ @'
    ro=pxRoll({head:lk.head,skin:lk.skin,clothes:lk.clothes,bot:lk.bot,mir:mir,band:seatMarkOf(st)>=0?SEATCOL[seatMarkOf(st)&3]:'',fr:Math.floor(((ph/12.6)%1+1)%1*4)%4}); // v28.xx (cw-cx-pixsets): seat trim rolls with the set
'@

SubRx @'
  var fam='r|'+o.head+'|'+o.skin+'|'+o.clothes+'|'+o.bot+'|'+o.mir;
'@ @'
  var fam='r|'+o.head+'|'+o.skin+'|'+o.clothes+'|'+o.bot+'|'+o.mir+'|'+(o.band||''); // v28.xx (cw-cx-pixsets): separate seat bands
'@

SubRx @'
  var fam='t|'+lk.head+'|'+lk.skin+'|'+lk.clothes+'|'+lk.bot+'|'+mir+'|'+sg+'|'+A+'|'+(lk.bulk|0);
'@ @'
  var fam='t|'+lk.head+'|'+lk.skin+'|'+lk.clothes+'|'+lk.bot+'|'+mir+'|'+sg+'|'+A+'|'+(lk.bulk|0)+'|'+(lk.band||''); // v28.xx (cw-cx-pixsets): trim survives the topple
'@

SubRx @'
arms:1,lamp:'',band:'',low:0,bulk:lk.bulk|0}
'@ @'
arms:1,lamp:'',band:lk.band||'',low:0,bulk:lk.bulk|0}
'@

SubRx @'
  lk.bulk=Math.min(3,Math.max(0,Math.round(st.bulk||0)));
  spr=pxToppleSpr(lk,fl<0?1:0,sg,
'@ @'
  lk.bulk=Math.min(3,Math.max(0,Math.round(st.bulk||0)));
  lk.band=seatMarkOf(st)>=0?SEATCOL[seatMarkOf(st)&3]:''; // v28.xx (cw-cx-pixsets): the player keeps a seat band while falling
  spr=pxToppleSpr(lk,fl<0?1:0,sg,
'@

SubRx @'
  hold=gunHeldOn(st,mode); back=hold&&Math.sin(face)<-0.3;
'@ @'
  if(lk.clothes==='skeleton')sk=PXS_BONE;else if(lk.clothes==='trooper')sk=PXS_DARK;else if(lk.clothes==='android')sk=PXS_PALE; // v28.xx (cw-cx-pixsets): set hands
  hold=gunHeldOn(st,mode); back=hold&&Math.sin(face)<-0.3;
'@

SubRx @'
.costile{width:96px;padding:8px 6px;
'@ @'

/* v28.xx (cw-cx-pixsets): four racks in the existing fashion columns, whole 2x tile art and readable short labels. */
#root .pixwardrobe .pixrack{margin:0 0 16px}
#root .pixwardrobe .glab{font:600 20px var(--f-cond);color:var(--tx-1);margin:0 0 8px;letter-spacing:.04em}
#root .pixwardrobe .pixtiles{display:grid;grid-template-columns:repeat(4,minmax(112px,1fr));gap:8px}
#root #appavatarpicker.pixwardrobe .costile,#root .pixwardrobe .costile{width:auto;min-width:0;padding:8px;background:var(--ui-raised,#202528);border:1px solid var(--ui-line-hi,#4a5257);border-radius:4px;box-shadow:none;color:var(--tx-1);justify-content:flex-end}
#root .pixwardrobe .costile.on{border-color:var(--acc);background:var(--ui-raised,#202528);box-shadow:inset 0 -3px var(--acc)}
#root .pixwardrobe .costile:focus-visible{outline:3px solid var(--acc);outline-offset:2px}
#root .pixwardrobe .costile canvas{width:auto;height:auto;flex-shrink:0;image-rendering:pixelated}
#root .pixwardrobe .cosname{font:600 20px/1.2 var(--f-cond);margin:4px 0;color:var(--tx-1)}
#root .pixwardrobe .cosreq{font:600 16px/1.2 var(--f-cond);color:var(--tx-2);min-height:20px}

.costile{width:96px;padding:8px 6px;
'@

SubRx @'
var VER='33.90';
'@ @'
var VER='33.91';
'@

$pat = "(?m)^  now:'v33\.90:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v33.91: Skeleton, trooper and android share every pixel pose. Fashion has four racks, and the demo and crowd share twelve looks. Check 33.91 fails on v33.90',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
