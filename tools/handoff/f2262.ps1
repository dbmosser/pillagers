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

if ($s.Contains("  {v:'22.62',what:")) { throw "check 22.62 is in the fixture already" }

SubRx @'
  {v:'22.61',what:
'@ @'
  {v:'22.62',what:'backpack full and the stall refusal in the shooter voice: BACKPACK FULL at a stall and on a search with autoloot on has the caps detail naming the backpack key and the drop key, never drops the selected item or nothing left worth dropping, and NOT ENOUGH BANKED CREDITS with stall money on him reads Carrying with the figure, not a sentence about banking',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__loop)) return 'SKIP: this fixture cannot deploy or step the loop';
     if(typeof pedBuy!=='function'||typeof bagWeight!=='function'||typeof bagDropHint!=='function'||typeof padOn!=='function'||typeof keyLabel!=='function') return 'SKIP: no stall or backpack here';
     if(!ITEMS.scrap) return 'SKIP: no Scrap Metal item';
     var bad=[], g=null, p, ct=null, kp=null, i, c, t0, f=0, keepCr=P.credits, keepAuto=P.autoloot, keepBW=bagWeight, s, lg, BF=['BACKPACK','FULL'].join(' '),
         OLD1=['the','selected','item'].join(' '), OLD2=['worth','dropping'].join(' '), OLD3=['not','banked'].join(' ');
     function bfSub(){ var q=g.pick||[], j; for(j=0;j<q.length;j++) if(q[j].key==='bagfull'&&q[j].T>0) return String(q[j].sub||''); return null; }
     function okHint(s,where){
       if(s===null){ bad.push(where+': no BACKPACK FULL row in the pickup stack'); return; }
       if(s.indexOf(OLD1)>=0||s.indexOf(OLD2)>=0) bad.push(where+': the detail is still a sentence ['+s+']');
       if(s.indexOf('BACKPACK')<0||s.indexOf('DROP')<0) bad.push(where+': the detail does not name the backpack and the drop ['+s+']');
       if(!padOn()&&(s.indexOf('['+keyLabel('KeyB','B')+']')<0||s.indexOf('['+keyLabel('KeyZ','Z')+']')<0)) bad.push(where+': on the keyboard the detail does not name the B and Z keys ['+s+']');
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       keys={};
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||g.sim||!g.player) return 'SKIP: staging: no live raid';
       p=g.player; g.ents.length=0; g.waveT=-1e9; g.mapOpen=false; g.bagOpen=false; p.iv=99; p.downed=false;
       if(CFG.raidSec>0&&g.timeLeft<600) g.timeLeft=600;
       // A. a purchase at a stall with a full backpack
       g.pick=[]; g.msgLog=[];
       P.credits=1e6; bagWeight=function(){ return 1e9; };
       g.trade={x:p.x,y:p.y,stock:[{k:'scrap',price:1,sold:false}]};
       pedBuy(0);
       okHint(bfSub(),'buying with a full backpack');
       // B. the refusal with stall money on him
       g.trade={x:p.x,y:p.y,stock:[{k:'scrap',price:999,sold:false}]};
       P.credits=0; g.pedCarry=4321; g.msgLog=[];
       pedBuy(0);
       lg=g.msgLog||[]; s=null;
       for(i=0;i<lg.length;i++) if(String(lg[i].m).indexOf('NOT ENOUGH')===0) s=String(lg[i].sub||'');
       if(s===null) bad.push('the stall refusal was not said');
       else {
         if(s.indexOf(OLD3)>=0) bad.push('the refusal detail still explains banking ['+s+']');
         if(s.indexOf('$4,321')<0&&s.indexOf('$4321')<0) bad.push('the refusal detail does not name the $4,321 on him ['+s+']');
         if(s.indexOf('$999')<0) bad.push('the refusal detail does not name the price ['+s+']');
       }
       g.trade=null; g.pedCarry=0; P.credits=keepCr;
       // C. a search with autoloot on and nothing it may shed
       for(i=0;i<g.zones.length;i++) if(Math.hypot(p.x-g.zones[i].x,p.y-g.zones[i].y)<(g.zones[i].r||0)+40) return bad.length?bad.join('; '):null;
       for(i=0;i<g.containers.length;i++){ c=g.containers[i]; if(c&&!c.opened&&!c.strong&&!c.cache&&!c.dropped&&!c.auto&&!c.mercSrc&&c.loot&&(c.type==='crate'||c.type==='locker')){ ct=c; break; } }
       if(ct){
         kp={x:ct.x,y:ct.y};
         ct.x=p.x+14; ct.y=p.y; ct.loot=['scrap']; ct.opened=false; ct.prog=0; ct.pulled=0; ct.time=5; ct.hotPaid=1;
         g.bag=[]; P.autoloot=1;
         g.msgT=0; g.msg=''; g.msgQ=[]; g.feed=[]; g.alert=null; g.alertQ=[]; g.pick=[]; g.msgLog=[];
         t0=Math.max(performance.now(),(typeof lastTs==='number'&&isFinite(lastTs))?lastTs:0);
         for(i=0;i<40;i++){ keys['KeyE']=true; __loop(t0+(++f)*16.7); if(__state()!==g||g.over) break; }
         keys={};
         okHint(bfSub(),'searching with autoloot on and a full backpack');
       }
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       keys={};
       bagWeight=keepBW; P.autoloot=keepAuto; P.credits=keepCr;
       try{ if(ct&&kp){ ct.x=kp.x; ct.y=kp.y; } }catch(_k){}
       try{ var g2=__state(); if(g2){ g2.trade=null; g2.pedCarry=0; g2.pick=[]; if(!g2.over){ g2.player.downed=false; g2.player.iv=0; g2.searching=null; __endRaid('abandon'); } } }catch(_e){}
       keys={};
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'22.61',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
