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
  {v:'10.94',what:'nothing a face can wear is painted over the eye
'@ @'
  {v:'10.95',what:'every word drawn on the canvas is set in one family, the loot pop and the world labels included',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__frame&&window.__hud&&window.__hubEnter&&window.__hubStep))
       return 'SKIP: this fixture cannot draw the game';
     if(!__vpAlive()) return 'SKIP: the pane has no layout';
     var bad=[];
     __runPrep(); __resetCfg(); __pinDefaults(0); __forceSize(1920,1080);
     // THE FAMILY IS THE QUESTION, NOT THE SIZE. The canvas hands the font back
     // serialised, and the size legitimately varies: the HUD scale multiplies
     // every role, so one role appears at several sizes in a single frame. What
     // must never vary is which typeface the words are in.
     function famOf(f){
       var m=/px\s+(.*)$/.exec(String(f));
       if(!m) return String(f);
       var first=m[1].split(',')[0];
       return first.replace(/["']/g,'').trim().toLowerCase();
     }
     var proto=CanvasRenderingContext2D.prototype, orig=proto.fillText;
     var seen={}, texts={}, draws=0;
     function trace(fn){
       proto.fillText=function(t,x,y){
         var fam=famOf(this.font); draws++;
         (seen[fam]=seen[fam]||{n:0,eg:[]});
         seen[fam].n++;
         if(seen[fam].eg.length<3) seen[fam].eg.push(String(t).slice(0,22));
         texts[String(t)]=1;
         return orig.apply(this,arguments);
       };
       try{ fn(); } finally { proto.fillText=orig; }
     }
     var MARK='ZQX LOOT PROBE';
     trace(function(){
       // Deploy INSIDE the trace, because the ground is baked once when the map
       // is built and a check that arrives afterwards never sees what is painted
       // into it.
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state();
       // HIS ACTUAL COMPLAINT, on screen: a loot pop with an item name on it,
       // and one small label beside it, so both sizes of world label are drawn.
       g.labels.push({x:g.player.x,y:g.player.y-20,txt:MARK,c:'#ffc04a',t:0,life:1.8,big:true,ik:null});
       g.labels.push({x:g.player.x+30,y:g.player.y-20,txt:'PICKED UP',c:'#4de3d0',t:0,life:1.8,big:false,ik:null});
       __frame(0); __hud();
       for(var f=0;f<3;f++) __loop(performance.now()+f*16.7);
       g.mapOpen=true; __frame(0); __hud(); g.mapOpen=false;
       __hubEnter(); for(var h=0;h<4;h++) __hubStep(0.016);
     });
     // CONTROL ONE, and without it every line below is decoration: the loot pop
     // has to have been drawn at all. If the label never reached the screen this
     // check would report one clean family and mean nothing.
     if(!texts[MARK]) bad.push('control: the loot pop never reached the screen, so nothing here is about his note');
     if(draws<60) bad.push('control: only '+draws+' words were drawn in the whole sweep, which is not the game');
     // CONTROL TWO: the tracer has to be able to fail. Draw one word in a
     // deliberately foreign face and require it to be caught.
     var caught=null;
     trace(function(){
       var cv2=document.createElement('canvas'), c2=cv2.getContext('2d');
       c2.font='700 20px "Comic Sans MS", cursive'; c2.fillText('control',2,18);
     });
     caught=!!seen['comic sans ms'];
     if(!caught) bad.push('control: a word drawn in a foreign face was not noticed, so this check cannot see a second family');
     // THE FINDING. On v10.94 the world labels came back in Titan One at 15.6
     // and 17.2 pixels, and the district numbers baked into the ground came back
     // in it between 114 and 244.
     var fam;
     for(fam in seen){
       if(fam==='comic sans ms') continue;              // the control, on its own canvas
       if(fam==='rubik') continue;
       bad.push(fam+' is a second typeface on the canvas, '+seen[fam].n+' words including '+seen[fam].eg.join(', '));
     }
     if(!seen['rubik']) bad.push('control: nothing at all was drawn in the game font, so the sweep is not looking at the game');
     return bad.length?bad.join('; '):null; }},
  {v:'10.94',what:'nothing a face can wear is painted over the eye
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
