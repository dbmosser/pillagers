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

# v12.17 CHECK, inserted before the v12.16 entry. A raid is deployed with no
# Frag and two Smoke, the Frag cell is selected, and the trigger is held for
# one real player update. The gun must be selected, nothing cooking, the
# Smoke untouched, and the toast must say so.
SubRx @'
  {v:'12.16',what:'a death banks the XP its card printed, dose bonus included, instead of paying the run without the bonus after the drink is cleared (2026-09-06 first-ten-minutes audit)',
'@ @'
  {v:'12.17',what:'the trigger on an empty grenade cell selects the gun and says so, fires nothing on that same hold, and a loaded cell still cooks (2026-09-06 first-ten-minutes audit)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof updatePlayer!=='function'||typeof hotbarSlots!=='function'||typeof setHot!=='function') return 'SKIP: no belt or player update in this build';
     var bad=[];
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g.player;
       g.pouch.frag=0; g.pouch.smoke=2; g.pouch.decoy=0;
       var sl=hotbarSlots(), fi=-1;
       for(var i=0;i<sl.length;i++) if(sl[i]&&sl[i].kind==='throw'&&/frag/i.test(String(sl[i].k||sl[i].itemKey||sl[i].icon||''))){ fi=i; break; }
       if(fi<0) return 'SKIP: no Frag cell on the belt ('+sl.map(function(c){ return c&&(c.k||c.kind); }).join(',')+')';
       setHot(fi);
       if(hotSel()!==fi) return 'SKIP: the empty Frag cell could not be selected (selected '+hotSel()+')';
       p.downed=false; p.cooking=0; p.fired=false; mouse.down=true; window.__lastSay=null;
       updatePlayer(0.016);
       if(hotSel()!==0) bad.push('the press on the empty Frag cell left cell '+hotSel()+' selected instead of the gun');
       // TWO: the same hold, two more frames: the gun it raised must not fire.
       var _sh0=g.tel.shots||0, _am0=p.ammo;
       updatePlayer(0.016); updatePlayer(0.016);
       if((g.tel.shots||0)!==_sh0||p.ammo!==_am0) bad.push('the hold that yielded to the gun fired it on the same hold ('+((g.tel.shots||0)-_sh0)+' shots, ammo '+_am0+' to '+p.ammo+')');
       mouse.down=false; updatePlayer(0.016);
       if(p.cooking) bad.push('the press cooked a '+p.cookKind+' the cell did not name');
       if(g.pouch.smoke!==2) bad.push('the press spent a Smoke from an empty Frag cell (smoke now '+g.pouch.smoke+')');
       if(!/Nothing in that cell/.test(String(window.__lastSay||''))) bad.push('the press did not say the cell is empty (said "'+String(window.__lastSay||'')+'")');
       // THREE, CONTROL: a loaded Frag cell still cooks on the press and keeps the selection.
       g.pouch.frag=2; setHot(fi); p.fired=false; p.cooking=0; p.trigYield=0; mouse.down=true; updatePlayer(0.016);
       if(!p.cooking||p.cookKind!=='frag') bad.push('control: a loaded Frag cell did not cook on the press (cooking '+p.cooking+', kind '+p.cookKind+')');
       if(hotSel()!==fi) bad.push('control: a loaded Frag cell lost the selection');
       mouse.down=false; updatePlayer(0.016);
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{ try{ mouse.down=false; var g2=__state(); if(g2&&!g2.over){ g2.player.cooking=0; g2.player.fired=false; g2.player.downed=false; __endRaid('extract'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'12.16',what:'a death banks the XP its card printed, dose bonus included, instead of paying the run without the bonus after the drink is cleared (2026-09-06 first-ten-minutes audit)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
