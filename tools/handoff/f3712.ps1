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

if ($s.Contains("  {v:'37.12',what:")) { throw "check 37.12 is in the fixture already" }

SubRx @'
  {v:'37.11',what:
'@ @'
  {v:'37.12',what:'machine smoke vents out to the sides as it rises (so it shows over open ground, not only over the body), and is at least 0.85 opaque',
   run:function(){
     var PR=CanvasRenderingContext2D.prototype, of=PR.fillRect, oa=PR.arc, g=null, m=null, i, e, H, hi=0, wide=0, n=0;
     function rec(ctx,x,y){ if(ctx!==wc) return; n++; if(ctx.globalAlpha>hi) hi=ctx.globalAlpha; if(Math.abs(x-m.x)>wide) wide=Math.abs(x-m.x); }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player) return 'SKIP: no raid';
       for(i=0;i<g.ents.length;i++){ e=g.ents[i]; if(GFXDMG_KINDS[e.kind]&&e.maxhp>0&&e.hp>0){ m=e; break; } }
       if(!m) return 'SKIP: no machine in the raid';
       g.player.x=m.x; g.player.y=m.y+60; m.hp=m.maxhp*0.45; H=elemBodyH(m);
       PR.fillRect=function(x,y,w,h){ rec(this,x+w/2,y+h/2); return of.apply(this,arguments); };
       PR.arc=function(x,y){ rec(this,x,y); return oa.apply(this,arguments); };
       for(i=0;i<20;i++){ g.t=i*0.1; gfxBodyFx(0.016); }
       PR.fillRect=of; PR.arc=oa;
       if(!n) return 'a machine at 45% drew no smoke';
       if(hi<0.85) return 'the smoke is too faint: top opacity '+hi.toFixed(2)+' (needs 0.85)';
       if(wide<H*0.45) return 'the smoke stays over the body: widest '+wide.toFixed(1)+' of body height '+H.toFixed(1)+' (needs 0.45)';
       return null;
     } finally {
       PR.fillRect=of; PR.arc=oa;
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     } }},
  {v:'37.11',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
