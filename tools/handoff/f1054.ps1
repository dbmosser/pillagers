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
  {v:'10.53',what:'the cheat box ALL COSMETICS switch opens every rack when on, returns exactly the earned racks when off, and touches nothing earned or bought',
'@ @'
  {v:'10.54',what:'the OUTFIT rack exists, each suit repaints the whole figure and hides the coat colour, an unowned suit changes nothing, and the Depot lists the slot',
   run:function(){
     var bad=[];
     if(typeof drawOp!=='function'||typeof cosWorn!=='function'||typeof COSMETICS==='undefined') return 'SKIP: no painter or racks in this build';
     var P2=__P();
     var keep={all:P2.cosAll,out:P2.cosOutfit,fit:P2.cosFit,slot:P2._avSlot};
     function paint(){
       var c=document.createElement('canvas'); c.width=200; c.height=320;
       var g=c.getContext('2d'); var keepWc=wc; wc=g;
       try{ g.save(); g.translate(100,304); g.scale(5.2,5.2);
            drawOp(0,0,0,0,'#242832',0,0,'none',0,{hero:1,moving:false,sprint:false,ads:false,hurt:0,rl:0,own:{wep:null}});
            g.restore(); }
       finally { wc=keepWc; }
       return g.getImageData(0,0,200,320).data;
     }
     function differ(a,b){ var d=0; for(var j=0;j<a.length;j+=4) if(a[j]!==b[j]||a[j+1]!==b[j+1]||a[j+2]!==b[j+2]) d++; return d; }
     function countCol(a,r,g,b){ var d=0; for(var j=0;j<a.length;j+=4) if(Math.abs(a[j]-r)<=2&&Math.abs(a[j+1]-g)<=2&&Math.abs(a[j+2]-b)<=2) d++; return d; }
     try{
       var suits=COSMETICS.filter(function(c){ return c.kind==='outfit'&&c.id!=='outnone'; });
       if(suits.length<7) bad.push('the OUTFIT rack holds '+suits.length+' suits, not seven');
       if(typeof LOOK_KINDS==='undefined'||LOOK_KINDS.indexOf('outfit')<0) bad.push('a look does not carry the outfit');
       // 1. Unowned: a fresh profile wearing a suit it has not earned paints its own clothes.
       P2.cosAll=false; P2.cosFit='slate'; P2.cosOutfit='outnone';
       // A fresh profile for this pair of paints: the counters are lent back to
       // zero so nothing is owned, then both figures are painted under the same
       // racks and only the outfit differs between them.
       var lend={runs:P2.runs,ext:P2.ext,lvl:P2.xpLevel,kills:P2.kills};
       P2.runs=0; P2.ext=0; P2.xpLevel=1; P2.kills={};
       var fresh=paint();
       var stillOwned=cosOwned(cosFind('outskeleton'));
       P2.cosOutfit='outskeleton';
       var unowned=paint();
       P2.runs=lend.runs; P2.ext=lend.ext; P2.xpLevel=lend.lvl; P2.kills=lend.kills;
       P2.cosOutfit='outnone';
       var base=paint();
       if(stillOwned) bad.push('a fresh profile owns the Skeleton without earning it');
       else if(differ(fresh,unowned)!==0) bad.push('an unowned suit repainted '+differ(fresh,unowned)+' pixels');
       // 2. Owned: every suit repaints the figure and hides the slate coat.
       P2.cosAll=true;
       var slateN=countCol(base,0x59,0x62,0x6f);
       if(slateN<40) bad.push('the control figure shows only '+slateN+' slate coat pixels, so the coat test would prove nothing');
       for(var i=0;i<suits.length;i++){
         P2.cosOutfit=suits[i].id;
         var px=paint(), d=differ(base,px), sl=countCol(px,0x59,0x62,0x6f);
         if(d<300) bad.push(suits[i].name+' changes only '+d+' pixels of the figure');
         if(sl>0) bad.push(suits[i].name+' still shows '+sl+' pixels of the slate coat');
       }
       P2.cosOutfit='outtrooper';
       if(countCol(paint(),0x3f,0x6a,0x3a)<30) bad.push('the Trooper paints no helmet green');
       // 3. The Depot lists the slot, first.
       P2.cosOutfit='outnone'; P2._avSlot=null;
       if(typeof renderAvatar==='function'&&document.getElementById('appavatar')){
         renderAvatar('appavatar','appavatarpicker');
         var slots=document.querySelectorAll('#appavatar [data-av]');
         if(!slots.length||slots[0].getAttribute('data-av')!=='outfit') bad.push('the Depot does not list OUTFIT as its first slot');
         var tiles=document.querySelectorAll('#appavatarpicker .costile[data-kind="outfit"]');
         if(tiles.length<8) bad.push('the Depot racks show '+tiles.length+' outfit tiles, not eight');
       } else bad.push('the Depot is not on this page');
     } finally {
       P2.cosAll=keep.all; P2.cosOutfit=keep.out||'outnone'; P2.cosFit=keep.fit; P2._avSlot=keep.slot;
       try{ saveProfile(); }catch(_sv){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'10.53',what:'the cheat box ALL COSMETICS switch opens every rack when on, returns exactly the earned racks when off, and touches nothing earned or bought',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
