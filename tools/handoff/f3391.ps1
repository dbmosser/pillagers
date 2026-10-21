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

if ($s.Contains("  {v:'33.91',what:")) { throw "check 33.91 is in the fixture already" }

SubRx @'
  {v:'33.90',what:
'@ @'
  {v:'33.91',what:'pixel sets share every pose and seat trim; four wardrobe racks write only kept ids, off restores nineteen, twelve demo and crowd rolls preserve saves',
   run:function(){
     if(typeof pxSetUpper!=='function'||typeof renderPixWardrobe!=='function')return 'no pixel sets or four-rack wardrobe';
     var cfg=CFG.xfPix,p0,arc=ARCADE.on,rnd=Math.random,keepW=wc,box=null,bad=[],sets=['skeleton','trooper','android'],out=['outskeleton','outtrooper','outandroid'],i,j,k,h,s,c,a,b,lk,base,now,wear,cols={},seen={},g,origCos;
     function fail(t){if(bad.length<14)bad.push(t);}
     function hash(cv){var d=cv.getContext('2d').getImageData(0,0,cv.width,cv.height).data,h=2166136261,n=0;for(var z=0;z<d.length;z++){h=Math.imul(h^d[z],16777619);if(z%4===3&&d[z])n++;}if(!n)fail('empty set art');return h>>>0;}
     function bandCount(cv,col){var d=cv.getContext('2d').getImageData(0,0,cv.width,cv.height).data,n=0,r=parseInt(col.slice(1,3),16),g=parseInt(col.slice(3,5),16),b=parseInt(col.slice(5,7),16);for(var z=0;z<d.length;z+=4)if(d[z]===r&&d[z+1]===g&&d[z+2]===b&&d[z+3])n++;return n;}
     try{
       __runPrep();__topClear();__resetCfg();__pinDefaults(0);__cleanProfile();p0=JSON.stringify(P);CFG.xfPix=1;P.cosAll=1;
       if(slotKeyOf('1')!=='salvagerun:profile')fail('profile key changed');
       origCos=JSON.stringify([COSMETICS,COSKEY,LOOK_KINDS]);
       // v28.xx (cw-cx-pixsets): compare real raster output with all 27 ordinary looks.
       for(h=0;h<3;h++)for(s=0;s<3;s++)for(c=0;c<3;c++)cols[hash(pixBodyCell(PXB_HEADS[h],PXB_SKINS[s],PXB_CLOTHS[c],0,0,0))]=1;
       for(i=0;i<3;i++){
         a=hash(pixSetCell(sets[i],0,''));if(cols[a])fail(sets[i]+' duplicates another body');cols[a]=1;
         b=hash(pixSetCell(sets[i],1,''));if(a===b)fail(sets[i]+' mirror did not bake');
         for(j=0;j<4;j++)if(!bandCount(pixSetCell(sets[i],0,SEATCOL[j]),SEATCOL[j]))fail(sets[i]+' missing seat '+j+' trim');
         P.cosOutfit=out[i];P.cosHat='none';P.cosCut='crop';P.cosSkin='fair';P.cosScheme='schsand';
         base=JSON.stringify(pxLookOf({hero:1}));
         for(j=0;j<27;j++){
           P.cosHat=j%3===2?'hood':'none';P.cosCut=j%3===1?'long':'crop';P.cosSkin=PXB_SKINS[Math.floor(j/3)%3];P.cosScheme=['schsand','schdrab','schcharcoal'][Math.floor(j/9)];
           if(JSON.stringify(pxLookOf({hero:1}))!==base)fail(sets[i]+' reads a hidden base pick');
         }
         wear=JSON.stringify([P.cosHat,P.cosCut,P.cosSkin,P.cosScheme]);pixWear('set','off',false);
         if(JSON.stringify([P.cosHat,P.cosCut,P.cosSkin,P.cosScheme])!==wear||pxLookOf({hero:1}).clothes!=='heavy')fail('set off lost the stored picks');
         // Bake all gait frames, both facings, crouch, all roll frames and both directions of all topple frames.
         for(j=0;j<2;j++){
           ['s','w','r','c'].forEach(function(kind){for(var f=0;f<(kind==='w'||kind==='r'?6:1);f++)hash(pxBuildLegs({clothes:sets[i],mir:j,kind:kind,fr:f}).c);});
           for(k=0;k<4;k++)hash(pxBuildRoll({clothes:sets[i],mir:j,fr:k,band:SEATCOL[0]}).c);
           for(k=0;k<8;k++){pixFrame();hash(pxToppleSpr({head:'short',skin:'fair',clothes:sets[i],bot:0,band:SEATCOL[0]},j,1,k,1.5708).c);pixFrame();hash(pxToppleSpr({head:'short',skin:'fair',clothes:sets[i],bot:0,band:SEATCOL[0]},j,-1,k,1.4835).c);}
         }
       }
       // v28.xx (cw-cx-pixsets): compare every profile key changed by each of the thirteen controls.
       box=document.createElement('div');document.body.appendChild(box);renderCosmetics(box);
       if(box.querySelectorAll('[data-pixrack]').length!==4||box.querySelectorAll('[data-pixid]').length!==13)fail('expected four racks and twelve tiles plus off');
       PIX_RACKS.forEach(function(rack){rack[1].forEach(function(t){
         for(var q in COSKEY)P[COSKEY[q]]=COSDEF[q];
         P.cosHat='crown';P.cosCut='shaved';P.cosSkin='ebony';P.cosScheme='schnight';P.cosPack='packnone';P.cosOutfit='outpoet';
         var before=JSON.parse(JSON.stringify(P)),expected=JSON.parse(JSON.stringify(P));
         for(var q in t[1])expected[COSKEY[q]]=t[1][q];
         if(!pixWear(rack[0],t[0],false)||JSON.stringify(P)!==JSON.stringify(expected))fail(rack[0]+' '+t[0]+' wrote outside its listed ids');
       });});
       P.cosAll=0;P.ext=0;P.runs=0;P.xp=0;P.xpLevel=1;P.kills={};
       if(pixWear('set','skeleton',false))fail('locked skeleton was wearable');P.cosAll=1;
       // v28.xx (cw-cx-pixsets): the real click handler and shared pad routes on FASHION.
       __hubEnter();CFG.xfPix=1;P.cosAll=1;__station('mirror','KeyE');
       var md=document.getElementById('appearmodal'),pk=document.getElementById('appavatarpicker');
       renderAvatar('appavatar','appavatarpicker');
       var tiles=pk.querySelectorAll('[data-pixid]'),focus=padFocusables(md);
       for(i=0;i<tiles.length;i++)if(focus.indexOf(tiles[i])<0)fail('pad cannot reach '+tiles[i].getAttribute('data-pixid'));
       var hood=pk.querySelector('[data-pixkind="head"][data-pixid="hood"]');hood.click();if(P.cosHat!=='hood')fail('hood click did not write old id');
       P.cosAll=0;if(cosWorn('hat')!=='hood'||netLook().hat!=='hood')fail('always-owned hood lost in save or net look');
       var saved=lookSnap();P.cosHat='none';lookWear(saved);if(P.cosHat!=='hood')fail('saved look lost pixel hood');
       var code=restoreRead(restoreCode());if(!code||!code.w||code.w.hat!=='hood')fail('restore code lost the listed old id');
       padMenu(function(){return false;});padMenu(function(n){return n===1;});padMenu(function(){return false;});if(md.classList.contains('on'))fail('pad B did not close fashion');
       // v28.xx (cw-cx-pixsets): off restores all nineteen old groups and ids.
       CFG.xfPix=0;renderCosmetics(box);
       var legacyKinds=['set','outfit','scheme','build','vest','pads','skin','eyes','face','tattoo','hair','cut','beard','hat','fit','patch','gloves','boots','pack'],legacyRows=[];
       [].forEach.call(box.children,function(row){var tile=row.querySelector('.costile[data-kind]');if(tile&&tile.parentNode===row)legacyRows.push(tile.getAttribute('data-kind'));});
       if(legacyRows.join('|')!==legacyKinds.join('|')||box.querySelector('[data-pixid]'))fail('off did not restore nineteen racks: '+legacyRows.join(','));
       if(JSON.stringify([COSMETICS,COSKEY,LOOK_KINDS])!==origCos)fail('old wardrobe definitions changed');
       // v28.xx (cw-cx-pixsets): drive every equally sized interval through both actual rollers, 200 times.
       CFG.xfPix=1;ARCADE.on=1;
       var allowed={};for(i=0;i<12;i++){lk=pixRollLook(i);allowed[JSON.stringify(pixLook(lk))]=1;}
       for(i=0;i<200;i++){
         Math.random=function(){return ((i%12)+.5)/12;};arcadeLook();a=JSON.stringify(pixLook(pixRawLook()));b=JSON.stringify(pixLook(hubRollLook()));
         if(!allowed[a]||!allowed[b])fail('cut item in demo or crowd roll '+i);seen[a]=1;
         for(k in {hat:1,cut:1,skin:1,scheme:1,pack:1,outfit:1})if(P[COSKEY[k]]!==pixRollLook(i%12)[k])fail('arcade wrote an unlisted '+k);
       }
       if(Object.keys(seen).length!==12)fail('demo did not reach all twelve equally weighted looks');
       Math.random=rnd;ARCADE.on=arc;
       // v28.xx (cw-cx-pixsets): render the real bodies in the deployed raid rig in ten distinct poses.
       __topClear();__deploy({kit:['gun_rifle'],safe:null,mapIx:0,seed:4242});g=__state();CFG.xfPix=1;P.cosAll=1;
       var cv=document.createElement('canvas');cv.width=256;cv.height=256;wc=cv.getContext('2d');wc.translate(128,180);var faults=PIX.errs;
       for(i=0;i<3;i++)for(j=0;j<10;j++){
         P.cosOutfit=out[i];g.player.hp=100;g.player.downed=0;g.deathBeat=0;
         var st={hero:1,own:g.player,moving:j===1||j===2,sprint:j===2,ads:j===3,rl:j===4?1:0,bulk:0,seat:0};
         var mode=j===5?'crouch':j===6?'roll':j===7?'fist':j>=8?'down':'';
         if(j===8)g.player.downed=1;if(j===9){g.player.hp=0;g.deathBeat=1.4;}
         var ok=false;for(k=0;k<20;k++){pixFrame();ok=pixDrawOp(0,0,.3,j*.8,'#242832',0,0,mode,0,st);}
         if(!ok)fail(sets[i]+' fell back in pose '+j);
       }
       if(PIX.errs!==faults)fail('set rendering raised a pixel fault');
       return bad.length?bad.join('; '):null;
     }finally{
       wc=keepW;Math.random=rnd;ARCADE.on=arc;try{__endRaid('abandon');}catch(e){}if(box)box.remove();
       __topClear();__resetCfg();__cleanProfile();if(p0)P=JSON.parse(p0);CFG.xfPix=cfg;pixDropAll();pixFrame();
     }
   }},
  {v:'33.90',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
