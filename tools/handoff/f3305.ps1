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

if ($s.Contains("  {v:'33.05',what:")) { throw "check 33.05 is in the fixture already" }

SubRx @'
  {v:'33.04',what:
'@ @'
  {v:'33.05',what:'the experimental page switches the needed-item glow, the haul reveal and the shop re-roll, each read live in its own window: they run with their switch on and stop with it off',
   run:function(){
     if(typeof needRefresh!=='function'||typeof haulRevealStart!=='function'||typeof shopStocked!=='function'||typeof arcadeDeploy!=='function'||typeof xfSnap!=='function') return 'SKIP: these features are not all here';
     var bad=[], i, g, ks=['xfNeed','xfHaul','xfShop'], oldNeed=needItems, w, hadW, oldHtml, pool, n, got;
     function setK(key,v){ CFG[key]=v; xfSnap(); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       SETSUB='exp'; renderSettings();
       ks.forEach(function(k){ var b=document.getElementById('go_'+k); if(!b) bad.push('ONE: no row for '+k); else if(String(b.textContent).toLowerCase()!=='on'||CFG[k]!==1) bad.push('ONE: '+k+' does not start on'); });
       SETSUB=''; renderSettings();
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: no arcade raid';
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       // NEEDED-ITEM GLOW: a contract that needs an item
       needItems=function(){ return {bandage:1}; };
       [1,0].forEach(function(v){
         setK('xfNeed',v); got=needRefresh();
         if(v===1&&(got!==1||g.needN!==1)) bad.push('NEED on: a needed item did not light a box (count '+got+')');
         if(v===0&&(got!==0||g.needN!==0)) bad.push('NEED off: a needed item still lit a box (count '+got+')');
       });
       needItems=oldNeed; setK('xfNeed',1); needRefresh();
       // HAUL REVEAL: a card with three items
       w=document.getElementById('oc_manifest'); hadW=!!w;
       if(!w){ w=document.createElement('div'); w.id='oc_manifest'; document.body.appendChild(w); }
       oldHtml=w.innerHTML;
       [1,0].forEach(function(v){
         w.innerHTML='<div class="haulstrip"><span class="haulit" data-r="common" data-v="10"></span><span class="haulit" data-r="common" data-v="20"></span><span class="haulit" data-r="common" data-v="30"></span></div>';
         setK('xfHaul',v); HAUL_REV=null; got=haulRevealStart();
         if(v===1&&(got!==3||!HAUL_REV)) bad.push('HAUL on: the haul did not start to come up (items '+got+')');
         if(v===0&&(got!==0||HAUL_REV)) bad.push('HAUL off: the haul still came up item by item (items '+got+')');
       });
       HAUL_REV=null; w.innerHTML=oldHtml; if(!hadW&&w.parentNode) w.parentNode.removeChild(w);
       setK('xfHaul',1);
       // SHOP RE-ROLL: of the four extras two are in stock, or all four off
       pool=SHOP.filter(function(o){ return o&&!SHOP_CORE[o.k]&&o.kind!=='pack'; });
       [1,0].forEach(function(v){
         setK('xfShop',v); n=pool.filter(function(o){ return shopStocked(o); }).length;
         if(v===1&&!(n===SHOP_PICK&&n<pool.length)) bad.push('SHOP on: '+n+' of '+pool.length+' extras in stock, not '+SHOP_PICK);
         if(v===0&&n!==pool.length) bad.push('SHOP off: only '+n+' of '+pool.length+' extras in stock');
       });
     } catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       needItems=oldNeed; HAUL_REV=null; SETSUB='';
       for(i=0;i<ks.length;i++){ try{ if(P.gameOpts) delete P.gameOpts[ks[i]]; }catch(_d){} }
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       __topClear(); __resetCfg(); xfSnap(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'33.04',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
