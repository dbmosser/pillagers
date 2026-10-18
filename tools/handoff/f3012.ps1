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

if ($s.Contains("  {v:'30.12',what:")) { throw "check 30.12 is in the fixture already" }

SubRx @'
  {v:'30.11',what:
'@ @'
  {v:'30.12',what:'the arcade controls card has a How to play title, ends above the feed (under 69 percent of the screen height) and the F1 controls hint is not drawn under it (critic on 47: the hint and a feed line showed through the card edge)',
   run:function(){
     if(typeof arcadeCardHud!=='function'||typeof arcadeCardOn!=='function'||typeof arcadeDeploy!=='function'||typeof ARCADE!=='object'||!ARCADE||!window.__frame||!window.__state) return 'SKIP: no arcade raid here';
     var proto=CanvasRenderingContext2D.prototype, oft=proto.fillText, orr=proto.roundRect, oOn=arcadeCardOn, texts=[], panel=null, bad=null, g;
     try{
       __topClear(); __runPrep();
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); if(!g||!g.arcade) return 'SKIP: the drop is not an arcade raid';
       g.legendOn=0;
       arcadeCardOn=function(){ return 1; };
       proto.fillText=function(t){ texts.push(String(t)); return oft.apply(this,arguments); };
       if(orr) proto.roundRect=function(x,y,w,h){ if(!panel&&h>H*0.35) panel={y:y,h:h}; return orr.apply(this,arguments); };
       __frame(0.001);
       if(!texts.some(function(t){ return /^how to play$/i.test(t); })) bad='the controls card has no How to play title';
       else if(texts.some(function(t){ return /F1/.test(t)&&/controls\s*$/i.test(t); })) bad='the F1 controls hint is still drawn under the card';
       else if(panel&&panel.y+panel.h>H*0.69+4) bad='the card ends at '+Math.round(panel.y+panel.h)+', below 69 percent of the height '+Math.round(H);
       return bad;
     } finally {
       proto.fillText=oft; if(orr) proto.roundRect=orr; arcadeCardOn=oOn;
       try{ if(ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ var g2=__state(); if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){}
       try{ __topClear(); }catch(_c){}
     }
   }},
  {v:'30.11',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
