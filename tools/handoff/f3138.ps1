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

if ($s.Contains("  {v:'31.38',what:")) { throw "check 31.38 is in the fixture already" }

SubRx @'
  {v:'31.37',what:
'@ @'
  {v:'31.38',what:'the armour and stamina bars are the same height (the critic, 10-19: three bars of the same height)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)||typeof bar!=='function') return 'SKIP: this fixture cannot deploy';
     var g=null, oB=bar, rec=[], i, hs=[];
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:['gun_shotgun','gun_rifle'],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: staging: no raid';
       g.bagOpen=false; g.mapOpen=false; g.paused=false; keys={}; mouse.down=false; g.player.armor=40;
       bar=function(x,y,w,h,f,c,bg){ rec.push({x:x,w:w,h:h}); return oB.apply(this,arguments); };
       try{ __frame(0.016); }finally{ bar=oB; }
       for(i=0;i<rec.length;i++) if(rec[i].x===16&&rec[i].h>=10&&rec[i].h<=18) hs.push(rec[i].h);
       if(hs.length<2) return 'fewer than two small vitals bars drawn ('+hs.length+')';
       for(i=1;i<hs.length;i++) if(hs[i]!==hs[0]) return 'the armour and stamina bars differ in height: '+hs.join(',');
       return null;
     } finally {
       bar=oB;
       try{ __endRaid('abandon'); }catch(_e2){}
       __topClear();
     } }},
  {v:'31.37',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
