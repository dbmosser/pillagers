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

if ($s.Contains("  {v:'34.80',what:")) { throw "check 34.80 is in the fixture already" }

SubRx @'
  {v:'34.79',what:
'@ @'
  {v:'34.80',what:'a flash lights the ground in its own colour in the light map (not plain white), and not under CLASSIC lighting',
   run:function(){
     var PR=CanvasRenderingContext2D.prototype, od=PR.drawImage, g=null, hit=0, spr=null, gl0=CFG.gfxLight, cond0=P.cond, bad=[], c='#ff3a9a';
     function run(){
       hit=0;
       PR.drawImage=function(im){ if(spr&&im===spr&&this===LMAP.x) hit++; return od.apply(this,arguments); };
       try{ g.flashes.push({x:g.player.x+40,y:g.player.y,r:160,c:c,t:0,life:9}); for(var f=0;f<3;f++) __loop(performance.now()+f*16.7); }
       finally{ PR.drawImage=od; }
       return hit;
     }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player) return 'SKIP: no raid';
       g.ents.length=0; g.player.iv=99; P.cond='night';
       if(isDay()) return 'SKIP: the raid would not go dark';
       if(typeof gfxLightSpr!=='function'||typeof LMAP==='undefined') return 'SKIP: no light map';
       spr=gfxLightSpr(c,'map');
       CFG.gfxLight=2; g.flashes.length=0;
       if(run()<1) bad.push('a '+c+' flash was not stamped in its own colour in the light map');
       CFG.gfxLight=0; g.flashes.length=0;
       if(run()>0) bad.push('the coloured stamp was drawn under CLASSIC lighting');
       return bad.length?bad.join('; '):null;
     } finally {
       PR.drawImage=od; CFG.gfxLight=gl0; P.cond=cond0;
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     } }},
  {v:'34.79',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
