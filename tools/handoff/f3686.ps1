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

if ($s.Contains("  {v:'36.86',what:")) { throw "check 36.86 is in the fixture already" }

SubRx @'
  {v:'36.85',what:
'@ @'
  {v:'36.86',what:'cw-bldsmooth: the smooth look (look off, the default) bakes the kind floor and the flat details of each building kind into the ground, the same as the pixel look; the seeded stream does not move',
   run:function(){
     if(typeof bldKind!=='function'||typeof pixKindDetail!=='function'||typeof bldKindFloor!=='function') return 'no building kind (bldKind)';
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__topClear)) return 'SKIP: this fixture cannot build a raid';
     var bad=[], old=CFG.xfPix, m, g, c, i, j, b, kinds={}, kk=[], sav=[], a, im, im2, d, n, nk=0, r0, r1, perKind={}, w, h, g2, k;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       CFG.xfPix=0; CFG.bsolid=0;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242}); keys={};
       m=__state().map;
       for(i=0;i<m.buildings.length;i++){ k=m.buildings[i].kind; if(k&&!kinds[k]){ kinds[k]=1; nk++; } }
       if(nk<3) bad.push('only '+nk+' kinds on the map');
       RNGS=777; g=bakeGround(m,false); r0=RNGS;
       c=g.getContext('2d');
       for(i=0;i<m.buildings.length;i++){ sav.push(m.buildings[i].kind); m.buildings[i].kind=undefined; }
       RNGS=777; g2=bakeGround(m,false); r1=RNGS;
       if(r0!==r1) bad.push('kinds move the seeded stream in the smooth bake: '+r0+' against '+r1);
       for(i=0;i<m.buildings.length;i++){ m.buildings[i].kind=sav[i]; }
       for(i=0;i<m.buildings.length;i++){
         b=m.buildings[i]; if(!b.kind) continue;
         w=Math.floor(b.w-40); h=Math.floor(b.h-40); if(w<40||h<40) continue;
         im=c.getImageData(Math.floor(b.x+20),Math.floor(b.y+20),w,h).data;
         im2=g2.getContext('2d').getImageData(Math.floor(b.x+20),Math.floor(b.y+20),w,h).data;
         n=0; for(j=0;j<im.length;j+=4) if(Math.abs(im[j]-im2[j])+Math.abs(im[j+1]-im2[j+1])+Math.abs(im[j+2]-im2[j+2])>12) n++;
         perKind[b.kind]=Math.max(perKind[b.kind]||0,n);
       }
       for(var kd in kinds) if(!(perKind[kd]>=120)) bad.push('the smooth ground of a '+kd+' looks the same with or without its kind ('+(perKind[kd]||0)+' px differ)');
       return bad.length?bad.join('; '):null;
     } catch(err){
       return 'smooth building kinds check: '+String(err&&err.message||err);
     } finally {
       delete CFG.bsolid; CFG.xfPix=old;
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e2){}
       keys={}; __resetCfg(); __topClear(); __cleanProfile();
     } }},
  {v:'36.85',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
