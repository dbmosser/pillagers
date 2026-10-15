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

if ($s.Contains("  {v:'26.98',what:")) { throw "check 26.98 is in the fixture already" }

SubRx @'
  {v:'26.97',what:
'@ @'
  {v:'26.98',what:'party7, from the 1080p picture: the combo multiplier sits clear of the TEAM ring while that ring is up, and where it was when it is not',
   run:function(){
     if(typeof arcadeDeploy!=='function'||typeof ARCADE!=='object'||typeof styleDraw!=='function'||typeof teamDraw!=='function') return 'SKIP: no arcade here';
     var bad=[], g=null, p, own=false, rs=say, oSolo, oFt, proto, xs0=[], xs1=[], z, i;
     function grab(into){
       var a=[];
       proto.fillText=function(){ a.push([String(arguments[0]),arguments[1]]); return oFt.apply(this,arguments); };
       try{ styleDraw(ctx,p,640,360); } finally { proto.fillText=oFt; }
       for(i=0;i<a.length;i++) if(a[i][0]==='x3') into.push(a[i][1]);
     }
     try{
       __topClear(); __runPrep();
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       p=g.player; keys={}; say=function(){}; own=true; ARCADE.holdT=0; oSolo=ARCADE.solo; ARCADE.solo=0;
       proto=CanvasRenderingContext2D.prototype; oFt=proto.fillText; z=Math.max(1,hudRes());
       ARCADE.streak={n:3,t:g.t-1}; ARCADE.team=null; grab(xs0);
       ARCADE.team={n:2,at:Date.now()-200}; grab(xs1);
       if(xs0.length!==1||xs1.length!==1) bad.push('the multiplier was drawn '+xs0.length+' and '+xs1.length+' times');
       else if(!(xs1[0]-xs0[0]>=8*z)) bad.push('the multiplier moved only '+(xs1[0]-xs0[0])+' px out for the TEAM ring (it needs '+(8*z)+')');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       if(own) say=rs;
       try{ if(proto&&oFt) proto.fillText=oFt; }catch(_p){}
       keys={};
       try{ if(typeof ARCADE==='object'){ ARCADE.solo=oSolo; ARCADE.team=null; ARCADE.streak=null; if(ARCADE.on) arcadeLeave(); } }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ if(typeof ARCADE==='object'){ ARCADE.mine=0; ARCADE.waveT=0; ARCADE.holdT=0; } }catch(_h){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'26.97',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
