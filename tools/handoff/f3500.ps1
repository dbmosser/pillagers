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

if ($s.Contains("  {v:'35.00',what:")) { throw "check 35.00 is in the fixture already" }

SubRx @'
  {v:'34.99',what:
'@ @'
  {v:'35.00',what:'a bush stands on turf: the smooth ground pixel under every bush centre is green, not slab or tarmac (his photo note, bricks under a bush)',
   run:function(){
     var g=null, i, j, b, cv, cx, px, bad=[], n=0, inB;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||!g.map) return 'SKIP: no raid';
       cv=bakeGround(g.map,false); cx=cv.getContext('2d');
       for(i=0;i<(g.map.bushes||[]).length;i++){
         b=g.map.bushes[i]; inB=false;
         for(j=0;j<g.map.buildings.length;j++){ var bd=g.map.buildings[j]; if(b.x>bd.x&&b.x<bd.x+bd.w&&b.y>bd.y&&b.y<bd.y+bd.h){ inB=true; break; } }
         if(inB) continue;
         n++; px=cx.getImageData(Math.round(b.x),Math.round(b.y),1,1).data;
         if(!(px[1]>px[0]+6)) bad.push(Math.round(b.x)+','+Math.round(b.y)+' rgb '+px[0]+','+px[1]+','+px[2]);
       }
       cv=null; cx=null;
       if(!n) return 'SKIP: no bushes outside buildings';
       if(bad.length) return bad.length+' of '+n+' bushes stand on ground that is not turf, first '+bad[0];
       return null;
     } finally {
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     } }},
  {v:'34.99',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
