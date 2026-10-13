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

if ($s.Contains("  {v:'25.00',what:")) { throw "check 25.00 is in the fixture already" }

SubRx @'
  {v:'24.99',what:
'@ @'
  {v:'25.00',what:'his order (2026-10-12): no 3, 2, 1, GO! when a raid starts; a career raid and a demo run both start with him in control and the clock and the world running from the first frame',
   run:function(){
     if(!window.__deploy||!window.__endRaid||!window.__loop||!window.__drawHUD) return 'SKIP: no raid here';
     var bad=[], src='', gs0=(typeof GO_SEC==='number')?GO_SEC:null, rf=ctx.fillText, own=false, big=[], lim=(typeof LH==='function')?LH(60):60;
     function rec(){ big=[]; own=true; ctx.fillText=function(s){ var m=/([\d.]+)px/.exec(String(ctx.font||'')); if(m&&+m[1]>=lim) big.push(String(s)); return rf.apply(this,arguments); }; }
     function unrec(){ if(own){ delete ctx.fillText; if(ctx.fillText!==rf) ctx.fillText=rf; own=false; } }
     function one(tag,build){
       var g, p, x0, y0, t0, T, f, d, hit;
       __topClear(); __runPrep(); __resetCfg(); keys={};
       if(gs0!==null) GO_SEC=3;
       if(!build()){ bad.push(tag+': no raid was built'); return; }
       g=__state(); if(!g||g.over){ bad.push(tag+': no live raid'); return; }
       p=g.player;
       if(g.goT>0) bad.push(tag+': the raid opens held on a count (goT '+g.goT+')');
       x0=p.x; y0=p.y; t0=g.t;
       rec();
       try{
         keys['KeyD']=true; keys['KeyS']=true;
         T=performance.now();
         for(f=0;f<6;f++){ __loop(T+=50); __drawHUD(); }
         d=Math.abs(p.x-x0)+Math.abs(p.y-y0);
         if(!(d>1)) bad.push(tag+': held D and S moved him '+d.toFixed(2)+' in the first 0.3 s');
         if(!(g.t>t0)) bad.push(tag+': the raid time did not run in the first 0.3 s ('+t0+' to '+g.t+')');
         keys={};
         for(f=0;f<54&&!g.over;f++){ __loop(T+=50); if(f%3===0) __drawHUD(); }
       } finally { unrec(); keys={}; }
       hit=big.filter(function(s){ return /^(1|2|3|GO!)$/.test(s); });
       if(hit.length) bad.push(tag+': a big '+hit.slice(0,6).join(',')+' was drawn on the HUD in the first 3 s');
     }
     try{
       if(typeof goTick==='function') bad.push('goTick is still in the game');
       if(typeof drawGoCount==='function') bad.push('drawGoCount is still in the game');
       src=[].slice.call(document.scripts).map(function(s){ return s.text||''; }).join('');
       if(src.indexOf('var GO'+'_SEC=')>=0) bad.push('GO_SEC is still declared');
       if(src.indexOf("type==='count"+"go'")>=0) bad.push('the count beep is still in blip');
       one('career',function(){ __deploy({kit:[],safe:null,mapIx:0,seed:4242}); return !!(__state()&&!__state().over); });
       if(__state()&&!__state().over) __endRaid('abandon');
       __topClear();
       if(typeof arcadeDeploy==='function'&&typeof arcadeLeave==='function'){
         one('demo',function(){ return arcadeDeploy({mapIx:0,seed:4242}); });
         try{ arcadeLeave(); }catch(_al){}
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ unrec(); keys={}; if(gs0!==null) GO_SEC=gs0; try{ if(typeof ARCADE==='object'&&ARCADE&&ARCADE.on&&typeof arcadeLeave==='function') arcadeLeave(); }catch(_al2){} try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){} __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'24.99',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
