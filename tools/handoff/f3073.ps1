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

if ($s.Contains("  {v:'30.73',what:")) { throw "check 30.73 is in the fixture already" }

SubRx @'
  {v:'30.72',what:
'@ @'
  {v:'30.73',what:'the gun card is the one raid panel with a lime tab, and in the demo it is shorter than in career (critic 10-19, his Q56)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)||typeof hudPanel!=='function') return 'SKIP: this fixture cannot deploy';
     var g=null, oP=hudPanel, rec=[], a0, car, dem;
     function pass(){ rec=[]; hudPanel=function(x,y,w,h,a,plain){ rec.push({w:w,h:h,a:a,plain:plain}); return oP.apply(this,arguments); };
       try{ __frame(0.016); }finally{ hudPanel=oP; }
       return rec.slice(); }
     function card(r){ var i, o=null; for(i=0;i<r.length;i++) if(r[i].a===0.62) o=r[i]; return o; }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:['gun_shotgun','gun_rifle'],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: staging: no raid';
       g.bagOpen=false; g.mapOpen=false; g.paused=false; keys={}; mouse.down=false; a0=g.arcade;
       g.arcade=0; car=pass();
       g.arcade=1; dem=pass();
       var cc=card(car), dc=card(dem), tabs, i;
       if(!cc||!dc) return 'the gun card panel is not drawn (career '+!!cc+', demo '+!!dc+')';
       if(cc.plain||dc.plain) return 'the gun card lost its tab';
       if(!(dc.h<cc.h)) return 'the demo gun card is not shorter than the career one ('+dc.h+' vs '+cc.h+')';
       for(i=0;i<dem.length;i++){ if(dem[i]!==dc&&!dem[i].plain&&dem[i].a!==undefined&&dem[i].a<0.9) return 'a raid panel besides the gun card still has the lime tab (w '+Math.round(dem[i].w)+', h '+Math.round(dem[i].h)+')'; }
       return null;
     } finally {
       hudPanel=oP;
       try{ if(g) g.arcade=a0; }catch(_e){}
       try{ __endRaid('abandon'); }catch(_e2){}
       __topClear();
     } }},
  {v:'30.72',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
