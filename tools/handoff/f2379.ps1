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

if ($s.Contains("  {v:'23.79',what:")) { throw "check 23.79 is in the fixture already" }

SubRx @'
  {v:'23.78',what:
'@ @'
  {v:'23.79',what:'his #17 and answer 34: picking up a gun raises its stat card against the gun in hand (verdict, DMG to HANDLING), twice the size at 4K, gone after 4 s',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__textTrace&&window.__forceSize)||typeof drawHUD!=='function'||typeof hudRes!=='function'||typeof grantLoot!=='function') return 'SKIP: no raid or HUD here';
     if(!ITEMS.gun_dmr) return 'SKIP: no Marksman Rifle item';
     var bad=[], g=null, p=null, forced=false, w0, a, b, gone;
     function grab(w,h){
       var out={dmg:0,hand:0,verdict:0}, tr, i;
       __forceSize(w,h); forced=true;
       g.bagOpen=false; g.mapOpen=false; if(g.gunCard) g.gunCard.t0=g.t||0;
       tr=__textTrace(function(){ try{ drawHUD(); }catch(_h){} });
       for(i=0;i<tr.length;i++){ if(tr[i].t==='DMG'&&!out.dmg) out.dmg=tr[i].px; if(tr[i].t==='HANDLING') out.hand=1; if(tr[i].t==='UPGRADE'||tr[i].t==='DOWNGRADE'||tr[i].t==='SIDEGRADE') out.verdict=tr[i].t; }
       return out;
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __pinDPR(1); }catch(_d){}
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       p=g.player; keys={}; g.bagOpen=false; g.mapOpen=false;
       w0=p.wep;
       grantLoot({x:p.x,y:p.y,loot:[]},['gun_dmr']);
       if(!g.gunCard) return 'picking up a Marksman Rifle raised no stat card';
       if(g.gunCard.gk!=='dmr') bad.push('the card is for '+g.gunCard.gk+', not the Marksman Rifle');
       if(g.gunCard.vs!==w0) bad.push('the card compares against something other than the gun that was in hand');
       a=grab(1920,1080);
       if(!a.dmg||!a.hand) bad.push('the pickup card did not draw DMG and HANDLING at 1080p');
       if(a.verdict!=='UPGRADE') bad.push('a Marksman Rifle over the starter reads '+a.verdict+', not UPGRADE');
       b=grab(3840,2160);
       if(W>3000&&a.dmg&&b.dmg&&b.dmg<a.dmg*1.8) bad.push('at 4K the card is '+b.dmg.toFixed(1)+' px against '+a.dmg.toFixed(1)+' px at 1080p');
       __forceSize(1920,1080);
       g.gunCard.t0=(g.t||0)-10;
       gone=__textTrace(function(){ try{ drawHUD(); }catch(_h3){} }).some(function(o){ return o.t==='HANDLING'; });
       if(gone) bad.push('the card is still up 10 s after the pickup');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       if(forced){ try{ cv.style.width=''; cv.style.height=''; hcv.style.width=''; hcv.style.height=''; resize(); }catch(_f){} }
       try{ var g2=__state(); if(g2&&!g2.over){ g2.gunCard=null; g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'23.78',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
