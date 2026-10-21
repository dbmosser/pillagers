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

if ($s.Contains("  {v:'33.76',what:")) { throw "check 33.76 is in the fixture already" }

SubRx @'
  {v:'33.75',what:
'@ @'
  {v:'33.76',what:'cw-pixdoors (86d): THE PIXEL DOOR, WINDOW, STRONGHOLD WALL AND UNDERCROFT WALL. With the pixel look on a door, a window, a stronghold shutter and barricade and an Undercroft wall draw only solid (alpha 255) pixels on the 2 unit art grid, in the district ramp, ink, lock, glass and hazard tones; the hub wall bakes once; kerbs and ruins bake as pixel wall sprites; the keyed door lock light follows the key',
   run:function(){
     if(typeof pixDoorDraw!=='function'||typeof pixWinDraw!=='function'||typeof pixShDraw!=='function'||typeof pixHubWall!=='function') return 'no pixel door/window/stronghold/hub wall';
     if(!(window.__deploy&&window.__state&&window.__runPrep&&window.__topClear&&window.__endRaid)) return 'SKIP: this fixture cannot build a raid';
     var bad=[], cond0=P.cond, nm, R, ok, ox, oy, W, H, s, px, px2, e, e2, GL, i, hxs;
     function hex(r,g,b){ return '#'+((1<<24)+(r<<16)+(g<<8)+b).toString(16).slice(1); }
     function shot(fn,w,h){ var s2=pixCanvas(w,h); s2.x.translate(-ox,-oy); fn(s2.x); return s2.x.getImageData(0,0,w,h).data; }
     function audit(p,w,h,okm,label){
       var x, y, o, a, h0, j, painted=0;
       for(y=0;y<h;y++) for(x=0;x<w;x++){
         o=(y*w+x)*4; a=p[o+3];
         if(a!==0&&a!==255) return label+': alpha '+a+' at '+x+','+y;
         if(a===255){ painted++; h0=hex(p[o],p[o+1],p[o+2]); if(!okm[h0]) return label+': colour '+h0+' is not an allowed tone'; }
       }
       for(y=0;y<h;y+=2) for(x=0;x<w;x+=2){
         o=(y*w+x)*4;
         for(j=0;j<4;j++) if(p[o+j]!==p[o+4+j]||p[o+j]!==p[o+w*4+j]||p[o+j]!==p[o+w*4+4+j]) return label+': not on the 2 unit grid at '+x+','+y;
       }
       return painted>0?null:label+': drew nothing';
     }
     function okOf(rr,extra){ var m={}; rr.wall.concat(rr.top).concat(extra||[]).forEach(function(h2){ m[h2.toLowerCase()]=1; }); m[PIX_INK]=1; return m; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242}); keys={};
       CFG.xfPix=1;
       for(nm=0;nm<2;nm++){
         P.cond=nm?'night':'day'; GL=PIX_GLASS[nm?'night':'day']; R=pixWallRamps(3); ok=okOf(R,GL.concat(['#7fc4a0','#ffc04a']));
         // the door, with and without its key
         for(i=0;i<2;i++){
           ox=60; oy=40; W=120; H=120;
           px=shot(function(c){ pixDoorDraw(c,{x:100,y:100,w:24,h:12,d:3,door:'k1'},3,26,!!i); },W,H);
           s=audit(px,W,H,ok,(nm?'night':'day')+' door'+i); if(s) bad.push(s);
           if(i===0) px2=px; else { var same=true, q; for(q=0;q<px.length;q++) if(px[q]!==px2[q]){ same=false; break; } if(same) bad.push('the door looks the same with and without its key'); }
         }
         px=shot(function(c){ pixWinDraw(c,{x:100,y:100,w:40,h:10,d:3,win:1},3,26); },W,H);
         s=audit(px,W,H,ok,(nm?'night':'day')+' window'); if(s) bad.push(s);
         ok=okOf(R,['#4a525b','#626d79','#8a96a3','#3a4048','#f0c020','#15171a','#ff4028','#9a2418','#3a2f22','#4a3c2a','#7a6244','#b9a37c']);
         px=shot(function(c){ if(!pixShDraw(c,{x:100,y:100,w:60,h:12,d:3,sh:1,sgate:1},26)) bad.push('shutter not drawn'); },W,H);
         s=audit(px,W,H,ok,(nm?'night':'day')+' shutter'); if(s) bad.push(s);
         px=shot(function(c){ if(!pixShDraw(c,{x:100,y:100,w:40,h:12,d:3,sh:1,sblk:1},26)) bad.push('barricade not drawn'); },W,H);
         s=audit(px,W,H,ok,(nm?'night':'day')+' barricade'); if(s) bad.push(s);
         if(pixShDraw(null,{x:0,y:0,w:10,h:10,sh:1},26)) bad.push('a plain stronghold wall claimed the pixel draw');
       }
       // the Undercroft wall: solid, on the grid, baked once
       hxs={}; for(i=0;i<DISTRICTS.length;i++){ var Dq=DISTRICTS[i]; [0.30,0.45,0.58].forEach(function(k){ hxs[hubWallHex(Dq.wallTop,k)]=1; }); [0.42,0.55,0.66,0.76].forEach(function(k){ hxs[hubWallHex(Dq.wall,k)]=1; }); }
       hxs[PIX_INK]=1;
       ok={}; Object.keys(hxs).forEach(function(h2){ ok[h2.toLowerCase()]=1; });
       ox=60; oy=40; W=160; H=120;
       px=shot(function(c){ pixHubWall(c,{x:100,y:100,w:90,h:10,d:1},1,26); },W,H);
       s=audit(px,W,H,ok,'hub wall'); if(s) bad.push(s);
       var keys0=Object.keys(PIXHUBW).length; pixHubWall(pixCanvas(10,10).x,{x:100,y:100,w:90,h:10,d:1},1,26);
       if(Object.keys(PIXHUBW).length!==keys0) bad.push('the hub wall baked again for the same wall');
       // kerbs and ruins are pixel wall sprites
       P.cond='day';
       e=wallSprite({x:300,y:300,w:60,h:14,d:1,ledge:1},1,0); e2=wallSprite({x:400,y:300,w:70,h:30,d:1,ruin:1},1,26);
       if(!e||!e.px) bad.push('a kerb is not a pixel wall sprite'); else if(e.c.height!==7) bad.push('the kerb sprite is '+e.c.height+' art px tall, wanted 7');
       if(!e2||!e2.px) bad.push('a ruin is not a pixel wall sprite');
       // the look off: the pixel doors do not run (pixOn is the switch the wall pass reads)
       CFG.xfPix=0; if(pixOn()) bad.push('xfPix 0 still says the pixel look is on');
       if(pixFaults()) bad.push('pixel faults logged: '+pixFaults());
       return bad.length?bad.join('; '):null;
     } catch(err){
       return 'pixel door check: '+String(err&&err.message||err);
     } finally {
       P.cond=cond0; CFG.xfPix=0;
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e2){}
       keys={}; __resetCfg(); __topClear(); __cleanProfile();
     } }},
  {v:'33.75',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
