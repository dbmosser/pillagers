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

if ($s.Contains("  {v:'29.08',what:")) { throw "check 29.08 is in the fixture already" }

SubRx @'
  {v:'29.07',what:
'@ @'
  {v:'29.08',what:'cw-muzzlenet: the partner window draws a teammate rifle flash at the drawn muzzle and starts his tracer there, as the shooter window does, aiming east and west',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: no raid here';
     var bad=[], g, p, k, NK={}, sent=[], oBy=GFX.bypass, w, own, b, msg, fm, fb, r, j, angs=[0,Math.PI];
     function mk(seat){ return {state:'in',seat:seat,name:'ZQX',timers:[],dc:{readyState:'open',send:function(t){ sent.push(JSON.parse(t)); }}}; }
     for(k in NET) NK[k]=NET[k];
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       if(g.sim) return 'SKIP: the fixture raid is a sim raid';
       p=g.player; p.iv=99; GFX.bypass=0; w=WEAPONS.rifle;
       NET.on=true; NET.up=[]; NET.upSeed=g.seed>>>0;
       NET.roster=[{seat:0,pid:'me',name:'HOST',host:true},{seat:1,pid:'zqxmate',name:'ZQX MATE'}];
       for(j=0;j<angs.length;j++){
         GFXMUZ.length=0; g.bullets.length=0; g.fxBullets=[]; sent.length=0; NET.role='host'; NET.seat=0; NET.peers=[mk(1)];
         fireWeapon(p,w,p.x+300*Math.cos(angs[j]),p.y+300*Math.sin(angs[j]),true);
         own=GFXMUZ[GFXMUZ.length-1]; b=g.bullets[g.bullets.length-1];
         msg=sent.filter(function(m){ return m&&m.t==='fx'&&m.k==='b'; })[0];
         if(!own||!b||!(b.mzd>0)) return 'SKIP: staging: the shooter window drew no muzzle flash or no muzzle tracer';
         if(!msg) return 'SKIP: staging: no tracer word was sent';
         GFXMUZ.length=0; g.fxBullets=[]; NET.role='join'; NET.seat=1; NET.peers=[mk(0)];
         r=netFxTake(NET.peers[0],msg);
         fm=GFXMUZ[GFXMUZ.length-1]; fb=g.fxBullets[g.fxBullets.length-1];
         if(r!=='fx:b'||!fm||!fb){ bad.push((j?'west':'east')+': the partner window did not take the tracer word ('+r+')'); continue; }
         if(Math.hypot(fm.x-own.x,fm.y-own.y)>2) bad.push((j?'west':'east')+': partner flash at '+(fm.x-p.x).toFixed(1)+','+(fm.y-p.y).toFixed(1)+' but the shooter flash at '+(own.x-p.x).toFixed(1)+','+(own.y-p.y).toFixed(1));
         if(!(Math.abs((+fb.mzd||0)-b.mzd)<=0.1)) bad.push((j?'west':'east')+': partner tracer starts '+(fb.mzd===undefined?'inside the gun (no mzd)':fb.mzd)+' but the shooter tracer at mzd '+b.mzd.toFixed(1));
         else if(!(Math.abs(Math.hypot(fb.x-fb.sx,fb.y-fb.sy)-Math.hypot(b.x-b.sx,b.y-b.sy))<=0.5)) bad.push((j?'west':'east')+': partner tracer measures its muzzle from a different point');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ GFX.bypass=oBy; GFXMUZ.length=0; for(k in NET) if(!(k in NK)) delete NET[k]; for(k in NK) NET[k]=NK[k]; if(g){ g.bullets.length=0; g.fxBullets=[]; } }catch(_h){}
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'29.07',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
