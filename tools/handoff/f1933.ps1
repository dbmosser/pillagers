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

if ($s.Contains("  {v:'19.33',what:")) { throw "check 19.33 is in the fixture already" }

SubRx @'
  {v:'19.32',what:
'@ @'
  {v:'19.33',what:'the map conditions line leaves a clear gap before the credits readout: the gap is at least the text height, not a fixed 14 pixels',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)) return 'SKIP: this fixture cannot deploy and draw';
     var bad=[], g, tr=document.getElementById('topright'), proto=CanvasRenderingContext2D.prototype, o=proto.fillText, hit=null, wn, cssY, stubL, fs0=FS;
     if(!tr) return 'SKIP: no credits readout here';
     function grab(){ hit=null; __frame(0.001); return hit; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:1,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       g.ents.length=0; g.bagOpen=false; g.mapOpen=true; wn=g.wx&&g.wx.name;
       if(!wn) return 'SKIP: no weather name';
       FS=function(spec){ var f=fs0(spec); return String(f).replace((/([\d.]+)px/),function(m0,n0){ return (parseFloat(n0)*2).toFixed(1)+'px'; }); };
       proto.fillText=function(t,x,y){ if(this.textAlign==='right'&&String(t).indexOf(wn)>=0&&this.canvas){ var m=this.getTransform(), r=this.canvas.getBoundingClientRect(), kk=r.width>0?r.width/this.canvas.width:1, fm=(/([\d.]+)px/).exec(String(this.font)); hit={x:(m.a*x+m.e)*kk+r.left,y:(m.d*y+m.f)*kk+r.top,fp:(fm?parseFloat(fm[1]):12)*m.d*kk}; } return o.apply(this,arguments); };
       if(!grab()) return 'SKIP: the conditions line was not drawn';
       cssY=hit.y; stubL=hit.x-20;
       tr.getBoundingClientRect=function(){ return {left:stubL,right:stubL+300,top:0,bottom:cssY+10,width:300,height:cssY+10,x:stubL,y:0}; };
       if(!grab()) return 'SKIP: the conditions line was not drawn the second time';
       if(stubL-hit.x<hit.fp*0.9) bad.push('the gap before the credits readout is '+Math.round(stubL-hit.x)+' px with '+Math.round(hit.fp)+' px text');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ FS=fs0; proto.fillText=o; try{ delete tr.getBoundingClientRect; }catch(_d){} try{ var g2=__state(); if(g2){ g2.mapOpen=false; if(!g2.over){ g2.player.downed=false; __endRaid('abandon'); } } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'19.32',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
