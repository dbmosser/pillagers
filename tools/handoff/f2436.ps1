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

if ($s.Contains("  {v:'24.36',what:")) { throw "check 24.36 is in the fixture already" }

SubRx @'
  {v:'24.35',what:
'@ @'
  {v:'24.36',what:'graphics program gfx24: the muzzle flash is on the first frame: he fires, two 0.05 second sim steps run his muzzle timer out, and the next drawn frame still paints the baked flash sprite once at full strength (alpha 0.9 or more); the frame after is fainter or gone; a teammate tracer start in sight makes one too',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__runPrep&&window.__sim&&window.__frame)||typeof fireWeapon!=='function') return 'SKIP: this fixture cannot fire and draw';
     if(typeof MUZSPR==='undefined'||typeof GFXMUZ==='undefined') return 'there is no muzzle flash sprite store (MUZSPR): a shot whose timer ran out before the frame has no flash';
     var bad=[], g=null, p=null, w=null, own=false, of=null, hits=[], by0=GFX.bypass, r;
     function isMuz(im){ var k; for(k in MUZSPR.m) if(MUZSPR.m[k]===im) return true; return false; }
     function draw(){
       hits=[]; own=Object.prototype.hasOwnProperty.call(wc,'drawImage'); of=wc.drawImage;
       wc.drawImage=function(im){ if(isMuz(im)) hits.push(this.globalAlpha); return of.apply(this,arguments); };
       try{ __frame(0.016); } finally { if(own) wc.drawImage=of; else delete wc.drawImage; }
       return hits.slice();
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0);
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       p=g.player; p.iv=99; p.face=0; keys={}; GFX.bypass=0; GFXMUZ.length=0;
       w=(typeof WEAPONS!=='undefined'&&WEAPONS.pistol)?WEAPONS.pistol:null;
       if(!w&&p.wep&&p.wep.mag>0) w=p.wep;
       if(!w) return 'SKIP: staging: no gun to fire';
       draw();
       fireWeapon(p,w,p.x+200,p.y,true);
       __sim(0.05); __sim(0.05);
       if(p.muzzle>0) return 'SKIP: staging: the muzzle timer did not run out in 0.1 seconds';
       r=draw();
       if(r.length!==1) bad.push('the first frame after the shot drew the flash sprite '+r.length+' times, not once');
       else if(!(r[0]>=0.9)) bad.push('the first frame drew the flash at alpha '+r[0]+', not 0.9 or more');
       r=draw();
       if(r.length&&r[0]>=0.9) bad.push('the second frame still drew the flash at full strength ('+r[0]+')');
       draw(); draw(); draw(); draw();
       if(GFXMUZ.length) bad.push(GFXMUZ.length+' flash events are left 6 frames after the shot');
       if(typeof gfxShotFx!=='function') bad.push('there is no flash for a teammate tracer (gfxShotFx)');
       else {
         gfxShotFx(p.x+30,p.y,0,'#ffd48a'); gfxShotFx(p.x+31,p.y,0.05,'#ffd48a');
         r=draw();
         if(r.length!==1) bad.push('a teammate shot of two pellets beside him drew '+r.length+' flashes, not 1');
       }
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       GFX.bypass=by0; keys={}; try{ GFXMUZ.length=0; }catch(_m){}
       try{ var g2=__state(); if(g2){ if(!g2.over){ g2.player.iv=0; g2.player.downed=false; __endRaid('abandon'); } } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'24.35',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
