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

if ($s.Contains("  {v:'34.65',what:")) { throw "check 34.65 is in the fixture already" }

SubRx @'
  {v:'34.64',what:
'@ @'
  {v:'34.65',what:'raid backpack tiles are at least the guide 88 px, empty cells fill two rows, and every cell stays inside the card',
   run:function(){
     var g, bp, f, n=0, out=[], PR=CanvasRenderingContext2D.prototype, os=PR.strokeRect, tw=0;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:['gun_carbine','medkit','bandage','bandage','plate','frag','smoke'],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player) return 'SKIP: no raid';
       g.ents.length=0; g.player.iv=99; g.bagOpen=true;
       for(f=0;f<8;f++) __loop(performance.now()+f*16.7);
       bp=g.bagPanel; if(!bp) return 'the backpack panel was not drawn';
       var cells=g.bagCells||[];
       if(!cells.length) return 'the backpack drew no tiles';
       tw=cells[0].w;
       if(tw<87.9) return 'a backpack tile is '+Math.round(tw)+' px, under the guide 88';
       PR.strokeRect=function(x,y,w,h){
         if(Math.abs(w-(tw-1))<1&&Math.abs(h-(tw-1))<1){ n++; if(x<bp.x||y<bp.y||x+w>bp.x+bp.w||y+h>bp.y+bp.h) out.push(Math.round(x)+','+Math.round(y)); }
         return os.apply(this,arguments);
       };
       for(f=0;f<2;f++) __loop(performance.now()+f*16.7);
       PR.strokeRect=os;
       if(n<2*Math.max(1,g.bagCols)) return 'the backpack drew '+n+' cells, under two full rows of '+g.bagCols;
       if(out.length) return 'a backpack cell is drawn outside the card at '+out.join(' ');
       return null;
     } finally {
       PR.strokeRect=os;
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     } }},
  {v:'34.64',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
