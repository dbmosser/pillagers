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

if ($s.Contains("  {v:'31.48',what:")) { throw "check 31.48 is in the fixture already" }

SubRx @'
  {v:'31.47',what:
'@ @'
  {v:'31.48',what:'cw-mapstyle2: on the sector map card the weather line has one separator, zone names are a size under the extraction names and not bold, the contract names are all in the main text colour with the reward in the smaller type, the footer has a close hint with its key (not on the opening map), and no label sits within 8 px of the map frame',
   run:function(){
     if(typeof mapCard!=='function'||typeof mapContractRows!=='function') return 'no map card in this build (mapCard or mapContractRows is missing)';
     if(!(window.__state&&window.__endRaid&&window.__deploy&&window.__topClear&&window.__runPrep&&window.__resetCfg&&window.__pinDefaults&&window.__cleanProfile)) return 'SKIP: this fixture cannot deploy a raid';
     var hp=parseFloat((/([\d.]+)px/).exec(FS(TYPE.head))[1]), bad=[], g=null, w0=W, h0=H, us0=P.uiScale, hadUs=Object.prototype.hasOwnProperty.call(P,'uiScale'), oSkip=MAPFIRST.skip, proto=CanvasRenderingContext2D.prototype, oFT=proto.fillText, cd, i, ent, zn, zfs=[], doneFs=null, wx, nm, rw, zp=0, inset, n=0, b, cx, cy, ow;
     function hex2(s){ var m=/^rgba?\(([\d.]+),\s*([\d.]+),\s*([\d.]+)(?:,\s*([\d.]+))?\)$/.exec(String(s)); return m?(m[4]===undefined?1:+m[4]):1; }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       MAPFIRST.skip=1; keys={}; mouse.down=false;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no raid';
       P.contracts=[
         {type:'kill',tgt:'crawler',n:5,prog:3,reward:4321,desc:'Destroy 5 crawlers',tier:'std'},
         {type:'open',ct:'crate',n:4,prog:4,reward:777,desc:'Search 4 crates',tier:'std'},
         {type:'conduct',ck:'clean',n:1,prog:0,reward:1234,desc:'Extract without using a single heal',tier:'std'}];
       if(hadUs) delete P.uiScale;
       W=1920; H=1080; g.mapOpen=true; g.mapFirst=0; cd=mapCard();
       zn=((g.map&&g.map.zones)||[]).map(function(z){ return String(z.name||''); }).filter(function(s){ return s; });
       proto.fillText=function(s){ var k=String(s); if(zn.indexOf(k)>=0) zfs.push(this.fillStyle); if(/^search crates$/i.test(k)) doneFs=this.fillStyle; return oFT.apply(this,arguments); };
       try{ ent=txRecord(function(){ drawMapOverlay(); }); } finally { proto.fillText=oFT; }
       // ONE: the weather line
       wx=ent.filter(function(h){ return h.al==='right'&&h.y>=cd.y&&h.y<=cd.y+cd.hh&&String(h.t).indexOf(String(g.wx.name).toLowerCase())>=0; })[0];
       if(!wx) bad.push('ONE: no weather line in the header');
       else if(String(wx.t).indexOf('\u00b7')<0||/ {2}/.test(String(wx.t))) bad.push('ONE: the weather line is not hour, one separator, weather ('+JSON.stringify(wx.t)+')');
       // TWO: zone names are a size under the extraction names, not bold, quieter
       ent.forEach(function(h){ if(zn.indexOf(String(h.o))>=0&&!(h.y<cd.y+cd.hh)){ n++; if(h.h>hp*0.95*cd.z) zp++; } });
       if(n<3) bad.push('TWO: only '+n+' zone names were drawn');
       else if(zp) bad.push('TWO: '+zp+' zone names are as big as a callout head ('+hp+' px), not a size under the extraction names');
       if(zfs.length&&Math.max.apply(null,zfs.map(hex2))>0.70) bad.push('TWO: a zone name is drawn at more than 70 percent ('+zfs[0]+')');
       // THREE: contract names all in the main text colour (a finished one too), the reward smaller than the name
       if(String(doneFs).toLowerCase()!==String(UIC.tx_1).toLowerCase()) bad.push('THREE: the finished contract name is not in the main text colour ('+doneFs+')');
       nm=ent.filter(function(h){ return /^destroy crawlers$/.test(String(h.t)); })[0]; rw=ent.filter(function(h){ return /^\$4.321$/.test(String(h.t)); })[0];
       if(!nm||!rw) bad.push('THREE: the kill contract row or its reward is missing ('+(nm?'':'name ')+(rw?'':'reward')+')');
       else if(!(nm.h-rw.h>=2*cd.z)) bad.push('THREE: the reward ('+rw.h.toFixed(1)+' px) is not smaller than the contract name ('+nm.h.toFixed(1)+' px)');
       // FOUR: the close hint
       ow=ent.filter(function(h){ return /^close$/.test(String(h.t)); })[0];
       if(!ow) bad.push('FOUR: no close hint on the map opened in the raid');
       g.mapFirst=1;
       ent=txRecord(function(){ drawMapOverlay(); }); g.mapFirst=0;
       if(ent.filter(function(h){ return /^close$/.test(String(h.t)); }).length) bad.push('FOUR: the opening map shows a close hint (the start button is there)');
       // FIVE: no label within 8 px of the map frame
       ent=txRecord(function(){ drawMapOverlay(); }); inset=8*cd.z; n=0; zp=0;
       ent.forEach(function(h){ b=txBox(h); cx=b.x+b.w/2; cy=b.y+b.h/2;
         if(cx>cd.ox&&cx<cd.ox+WORLD_W*cd.sc&&cy>cd.oy&&cy<cd.oy+WORLD_H*cd.sc){ n++; if(b.x<cd.ox+inset-1||b.x+b.w>cd.ox+WORLD_W*cd.sc-inset+1||b.y<cd.oy+inset-1||b.y+b.h>cd.oy+WORLD_H*cd.sc-inset+1){ zp++; if(zp<3) bad.push('FIVE: the label '+h.t+' is within 8 px of the map frame'); } } });
       if(n<10) bad.push('FIVE: only '+n+' texts were drawn on the map');
       return bad.length?bad.join('; '):null;
     } finally {
       proto.fillText=oFT; W=w0; H=h0;
       if(hadUs) P.uiScale=us0; else delete P.uiScale;
       MAPFIRST.skip=oSkip; keys={}; mouse.down=false;
       try{ if(G&&!G.over){ G.mapOpen=false; G.arcade=false; __endRaid('abandon'); } }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     } }},
  {v:'31.47',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
