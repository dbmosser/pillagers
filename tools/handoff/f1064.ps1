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
window.__howlerHit=function(SH){ return howlerImpact(SH); };   // v10.63
'@ @'
window.__howlerHit=function(SH){ return howlerImpact(SH); };   // v10.63
window.__legends=function(){ return {full:LEGEND,mini:LEGEND_MINI}; };   // v10.64
'@

SubRx @'
  {v:'10.63',what:'a Howler shell that lands on a building bursts on the roof and hurts nobody under it, while the same shell in the open still hurts and one fired from inside still hurts',
'@ @'
  {v:'10.64',what:'F strikes with a gun in hand, through the real key handler, and both controls lists name the key',
   run:function(){
     var bad=[];
     if(!(window.__startRaid&&window.__loop&&window.__weapons&&window.__state&&window.__legends)) return 'SKIP: this build cannot drive a raid key';
     __resetCfg();
     __startRaid({seed:4242,mapIx:0});
     var G2=__state(); if(!G2||!G2.player) return 'no raid';
     var p=G2.player, W=__weapons();
     function mk(id){ var g={}; for(var k in W[id]) g[k]=W[id][k]; g.q='field'; g.qRank=1; return g; }
     var K=window.__keysRef?__keysRef():null;
     if(K) for(var k in K) delete K[k];   // a latched key from an earlier check reads as a press
     function press(code){
       try{ document.dispatchEvent(new KeyboardEvent('keydown',{code:code,key:code,bubbles:true,cancelable:true})); }catch(_e){}
       try{ window.dispatchEvent(new KeyboardEvent('keydown',{code:code,key:code,bubbles:true,cancelable:true})); }catch(_e2){}
       try{ document.dispatchEvent(new KeyboardEvent('keyup',{code:code,key:code,bubbles:true,cancelable:true})); }catch(_e3){}
       try{ window.dispatchEvent(new KeyboardEvent('keyup',{code:code,key:code,bubbles:true,cancelable:true})); }catch(_e4){}
     }
     var t=performance.now();
     function step(nf){ for(var f=0;f<(nf||4);f++){ t+=16.7; __loop(t); } }
     var keep={wep:p.wep,ammo:p.ammo,face:p.face,x:p.x,y:p.y,ents:G2.ents.slice()};
     try{
       // 1. HIS CASE: a gun in his hands, a body at arm's length, F must hurt it.
       G2.ents.length=0;
       p.wep=mk('rifle'); p.ammo=25; p.face=0; p.downed=false; p.roll=0;
       var e={kind:'crawler',x:p.x+26,y:p.y,r:10,hp:100,maxhp:100,state:'idle',face:0};
       G2.ents.push(e);
       press('KeyF'); step(4);
       var hit=100-e.hp;
       if(hit<=0) bad.push('with a rifle in hand, F did not strike a body at arm\u0027s length');
       // 2. It is a strike, not a shot: no round left the magazine.
       if(p.ammo!==25) bad.push('the strike spent ammunition (magazine went from 25 to '+p.ammo+')');
       // 3. Reach: a body across the room is not struck.
       // Put it back beside him each time: a live crawler drifts between presses,
       // and a check that forgets that measures the drift instead of the reach.
       e.hp=100; e.x=p.x+300; e.y=p.y; p.face=0;
       p.meleeAt=undefined;
       press('KeyF'); step(4);
       if(e.hp<100) bad.push('F struck a body 300 units away, which is not a melee reach');
       // 4. The cooldown holds: two presses in the same breath land one blow.
       e.hp=100; e.x=p.x+26; e.y=p.y; p.face=0; p.meleeAt=undefined;
       press('KeyF'); var one=100-e.hp;
       press('KeyF'); var two=100-e.hp;
       if(one<=0) bad.push('the cooldown case did not land its first blow');
       else if(two>one*1.6) bad.push('two presses in the same breath landed '+two.toFixed(1)+' against '+one.toFixed(1)+' for one, so there is no cooldown');
       // 5. Both controls lists name the key, or it is invisible again.
       var L=__legends(), full=JSON.stringify(L.full).toLowerCase(), mini=JSON.stringify(L.mini).toLowerCase();
       if(full.indexOf('melee')<0) bad.push('the full controls list does not name melee');
       if(mini.indexOf('melee')<0) bad.push('the short controls list does not name melee');
       if(full.indexOf('"f"')<0&&full.indexOf("'f'")<0) bad.push('the full controls list does not name the F key');
     } finally {
       if(K) for(var k2 in K) delete K[k2];
       p.wep=keep.wep; p.ammo=keep.ammo; p.face=keep.face; p.x=keep.x; p.y=keep.y;
       G2.ents.length=0; for(var i=0;i<keep.ents.length;i++) G2.ents.push(keep.ents[i]);
     }
     return bad.length?bad.join('; '):null; }},
  {v:'10.63',what:'a Howler shell that lands on a building bursts on the roof and hurts nobody under it, while the same shell in the open still hurts and one fired from inside still hurts',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
