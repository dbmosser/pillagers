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

if ($s.Contains("  {v:'35.67',what:")) { throw "check 35.67 is in the fixture already" }

SubRx @'
  {v:'35.66',what:
'@ @'
  {v:'35.67',what:'enemy rounds warn red in both windows; allied and forged player rounds keep gun colours, and muzzle flashes stay warm',
   run:function(){
     var g=null,p,keep={},k,sent=[],flashes=[],local=[],oFlash=flash,oFx=gfxShotFx,by0=GFX.bypass;
     function peer(seat){ return {state:'in',seat:seat,name:'tracer check',timers:[],dc:{readyState:'open',send:function(t){sent.push(JSON.parse(t));}}}; }
     function shot(sh,w,mine,tint,label){
       g.bullets.length=0; local.length=0;
       fireWeapon(sh,w,p.x+300,p.y,mine);
       var b=g.bullets[g.bullets.length-1];
       if(!b) throw Error(label+' made no round');
       if(b.tint!==tint) throw Error(label+' tint '+b.tint+', expected '+tint);
       if(local[local.length-1]!== (w.tint||'#ffc27a')) throw Error(label+' changed the local muzzle tint');
       return b;
     }
     function take(b,sh,w,expected){
       NET.role='host'; NET.seat=0; NET.peers=[peer(1)]; sent.length=0;
       if(!netFxShot(b,sh,w,0)) throw Error('shot was not sent');
       var m=sent.filter(function(q){return q.t==='fx'&&q.k==='b';})[0],j,fb,hasMuzzle=sh===p||sh.kind==='raider';
       if(!m||m.b[5]!==b.tint) throw Error('wire changed tracer tint');
       // Machines have no held gun muzzle: their normal word has eight fields.
       // Player and pillager bot words carry the drawn muzzle, exercising both receiver calls below.
       if(hasMuzzle&&m.b.length<11) throw Error(sh.kind+' modern muzzle word missing');
       if(!hasMuzzle&&m.b.length!==8) throw Error(sh.kind+' base shot word has '+m.b.length+' fields');
       NET.role='join'; NET.seat=1; NET.peers=[peer(0)];
       for(j=0;j<(hasMuzzle?2:1);j++){
         g.fxBullets=[]; flashes.length=0;
         netFxTake(NET.peers[0],{t:'fx',k:'b',s:0,b:j?m.b.slice(0,8):m.b});
         fb=g.fxBullets[0];
         if(!fb||fb.tint!==b.tint||fb.elw!==(b.el?1:0)) throw Error('receiver changed tracer colour or elemental width');
         if(flashes.length!==1||flashes[0]!==expected) throw Error((hasMuzzle&&!j?'modern':'legacy')+' receiver flash '+flashes.join(',')+', expected '+expected);
       }
     }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:['gun_rifle'],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: staging: no raid';
       p=g.player; p.iv=999; keys={}; mouse.down=false; CFG.xfPix=0;
       for(k in NET) keep[k]=NET[k];
       NET.on=false; GFX.bypass=0;
       flash=function(x,y,r,c,t){local.push(c);return oFlash.apply(this,arguments);};
       gfxShotFx=function(x,y,a,c){flashes.push(c);return true;};
       var s={kind:'sentry',x:p.x-150,y:p.y,r:22,hp:150,face:0,hostile:true},
           bot={kind:'raider',x:p.x-150,y:p.y-60,r:11,hp:70,face:0,hostile:true},
           sw={dmg:14,spread:0.1,rng:340,noise:340,tint:'#ff9a6a'},rw=cloneObj(WEAPONS.rifle),b,fw,i;
       b=shot(s,sw,false,'#ff3b2f','sentry');
       if(typeof ENEMY_TRACER==='undefined'||ENEMY_TRACER!=='#ff3b2f') return 'missing shared warning colour';
       shot(bot,rw,false,ENEMY_TRACER,'hostile pillager bot');
       var allies=[{kind:'raider',merc:1},{kind:'raider',friendlyPC:1},{kind:'raider',friendly:1},{kind:'stray'},{kind:'peddler'}];
       for(i=0;i<allies.length;i++){ allies[i].x=bot.x; allies[i].y=bot.y; allies[i].r=11; allies[i].hp=70; allies[i].face=0; shot(allies[i],rw,false,'#ffcf7a','ally '+i); }
       shot(p,rw,true,rw.tint,'player');
       fw=forgeApply(cloneObj(WEAPONS.rifle),2,'shock');
       if(fw.el!=='shock'||!fw.tint) return 'forged rifle did not stage';
       bot.elite=true; shot(bot,fw,false,ENEMY_TRACER,'forged elite pillager bot');
       b=shot(p,fw,true,fw.tint,'forged player');
       if(b.el!=='shock') return 'forged player round lost its element';
       NET.on=true; NET.up=[]; NET.upSeed=g.seed>>>0;
       NET.roster=[{seat:0,pid:'me',name:'host',host:true},{seat:1,pid:'tracer-mate',name:'mate'}];
       take(b,p,fw,fw.tint);
       NET.on=false; b=shot(s,sw,false,ENEMY_TRACER,'network sentry'); NET.on=true; take(b,s,sw,'#ffc27a');
       NET.on=false; b=shot(bot,rw,false,ENEMY_TRACER,'network bot'); NET.on=true; take(b,bot,rw,'#ffc27a');
       return null;
     } finally {
       flash=oFlash; gfxShotFx=oFx; GFX.bypass=by0;
       if(g){ g.bullets.length=0; g.fxBullets=[]; }
       if(Object.keys(keep).length){for(k in NET) if(!(k in keep)) delete NET[k]; for(k in keep) NET[k]=keep[k];}
       try{__endRaid('abandon');}catch(_e){} __topClear();
     }
   }},
  {v:'35.66',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
