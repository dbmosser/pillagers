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
  {v:'10.90',what:'the bottom-right corner reserves itself
'@ @'
  {v:'10.91',what:'every panel resize grip has somewhere to drag to: a panel pinned to the right edge grips on its left, and the click, the cursor and the drawing all agree where it is',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__hud&&window.__hudBox)) return 'SKIP: this fixture cannot draw and measure the HUD';
     if(!__vpAlive()) return 'SKIP: the pane has no layout';
     // The fallback is the old build on purpose, not a skip.
     if(typeof hudGrip!=='function')
       return 'the grip is always the panel bottom-right corner, so a panel against the right of the screen has nowhere to drag to, which is his note';
     var bad=[];
     __runPrep(); __resetCfg(); __pinDefaults(0); __forceSize(1920,1080);
     __deploy({kit:[],safe:null,mapIx:0,seed:4242});
     var g=__state(); g.ents.length=0;
     for(var f=0;f<4;f++) __loop(performance.now()+f*16.7);
     __frame(0); __hud();
     var B=__hudBox(); if(!B) return 'SKIP: no HUD panels to measure';
     var Wv=window.innerWidth||1920, gs=hudGripS(), pinned=0, roomy=0, k;
     for(k in B){
       var b=B[k]; if(!b||!b.w) continue;
       if(HUDZ[k]===undefined) continue;      // not a panel that resizes
       var G2=hudGrip(b);
       var rightRoom=Wv-(b.x+b.w);
       // 1. THE GRIP IS ON THE SIDE THAT HAS ROOM.
       if(rightRoom<gs+10){
         pinned++;
         if(!G2.left) bad.push(k+' is '+Math.round(rightRoom)+' pixels from the right of the screen and still grips on its right, so there is nowhere to drag');
       } else {
         roomy++;
         if(G2.left) bad.push(k+' has '+Math.round(rightRoom)+' pixels of room on its right and grips on its left anyway');
       }
       // 2. AND THE GRIP HAS SOMEWHERE TO GO. This is the whole complaint: the
       //    panel is sized by how far the pointer gets from the anchor, so a
       //    grip with no travel is a panel that cannot grow.
       var travel=G2.left?G2.x:(Wv-G2.x);
       if(travel<120) bad.push(k+' can only be dragged '+Math.round(travel)+' pixels before the pointer leaves the screen');
       // 3. THE ANCHOR IS THE OTHER CORNER, or the panel would shrink as he
       //    pulls it outward.
       if(G2.left&&Math.abs(G2.ax-(b.x+b.w))>1) bad.push(k+' grips left but is sized from '+Math.round(G2.ax)+' rather than its right edge');
       if(!G2.left&&Math.abs(G2.ax-b.x)>1) bad.push(k+' grips right but is sized from '+Math.round(G2.ax)+' rather than its left edge');
       // 4. AND THE HIT TEST AGREES WITH THE CORNER. Three places read this; if
       //    they disagree the grip looks like it is somewhere it is not.
       var inx=G2.left?(G2.x+2):(G2.x-2);
       if(!hudOnGrip(b,inx,G2.y-2)) bad.push(k+' draws its grip where the click does not accept it');
       var farx=G2.left?(b.x+b.w-2):(b.x+2);
       if(hudOnGrip(b,farx,G2.y-2)) bad.push(k+' accepts a click on the opposite corner as the grip');
     }
     // 5. CONTROLS. Both kinds of panel have to be present or this proves half a
     //    rule, and at 1920x1080 the gear and conditions panels are pinned while
     //    the body, legend and pillager list are not.
     if(!pinned) bad.push('control: no panel is pinned to the right edge here, so the case he reported is not being tested');
     if(!roomy) bad.push('control: every panel is pinned, so the unchanged case is not being tested');
     return bad.length?bad.join('; '):null; }},
  {v:'10.90',what:'the bottom-right corner reserves itself
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
