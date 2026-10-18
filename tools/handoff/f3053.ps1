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

if ($s.Contains("  {v:'30.53',what:")) { throw "check 30.53 is in the fixture already" }

SubRx @'
  {v:'30.52',what:
'@ @'
  {v:'30.53',what:'the demo gun card has no item-value line and no backpack hint; career keeps both (his Q56, 10-18)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)) return 'SKIP: this fixture cannot deploy';
     var g=null, oF=ctx.fillText, tx=[], a0, car, dem;
     function cue(){ tx=[]; ctx.fillText=function(s){ tx.push(String(s)); return oF.apply(this,arguments); }; try{ __frame(0.016); }finally{ ctx.fillText=oF; }
       return {bp:tx.some(function(s){ return (/\S\s+BACKPACK$/i).test(s); }), val:tx.some(function(s){ return (/^\d+ items?\s+\$/i).test(s); })}; }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:['gun_shotgun','gun_rifle'],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: staging: no raid';
       g.bagOpen=false; g.mapOpen=false; g.paused=false; keys={}; mouse.down=false; a0=g.arcade;
       g.arcade=0; car=cue();
       g.arcade=1; dem=cue();
       if(!car.bp||!car.val) return 'career lost the backpack hint or the item-value line (hint '+car.bp+', value '+car.val+')';
       if(dem.bp) return 'the demo still shows the backpack hint';
       if(dem.val) return 'the demo still shows the item-value line';
       return null;
     } finally {
       try{ if(g) g.arcade=a0; }catch(_e){}
       try{ __endRaid('abandon'); }catch(_e2){}
       __topClear();
     } }},
  {v:'30.52',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
