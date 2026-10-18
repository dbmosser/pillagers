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

if ($s.Contains("  {v:'30.83',what:")) { throw "check 30.83 is in the fixture already" }

SubRx @'
  {v:'30.82',what:
'@ @'
  {v:'30.83',what:'the SCORE label at the top centre is fully on screen, its ink starting 6 pixels or more below the top edge (the critic, 10-19)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)) return 'SKIP: this fixture cannot deploy';
     var g=null, oF=ctx.fillText, rec=[], t, top, m;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:['gun_shotgun','gun_rifle'],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: staging: no raid';
       g.bagOpen=false; g.mapOpen=false; g.paused=false; keys={}; mouse.down=false; g.arcade=1;
       ctx.fillText=function(s,x,y){ var mm=null; try{ mm=ctx.measureText(String(s)); }catch(_m){} rec.push({s:String(s),y:y,a:mm?mm.actualBoundingBoxAscent:0}); return oF.apply(this,arguments); };
       try{ __frame(0.016); }finally{ ctx.fillText=oF; }
       t=rec.filter(function(r){ return (/^(team )?score$/i).test(r.s); });
       if(!t.length) return 'the score label is not drawn in this staging';
       m=t[t.length-1]; top=m.y-m.a;
       if(top<6) return 'the SCORE label ink starts at '+Math.round(top)+' pixels from the top edge (needs 6 or more)';
       return null;
     } finally {
       ctx.fillText=oF;
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     } }},
  {v:'30.82',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
