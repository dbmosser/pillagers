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
  {v:'10.36',what:'TATTOO is a fourteenth rack: five inks on the sprite face and neck and the figure, with a swatch',
'@ @'
  {v:'10.37',what:'the message line scales with the monitor like the panels do',
   run:function(){
     var bad=[];
     if(!__vpAlive()) return 'SKIP: the pane has no layout, nothing is drawn';
     if(!(window.__textTrace&&window.__deploy&&window.__frame)) return 'SKIP: this fixture cannot read what the HUD draws';
     __resetCfg(); __pinDefaults(0); __cleanProfile();
     __deploy({kit:[],safe:null,mapIx:0,seed:4242});
     var g=__state(); if(!g) return 'SKIP: no raid';
     var p=g.player; p.hp=100000; p.maxhp=100000; g.ents.length=0;
     var MSG=['Measured ','message'].join('');
     function msgPx(W,H){
       __pinDPR(1); __forceSize(W,H);
       g.msg=MSG; g.msgT=3;
       for(var f=0;f<3;f++) __frame(0.016);
       g.msg=MSG; g.msgT=3;
       var tr=__textTrace(function(){ __frame(0.016); });
       for(var i=0;i<tr.length;i++) if(tr[i].t===MSG) return {px:tr[i].px,y:tr[i].y,x:tr[i].x};
       return null;
     }
     var a=msgPx(1920,1080), b=msgPx(3840,2160), c=msgPx(2560,1440);
     __pinDPR(1); __forceSize(1920,1080); g.msgT=0;
     if(!a||!b||!c) return 'SKIP: the message line was not drawn ('+(a?'':'1080p ')+(c?'':'1440p ')+(b?'':'4K')+')';
     // THE FINDING. On v10.36 the message was 19px at 1080p and 19px at 4K.
     if(!(b.px>=a.px*1.8)) bad.push('at 4K the message line is '+Math.round(b.px)+'px against '+Math.round(a.px)+'px at 1080p; it does not grow with the monitor');
     if(!(c.px>=a.px*1.2)) bad.push('at 1440p the message line is '+Math.round(c.px)+'px against '+Math.round(a.px)+'px at 1080p');
     // CONTROL: it stays centred, and at 1080p it is where it always was.
     if(Math.abs(a.x-960)>4) bad.push('control: at 1080p the message is centred at x='+Math.round(a.x)+', not 960');
     if(Math.abs(b.x-1920)>6) bad.push('control: at 4K the message is centred at x='+Math.round(b.x)+', not 1920');
     // LH carries a fixed 1.5625 factor on top of the monitor scale, so LH(109) lands at 170 at 1080p; measured on v10.18.
     if(a.y<150||a.y>190) bad.push('control: at 1080p the message sits at y='+Math.round(a.y)+', not near 170');
     return bad.length?bad.join('; '):null; }},
  {v:'10.36',what:'TATTOO is a fourteenth rack: five inks on the sprite face and neck and the figure, with a swatch',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
