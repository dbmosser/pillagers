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

if ($s.Contains("  {v:'22.54',what:")) { throw "check 22.54 is in the fixture already" }

SubRx @'
  {v:'22.53',what:
'@ @'
  {v:'22.54',what:'pickup rows say where it went: the best gun searched out of a crate with X held and the second gun slot empty shows as a pickup row tagged SLOT 2, and no feed row or waiting line names the gun or says STOWED or SWAP',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__loop)) return 'SKIP: this fixture cannot deploy or step the loop';
     if(window.__vpAlive&&!__vpAlive()) return 'SKIP: the pane has no layout, so nothing is drawn';
     if(typeof ITEMS==='undefined'||typeof WEAPONS==='undefined'||typeof WTIER==='undefined') return 'SKIP: no gun tables here';
     var bad=[], g=null, p, ct=null, kp=null, i, c, k, it, best=null, bt=-1, t0, f=0, nm='', row=null, said=[], rx;
     function look(){
       var gg=__state(), q, r1, j;
       if(!gg) return;
       if(gg.msg&&gg.msgT>0) said.push('feed: '+gg.msg+' '+(gg.msgSub||''));
       r1=gg.feed&&gg.feed[1]; if(r1&&r1.T>0&&r1.m) said.push('feed: '+r1.m+' '+(r1.sub||''));
       q=gg.msgQ||[]; for(j=0;j<q.length;j++) said.push('queued: '+q[j]);
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       keys={};
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||g.sim||!g.player) return 'SKIP: staging: no live raid';
       p=g.player; g.ents.length=0; g.waveT=-1e9; g.mapOpen=false; g.bagOpen=false; p.iv=99; p.downed=false;
       if(CFG.raidSec>0&&g.timeLeft<600) g.timeLeft=600;
       for(k in ITEMS){ it=ITEMS[k]; if(it&&it.use==='gun'&&it.gk&&WEAPONS[it.gk]&&(WTIER[it.gk]||0)>bt){ bt=WTIER[it.gk]||0; best=k; } }
       if(!best||!(bt>(WTIER[p.wep.id]||0))) return 'SKIP: nothing in the gun table outranks the gun in hand';
       nm=ITEMS[best].name;
       p.sec=null;   // the second gun slot is empty: the branch under test
       for(i=0;i<g.containers.length;i++){ c=g.containers[i]; if(c&&!c.opened&&!c.strong&&!c.cache&&!c.dropped&&!c.auto&&!c.mercSrc&&c.loot&&(c.type==='crate'||c.type==='locker')){ ct=c; break; } }
       if(!ct) return 'SKIP: no plain crate on this seed';
       kp={x:ct.x,y:ct.y};
       ct.x=p.x+14; ct.y=p.y; ct.loot=[best]; ct.opened=false; ct.prog=0; ct.pulled=0; ct.time=1.5; ct.hotPaid=1;
       g.msgT=0; g.msg=''; g.msgQ=[]; g.msgQM=[]; g.feed=[]; g.alert=null; g.alertQ=[]; g.pick=[];
       t0=Math.max(performance.now(),(typeof lastTs==='number'&&isFinite(lastTs))?lastTs:0);
       keys['KeyX']=true;
       for(i=0;i<600&&!ct.opened;i++){ __loop(t0+(++f)*16.7); look(); if(__state()!==g||g.over) break; }
       keys={};
       if(!ct.opened) return 'SKIP: staging: holding X beside the crate for 10 s never finished the search';
       for(i=0;i<30;i++){ __loop(t0+(++f)*16.7); look(); }
       if(!(p.sec&&p.sec.id===ITEMS[best].gk)) return 'SKIP: staging: the '+nm+' did not go into the empty second slot (second slot '+(p.sec&&p.sec.id)+')';
       for(i=0;i<(g.pick||[]).length;i++) if(g.pick[i].item===best) row=g.pick[i];
       if(!row) bad.push('no pickup row for the '+nm);
       else if(row.tag!=='SLOT 2') bad.push('the '+nm+' row is tagged '+JSON.stringify(row.tag||'')+', not SLOT 2');
       rx=new RegExp(nm.replace(/[.*+?^${}()|[\]\\]/g,'\\$&')+'|STOWED|SWAP','i');
       for(i=0;i<said.length;i++) if(rx.test(said[i])){ bad.push('a second line about the gun was shown or queued: '+said[i]); break; }
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       keys={};
       try{ if(ct&&kp){ ct.x=kp.x; ct.y=kp.y; } }catch(_k){}
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; g2.player.iv=0; __endRaid('abandon'); } }catch(_e){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'22.53',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
