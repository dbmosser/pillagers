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

if ($s.Contains("  {v:'28.56',what:")) { throw "check 28.56 is in the fixture already" }

SubRx @'
  {v:'28.55',what:
'@ @'
  {v:'28.56',what:'cloud-feel-rico-wreck-gone: a glancing round of yours still bounces off a standing wreck, and the round that breaks the wreck does not bounce off the gone wall',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: no raid here';
     var bad=[], g, p, w=null, ws, b, E0=null, r1, r2, hl, hm;
     function shoot(left){
       var ang=0.5236, k;
       g.bullets.length=0; g.ents=[];
       if(left!==undefined){ w.hpLeft=left; w.hpMax=wallHp(w); } else delete w.hpLeft;
       if(g.map.walls.indexOf(w)<0){ g.map.walls.push(w); rebuildGeometry(); }
       b={x:w.x+w.w/2-20,y:w.y-10,vx:Math.cos(ang)*1180,vy:Math.sin(ang)*1180,dmg:30,life:0.6,player:true,owner:p,tint:'#fff',thru:0};
       g.bullets.push(b);
       for(k=0;k<4&&g.bullets.indexOf(b)>=0&&!b._rico&&!b._pen;k++) updateBullets(0.016);
       return {stands:g.map.walls.indexOf(w)>=0, bounced:!!b._rico};
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       if(g.sim) return 'SKIP: the fixture raid is a sim raid';
       p=g.player; p.iv=99; E0=g.ents;
       ws=g.map.walls.filter(function(x){ return x.wreck&&wallHp(x)!==null&&x.w>30&&matOf(x)==='metal'; });
       if(!ws.length) return 'SKIP: staging: no metal wreck in the fixture raid';
       w=ws[0]; hl=w.hpLeft; hm=w.hpMax;
       r1=shoot();
       if(!r1.stands) return 'SKIP: staging: one round broke a healthy wreck';
       if(!r1.bounced) bad.push('a glancing round off a healthy wreck did not bounce');
       r2=shoot(10);
       if(r2.stands) return 'SKIP: staging: the 10 hp wreck survived the round';
       if(r2.bounced) bad.push('the round that broke the wreck still bounced off the wall that is gone');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(g){ g.bullets.length=0; if(E0) g.ents=E0; if(w){ if(hl===undefined) delete w.hpLeft; else w.hpLeft=hl; if(hm===undefined) delete w.hpMax; else w.hpMax=hm; if(g.map.walls.indexOf(w)<0){ g.map.walls.push(w); rebuildGeometry(); } } } }catch(_h){}
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'28.55',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
