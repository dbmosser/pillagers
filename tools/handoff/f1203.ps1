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

# v12.03 CHECK, inserted before the v12.02 entry. A raid is deployed with one
# note logged, a frame drawn with the canvas text call recorded, and the
# notes line must sit below the corner readout's bottom edge.
SubRx @'
  {v:'12.02',what:'the heal verb says Only bandages left above their reach, says Already at full with a Medkit at full health, and keeps a second Bandage that cannot raise you past what is already inbound, while a Medkit over running Bandages is still taken (2026-09-06 audits)',
'@ @'
  {v:'12.03',what:'the notes-logged line in the raid HUD is drawn below the corner credits and XP readout, not through it (2026-09-06 first-ten-minutes audit)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__frame&&window.__forceSize)) return 'SKIP: this fixture cannot deploy and draw';
     if(typeof topRightBottom!=='function') return 'SKIP: no corner readout helper in this build';
     var bad=[], rec=[], proto=CanvasRenderingContext2D.prototype, o=proto.fillText;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile(); __forceSize(1920,1080);
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state();
       g.tel.notes=[{t:1,txt:'probe note 4242'}];
       __frame(0.016);
       var bottom=topRightBottom();
       if(!(bottom>26)) return 'SKIP: the corner readout is not on screen here (bottom '+Math.round(bottom)+')';
       proto.fillText=function(t,x,y){ rec.push({t:String(t),y:y}); return o.apply(this,arguments); };
       __frame(0.016);
       proto.fillText=o;
       var ln=null; for(var i=0;i<rec.length;i++) if(/notes? logged/.test(rec[i].t)){ ln=rec[i]; break; }
       if(!ln) bad.push('control: the notes line was not drawn');
       else if(ln.y<=bottom) bad.push('the notes line is drawn at y '+Math.round(ln.y)+', inside the corner readout that ends at '+Math.round(bottom));
       else if(ln.y>H) bad.push('the notes line is drawn off the canvas at y '+Math.round(ln.y));
       var C=(typeof HUDBOX!=='undefined')&&HUDBOX.cond;
       if(ln&&C&&ln.y>C.y&&ln.y<C.y+C.h) bad.push('the notes line is drawn at y '+Math.round(ln.y)+', inside the conditions panel at '+Math.round(C.y)+' to '+Math.round(C.y+C.h));
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{ proto.fillText=o; try{ var g2=__state(); if(g2&&!g2.over){ g2.tel.notes=[]; g2.player.downed=false; __endRaid('extract'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'12.02',what:'the heal verb says Only bandages left above their reach, says Already at full with a Medkit at full health, and keeps a second Bandage that cannot raise you past what is already inbound, while a Medkit over running Bandages is still taken (2026-09-06 audits)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
