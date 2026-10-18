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

if ($s.Contains("  {v:'30.59',what:")) { throw "check 30.59 is in the fixture already" }

SubRx @'
  {v:'30.58',what:
'@ @'
  {v:'30.59',what:'the gun card shows the rounds in the gun as the big hero number, the reserve small beside it (his Q57, 10-18)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)) return 'SKIP: this fixture cannot deploy';
     var g=null, oF=ctx.fillText, rec=[], mag, res, pm, pr;
     function px(f){ var m=(/([\d.]+)px/).exec(String(f)); return m?parseFloat(m[1]):0; }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:['gun_shotgun','gun_rifle'],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: staging: no raid';
       g.bagOpen=false; g.mapOpen=false; g.paused=false; keys={}; mouse.down=false;
       g.player.reloading=0; g.player.jam=0; g.player.ammo=7; g.player.reserve=42;
       if(!g.player.wep||!(g.player.wep.mag>0)) return 'SKIP: the held gun has no magazine';
       ctx.fillText=function(s){ rec.push({s:String(s),f:this.font}); return oF.apply(this,arguments); };
       try{ __frame(0.016); }finally{ ctx.fillText=oF; }
       mag=rec.filter(function(r){ return r.s==='7'; }); res=rec.filter(function(r){ return (/^\s*\/\s*42$/).test(r.s); });
       if(!mag.length) return 'the rounds in the gun are not drawn as a figure of their own';
       if(!res.length) return 'the reserve is not drawn beside it';
       pm=px(mag[mag.length-1].f); pr=px(res[res.length-1].f);
       if(pm<40) return 'the rounds figure is only '+pm+' px, not the big number size (44)';
       if(pm<=pr*1.4) return 'the rounds ('+pm+' px) are not clearly bigger than the reserve ('+pr+' px)';
       return null;
     } finally {
       ctx.fillText=oF;
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     } }},
  {v:'30.58',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
