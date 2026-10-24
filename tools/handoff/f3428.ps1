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

if ($s.Contains("  {v:'34.28',what:")) { throw "check 34.28 is in the fixture already" }

SubRx @'
  {v:'34.27',what:
'@ @'
  {v:'34.28',what:'the raid HUD is couch size: no text under 16 px on the screen in one raid frame, and a long contract has a short form that fits the run info panel on one line',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)) return 'SKIP: this fixture cannot deploy and draw';
     var proto=CanvasRenderingContext2D.prototype, o=proto.fillText, bad=[], small={}, n=0, g, i, f;
     function px(c){ var m=/([\d.]+)px/.exec(c.font); return m?Math.round(parseFloat(m[1])*c.getTransform().a*10)/10:0; }
     try{
       if(typeof runInfoShort!=='function') bad.push('no runInfoShort: a long contract wraps in the run info panel');
       else{
         ctx.save(); ctx.font=FS(TYPE.label);
         var w=trBW()-22, long1='extract with a haul worth $12,000 or more\u00a0\u00a00/1', s1=runInfoShort(long1);
         if(!(/^haul over \$12,000/.test(s1))) bad.push('the short haul line is '+s1);
         else if(txRawW(ctx,s1)>w) bad.push('the short haul line is '+Math.round(txRawW(ctx,s1))+' wide, the panel holds '+w);
         ctx.restore();
         if(String(drawHUD).indexOf('runInfoShort(t)')<0) bad.push('drawHUD does not use runInfoShort');
       }
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       g.bagOpen=false; g.mapOpen=false;
       __frame(0.001);
       proto.fillText=function(t,x,y){ if(this===ctx&&typeof t==='string'&&t.length&&/\S/.test(t)){ n++; var p=px(this); if(p<15.9){ (small[p]=small[p]||[]).length<4&&small[p].push(String(t).slice(0,10)+'@'+Math.round(x)+','+Math.round(y)+' '+this.font+' a'+this.getTransform().a.toFixed(2)); } } return o.apply(this,arguments); };
       __frame(0.001);
       if(!n) bad.push('no text drawn');
       for(f in small) bad.push(f+' px: '+small[f].join('|'));
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ proto.fillText=o; try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'34.27',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
