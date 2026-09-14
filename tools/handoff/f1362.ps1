$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

SubRx @'
  {v:'13.61',what:
'@ @'
  {v:'13.62',what:'a cooked grenade owns the hand until it is thrown: switching to an automatic gun mid-cook and holding the trigger fires nothing while the fuse keeps counting, and G throws no second grenade, while the same gun fires normally with nothing cooking (in-raid audit 2026-09-14, finding 3)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof updatePlayer!=='function'||typeof startCook!=='function'||typeof setHot!=='function'||typeof gunCell!=='function'||typeof doThrow!=='function') return 'SKIP: no cook or belt in this build';
     var bad=[];
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g.player, i;
       if(!p.wep||!p.wep.id||p.wep.id==='fists') return 'SKIP: no gun in hand at the drop';
       g.ents.length=0; p.downed=false; p.iv=99; p.roll=0;
       p.wep.auto=true; p.wep.jam=0; p.jam=0; p.reloading=0; p.ammo=Math.max(p.ammo||0,20); p.trigYield=0;
       var gc=gunCell(), fc=-1, sl=hotbarSlots();
       for(i=0;i<sl.length;i++) if(sl[i]&&sl[i].k==='throw:frag') fc=i;
       if(fc<0) return 'SKIP: no Frag cell on the belt';
       // CONTROL: the gun fires when nothing is cooking.
       setHot(gc); p.cooking=0; p.fired=false; p.lastShot=-99999;
       var s0=g.tel.shots||0;
       mouse.down=true; updatePlayer(0.016); mouse.down=false; updatePlayer(0.016);
       if(!((g.tel.shots||0)>s0)) return 'SKIP: the gun did not fire in this staging, so a silence below would prove nothing';
       // THE FINDING: cook a Frag, switch to the gun, keep holding.
       g.pouch.frag=2; setHot(fc); p.fired=false; p.cooking=0; p.cookT=0;
       mouse.down=true; updatePlayer(0.016);
       if(!p.cooking) return 'SKIP: the press on the Frag cell did not start a cook';
       setHot(gc);
       var s1=g.tel.shots||0, t0=p.cookT||0, fuse=(typeof FRAG_FUSE==='number')?FRAG_FUSE:2;
       var steps=Math.max(2,Math.floor((fuse*0.5)/0.05));
       for(i=0;i<steps&&p.cooking;i++){ p.lastShot=-99999; updatePlayer(0.05); }
       if((g.tel.shots||0)!==s1) bad.push('with a Frag cooking in his hand, switching to the gun and holding the trigger fired '+((g.tel.shots||0)-s1)+' round(s)');
       if(p.cooking&&!((p.cookT||0)>t0+0.2)) bad.push('with the gun selected mid-cook the fuse stopped counting ('+t0.toFixed(2)+' to '+(p.cookT||0).toFixed(2)+'), so the grenade in hand never goes off');
       // AND G does not throw a second grenade while one is cooking.
       if(p.cooking){
         var pouch0=g.pouch.frag, thr0=g.throws.length;
         G.tsel=THROWKEYS.indexOf('frag'); doThrow();
         if(g.pouch.frag!==pouch0||g.throws.length!==thr0) bad.push('the throw key with a Frag cooking threw a second grenade (pouch '+pouch0+' to '+g.pouch.frag+')');
       }
       mouse.down=false;
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ mouse.down=false; var g2=__state(); if(g2&&g2.player){ g2.player.cooking=0; g2.player.cookT=0; g2.player.iv=0; g2.player.downed=false; if(g2.throws) g2.throws.length=0; } if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.61',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
