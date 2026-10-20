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

if ($s.Contains("  {v:'32.81',what:")) { throw "check 32.81 is in the fixture already" }

SubRx @'
  {v:'32.80',what:
'@ @'
  {v:'32.81',what:'backpack tiles share one idle border colour (rarity is a bar) and the panel keeps no more than 50 px of dead strip',
   run:function(){
     var g, bp, f, maxY=0, bad=[], PR=CanvasRenderingContext2D.prototype, of=PR.fillText, os=PR.strokeRect;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:['gun_carbine','medkit','bandage','bandage','plate','frag','smoke'],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player) return 'SKIP: no raid';
       g.ents.length=0; g.player.iv=99; g.bagOpen=true;
       for(f=0;f<8;f++) __loop(performance.now()+f*16.7);
       bp=g.bagPanel; if(!bp) return 'the backpack panel was not drawn';
       var cells=g.bagCells||[], sel=g.bagSel||0;
       PR.fillText=function(s){
         if(String(s).trim()&&arguments[1]>=bp.x&&arguments[1]<=bp.x+bp.w&&arguments[2]>=bp.y&&arguments[2]<=bp.y+bp.h&&arguments[2]>maxY) maxY=arguments[2];
         return of.apply(this,arguments);
       };
       PR.strokeRect=function(x,y,w,h){
         var i, c; for(i=0;i<cells.length;i++){ c=cells[i]; if(c.stackIx!==sel&&Math.abs(c.x+.5-x)<1&&Math.abs(c.y+.5-y)<1&&Math.abs(c.w-1-w)<1&&String(this.strokeStyle).toLowerCase()!=='#4a5257') bad.push(String(this.strokeStyle)); }
         return os.apply(this,arguments);
       };
       for(f=0;f<2;f++) __loop(performance.now()+f*16.7);
       PR.fillText=of; PR.strokeRect=os;
       if(cells.length<2) return 'the backpack drew '+cells.length+' tiles';
       if(bad.length) return 'an idle backpack tile has a coloured border: '+bad.join(',');
       if(bp.y+bp.h-maxY>50) return 'the backpack panel has '+Math.round(bp.y+bp.h-maxY)+' px of dead panel under its last line';
       return null;
     } finally {
       PR.fillText=of; PR.strokeRect=os;
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     } }},
  {v:'32.80',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
