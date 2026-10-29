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

if ($s.Contains("  {v:'36.55',what:")) { throw "check 36.55 is in the fixture already" }

SubRx @'
  {v:'36.54',what:
'@ @'
  {v:'36.55',what:'old saved key maps route real middle mouse events to one mark in all three views, solo and both roles; compact keys and pad legends name mark once',
   run:function(){
     var keep={},ks=['on','role','seat','peers','pings','wps','pingAt','pingLast','pingTarget','entMap','upSeed'],g,p,m,q,i,j,mode,MP,pad=false,txt=[],shown=[],sent=[];
     var km=JSON.stringify(P.keymap||{}),kv=P.keymapV,mw=mouseWorld,bc=netBroadcast,ns=netSend,cg=colourCueGlyph,po=padOn,ft=ctx.fillText,x0=mouse.x,y0=mouse.y;
     ks.forEach(function(k){keep[k]=NET[k];});
     function mmb(){window.dispatchEvent(new MouseEvent('mousedown',{button:1,bubbles:true,cancelable:true}));window.dispatchEvent(new MouseEvent('mouseup',{button:1,bubbles:true,cancelable:true}));}
     function views(mark,own){
       if(netPingDraw()!==1)return 'raid missing or duplicate';
       shown=[];mmMarks({x:100,y:100,w:400,h:400},.3,1);
       if(shown.filter(function(v){return v.k==='place';}).length!==1)return 'minimap missing or duplicate';
       if(own&&!MMAP.got.wp)return 'own minimap mark absent';
       g.mapOpen=true;shown=[];drawMapOverlayRaw();MP=mapProj();g.mapOpen=false;
       if(shown.filter(function(v){return v.k==='place'&&Math.abs(v.x-(MP.ox+mark.x*MP.sc))<2&&Math.abs(v.y-(MP.oy+mark.y*MP.sc))<2;}).length!==1)return 'map missing or duplicate';
       return null;
     }
     try{
       __runPrep();__topClear();__resetCfg();__pinDefaults(0);__cleanProfile();NET.on=false;
       __deploy({kit:['gun_rifle'],safe:null,mapIx:0,seed:4242});g=__state();p=g.player;
       g.mapFirst=false;g.mapOpen=false;g.bagOpen=false;g.paused=false;g.rise=null;g.legendOn=1;keys={};mouse.down=false;CFG.xfPix=0;
       P.keymap={KeyV:'KeyV',KeyZ:'KeyZ',KeyR:'KeyK'};P.keymapV=3;KEYS.inv=null;keysInv();
       netBroadcast=function(v){sent.push(JSON.parse(JSON.stringify(v)));};netSend=function(pe,v){sent.push(JSON.parse(JSON.stringify(v)));return true;};
       colourCueGlyph=function(c,k,x,y){shown.push({k:k,x:x,y:y});return cg.apply(this,arguments);};
       padOn=function(){return pad;};
       q=null;for(j=0;j<100&&!q;j++){var pt={x:p.x+(j%10-5)*70,y:p.y+(Math.floor(j/10)-5)*70};if(pt.x>0&&pt.y>0&&pt.x<WORLD_W&&pt.y<WORLD_H&&!g.ents.some(function(e){return e.hp>0&&!e.merc&&dist(e,pt)<NET_PING_SNAP+2;}))q=pt;}
       if(!q)return 'cannot stage empty cursor point';mouseWorld=function(){return q;};
       for(mode=0;mode<3;mode++){
         NET.on=mode>0;NET.role=mode===2?'join':'host';NET.seat=mode===2?1:0;NET.upSeed=g.seed;NET.pings=[];NET.wps={};NET.pingAt=0;NET.pingLast=null;g.waypoint=null;sent=[];
         mmb();m=g.waypoint;
         if(!m||!m.spot||NET.pings.length!==1||m!==NET.pings[0])return 'old map middle mouse missing shared mark in mode '+mode;
         if(JSON.stringify(P.keymap)!==JSON.stringify({KeyV:'KeyV',KeyZ:'KeyZ',KeyR:'KeyK'})||P.keymapV!==3||keyRemap('KeyK')!=='KeyR')return 'old saved keys changed';
         var err=views(m,true);if(err)return 'own '+mode+': '+err;
         if(mode>0){
           if(sent.length!==1||sent[0].t!=='png'||!sent[0].spot)return 'middle mouse did not send one png';
           var packet=sent[0],sender=NET.seat;NET.seat=1-sender;NET.role=sender===0?'join':'host';NET.pings=[];NET.wps={};g.waypoint=null;NET.peers=[{state:'in',seat:sender},{state:'in',seat:2}];sent=[];
           if(netPingTake(NET.peers[0],packet)!=='png'||NET.pings.length!==1||!NET.wps[sender])return 'partner did not take mark';
           err=views(NET.pings[0],false);if(err)return 'partner '+mode+': '+err;
           if(sender===1&&(sent.length!==1||sent[0].s!==1))return 'host did not relay sender seat';
         }
       }
       NET.on=true;g.legendOn=1;
       for(i=0;i<2;i++){
         pad=!!i;txt=[];ctx.fillText=function(t){txt.push(String(t));};
         try{drawLegend();}finally{ctx.fillText=ft;}
         var count=0;for(j=0;j<txt.length;j++)if(/^mark(?:\b|,)/i.test(txt[j])){count++;if(i&&String(txt[j-1]).toUpperCase()!=='D-UP')return 'pad mark is not D-UP';}
         if(count!==1)return 'compact '+(i?'pad':'keys')+' legend lists mark '+count+' times';
       }
       return null;
     }finally{
       mouseWorld=mw;netBroadcast=bc;netSend=ns;colourCueGlyph=cg;padOn=po;ctx.fillText=ft;mouse.x=x0;mouse.y=y0;
       NET.on=false;try{__endRaid('abandon');}catch(_e){}__topClear();keys={};mouse.down=false;
       P.keymap=JSON.parse(km);P.keymapV=kv;KEYS.inv=null;KEYS.mmb=0;keysInv();ks.forEach(function(k){NET[k]=keep[k];});
     }
   }},
  {v:'36.54',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
