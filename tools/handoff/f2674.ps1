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

if ($s.Contains("  {v:'26.74',what:")) { throw "check 26.74 is in the fixture already" }

SubRx @'
  {v:'26.73',what:
'@ @'
  {v:'26.74',what:'flow2b, the air strike meter plate grows with the screen: at a HUD scale of 2 (4K) the plate is twice as wide as at 1, as the text in it is',
   run:function(){
     if(!(window.__state&&window.__endRaid&&window.__runPrep&&window.__frame)) return 'SKIP: no raid or frame here';
     if(typeof arcadeDeploy!=='function'||typeof ARCADE!=='object') return 'SKIP: no arcade here';
     if(typeof airDraw!=='function') return 'there is no air strike in this build';
     var bad=[], g=null, p, w1, w2, pr=CanvasRenderingContext2D.prototype, orr=pr.roundRect, oh=hudRes;
     function plateW(res){
       var ws=[], i, mx=0;
       hudRes=function(){ return res; };
       pr.roundRect=function(x,y,w,h){ ws.push(w); return orr.apply(this,arguments); };
       try{ airDraw(ctx,p); } finally { hudRes=oh; pr.roundRect=orr; }
       for(i=0;i<ws.length;i++) if(ws[i]>mx) mx=ws[i];
       return mx;
     }
     try{
       if(!orr) return 'SKIP: no roundRect here';
       __topClear(); __runPrep();
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       p=g.player; keys={};
       flowTick(0.016); g.flow.air.m=500; render2D(0);
       w1=plateW(1); w2=plateW(2);
       if(!(w1>0)) bad.push('the plate was not drawn at scale 1');
       else if(!(w2>=w1*1.8)) bad.push('the plate is '+w1.toFixed(0)+' wide at scale 1 and '+w2.toFixed(0)+' at scale 2');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       try{ hudRes=oh; pr.roundRect=orr; }catch(_r){}
       keys={};
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ if(typeof ARCADE==='object'){ ARCADE.mine=0; ARCADE.waveT=0; ARCADE.holdT=0; } }catch(_h){}
       __topClear();
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'26.73',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
