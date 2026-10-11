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

if ($s.Contains("  {v:'22.56',what:")) { throw "check 22.56 is in the fixture already" }

SubRx @'
  {v:'22.55',what:
'@ @'
  {v:'22.56',what:'trade in the pickup stack: buying a Medkit priced 1,240 at a staged stall and selling the backpack leave a Medkit row, a -$1,240 row and a +$ row for the sale in the pickup stack, and no line said for them is longer than 56 characters as a feed row',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P)) return 'SKIP: this fixture cannot deploy';
     if(typeof mkPeddler!=='function'||typeof pedBuy!=='function'||typeof pedSellAll!=='function') return 'SKIP: no stall here';
     if(!ITEMS.medkit||!ITEMS.blackbox||!ITEMS.reactor||!ITEMS.codex) return 'SKIP: no Medkit or no elite salvage here';
     var bad=[], P2=__P(), keepC=P2.credits, g=null, p, pd, rows, i, e, s, lg, long=[], mi=false, mm=null, mp=null, carry, D='$';
     function names(){ return (g.pick||[]).map(function(r){ return r.m+(r.tag?' '+r.tag:''); }).join(', '); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||g.sim||!g.player) return 'SKIP: staging: no live raid';
       p=g.player; p.downed=false; g.ents.length=0;
       pd=mkPeddler(p.x+40,p.y,g.map);
       pd.stock=[{k:'medkit',price:1240,sold:false}];
       g.trade=pd; g.hotAssign={}; g.hotAuto={}; g.bag=[]; g.pedCarry=0;
       P2.credits=5000;
       g.msgT=0; g.msg=''; g.msgQ=[]; g.msgQM=[]; g.feed=[]; g.alert=null; g.alertQ=[]; g.pick=[]; g.msgLog=[];
       pedBuy(0);
       if(P2.credits!==5000-1240) return 'SKIP: staging: the purchase did not go through (credits '+P2.credits+')';
       g.bag=['blackbox','reactor','codex']; g.trade=pd;
       pedSellAll();
       carry=g.pedCarry||0;
       if(!(carry>=1000)) return 'SKIP: staging: the sale paid '+carry+', under 1,000';
       rows=g.pick||[];
       for(i=0;i<rows.length;i++){
         if(rows[i].item==='medkit') mi=true;
         if(String(rows[i].m).indexOf('-'+D)===0) mm=String(rows[i].m);
         if(String(rows[i].m).indexOf('+'+D)===0) mp=String(rows[i].m);
       }
       if(!mi) bad.push('no Medkit row in the pickup stack after the purchase (rows: '+names()+')');
       if(mm!=='-'+D+(1240).toLocaleString()) bad.push('no -'+D+(1240).toLocaleString()+' row in the pickup stack (rows: '+names()+')');
       if(mp!=='+'+D+carry.toLocaleString()) bad.push('no +'+D+carry.toLocaleString()+' row for the sale in the pickup stack (rows: '+names()+')');
       lg=g.msgLog||[];
       for(i=0;i<lg.length;i++){ e=lg[i]; if(!e||e.k==='pick'||e.k==='log') continue; s=String(e.m)+(e.sub?'  \u00b7  '+e.sub:''); if(s.length>56) long.push(s.length+': '+s); }
       if(long.length) bad.push('lines longer than 56 characters were said: '+long.join(' | '));
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       try{ var g2=__state(); if(g2&&!g2.over){ g2.trade=null; g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       try{ P2.credits=keepC; saveProfile(); }catch(_s){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'22.55',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
