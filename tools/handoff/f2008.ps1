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

if ($s.Contains("  {v:'20.08',what:")) { throw "check 20.08 is in the fixture already" }

SubRx @'
  {v:'20.07',what:
'@ @'
  {v:'20.08',what:'the jiggle follows the body, not the map: walking it swings the chest without sitting on its stop, and moving across the map with no bob does not shake it',
   run:function(){
     if(typeof bodyJiggle!=='function'||typeof drawOp!=='function') return 'SKIP: no jiggle spring here';
     var bad=[], o={}, t=1000, i, J, ph, mx, hit, w0=wc, cv=document.createElement('canvas'), x2, own={wep:null}, k=(typeof COSKEY!=='undefined'&&COSKEY.build)||'cosBuild', b0=P[k];
     function walk(rate){ o={}; t=1000; ph=0; mx=0; hit=0; bodyJiggle(o,0,t); for(i=0;i<240;i++){ t+=16.7; ph+=rate*0.0167; J=bodyJiggle(o,-Math.abs(Math.sin(ph))*1.5,t); if(i>60){ mx=Math.max(mx,Math.abs(J.c)); if(Math.abs(J.c)>=1.199) hit++; } } return {mx:mx,hit:hit}; }
     var w=walk(9), s=walk(15);
     if(w.hit||s.hit) bad.push('the chest sat on its stop while walking ('+w.hit+') or sprinting ('+s.hit+')');
     if(!(w.mx>0.25)) bad.push('the chest barely moves while walking ('+w.mx.toFixed(2)+')');
     cv.width=60; cv.height=60; x2=cv.getContext('2d');
     try{
       P[k]='curved'; wc=x2;
       for(i=0;i<8;i++){ if(own._jg) own._jg.t-=20; drawOp(0,300+i*40,0,0,'#242832',0,0,'none',0,{hero:1,moving:false,sprint:false,ads:false,hurt:0,rl:0,own:own}); }
       wc=w0;
       if(!own._jg) bad.push('no spring state on the body');
       else if(Math.abs(own._jg.c)>0.05) bad.push('moving across the map with no bob shook the chest ('+own._jg.c.toFixed(2)+')');
     }catch(e){ wc=w0; bad.push('threw: '+(e&&e.message||e)); }
     finally{ wc=w0; P[k]=b0; }
     return bad.length?bad.join('; '):null; }},
  {v:'20.07',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
