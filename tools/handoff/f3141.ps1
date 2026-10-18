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

if ($s.Contains("  {v:'31.41',what:")) { throw "check 31.41 is in the fixture already" }

SubRx @'
  {v:'31.40',what:
'@ @'
  {v:'31.41',what:'cw-mapstyle: the sector map is one charcoal card (5 percent margin) with a header row (the sector name, an X that closes it, or starts the raid on the opening map), readable zone names over a halo, no explaining sentence, every contract listed on it with its progress and reward in $ (and none in the demo), the opening start button bottom right of the card, and the player marker in the seat colour; at 1080, 4k and with the TV text size',
   run:function(){
     if(typeof mapCard!=='function'||typeof mapContractRows!=='function'||typeof mapSeatColor!=='function') return 'no map card in this build (mapCard, mapContractRows or mapSeatColor is missing)';
     if(!(window.__loop&&window.__state&&window.__endRaid&&window.__deploy&&window.__topClear&&window.__runPrep&&window.__resetCfg&&window.__pinDefaults&&window.__cleanProfile)) return 'SKIP: this fixture cannot deploy a raid';
     var bad=[], g=null, w0=W, h0=H, us0=P.uiScale, hadUs=Object.prototype.hasOwnProperty.call(P,'uiScale'), oSkip=MAPFIRST.skip, oSeat=seatHere, oMI=mapIcon, proto=CanvasRenderingContext2D.prototype,
         oFill=proto.fill, oFT=proto.fillText, oST=proto.strokeText, cd, i, t, txt, got, nm, ic=[], fills=[], strokes=[], names=[], zn, hit, seenZ=0, lowZ=0, rows, mk, cv0=cv, ent;
     function ents(fn){ return txRecord(fn); }
     function strs(list){ var o=[], q; for(q=0;q<list.length;q++) o.push(String(list[q].t)); return o; }
     function has(list,rx){ for(var q=0;q<list.length;q++) if(rx.test(list[q])) return true; return false; }
     function hex2(s){ var m=/^#([0-9a-f]{2})([0-9a-f]{2})([0-9a-f]{2})$/i.exec(String(s)), n=/^rgba?\(([\d.]+),\s*([\d.]+),\s*([\d.]+)(?:,\s*([\d.]+))?\)$/.exec(String(s)); if(m) return [parseInt(m[1],16),parseInt(m[2],16),parseInt(m[3],16),1]; if(n) return [+n[1],+n[2],+n[3],n[4]===undefined?1:+n[4]]; return null; }
     function lum(c){ var a=c.map(function(v){ v/=255; return (v<=0.03928)?v/12.92:Math.pow((v+0.055)/1.055,2.4); }); return 0.2126*a[0]+0.7152*a[1]+0.0722*a[2]; }
     function contrast(fg,bg){ var f=hex2(fg), b=hex2(bg), r; if(!f||!b) return 0; r=[0,1,2].map(function(k){ return f[k]*f[3]+b[k]*(1-f[3]); }); r=lum(r); b=lum(b); return (Math.max(r,b)+0.05)/(Math.min(r,b)+0.05); }
     function inside(a,b,pad){ return a.x>=b.x-(pad||0)&&a.y>=b.y-(pad||0)&&a.x+a.w<=b.x+b.w+(pad||0)&&a.y+a.h<=b.y+b.h+(pad||0); }
     function click(x,y){ mouse.x=x; mouse.y=y; cv.dispatchEvent(new MouseEvent('mousedown',{button:0,bubbles:true,cancelable:true})); }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       MAPFIRST.skip=1; keys={}; mouse.down=false;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no raid';
       // distinctive contracts: a count, a finished one, a rule, a long place name
       P.contracts=[
         {type:'kill',tgt:'crawler',n:5,prog:3,reward:4321,desc:'Destroy 5 crawlers',tier:'std'},
         {type:'open',ct:'crate',n:4,prog:4,reward:777,desc:'Search 4 crates',tier:'std'},
         {type:'conduct',ck:'clean',n:1,prog:0,reward:1234,desc:'Extract without using a single heal',tier:'std'},
         {type:'district',d:0,n:3,prog:1,reward:480,desc:'Search 3 containers in the sector',tier:'std'},
         {type:'haul',v:1600,n:1,prog:0,reward:960,desc:'Extract with a haul worth $1,600 or more',tier:'std'}];
       // ONE: the card at 1080 and 4k, with and without contracts
       [[1920,1080],[3840,2160],[1280,720]].forEach(function(s){
         W=s[0]; H=s[1]; cd=mapCard();
         if(!(Math.abs(cd.w-0.9*W)<=2&&Math.abs(cd.h-0.9*H)<=2&&Math.abs(cd.x-0.05*W)<=2&&Math.abs(cd.y-0.05*H)<=2)) bad.push('ONE: at '+s[0]+' the card is not 90 percent of the screen with a 5 percent margin ('+JSON.stringify([cd.x,cd.y,cd.w,cd.h])+')');
         if(!cd.col) bad.push('ONE: at '+s[0]+' five contracts did not make a contracts column');
         else{
           if(!(cd.col.x>=cd.ox+WORLD_W*cd.sc&&cd.col.x+cd.col.w<=cd.x+cd.w&&cd.col.w>=300*hudRes())) bad.push('ONE: at '+s[0]+' the contracts column is not clear of the map and inside the card ('+JSON.stringify(cd.col)+')');
         }
         if(!(cd.ox>=cd.x&&cd.ox+WORLD_W*cd.sc<=cd.x+cd.w&&cd.oy>=cd.y+cd.hh&&cd.oy+WORLD_H*cd.sc<=cd.fy)) bad.push('ONE: at '+s[0]+' the map is not inside the body of the card');
         if(!(cd.xb.x+cd.xb.w<=cd.x+cd.w&&cd.xb.y>=cd.y&&cd.xb.y+cd.xb.h<=cd.y+cd.hh&&cd.xb.w>=40*hudRes())) bad.push('ONE: at '+s[0]+' the X is not inside the header row, at least 40 px');
       });
       W=w0; H=h0;
       // TWO: the map opened in the raid (M): what is written on it
       g.mapOpen=true; g.mapFirst=0;
       zn=((g.map&&g.map.zones)||[]).map(function(z){ return String(z.name||''); }).filter(function(s){ return s; });
       proto.fillText=function(s){ var k=String(s); if(zn.indexOf(k)>=0) names.push({s:k,fs:this.fillStyle}); return oFT.apply(this,arguments); };
       proto.strokeText=function(s){ strokes.push(String(s)); return oST.apply(this,arguments); };
       mapIcon=function(x,y,r){ var m=ctx.getTransform(); ic.push({l:(x-r)*m.a+m.e,t:(y-r)*m.d+m.f,r:(x+r)*m.a+m.e,b:(y+r)*m.d+m.f}); return oMI.apply(this,arguments); };
       try{ ent=ents(function(){ drawMapOverlay(); }); } finally { proto.fillText=oFT; proto.strokeText=oST; mapIcon=oMI; }
       txt=strs(ent); cd=mapCard();
       nm=String((g.map&&g.map.name)||'').toLowerCase();
       if(!nm||!has(txt,new RegExp('^'+nm.replace(/[^a-z0-9 ]/g,'.')+'$'))) bad.push('TWO: the header does not carry the sector name ('+nm+')');
       if(!has(txt,/^sector map$/)) bad.push('TWO: the muted words sector map are gone from the header');
       if(has(txt,/what you walk stays/)) bad.push('TWO: the explaining line what you walk stays on the map is still there');
       if(!has(txt,/^surveyed\s+\d+%$/)) bad.push('TWO: the surveyed figure is not in the footer');
       if(!has(txt,/^contracts$/)||!has(txt,/^1 of 5 done$/)) bad.push('TWO: no contracts title with 1 of 5 done ('+txt.filter(function(s){ return /contract|done/.test(s); }).join(' | ')+')');
       if(!has(txt,/^destroy crawlers$/)||!has(txt,/^3\/5$/)||!has(txt,new RegExp('^\\$'+(4321).toLocaleString().replace(/[^0-9a-z]/gi,'.')+'$'))) bad.push('TWO: the kill contract is not listed as destroy crawlers 3/5 $4,321 ('+txt.filter(function(s){ return /crawler|\/|\$/.test(s); }).join(' | ')+')');
       if(!has(txt,/^done$/)||!has(txt,/^holding$/)) bad.push('TWO: a finished contract does not say done, or a rule contract does not say holding');
       if(!has(txt,/^search crates$/)||!has(txt,/^no heals$/)||!has(txt,/^haul over \$1.600$/)) bad.push('TWO: a short name is missing ('+txt.filter(function(s){ return /search|heal|haul/.test(s); }).join(' | ')+')');
       // every contract text sits inside the column, the rows do not overlap
       rows=ent.filter(function(h){ return /^(destroy crawlers|search crates|no heals|haul over)/.test(String(h.t)); });
       for(i=0;i<rows.length;i++){ if(!(rows[i].x>=cd.col.x&&rows[i].x+(rows[i].w||0)<=cd.col.x+cd.col.w+2&&rows[i].y>=cd.col.y&&rows[i].y<=cd.col.y+cd.col.h)) bad.push('TWO: the contract row '+rows[i].t+' is outside its column'); if(i>0&&Math.abs(rows[i].y-rows[i-1].y)<(rows[i].h||10)*0.8) bad.push('TWO: two contract rows overlap'); }
       // zone names: light on dark with a halo
       for(i=0;i<names.length;i++){ seenZ++; if(contrast(names[i].fs,'#111315')<4.5) lowZ++; }
       if(seenZ<3) bad.push('TWO: only '+seenZ+' zone names were drawn (at least 3 expected)');
       else if(lowZ) bad.push('TWO: '+lowZ+' zone names read under 4.5:1 on the map ground ('+names.map(function(n){ return n.s+' '+n.fs; }).slice(0,3).join(' | ')+')');
       hit=0; for(i=0;i<names.length;i++) if(strokes.indexOf(names[i].s.toLowerCase())>=0||strokes.indexOf(names[i].s)>=0) hit++;
       if(!hit) bad.push('TWO: no zone name has a halo under it');
       // marker tags never sit on a mark
       t=0; for(i=0;i<ent.length;i++){
         mk=/^(cache|looted|encampment|peddler|strongbox|the forge|seal \d+%|waypoint)$/.test(String(ent[i].t)); if(!mk) continue;
         var bx=txBox(ent[i]);
         for(var q=0;q<ic.length;q++) if(bx.x<ic[q].r-1&&ic[q].l+1<bx.x+bx.w&&bx.y<ic[q].b-1&&ic[q].t+1<bx.y+bx.h){ t++; break; }
       }
       if(t>2) bad.push('TWO: '+t+' marker tags sit on a mark (at most 2 allowed where marks are packed)');
       // THREE: the X closes the map, a click on the map still sets the waypoint
       cd=mapCard(); click(cd.xb.x+cd.xb.w/2,cd.xb.y+cd.xb.h/2);
       if(g.mapOpen) bad.push('THREE: a click on the X did not close the map');
       g.mapOpen=true; g.waypoint=null; click(cd.ox+WORLD_W*cd.sc/2,cd.oy+WORLD_H*cd.sc/2);
       if(!g.waypoint) bad.push('THREE: a click on the map no longer sets a waypoint');
       if(!g.mapOpen) bad.push('THREE: the waypoint click shut the map');
       g.waypoint=null;
       // FOUR: the opening map: the X starts the raid, the start button is bottom right in the footer of the card
       MAPFIRST.skip=0; g.mapFirst=0; g.mapOpen=false;
       if(!mapFirstBegin()) bad.push('FOUR: could not put the opening map up');
       else{
         g.mapFirstT=0.5; cd=mapCard(); t=null;
         proto.fillText=function(s){ var k=String(s); if(/^(click to start|start)$/i.test(k)){ var m=this.getTransform(); t={x:arguments[1]*m.a+m.e,y:arguments[2]*m.d+m.f}; } return oFT.apply(this,arguments); };
         try{ drawMapOverlay(); } finally { proto.fillText=oFT; }
         if(!t) bad.push('FOUR: no start button text on the opening map');
         else if(!(t.x>cd.x+cd.w/2&&t.y>=cd.fy&&t.y<=cd.y+cd.h)) bad.push('FOUR: the start button is not bottom right in the footer row ('+JSON.stringify({x:Math.round(t.x),y:Math.round(t.y),fy:Math.round(cd.fy),right:Math.round(cd.x+cd.w)})+')');
         click(cd.xb.x+cd.xb.w/2,cd.xb.y+cd.xb.h/2);
         if(g.mapFirst) bad.push('FOUR: a click on the X did not start the raid on the opening map');
       }
       mapFirstEnd('test'); MAPFIRST.skip=1; g.mapOpen=true;
       // FIVE: the demo lists no contracts and centres the map
       g.arcade=true; W=1920; H=1080; cd=mapCard();
       if(cd.col||cd.has) bad.push('FIVE: the demo still makes a contracts column');
       if(Math.abs(cd.ox+WORLD_W*cd.sc/2-W/2)>2) bad.push('FIVE: without contracts the map is not centred across the card');
       W=w0; H=h0;
       ent=ents(function(){ drawMapOverlay(); }); txt=strs(ent);
       if(has(txt,/^contracts$/)||has(txt,/^destroy crawlers$/)) bad.push('FIVE: the demo map lists contracts');
       g.arcade=false;
       // SIX: the TV text size at 1080 keeps the rows apart and inside the column
       P.uiScale=1.5; W=1920; H=1080; cd=mapCard();
       ent=ents(function(){ drawMapOverlay(); });
       rows=ent.filter(function(h){ return /^(destroy crawlers|search crates|no heals|haul over|search )/.test(String(h.t)); });
       if(rows.length<4) bad.push('SIX: with the 1.5 text size only '+rows.length+' of 5 contract rows are drawn');
       for(i=0;i<rows.length;i++){ if(rows[i].y>cd.col.y+cd.col.h+1) bad.push('SIX: contract row '+rows[i].t+' runs out of the column at the 1.5 text size'); if(i>0&&Math.abs(rows[i].y-rows[i-1].y)<(rows[i].h||10)*0.7) bad.push('SIX: two contract rows overlap at the 1.5 text size'); }
       if(hadUs) P.uiScale=us0; else delete P.uiScale; W=w0; H=h0;
       // SEVEN: you are here: lime for a solo raid and player 1, the ally blue for player 2, a number only in a two player game
       function chevron(seat){ var f=[], j; seatHere=function(){ return seat; }; proto.fill=function(){ f.push(String(this.fillStyle).toLowerCase()); return oFill.apply(this,arguments); };
         try{ ent=ents(function(){ drawMapOverlay(); }); } finally { proto.fill=oFill; seatHere=oSeat; }
         return {fills:f,txt:strs(ent)}; }
       got=chevron(-1);
       if(got.fills.indexOf(String(UIC.acc).toLowerCase())<0) bad.push('SEVEN: a solo raid does not mark you in the lime accent');
       if(got.fills.indexOf('#39ff14')>=0) bad.push('SEVEN: the old neon green marker is still drawn');
       if(has(got.txt,/^[12]$/)) bad.push('SEVEN: a solo raid shows a player number on the marker');
       got=chevron(1);
       if(got.fills.indexOf(String(UIC.ally).toLowerCase())<0) bad.push('SEVEN: player 2 is not marked in the ally colour');
       if(!has(got.txt,/^2$/)) bad.push('SEVEN: player 2 has no number 2 on the marker');
       got=chevron(0);
       if(got.fills.indexOf(String(UIC.acc).toLowerCase())<0||!has(got.txt,/^1$/)) bad.push('SEVEN: player 1 in a two player game is not the lime marker with a number 1');
       return bad.length?bad.join('; '):null;
     } finally {
       proto.fill=oFill; proto.fillText=oFT; proto.strokeText=oST; mapIcon=oMI; seatHere=oSeat; W=w0; H=h0;
       if(hadUs) P.uiScale=us0; else delete P.uiScale;
       MAPFIRST.skip=oSkip; keys={}; mouse.down=false;
       try{ if(G&&!G.over){ G.mapOpen=false; G.arcade=false; __endRaid('abandon'); } }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     } }},
  {v:'31.40',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
