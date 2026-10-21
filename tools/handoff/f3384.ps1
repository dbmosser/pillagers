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

if ($s.Contains("  {v:'33.84',what:")) { throw "check 33.84 is in the fixture already" }

SubRx @'
  {v:'33.83',what:
'@ @'
  {v:'33.84',what:'cw-pixrole (86g): with the pixel look on the role gear is scaled by one figure constant so its shoulder line sits within 1 art px of the pixel shoulders, the aim dots take no build height on the pixel body, and the peddler and the survivor are pixel suits (the survivor with a bandage and no pack, the peddler with stubble), while the pixel look off keeps the old figure scale',
   run:function(){
     if(typeof figKS!=='function'||typeof PIX_FIGK==='undefined'||!PXB_RAMP.survivor) return 'no pixel role gear (figKS, PIX_FIGK, the suits)';
     if(!(window.__deploy&&window.__state&&window.__runPrep&&window.__topClear&&window.__endRaid)) return 'SKIP: this fixture cannot draw a raid';
     var bad=[], g, saved=false, k, bk, sc=[], s0, r0, rc=[], a, b, i, up, z, found, sv, pd, plain, n0;
     function px(c){ return c.getContext('2d').getImageData(0,0,c.width,c.height).data; }
     function draw1(s,mode,face){ pixFrame(); drawOp(600,500,face||0,0,'#242832',0,0,mode||'',0,s); }
     function body(s,mode,face,tr){ var j, b4=PIX.bodies; for(j=0;j<(tr||14)&&PIX.bodies===b4;j++) draw1(s,mode,face); return PIX.bodies>b4; }
     function firstRect(bld){
       var d0=wc.rect, out=null;
       wc.rect=function(){ if(!out) out=[].slice.call(arguments); return d0.apply(wc,arguments); };
       try{ drawAimMark({x:600,y:500},{id:'rifle'},0.5,300,false,bld); } finally{ delete wc.rect; }
       return out;
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242}); keys={}; g=__state();
       if(!g||g.over) return 'SKIP: no raid';
       wc.save(); saved=true; wc.setTransform(1,0,0,1,0,0);
       // the old figure scale stays with the pixel look off
       CFG.xfPix=0; bk=figBuildK('lean'); k=figKS('lean');
       if(Math.abs(k[0]-FIG_SCALE*bk[0])>1e-9||Math.abs(k[1]-FIG_SCALE*bk[1])>1e-9) bad.push('with the pixel look off the role gear scale is '+k.join(',')+', not the old figure scale');
       CFG.xfPix=1; k=figKS('broad');
       if(k[0]!==PIX_FIGK||k[1]!==PIX_FIGK) bad.push('with the pixel look on the role gear scale is '+k.join(',')+', not '+PIX_FIGK);
       // the shoulder line of the gear (the pauldron top, 23.6 up in the old figure) against the pixel shoulders (art row 22 plus the ink ring, up from the foot row)
       if(Math.abs(23.6*PIX_FIGK-(PXB.AY-23))>1) bad.push('the role gear shoulder line is '+(23.6*PIX_FIGK).toFixed(1)+' up, the pixel shoulders are '+(PXB.AY-23)+' up');
       // drawRoleMark applies that scale about the feet
       s0=wc.scale; wc.scale=function(){ sc.push([].slice.call(arguments)); return s0.apply(wc,arguments); };
       try{ drawRoleMark({kind:'raider',prole:'rush',x:600,y:500,hp:50,face:0,step:0,state:'idle',build:'broad'}); } finally{ delete wc.scale; }
       if(!sc.length||sc[0][0]!==PIX_FIGK||sc[0][1]!==PIX_FIGK) bad.push('drawRoleMark scaled the gear by '+(sc.length?sc[0].join(','):'nothing')+', wanted '+PIX_FIGK);
       // the aim dots take no build height on the pixel body
       a=firstRect('broad'); b=firstRect(null);
       if(!a||!b||a[0]!==b[0]||a[1]!==b[1]) bad.push('the aim dots move with the build on the pixel body ('+(a&&a.slice(0,2))+' against '+(b&&b.slice(0,2))+')');
       CFG.xfPix=0; a=firstRect('broad'); b=firstRect(null); CFG.xfPix=1;
       if(a&&b&&a[0]===b[0]&&a[1]===b[1]) bad.push('the aim dots lost the build height with the pixel look off');
       // the suits
       plain=px(pxBuildUpper({head:'short',skin:'tan',clothes:'scav',bot:0,mir:0,pup:0,arms:1,lamp:'',band:'',low:0,bulk:0,tell:0}).c);
       sv=px(pxBuildUpper({head:'short',skin:'tan',clothes:'survivor',bot:0,mir:0,pup:0,arms:1,lamp:'',band:'',low:0,bulk:0,tell:0}).c);
       pd=px(pxBuildUpper({head:'short',skin:'fair',clothes:'peddler',bot:0,mir:0,pup:0,arms:1,lamp:'',band:'',low:0,bulk:0,tell:0}).c);
       n0=0; found=0; for(i=0;i<sv.length;i+=4) if(sv[i+3]&&sv[i]===0xd8&&sv[i+1]===0xd4&&sv[i+2]===0xc8) found++;
       if(found<10) bad.push('the survivor has '+found+' bandage pixels');
       // no pack: the left of the sprite (where the satchel hangs) has fewer opaque pixels than the plain body
       a=0; b=0; for(z=0;z<PXB.H+2;z++) for(i=0;i<8;i++){ if(sv[(z*(PXB.W+2)+i)*4+3]) a++; if(plain[(z*(PXB.W+2)+i)*4+3]) b++; }
       if(!(a<b-20)) bad.push('the survivor carries a pack ('+a+' pixels on the pack side against '+b+')');
       n0=0; for(i=0;i<pd.length;i++) if(pd[i]!==plain[i]) n0++;
       if(n0<40) bad.push('the peddler suit looks like the plain scav ('+n0+' bytes differ)');
       if(!body({moving:false,sprint:false,ads:false,hurt:0,bulk:0,outfit:'outsurvivor',wave:0},'crouchnone',0,16)) bad.push('the survivor was not drawn in pixels');
       if(!body({moving:false,sprint:false,ads:false,hurt:0,outfit:'outpeddler'},'none',0,16)) bad.push('the peddler was not drawn in pixels');
       return bad.length?bad.join('; '):null;
     } catch(err){
       return 'pixel role check: '+String(err&&err.message||err);
     } finally {
       try{ delete wc.scale; }catch(_s){}
       try{ delete wc.rect; }catch(_s2){}
       if(saved){ try{ wc.restore(); }catch(_r){} }
       CFG.xfPix=0;
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e2){}
       keys={}; __resetCfg(); __topClear(); __cleanProfile();
     } }},
  {v:'33.83',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
