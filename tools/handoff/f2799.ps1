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

if ($s.Contains("  {v:'27.99',what:")) { throw "check 27.99 is in the fixture already" }

SubRx @'
  {v:'27.98',what:
'@ @'
  {v:'27.99',what:'his answer 14: the DEMO countdown clock is bigger: the minutes and seconds under the score draw at 18 pixels or more, and in the last minute at 25 or more, and clear the score',
   run:function(){
     if(typeof arcadeDeploy!=='function'||typeof ARCADE!=='object'||typeof arcadeScoreHud!=='function') return 'SKIP: no arcade here';
     var bad=[], g=null, proto, oFt, rec=[], own=false, px0, px1, y0, y1, bot0, bot1, rs=say;
     function px(f){ var m=/([\d.]+)px/.exec(String(f)); return m?+m[1]:0; }
     function grab(secs){
       var q, out=[], b;
       g.timeLeft=secs; rec=[];
       proto.fillText=function(){ rec.push({t:String(arguments[0]),f:this.font,y:arguments[2]}); return oFt.apply(this,arguments); };
       try{ b=arcadeScoreHud(60,1); } finally { proto.fillText=oFt; }
       for(q=0;q<rec.length;q++) if(/^\d+:\d\d$/.test(rec[q].t)) out.push(rec[q]);
       return {c:out[0]||null,bot:b,all:rec.slice()};
     }
     try{
       __topClear(); __runPrep();
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); if(!g||g.over||!g.player||!raidClockOn()) return 'SKIP: no live arcade raid with a clock';
       say=function(){}; own=true;
       proto=CanvasRenderingContext2D.prototype; oFt=proto.fillText;
       px0=grab(300); px1=grab(30);
       if(!px0.c) bad.push('the clock is not drawn under the score at 5:00');
       else if(!(px(px0.c.f)>=18)) bad.push('the clock is '+px(px0.c.f)+' pixels at 5:00, not 18 or more');
       if(!px1.c) bad.push('the clock is not drawn under the score at 0:30');
       else if(!(px(px1.c.f)>=25)) bad.push('the clock is '+px(px1.c.f)+' pixels in the last minute, not 25 or more');
       if(px0.c&&px0.all.length>1){ y0=px0.c.y; var sc=px0.all.filter(function(r){ return r.t!==px0.c.t&&/\d/.test(r.t)&&px(r.f)>=20; })[0]; if(sc&&!(px0.c.y>sc.y+px(px0.c.f)*0.5)) bad.push('the clock sits on the score ('+px0.c.y+' under '+sc.y+')'); }
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       try{ if(proto&&oFt) proto.fillText=oFt; }catch(_f){}
       if(own) say=rs;
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'27.98',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
