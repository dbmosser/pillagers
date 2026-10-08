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

if ($s.Contains("  {v:'19.53',what:")) { throw "check 19.53 is in the fixture already" }

SubRx @'
  {v:'19.52',what:
'@ @'
  {v:'19.53',what:'the SURVEYED note never runs off the screen: with the map text at a large size, both SURVEYED words sit wholly on the screen and below the map',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)) return 'SKIP: this fixture cannot deploy and draw';
     if(typeof drawMapOverlay!=='function') return 'SKIP: no map overlay here';
     var bad=[], g, fs0=FS, rec=[], proto=CanvasRenderingContext2D.prototype, o=proto.fillText, own=Object.prototype.hasOwnProperty.call(ctx,'fillText'), oF=ctx.fillText, s1=null, s2=null, cvH;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:1,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       g.ents.length=0; g.bagOpen=false; g.mapOpen=true;
       FS=function(spec){ var f=fs0(spec); return String(f).replace((/([\d.]+)px/),function(m0,n0){ return (parseFloat(n0)*2.6).toFixed(1)+'px'; }); };
       proto.fillText=function(t,x,y){ var m=this.getTransform(), fm=(/([\d.]+)px/).exec(String(this.font)); rec.push({t:String(t),y:m.d*y+m.f,fp:(fm?parseFloat(fm[1]):0)*m.d}); return o.apply(this,arguments); };
       __frame(0.001);
       rec.forEach(function(r){ if(r.t.indexOf('SURVEYED')===0) s1=r; if(r.t.indexOf('what you walk')===0) s2=r; });
       if(!s1||!s2) return 'SKIP: the SURVEYED words were not drawn';
       cvH=ctx.canvas.height;
       if(s2.y+s2.fp*0.22>cvH+0.5) bad.push('the second SURVEYED words run off the bottom of the screen ('+Math.round(s2.y+s2.fp*0.22)+' of '+cvH+')');
       if(s1.y+s1.fp*0.22>cvH+0.5) bad.push('SURVEYED runs off the bottom of the screen');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ FS=fs0; proto.fillText=o; if(own) ctx.fillText=oF; try{ var g2=__state(); if(g2){ g2.mapOpen=false; if(!g2.over){ g2.player.downed=false; __endRaid('abandon'); } } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'19.52',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
