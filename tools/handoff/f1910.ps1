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

if ($s.Contains("  {v:'19.10',what:")) { throw "check 19.10 is in the fixture already" }

SubRx @'
  {v:'19.09',what:
'@ @'
  {v:'19.10',what:'the use bar clears the extraction lines: with extraction inbound and a bandage going on, the use bar panel ends above the EXTRACT INBOUND line',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)) return 'SKIP: this fixture cannot deploy';
     if(typeof drawUseBar!=='function') return 'SKIP: no use bar here';
     var bad=[], g, p, oFT=ctx.fillText, oHP=hudPanel, lastP=null, useP=null, ban=null;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g.player; g.bagOpen=false; g.mapOpen=false; p.hp=40;
       if(!g.zones||!g.zones.length) return 'SKIP: no rings';
       g.active=g.zones[0]; g.beaconT=30; p.prep={t:0.5,max:1.5,kind:'heal',key:'bandage'};
       __frame(0.001);
       hudPanel=function(x,y,w,h,a){ var m=ctx.getTransform(), d=(typeof DPR==='number'&&DPR>0)?DPR:1; lastP={t:(m.d*y+m.f)/d,b:(m.d*(y+h)+m.f)/d}; return oHP.apply(this,arguments); };
       ctx.fillText=function(s,x,y){ var t=String(s), m=ctx.getTransform(), d=(typeof DPR==='number'&&DPR>0)?DPR:1, fm=(/([\d.]+)px/).exec(String(ctx.font)), fp=fm?parseFloat(fm[1]):12; if(t.indexOf('APPLYING ')===0) useP=lastP; if(t.indexOf(' INBOUND ')>0) ban={t:(m.d*(y-fp*0.75)+m.f)/d}; return oFT.apply(this,arguments); };
       try{ __frame(0.001); } finally { hudPanel=oHP; delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; }
       if(!useP) return 'SKIP: the use bar was not drawn';
       if(!ban) return 'SKIP: the extraction line was not drawn';
       if(useP.b>ban.t+1) bad.push('the use bar panel (bottom '+Math.round(useP.b)+') runs into the EXTRACT INBOUND line (top '+Math.round(ban.t)+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ hudPanel=oHP; delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; try{ var g2=__state(); if(g2){ g2.player.prep=null; g2.beaconT=null; if(!g2.over){ g2.player.downed=false; __endRaid('abandon'); } } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'19.09',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
