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

if ($s.Contains("  {v:'34.66',what:")) { throw "check 34.66 is in the fixture already" }

SubRx @'
  {v:'34.65',what:
'@ @'
  {v:'34.66',what:'raid backpack title is at the screen title size and empty cells are drawn with a visible border',
   run:function(){
     var g, bp, f, PR=CanvasRenderingContext2D.prototype, of=PR.fillText, os=PR.strokeRect, ts=0, em=0, tf;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:['gun_carbine','medkit','bandage','bandage','plate','frag','smoke'],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player) return 'SKIP: no raid';
       g.ents.length=0; g.player.iv=99; g.bagOpen=true;
       for(f=0;f<8;f++) __loop(performance.now()+f*16.7);
       bp=g.bagPanel; if(!bp) return 'the backpack panel was not drawn';
       tf=parseFloat(String(FS(TYPE.title)).match(/([\d.]+)px/)[1]);
       PR.fillText=function(s){ if(String(s).toLowerCase()==='backpack'&&this.font){ var m=String(this.font).match(/([\d.]+)px/); if(m&&arguments[1]>=bp.x&&arguments[1]<=bp.x+bp.w&&arguments[2]>=bp.y&&arguments[2]<=bp.y+bp.h) ts=parseFloat(m[1]); } return of.apply(this,arguments); };
       PR.strokeRect=function(){ if(String(this.strokeStyle).toLowerCase()==='#3d444a') em++; return os.apply(this,arguments); };
       for(f=0;f<2;f++) __loop(performance.now()+f*16.7);
       PR.fillText=of; PR.strokeRect=os;
       if(ts<tf-.5) return 'the backpack title is '+ts+' px, under the title size '+tf;
       if(em<4) return 'the backpack drew '+em+' visible empty cells';
       return null;
     } finally {
       PR.fillText=of; PR.strokeRect=os;
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     } }},
  {v:'34.65',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
