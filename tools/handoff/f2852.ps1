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

if ($s.Contains("  {v:'28.52',what:")) { throw "check 28.52 is in the fixture already" }

SubRx @'
  {v:'28.51',what:
'@ @'
  {v:'28.52',what:'cloud-feel-draw-roll: a swap (F) to the Longshot and a roll (Space) at once: the gun is ready about when it is without the roll, not 0.38 s later',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: no raid here';
     var bad=[], g, p, i, a, b;
     function kd(c){ window.dispatchEvent(new KeyboardEvent('keydown',{code:c,key:c,bubbles:true})); }
     function ku(c){ window.dispatchEvent(new KeyboardEvent('keyup',{code:c,key:c,bubbles:true})); }
     function st(n){ for(i=0;i<n;i++){ g.t+=0.016; __sim(0.016); } }
     function trial(roll){
       var n=1, r={};
       p.wep=cloneObj(WEAPONS.pistol); p.ammo=12; p.sec=cloneObj(WEAPONS.sniper); p.secAmmo=5; p.reserve=50; p.stam=100; p.rollCd=0; p.reloading=0; st(120);
       kd('KeyF'); ku('KeyF');
       if(!p.wep||p.wep.id!=='sniper') return null;
       st(1); r.d0=p.drawT;
       if(roll){ p.stam=100; p.rollCd=0; kd('Space'); ku('Space'); if(!(p.roll>0)) return null; }
       while(p.drawT>0&&n<200){ st(1); n++; }
       r.s=n*0.016; return r;
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       if(g.sim) return 'SKIP: the fixture raid is a sim raid';
       p=g.player; g.ents=[]; p.iv=99;
       a=trial(false); if(!a||!(a.d0>0.5)) return 'SKIP: staging: F did not start the Longshot draw';
       b=trial(true); if(!b) return 'SKIP: staging: the swap or the roll did not happen';
       if(!(b.s<a.s+0.1)) bad.push('the Longshot was ready after '+b.s.toFixed(2)+' s with a roll against '+a.s.toFixed(2)+' s without');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ mouse.down=false; ku('KeyF'); ku('Space'); keys['KeyF']=false; keys['Space']=false; }catch(_k){}
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'28.51',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
