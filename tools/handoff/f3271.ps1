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

if ($s.Contains("  {v:'32.71',what:")) { throw "check 32.71 is in the fixture already" }

SubRx @'
  {v:'32.70',what:
'@ @'
  {v:'32.71',what:'machines and effects (his art picks a27 a28 a30 a31 a34 a35): charging ring, machine death blast, moonlit night, lighter fog, chunkier sparks, bigger blast that stays inside its damage radius',
   run:function(){
     if(typeof __frame!=='function') return 'SKIP: no frame helper';
     var PR=CanvasRenderingContext2D.prototype, oa=PR.arc, os=PR.stroke, of=PR.fill, g=null, i, arcs=[], n0, p0, bn, b;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player) return 'SKIP: no raid';
       if(typeof fogFillStyle!=='function') return 'a31 no fogFillStyle: the fog is still the old .46 and .60';
       if(fogFillStyle(true,1,0,0)!=='rgba(58,46,38,0.3)') return 'a31 day fog is '+fogFillStyle(true,1,0,0)+', want alpha .30';
       if(fogFillStyle(false,1,0,0)!=='rgba(4,7,26,0.42)') return 'a31 night fog is '+fogFillStyle(false,1,0,0)+', want alpha .42';
       if(NIGHT_SHEET!==0.45) return 'a30 NIGHT_SHEET is '+NIGHT_SHEET+', want .45';
       if(typeof drawWindupGlow!=='function'||typeof windupRingR!=='function') return 'a27 no charging ring';
       PR.arc=function(x,y,r){ arcs.push(r); return oa.apply(this,arguments); };
       drawWindupGlow({windup:0.2,kind:'sentry'},100,100);
       PR.arc=oa;
       if(arcs.length!==1||Math.abs(arcs[0]-17)>0.01) return 'a27 ring radius at half windup is '+arcs.join(',')+', want one ring of 17';
       arcs=[]; PR.arc=function(x,y,r){ arcs.push(r); return oa.apply(this,arguments); };
       drawWindupGlow({windup:0.02,kind:'sentry'},100,100);
       PR.arc=oa;
       if(arcs.length!==2||arcs[1]!==3) return 'a27 no white core flash in the last frames: '+arcs.join(',');
       n0=g.sparks.length; spark(0,0,'#ffcf7a',10,200);
       if(g.sparks.length-n0<18) return 'a34 sparks added '+(g.sparks.length-n0)+' for 10, want 18';
       p0=g.puffs.length; bloodFx(10,10,0,0,30);
       if(g.puffs.length!==p0+1||Math.abs(g.puffs[g.puffs.length-1].r-12)>0.01) return 'a34 blood puff radius is '+(g.puffs[g.puffs.length-1]||{}).r+', want 12';
       bn=BOOMS.length; boomFx(50,50,1,'frag'); b=BOOMS[BOOMS.length-1];
       if(!b||Math.abs(b.s-1.6)>0.001) return 'a35 blast size is '+(b&&b.s)+', want 1.6';
       if(boomRingR(b,1)>190||boomRingR({s0:2.5,s:2.5,dmgR:72},1)>72) return 'a35 the blast ring draws past its damage radius';
       n0=g.sparks.length; bn=BOOMS.length;
       deathAnimAdd({x:60,y:60,r:15,kind:'sentry',face:0,hp:0});
       b=BOOMS[BOOMS.length-1];
       if(BOOMS.length<=bn&&BOOMS.length<6||!b||b.kind!=='bot'||Math.abs(b.s-0.6)>0.001) return 'a28 a dead machine did not blast (kind bot size .6)';
       if(g.sparks.length-n0<5) return 'a28 a dead machine threw '+(g.sparks.length-n0)+' chunks, want 5';
       return null;
     } finally {
       PR.arc=oa;
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     } }},
  {v:'32.70',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
