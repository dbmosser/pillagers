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

if ($s.Contains("  {v:'19.56',what:")) { throw "check 19.56 is in the fixture already" }

SubRx @'
  {v:'19.55',what:
'@ @'
  {v:'19.56',what:'the call prompt is said once: standing in the ring, HOLD E TO CALL FOR EXTRACTION shows above the belt and no second call prompt is printed over the character',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)) return 'SKIP: this fixture cannot deploy and draw';
     var bad=[], g, p, z, oFT=ctx.fillText, world=0, belt=0, k;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       p=g.player; g.ents.length=0; g.bagOpen=false; g.mapOpen=false;
       z=g.zones&&g.zones[0]; if(!z) return 'SKIP: no ring';
       g.active=z; p.x=z.x; p.y=z.y; g.beaconT=null;
       for(k=0;k<10;k++) __frame(0.05);
       ctx.fillText=function(t,x,y){ var s=String(t); if(/^\[[^\]]+\] CALL FOR EXTRACTION$/.test(s)) world++; if(/^HOLD .* TO CALL FOR EXTRACTION$/.test(s)) belt++; return oFT.apply(this,arguments); };
       __frame(0.05);
       if(!belt) return 'SKIP: the line above the belt was not drawn';
       if(world) bad.push('the call prompt is printed over the character as well as above the belt');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'19.55',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
