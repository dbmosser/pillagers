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

if ($s.Contains("  {v:'22.17',what:")) { throw "check 22.17 is in the fixture already" }

SubRx @'
  {v:'22.16',what:
'@ @'
  {v:'22.17',what:'the empty-gun reticle names the reload button of the device in hand: [X] RELOAD on a controller, [SQUARE] RELOAD on a PlayStation pad, [R] RELOAD on a keyboard with R unmoved',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof drawHUD!=='function'||typeof keyLabel!=='function'||typeof PAD!=='object'||!PAD) return 'SKIP: no raid or HUD here';
     var bad=[], g, p=null, seen=[], had=Object.prototype.hasOwnProperty.call(ctx,'fillText'), oFT=ctx.fillText, on0=PAD.on, br0=PAD.brand, mx0=mouse.x, my0=mouse.y, a0, r0, j0, rl0, w0, k, kb, pd;
     function draw(){ seen=[]; try{ drawHUD(); }catch(_h){} return seen.filter(function(s){ return /RELOAD$/.test(s)||/^EMPTY - /.test(s); }); }
     try{
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       p=g.player; a0=p.ammo; r0=p.reserve; j0=p.jam; rl0=p.reloading; w0=p.wep;
       if(!p.wep||!(p.wep.mag>0)){ for(k in WEAPONS) if(WEAPONS[k]&&WEAPONS[k].mag>0){ p.wep=WEAPONS[k]; break; } }
       if(!p.wep||!(p.wep.mag>0)) return 'SKIP: staging: no gun in hand';
       p.ammo=0; p.reserve=37; p.jam=0; p.reloading=0; g.bagOpen=false; g.mapOpen=false;
       mouse.x=Math.round(W*0.5); mouse.y=Math.round(H*0.4);
       ctx.fillText=function(s){ seen.push(String(s)); return oFT.apply(this,arguments); };
       PAD.on=false;
       kb=draw();
       if(!kb.length) return 'SKIP: staging: the empty reticle was not drawn';
       if(keysOf('KeyR')==='KeyR'&&kb[0]!=='[R] RELOAD') bad.push('on the keyboard the empty reticle reads '+kb[0]);
       PAD.on=true; PAD.brand='xbox';
       pd=draw();
       if(pd.indexOf('[X] RELOAD')<0) bad.push('on a controller the empty reticle reads '+(pd[0]||'nothing')+', not [X] RELOAD');
       PAD.brand='ps';
       pd=draw();
       if(pd.indexOf('[SQUARE] RELOAD')<0) bad.push('on a PlayStation pad the empty reticle reads '+(pd[0]||'nothing')+', not [SQUARE] RELOAD');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       if(had) ctx.fillText=oFT; else delete ctx.fillText;
       PAD.on=on0; PAD.brand=br0; mouse.x=mx0; mouse.y=my0;
       try{ if(p){ p.ammo=a0; p.reserve=r0; p.jam=j0; p.reloading=rl0; p.wep=w0; } }catch(_p){}
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'22.16',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
