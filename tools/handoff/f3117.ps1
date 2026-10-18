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

if ($s.Contains("  {v:'31.17',what:")) { throw "check 31.17 is in the fixture already" }

SubRx @'
  {v:'31.16',what:
'@ @'
  {v:'31.17',what:'hp, armour and stamina bars are all the same width (the critic, 10-19: three widths)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)||typeof bar!=='function') return 'SKIP: this fixture cannot deploy';
     var g=null, oB=bar, rec=[], i, ws=[];
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:['gun_shotgun','gun_rifle'],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: staging: no raid';
       g.bagOpen=false; g.mapOpen=false; g.paused=false; keys={}; mouse.down=false; g.player.armor=40;
       bar=function(x,y,w,h,f,c,bg){ rec.push({x:x,w:w,h:h}); return oB.apply(this,arguments); };
       try{ __frame(0.016); }finally{ bar=oB; }
       for(i=0;i<rec.length;i++) if(rec[i].x===16&&rec[i].h>=12&&rec[i].h<=26) ws.push(rec[i].w);
       if(ws.length<3) return 'fewer than three vitals bars drawn ('+ws.length+')';
       for(i=1;i<ws.length;i++) if(ws[i]!==ws[0]) return 'the vitals bars differ in width: '+ws.join(',');
       return null;
     } finally {
       bar=oB;
       try{ __endRaid('abandon'); }catch(_e2){}
       __topClear();
     } }},
  {v:'31.16',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
