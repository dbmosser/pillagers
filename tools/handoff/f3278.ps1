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

if ($s.Contains("  {v:'32.78',what:")) { throw "check 32.78 is in the fixture already" }

SubRx @'
  {v:'32.77',what:
'@ @'
  {v:'32.78',what:'the raid backpack is a compact panel (not a wide slab) whose text is never under the 16 px label size',
   run:function(){
     var g, bp, f, small=[], PR=CanvasRenderingContext2D.prototype, of=PR.fillText;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:['gun_carbine','medkit','bandage','bandage','plate','frag','smoke'],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player) return 'SKIP: no raid';
       g.ents.length=0; g.player.iv=99; g.bagOpen=true;
       for(f=0;f<8;f++) __loop(performance.now()+f*16.7);
       bp=g.bagPanel; if(!bp) return 'the backpack panel was not drawn';
       if(bp.w>innerWidth*0.5) return 'the backpack is a wide slab: '+Math.round(bp.w)+' px of '+innerWidth;
       if((g.bagCols||0)>8) return 'the backpack grid is '+g.bagCols+' tiles wide';
       PR.fillText=function(s){
         var px=parseFloat(String(this.font).match(/([\d.]+)px/)[1]);
         if(String(s).trim()&&arguments[1]>=bp.x&&arguments[1]<=bp.x+bp.w&&arguments[2]>=bp.y&&arguments[2]<=bp.y+bp.h&&px<15.5) small.push(String(s).slice(0,24)+'@'+px);
         return of.apply(this,arguments);
       };
       for(f=0;f<2;f++) __loop(performance.now()+f*16.7);
       PR.fillText=of;
       if(small.length) return 'backpack text under the 16 px floor: '+small.slice(0,4).join(' | ');
       return null;
     } finally {
       PR.fillText=of;
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     } }},
  {v:'32.77',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
