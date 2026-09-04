$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

SubRx @'
  {v:'10.89',what:'X does not swap weapons any more
'@ @'
  {v:'10.90',what:'the bottom-right corner reserves itself and every world label that would land on it is lifted clear, which is his screenshot of EXTRACTION - OPEN drawn through SUPPORT MG',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__hud)) return 'SKIP: this fixture cannot draw a HUD';
     if(!__vpAlive()) return 'SKIP: the pane has no layout';
     // THE FALLBACK IS THE OLD BUILD ON PURPOSE, not a skip: a build with no
     // dodge at all is the fault he photographed.
     if(typeof hudDodge!=='function')
       return 'nothing keeps world labels out of the corner readout, which is his screenshot: a world label is drawn straight through the gun name';
     var bad=[];
     __runPrep(); __resetCfg(); __pinDefaults(0); __forceSize(1920,1080);
     __deploy({kit:[],safe:null,mapIx:0,seed:4242});
     var g=__state(), p=g.player; g.ents.length=0; p.iv=99;
     var z=g.zones&&g.zones[0];
     if(z){ g.active=z; z.open=true; }
     function frame(){ for(var f=0;f<4;f++) __loop(performance.now()+f*16.7); __frame(0); __hud(); }
     frame();
     // 1. THE CORNER MEASURES ITSELF, and it is the corner it claims to be.
     var B=g.cornerBox;
     if(!B) return 'the corner readout never recorded the space it takes, so no label can know to avoid it';
     var Wv=window.innerWidth||1920, Hv=window.innerHeight||1080;
     if(B.w<120||B.h<40) bad.push('the reserved corner is only '+Math.round(B.w)+' by '+Math.round(B.h)+', which is smaller than the text in it');
     if(Math.abs((B.x+B.w)-Wv)>40) bad.push('the reserved corner ends '+Math.round(Wv-(B.x+B.w))+' pixels from the right edge, so it is not where the readout is');
     if(Math.abs((B.y+B.h)-Hv)>90) bad.push('the reserved corner ends '+Math.round(Hv-(B.y+B.h))+' pixels from the bottom, so it is not where the readout is');
     // 2. A LABEL THAT WOULD LAND ON IT IS LIFTED, and by enough to clear it.
     var midX=B.x+B.w/2, midY=B.y+B.h/2;
     var lifted=hudDodge(midX,midY,60,18,0);
     if(!(lifted<midY)) bad.push('a label dropped in the middle of the corner is not moved at all');
     else if(lifted+4>B.y) bad.push('a label in the corner is lifted only to '+Math.round(lifted)+', still inside a box that starts at '+Math.round(B.y));
     // 3. AND A LABEL THAT WOULD NOT IS LEFT ALONE. A dodge that moves
     //    everything would drag every marker on the screen upward.
     var freeY=120, freeX=Math.max(40,B.x-500);
     if(hudDodge(freeX,freeY,60,18,0)!==freeY) bad.push('a label nowhere near the corner was moved anyway');
     if(hudDodge(midX,120,60,18,0)!==120) bad.push('a label above the corner but in its column was moved anyway');
     // 4. IT NEVER PUSHES A LABEL OFF THE TOP. A marker shoved off the screen is
     //    a worse answer than one that overlaps.
     var tall=hudDodge(midX,midY,60,B.y+40,0);
     if(tall-(B.y+40)<0) bad.push('a tall label was lifted off the top of the screen, to '+Math.round(tall));
     // 5. AND THE REAL LABELS ASK IT. Without this the helper could be perfect
     //    and wired to nothing, which is exactly how his screenshot happened.
     var realDodge=hudDodge, calls=0;
     try{
       hudDodge=function(a,b,c,d,e){ calls++; return realDodge(a,b,c,d,e); };
       frame();
     } finally { hudDodge=realDodge; }
     if(!calls) bad.push('no world label asked about the corner while an extraction ring was open, so the helper is wired to nothing');
     return bad.length?bad.join('; '):null; }},
  {v:'10.89',what:'X does not swap weapons any more
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
