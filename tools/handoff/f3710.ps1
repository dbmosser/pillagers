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

if ($s.Contains("  {v:'37.10',what:")) { throw "check 37.10 is in the fixture already" }

SubRx @'
  {v:'37.09',what:
'@ @'
  {v:'37.10',what:'machine smoke reads: puffs start on the body (below its top, clear of the name plate) and are at least 0.6 opaque (his photo of v34.78 showed none)',
   run:function(){
     var PR=CanvasRenderingContext2D.prototype, of=PR.fillRect, oa=PR.arc, g=null, m=null, i, e, H, hi=0, below=0, n=0;
     function rec(ctx,y){ if(ctx!==wc) return; n++; if(ctx.globalAlpha>hi) hi=ctx.globalAlpha; if(y>m.y-H+3) below++; }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player) return 'SKIP: no raid';
       for(i=0;i<g.ents.length;i++){ e=g.ents[i]; if(GFXDMG_KINDS[e.kind]&&e.maxhp>0&&e.hp>0){ m=e; break; } }
       if(!m) return 'SKIP: no machine in the raid';
       g.player.x=m.x; g.player.y=m.y+60; m.hp=m.maxhp*0.45; H=elemBodyH(m);
       PR.fillRect=function(x,y,w,h){ rec(this,y+h/2); return of.apply(this,arguments); };
       PR.arc=function(x,y){ rec(this,y); return oa.apply(this,arguments); };
       for(i=0;i<20;i++){ g.t=i*0.1; gfxBodyFx(0.016); }
       PR.fillRect=of; PR.arc=oa;
       if(!n) return 'a machine at 45% drew no smoke';
       if(hi<0.6) return 'the smoke is too faint: top opacity '+hi.toFixed(2)+' (needs 0.6)';
       if(!below) return 'the smoke starts at the top of the body, under the name plate';
       return null;
     } finally {
       PR.fillRect=of; PR.arc=oa;
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     } }},
  {v:'37.09',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
